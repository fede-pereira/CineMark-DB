import datetime
import random
from faker import Faker
from faker.providers import address, date_time, internet, passport, phone_number
import uuid
import psycopg2
from .database import Database

from td7.custom_types import Records

class DataGenerator:
    def __init__(self):
        """Instantiates faker instance"""
        self.fake = Faker()
        self.fake.add_provider(address)
        self.fake.add_provider(date_time)
        self.fake.add_provider(internet)
        self.fake.add_provider(passport)
        self.fake.add_provider(phone_number)
    
    def generate_peliculas(self, n: int) -> Records:
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
                elements=("Action", "Comedy", "Drama", "Thriller", "Science Fiction", "Fantasy", "Horror", "Western", "Musical")
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
  
   
    def generate_clientes(self, n: int, data_clientes: Records) -> Records:
        clientes = []
        cuits = set([int(num['cuit']) for num in data_clientes])
        
        for _ in range(n):
            # cuit no repetido
            cuit = self.fake.random_number(digits=11, fix_len=True)
            while cuit in cuits:
                cuit = self.fake.random_number(digits=11, fix_len=True)
            cuits.add(cuit)
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

    def check_rango(self, ts: datetime.datetime, dic_salas: dict, id_sala: int, id_cine: int, dic_duraciones: dict, nombre_pelicula: str, nombre_director:str) -> bool:
        """"Chequea si una funcion puede ser creada"""
        if (id_sala, id_cine) not in dic_salas:
            return False
        ts_sala = dic_salas[(id_sala, id_cine)]
        duracion = dic_duraciones[(nombre_pelicula, nombre_director)]
        for ts_sala in ts_sala:
            if ts_sala <= ts and ts <= ts_sala + datetime.timedelta(seconds=duracion):
                return False
        return True

    def generate_funciones(self, n: int, peliculas_data: Records, salas_ids:Records, funciones_data:Records) -> Records:
        funciones = []

        # Creo diccionario con las salas y sus funciones
        salas = [num['id_sala'] for num in funciones_data]
        cines = [num['id_cine'] for num in funciones_data]
        ts = [num['ts'] for num in funciones_data]
        dic_salas = {}
        for i in range(len(salas)):
            sala =(salas[i], cines[i])
            if sala not in dic_salas:
                dic_salas[sala] = []
            dic_salas[sala].append(ts[i])
            
        # Creo diccionario con las duraciones de las peliculas
        nombres = [num['nombre_pelicula'] for num in peliculas_data]
        directores = [num['director'] for num in peliculas_data]
        duraciones = [int(num['duracion_en_segundos']) for num in peliculas_data]
        dic_duraciones = {}
        for i in range(len(nombres)):
            peli = (nombres[i], directores[i])
            dic_duraciones[peli] = duraciones[i]


        for _ in range(n): 
            data= self.fake.random_element(peliculas_data)
            nombre_pelicula = data['nombre_pelicula']
            director = data['director']
            precio = random.choice([4000,6000,10000])
            data_sala= random.choice(salas_ids)
            id_sala = data_sala['id_sala']
            id_cine = data_sala['id_cine']
            ts = self.fake.date_time_between(start_date="-2y", end_date="now")
            while not self.check_rango(ts, dic_salas, id_sala, id_cine, dic_duraciones, nombre_pelicula, director):
                ts = self.fake.date_time_between(start_date="-2y", end_date="now")
                precio = random.choice([4000,6000,10000])
            funciones.append({"nombre_pelicula": nombre_pelicula, 
                                "director": director, 
                                "id_sala": id_sala, 
                                "id_cine": id_cine, 
                                "ts": ts,
                                "precio": precio})    
        return funciones    

    def generate_actua(self, peliculas_data:Records, actores:Records, n: int) -> Records:
        actua = []
        #pido las peliculas y las salas de la base
        
        actores = [num['id_actor'] for num in actores]
        for _ in range(n): 
            data = self.fake.random_element(peliculas_data)
            nombre_pelicula = data['nombre_pelicula']
            director = data['director']

            id_actor, *_ = random.choice(actores)
            salario = round(self.fake.pyfloat(left_digits=5, right_digits=2, positive=True), 2)
            actua.append({"nombre_pelicula": nombre_pelicula, 
                                "director": director,
                                "id_actor": id_actor,
                                "salario": salario})    
        return actua    

    def generate_actores(self, n: int) -> Records:
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
    
        
    def generate_compras(self, n: int, funciones_data: Records, clientes_data: Records, salas_data: Records) -> Records:
        compras = []
        capacidades = {}
        disponibles = {}
        for row in salas_data:
            id_sala = row['id_sala']
            id_cine = row['id_cine']
            asientos = row['asientos']
            capacidades[(id_sala, id_cine)] = asientos
            disponibles[(id_sala, id_cine)] = {}
        for row in funciones_data:
            id_sala = row['id_sala']
            id_cine = row['id_cine']
            ts = row['ts']
            if ts not in disponibles[(id_sala, id_cine)]:
                disponibles[(id_sala, id_cine)][ts] = capacidades[(id_sala, id_cine)]

        print(disponibles)
        for _ in range(n):
            try:
                datos = self.fake.random_element(funciones_data)
                nombre_pelicula = datos['nombre_pelicula']
                director = datos['director']
                id_sala = datos['id_sala']
                id_cine = datos['id_cine']
                ts = datos['ts']


                print(nombre_pelicula, director, id_sala, id_cine, ts)
                data_cliente= random.choice(clientes_data)
                cuit = data_cliente['cuit']
                cantidad = self.fake.random_int(min=1, max=4)
                if (id_sala, id_cine) not in disponibles:
                    disponibles[(id_sala, id_cine)] = {}
                while disponibles[(id_sala, id_cine)][ts] <= cantidad:
                    # nombre_pelicula, director, id_sala, id_cine, ts, precio = self.fake.random_element(funciones_data)
                    datos = self.fake.random_element(funciones_data)
                    nombre_pelicula = datos['nombre_pelicula']
                    director = datos['director']
                    id_sala = datos['id_sala']
                    id_cine = datos['id_cine']
                    ts = datos['ts']
                    data_cliente= random.choice(clientes_data)
                    cuit = data_cliente['cuit']
                    cantidad = self.fake.random_int(min=1, max=4)
                disponibles[(id_sala, id_cine)][ts] -= cantidad
                if disponibles[(id_sala, id_cine)][ts] < 0:
                    raise ValueError("No hay suficientes asientos", nombre_pelicula, director, id_sala, id_cine, ts, cuit, cantidad)
                compras.append({"nombre_pelicula": nombre_pelicula, 
                                "director": director, 
                                "id_sala": id_sala, 
                                "id_cine": id_cine, 
                                "ts": ts, 
                                "cuit": cuit, 
                                "cantidad": cantidad})
            except Exception as e:
                raise ValueError(e, nombre_pelicula, director, id_sala, id_cine, ts, cuit, cantidad,datos)
        return compras