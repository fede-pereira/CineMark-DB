FROM python:3.11-bookworm

ENV AIRFLOW_HOME=/opt/airflow
ENV AIRFLOW_VERSION=2.9.1
ENV PYTHONPATH="${PYTHONPATH}:/opt/airflow/td7"
WORKDIR /opt/airflow

# Instalar Poetry y Prophet
RUN pip install poetry==1.4.2 \
    && pip install prophet==1.1.5

# Copiar archivos de configuración y código
COPY pyproject.toml poetry.lock /opt/airflow/
COPY td7/ /opt/airflow/td7
COPY README.md .env /opt/airflow/

# Configurar Poetry y instalar dependencias
RUN poetry config virtualenvs.create false \
    && poetry install --no-root

# Inicializar la base de datos de Airflow y crear un usuario administrador
RUN airflow db upgrade \
    && airflow users create --username airflow --firstname Peter --lastname Parker --role Admin --password airflow --email spiderman@superhero.org

# Añadir y configurar conexión en Airflow
RUN airflow connections add 'postgres' \
    --conn-type 'postgres' \
    --conn-login "douglas_adams" \
    --conn-password "hitchhiker" \
    --conn-host 'postgres' \
    --conn-port '5432' \
    --conn-schema 'postgres'

# Exponer el puerto para el servidor web
EXPOSE 8080

# Ejecutar el servidor web y el programador de Airflow en primer plano
CMD ["sh", "-c", "airflow webserver --port 8080 & airflow scheduler"]
