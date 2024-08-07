from typing import Optional

from td7.custom_types import Records
from td7.database import Database

class Schema:
    def __init__(self):
        self.db = Database()        
    # Estamos usando RANDOM() para no estar siempre trayendo los mismos datos
    def get_funciones(self, sample_n: Optional[int] = None)-> Records:
        query = "SELECT * FROM funciones ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_actores(self, sample_n: Optional[int] = None)-> Records:
        query = "SELECT * FROM actores ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)

    def get_peliculas(self, sample_n: Optional[int] = None)-> Records:
        query = "SELECT * FROM peliculas ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query) 
    
    def get_compras(self, sample_n: Optional[int] = None)-> Records:
        query = query = "SELECT * FROM compras ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_actua(self, sample_n: Optional[int] = None)-> Records:
        query = "SELECT * FROM actua ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_salas(self, sample_n: Optional[int] = None)-> Records:
        query = "SELECT * FROM salas ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_clientes(self, sample_n: Optional[int] = None)-> Records:
        query = "SELECT * FROM clientes ORDER BY RANDOM()"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_last_month_data(self)-> Records:
        query = "SELECT DATE(f.ts) AS dia, SUM(f.precio * c.cantidad) AS profit FROM compras c JOIN funciones f ON (c.id_sala = f.id_sala AND c.id_cine = f.id_cine AND c.ts = f.ts AND c.nombre_pelicula = f.nombre_pelicula AND c.director = f.director) WHERE f.ts >= NOW() - INTERVAL '3 month' GROUP BY DATE(f.ts);"
        return self.db.run_select(query)
        
    
    def insert(self, records: Records, table: str):
        self.db.run_insert(records, table)