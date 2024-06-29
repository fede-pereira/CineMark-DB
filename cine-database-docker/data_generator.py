import psycopg2
from faker import Faker
import random

# Connect to your PostgreSQL database
conn = psycopg2.connect(
    dbname="postgres", user="cine", password="cine", host="localhost"
)
cur = conn.cursor()

# Initialize Faker
fake = Faker()


# Function to generate fake data for salas table
def generate_salas_data(num_rows):
    for _ in range(num_rows):
        id_sala = fake.random_int(min=1, max=1000)
        id_cine = fake.random_int(min=1, max=1000)
        asientos = fake.random_int(min=50, max=300)
        yield (id_sala, id_cine, asientos)


# Function to generate fake data for peliculas table
def generate_peliculas_data(num_rows):
    for _ in range(num_rows):
        nombre_pelicula = fake.catch_phrase()
        director = fake.name()
        duracion_en_segundos = fake.random_int(min=3600, max=8459)  # 1-3 hours
        estudio = fake.company()
        presupuesto = fake.random_number(digits=8)
        tiempo_de_realizacion = fake.random_int(min=1, max=24)
        ano_estreno = fake.random_int(min=1970, max=2022)
        genero_pelicula = fake.random_element(
            elements=("Action", "Comedy", "Drama", "Thriller")
        )
        yield (
            nombre_pelicula,
            director,
            duracion_en_segundos,
            estudio,
            presupuesto,
            tiempo_de_realizacion,
            ano_estreno,
            genero_pelicula,
        )


# Function to generate fake data for actores table
def generate_actores_data(num_rows):
    for _ in range(num_rows):
        nombre = fake.first_name()
        apellido = fake.last_name()
        edad = fake.random_int(min=18, max=80)
        genero = random.choice(["m", "f", "o"])
        yield (nombre, apellido, edad, genero)


# Function to generate fake data for clientes table
def generate_clientes_data(num_rows):
    for _ in range(num_rows):
        cuit = fake.random_number(digits=11, fix_len=True)  # Ensure 11-digit number
        nombre = fake.first_name()
        apellido = fake.last_name()
        edad = fake.random_int(min=18, max=80)
        nacionalidad = fake.country()
        genero = random.choice(["m", "f", "o"])
        yield (cuit, nombre, apellido, edad, nacionalidad, genero)


# Function to generate fake data for funciones table
def generate_funciones_data(num_rows, salas_ids, peliculas_data):
    for _ in range(num_rows):
        nombre_pelicula, director, *_ = fake.random_element(peliculas_data)
        id_sala, id_cine, *_ = random.choice(salas_ids)
        ts = fake.date_time_between(start_date="-2y", end_date="now")
        precio = random.choice([4000,6000,10000])
        yield (nombre_pelicula, director, id_sala, id_cine, ts, precio)


# Function to generate fake data for compras table
def generate_compras_data(num_rows, funciones_data, clientes_data):
    for _ in range(num_rows):
        nombre_pelicula, director, id_sala, id_cine, ts, precio = fake.random_element(
            funciones_data
        )
        # id_sala, id_cine, *_ = random.choice(salas_data)
        # ts = fake.date_time_between(start_date="-1y", end_date="now")
        cuit, *_ = random.choice(clientes_data)
        cantidad = fake.random_int(min=1, max=10)
        yield (nombre_pelicula, director, id_sala, id_cine, ts, cuit, cantidad)


# Function to generate fake data for actua table
def generate_actua_data(num_rows, actores_ids, peliculas_data):
    for _ in range(num_rows):
        nombre_pelicula, director, *_ = fake.random_element(peliculas_data)
        id_actor, *_ = random.choice(actores_ids)
        salario = round(fake.pyfloat(left_digits=5, right_digits=2, positive=True), 2)
        yield (nombre_pelicula, director, id_actor, salario)


# Generate fake data and insert into tables
num_rows = 1000  # Adjust as needed
salas_data = list(generate_salas_data(num_rows))
peliculas_data = list(generate_peliculas_data(num_rows))
actores_data = list(generate_actores_data(num_rows))
clientes_data = list(generate_clientes_data(num_rows))

# Insert data into salas table
cur.executemany(
    "INSERT INTO salas (id_sala, id_cine, asientos) VALUES (%s, %s, %s)", salas_data
)

# Insert data into peliculas table
cur.executemany(
    "INSERT INTO peliculas (nombre_pelicula, director, duracion_en_segundos, estudio, presupuesto, tiempo_de_realizacion, ano_estreno, genero_pelicula) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)",
    peliculas_data,
)

# Insert data into actores table
cur.executemany(
    "INSERT INTO actores (nombre, apellido, edad, genero) VALUES (%s, %s, %s, %s)",
    actores_data,
)

# Insert data into clientes table
cur.executemany(
    "INSERT INTO clientes (cuit, nombre, apellido, edad, nacionalidad, genero) VALUES (%s, %s, %s, %s, %s, %s)",
    clientes_data,
)

# Generate foreign key relations
cur.execute("SELECT id_sala, id_cine FROM salas")
salas_ids = cur.fetchall()

# # Insert data into funciones table
funciones_data = list(generate_funciones_data(num_rows, salas_ids, peliculas_data))
cur.executemany(
    "INSERT INTO funciones (nombre_pelicula, director, id_sala, id_cine, ts, precio) VALUES (%s, %s, %s, %s, %s, %s)",
    funciones_data,
)

# Insert data into compras table
compras_data = list(generate_compras_data(num_rows, funciones_data, clientes_data))
cur.executemany(
    "INSERT INTO compras (nombre_pelicula, director, id_sala, id_cine, ts, cuit, cantidad) VALUES (%s, %s, %s, %s, %s, %s, %s)",
    compras_data,
)

# Generate foreign key relations
cur.execute("SELECT id_actor FROM actores")
actores_ids = cur.fetchall()

# Insert data into actua table
actua_data = list(generate_actua_data(num_rows, actores_ids, peliculas_data))
cur.executemany(
    "INSERT INTO actua (nombre_pelicula, director, id_actor, salario) VALUES (%s, %s, %s, %s)",
    actua_data,
)

# Commit the transaction
conn.commit()

# Close the cursor and connection
cur.close()
conn.close()
