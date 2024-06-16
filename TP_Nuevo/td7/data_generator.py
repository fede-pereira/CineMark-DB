import datetime
import random
from faker import Faker
from faker.providers import address, date_time, internet, passport, phone_number
import uuid
import psycopg2
from database import Database

from td7.custom_types import Records, Record

PHONE_PROBABILITY = 0.7

class DataGenerator:
    def __init__(self):
        """Instantiates faker instance"""
        self.fake = Faker()
        self.fake.add_provider(address)
        self.fake.add_provider(date_time)
        self.fake.add_provider(internet)
        self.fake.add_provider(passport)
        self.fake.add_provider(phone_number)

    def generate_people(self, n: int) -> Records:
        """Generates n people.

        Parameters
        ----------
        n : int
            Number of people to generate.

        Returns
        -------
        List[Dict[str, Any]]
            List of dicts that include first_name, last_name, phone_number,
            address, country, date_of_birth, passport_number and email.

        Notes
        -----
        People are guaranteed to be unique only within a function call.
        """
        people = []
        for _ in range(n):
            people.append(
                {
                    "first_name": self.fake.unique.first_name(),
                    "last_name": self.fake.unique.last_name(),
                    "phone_number": self.fake.unique.phone_number(),
                    "address": self.fake.unique.address(),
                    "country": self.fake.unique.country(),
                    "date_of_birth": self.fake.unique.date_of_birth(),
                    "passport_number": self.fake.unique.passport_number(),
                    "email": self.fake.unique.ascii_email(),
                }
            )
        return people
    
    def generate_peliculas_data(self, n: int) -> Records:
        peliculas = []
        for _ in range(n):
            nombre_pelicula = self.fake.catch_phrase()
            director = self.fake.name()
            duracion_en_segundos = self.fake.random_int(min=3600, max=8459)  # 1-3 hours
            estudio = self.fake.company()
            presupuesto = self.fake.random_number(digits=8)
            tiempo_de_realizacion = self.fake.random_int(min=1, max=24)
            ano_estreno = self.fake.random_int(min=1970, max=2022)
            genero_pelicula = self.fake.random_element(
                elements=("Action", "Comedy", "Drama", "Thriller")
            )
            peliculas.append({
                "nombre_pelicula":nombre_pelicula,
                "director":director,
                "duracion_en_segundos":duracion_en_segundos,
                "estudio":estudio,
                "presupuesto":presupuesto,
                "tiempo_de_realizacion":tiempo_de_realizacion,
                "ano_estreno":ano_estreno,
                "genero_pelicula":genero_pelicula}
        )
        return peliculas
  
   
    def generate_clientes_data(self, n: int) -> Records:
        clientes = []
        for _ in range(n):
            cuit = self.fake.random_number(digits=11, fix_len=True)  # Ensure 11-digit number
            nombre = self.fake.first_name()
            apellido = self.fake.last_name()
            edad = self.fake.random_int(min=18, max=80)
            nacionalidad = self.fake.country()
            genero = random.choice(["m", "f", "o"])

            clientes.append({"cuit": cuit, 
                             "nombre": nombre, 
                             "apellido": apellido, 
                             "edad": edad, 
                             "nacionalidad": nacionalidad, 
                             "genero": genero})
        return clientes
    
    
    def generate_salas(self, n: int) -> Records:
        """Generates n people.

        Parameters
        ----------
        n : int
            Numero de salas a generar.

        Returns
        -------
        List[Dict[str, Any]]
            List of dicts that include first_name, last_name, phone_number,
            address, country, date_of_birth, passport_number and email.

        Notes
        -----
        People are guaranteed to be unique only within a function call.
        """
        salas = []
        for _ in range(n):
            salas.append(
                {
            "id_sala" : self.fake.random_int(min=1, max=1000),
            "id_cine" : self.fake.random_int(min=1, max=1000),
            "asientos" : self.fake.random_int(min=50, max=300),
                }
                )
            return salas

    def generate_funciones(self, n: int) -> Records:
        funciones = []

        #pido las peliculas y las salas de la base
        db = Database()
        peliculas_data = db.run_select("SELECT * FROM peliculas")
        salas_ids = db.run_select("SELECT id_sala, id_cine FROM salas")
        
        for _ in range(n): 
            nombre_pelicula, director, *_ = self.fake.random_element(peliculas_data)
            id_sala, id_cine, *_ = random.choice(salas_ids)
            ts = self.fake.date_time_between(start_date="-2y", end_date="now")
            funciones.append({"nombre_pelicula": nombre_pelicula, 
                                "director": director, 
                                "id_sala": id_sala, 
                                "id_cine": id_cine, 
                                "ts": ts})    
        return funciones    

    def generate_actua(self, n: int) -> Records:
        actua = []

        #pido las peliculas y las salas de la base
        db = Database()
        peliculas_data = db.run_select("SELECT * FROM peliculas")
        actores =  db.run_select("SELECT id_actor FROM actores")
        actores = [num['id_actor'] for num in actores]
        for _ in range(n): 
            nombre_pelicula, director, *_ = self.fake.random_element(peliculas_data)
            id_actor, *_ = random.choice(actores)
            salario = round(self.fake.pyfloat(left_digits=5, right_digits=2, positive=True), 2)
            actua.append({"nombre_pelicula": nombre_pelicula, 
                                "director": director,
                                "id_actor": id_actor,
                                "salario": salario})    
        return actua    

    def generate_actores_data(self, n: int) -> Records:
        actores = []
        for _ in range(n):
            nombre = self.fake.first_name()
            apellido = self.fake.last_name()
            edad = self.fake.random_int(min=18, max=80)
            genero = random.choice(["m", "f", "o"])

            actores.append({"nombre": nombre, 
                            "apellido": apellido, 
                            "edad": edad, 
                            "genero": genero})
        return actores
    

    