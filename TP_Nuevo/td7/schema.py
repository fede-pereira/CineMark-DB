from typing import Optional

from td7.custom_types import Records
from td7.database import Database

class Schema:
    def __init__(self):
        self.db = Database()        
    
    def get_funciones(self, sample_n: Optional[int] = None)-> Records:
        "SELECT * FROM funciones"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_actores(self, sample_n: Optional[int] = None)-> Records:
        "SELECT * FROM actores"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)

    def get_peliculas(self, sample_n: Optional[int] = None)-> Records:
        "SELECT * FROM peliculas"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query) 
    
    def get_compras(self, sample_n: Optional[int] = None)-> Records:
        "SELECT * FROM compras"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_actua(self, sample_n: Optional[int] = None)-> Records:
        "SELECT * FROM actua"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
    
    def get_salas(self, sample_n: Optional[int] = None)-> Records:
        "SELECT * FROM salas"
        if sample_n is not None:
            query += f" LIMIT {sample_n}"
        return self.db.run_select(query)
        
    
    def insert(self, records: Records, table: str):
        self.db.run_insert(records, table)