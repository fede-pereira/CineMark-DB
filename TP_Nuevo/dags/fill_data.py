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

    #Sampleo de clientes
    sample_clientes = schema.get_clientes(1000)
    # Aca obtenemos las funciones y salas pre-existentes para fijarnos que no se excedan las cantidades.
    sample_funciones = schema.get_funciones()
    sample_salas = schema.get_salas()
    
    # Generar datos de COMPRAS
    compras = generator.generate_compras(1000 , sample_funciones,sample_clientes, sample_salas)
    schema.insert(compras, "compras")


def sunday_check(base_time: str) -> str:
    # Log in airflow base time
    if pendulum.parse(base_time).day_of_week == 0:
        return "forecast"
    else:
        return "end"

def forecast_sales():
    schema = Schema()
    ventas = schema.get_last_month_data()
    df_ventas = pd.DataFrame(ventas) 
    df_ventas.columns = ['ds', 'y']
    m = Prophet()
    m.fit(df_ventas)
    future = m.make_future_dataframe(periods=7)
    forecast = m.predict(future)
    weekly_profit = sum([float(daily) for daily in forecast[['yhat']].tail(7)['yhat']])
    logging.info(f"Profit for the next week: {weekly_profit}")


# def generate_data_weekly(base_time: str, n: int):
#     """Generates synth data and saves to DB.

#     Parameters
#     ----------
#     base_time: strpoetry export --without-hashes --format=requirements.txt > requirements.txt

#         Base datetime to start events from.
#     n : int
#         Number of events to generate.
#     """
#     generator = DataGenerator()
#     schema = Schema()
    
#     # Generar datos de PELICULAS
#     peliculas = generator.generate_peliculas(5)
#     schema.insert(peliculas, "peliculas")

#     # Generar datos de ACTORES
#     actores = generator.generate_actores(2)
#     schema.insert(actores, "actores")

#     # Sample de peliculas y salas
#     peliculas_sample = schema.get_peliculas()
#     salas_sample = schema.get_salas()

#     # Generar datos de FUNCIONES
#     funciones = generator.generate_funciones(1000, peliculas_sample, salas_sample)
#     schema.insert(funciones, "funciones")

#     # Generar datos de ACTUA
#     actores_sample = schema.get_actores(30)
#     actua = generator.generate_actua(peliculas_sample, actores_sample, 100)
#     schema.insert(actua, "actua")


# with DAG(
#     "fill_data_weekly",
#     start_date=pendulum.datetime(2024, 6, 1, tz="UTC"),
#     schedule_interval="@weekly",
#     catchup=True,
# ) as dag:
#     op = PythonOperator(
#         task_id="task",
#         python_callable=generate_data_weekly,
#         op_kwargs=dict(n=EVENTS_PER_DAY, base_time="{{ ds }}"),
#     )


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
        op_kwargs=dict(base_time="{{ ds }}")
    )

    forecast = PythonOperator(
        task_id="forecast",
        python_callable=forecast_sales,
        op_kwargs=dict(n=EVENTS_PER_DAY, base_time="{{ ds }}"),
    )

    end = DummyOperator(task_id="end")

gen_data >> branch_sunday >> [forecast, end]