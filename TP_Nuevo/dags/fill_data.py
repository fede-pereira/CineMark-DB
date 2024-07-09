from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.dummy import DummyOperator
import pendulum
import datetime
import logging
import pandas as pd
from td7.data_generator import DataGenerator
from td7.schema import Schema
from prophet import Prophet

EVENTS_PER_DAY = 10_000


def generate_data_daily(base_time: str, n: int):
    """Generates synth data and saves to DB.

    Parameters
    ----------
    base_time: strpoetry export --without-hashes --format=requirements.txt > requirements.txt

        Base datetime to start events from.
    n : int
        Number of events to generate.
    """
    generator = DataGenerator()
    schema = Schema()

    # Inicialmente arrancamos con una DB no vacia, luego tenemos que obtener los CUITs pre-existentes.
    sample_clientes_initial = schema.get_clientes()
    # Generar datos de CLIENTES
    clientes = generator.generate_clientes(1000, sample_clientes_initial)
    schema.insert(clientes, "clientes")

    # Sampleo de clientes
    sample_clientes = schema.get_clientes(1000)
    # Aca obtenemos las funciones y salas pre-existentes para fijarnos que no se excedan las cantidades.
    sample_funciones = schema.get_funciones()
    sample_salas = schema.get_salas()

    # Generar datos de COMPRAS
    compras = generator.generate_compras(
        1000, sample_funciones, sample_clientes, sample_salas
    )
    schema.insert(compras, "compras")


def sunday_check(base_time: str) -> str:
    # Log in airflow base time
    if pendulum.parse(base_time).day_of_week == 6:
        return "forecast"
    else:
        return "end_sunday"


def forecast_sales():
    schema = Schema()
    ventas = schema.get_last_month_data()
    df_ventas = pd.DataFrame(ventas)
    df_ventas.columns = ["ds", "y"]
    m = Prophet()
    m.fit(df_ventas)
    future = m.make_future_dataframe(periods=7)
    forecast = m.predict(future)
    weekly_profit = sum([float(daily) for daily in forecast[["yhat"]].tail(7)["yhat"]])
    logging.info(f"Profit for the next week: {weekly_profit}")
    if weekly_profit > 5500000:
        return "end_forecast"
    else:
        return "warn"


with DAG(
    "fill_data_daily",
    start_date=pendulum.datetime(2024, 7, 2, tz="UTC"),
    schedule_interval="@daily",
    catchup=True,
) as dag:
    gen_data = PythonOperator(
        task_id="gen_data",
        python_callable=generate_data_daily,
        op_kwargs=dict(n=EVENTS_PER_DAY, base_time="{{ ds }}"),
    )

    branch_sunday = BranchPythonOperator(
        task_id="branch_sunday",
        python_callable=sunday_check,
        op_kwargs=dict(base_time="{{ ds }}"),
    )

    forecast = BranchPythonOperator(
        task_id="forecast",
        python_callable=forecast_sales,
        op_kwargs=dict(n=EVENTS_PER_DAY, base_time="{{ ds }}"),
    )

    warn = PythonOperator(
        task_id="warn",
        python_callable=lambda: logging.info("Warning: Profit is below threshold"),
    )

    end_sunday = DummyOperator(task_id="end_sunday")

    end_forecast = DummyOperator(task_id="end_forecast")

gen_data >> branch_sunday >> [forecast, end_sunday]
forecast >> [end_forecast, warn]
