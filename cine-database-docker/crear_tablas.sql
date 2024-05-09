create table if not exists salas(
    id_sala int,
    id_cine int,
    asientos int,
    CONSTRAINT ident_sala PRIMARY KEY(id_sala,id_cine)
);

create table if not exists peliculas(
    nombre_pelicula varchar(200),
    director varchar(200),
    duracion_en_segundos int,
    estudio varchar(200),
    presupuesto numeric,
    tiempo_de_realizacion int,
    ano_estreno int,
    genero_pelicula varchar(200),

    CONSTRAINT ident_pelicula PRIMARY KEY(nombre_pelicula,director)
);

CREATE TABLE IF NOT EXISTS clientes (
    cuit BIGINT PRIMARY KEY CHECK (cuit <= 99999999999 AND cuit > 10000000000),
    nombre VARCHAR(50),				   
    apellido VARCHAR(50),
    edad INT,
    nacionalidad VARCHAR(200),
    genero VARCHAR(10) CHECK (genero IN ('m', 'f', 'o'))
);

create table if not exists actores(
    id_actor serial PRIMARY KEY,
    nombre varchar(50) not null,
    apellido varchar(50),
    edad int,
    genero varchar(1) check (genero in ('m','f','o'))

);

CREATE EXTENSION IF NOT EXISTS btree_gist;

-- Primero, creamos la función inmutable que suma los segundos al timestamp
CREATE FUNCTION sumar_segundos(timestamp, integer) RETURNS timestamp AS $$
    SELECT $1 + ($2 || ' seconds')::interval;
$$ LANGUAGE SQL IMMUTABLE;

-- Ahora creamos la tabla 'funciones' con el constraint EXCLUDE
CREATE TABLE IF NOT EXISTS funciones (
    nombre_pelicula VARCHAR(200) ,
    director VARCHAR(200),
    id_sala INT ,
    id_cine INT ,
    ts TIMESTAMP,
    --duracion_pelicula_segundos INT ,
    CONSTRAINT ident_funcion PRIMARY KEY(nombre_pelicula, director, id_sala, id_cine, ts),
    EXCLUDE USING GIST (
        id_sala WITH =,
        id_cine WITH =,
        tsrange(ts, sumar_segundos(ts, 8460), '[)') WITH &&
    ),
    FOREIGN KEY (nombre_pelicula, director) REFERENCES peliculas(nombre_pelicula, director),
    FOREIGN KEY (id_sala, id_cine) REFERENCES salas(id_sala, id_cine)
);

create table if not exists compras(
    id_compra serial PRIMARY KEY,
    nombre_pelicula varchar(200) ,
    director varchar(200) ,
    id_sala int ,
    id_cine int ,
    ts TIMESTAMP ,
    cuit bigint REFERENCES clientes(cuit) ,
    cantidad int,
    FOREIGN KEY (nombre_pelicula, director,id_sala, id_cine,ts) REFERENCES funciones(nombre_pelicula, director,id_sala, id_cine,ts),
    FOREIGN KEY (id_sala, id_cine) REFERENCES salas(id_sala, id_cine)
);

create table if not exists actua(
    nombre_pelicula varchar(200),
    director varchar(200),
    id_actor int REFERENCES actores(id_actor),
    salario numeric,
    CONSTRAINT ident_actua PRIMARY KEY(nombre_pelicula,director,id_actor),
    FOREIGN KEY (nombre_pelicula, director) REFERENCES peliculas(nombre_pelicula, director)
);

