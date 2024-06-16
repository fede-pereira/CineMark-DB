-- SQLBook: Code
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
CREATE OR REPLACE FUNCTION  sumar_segundos(timestamp, integer) RETURNS timestamp AS $$
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


CREATE OR REPLACE FUNCTION validar_suma()
RETURNS TRIGGER AS $$
DECLARE
    total INT;
    maximo INT;
BEGIN
    -- Calcular la suma de las filas existentes más la nueva fila a ser insertada
    SELECT SUM(cm.cantidad) + NEW.cantidad INTO total
    FROM compras cm
    WHERE NEW.ts = cm.ts and NEW.id_sala = cm.id_sala and NEW.id_cine = cm.id_cine;

    -- Obtener el máximo de la columna asientos en función de la sala y el cine
    SELECT MAX(sl.asientos) INTO maximo
    FROM salas sl
    WHERE NEW.id_sala = sl.id_sala and NEW.id_cine = sl.id_cine;

    -- Verificar si la suma supera el límite
    IF total > maximo THEN
        -- Si la suma supera el límite, abortar la inserción de la fila
        RAISE EXCEPTION 'La suma total excede el límite permitido';
    END IF;
    
    -- Si la suma está dentro del límite, permitir la inserción de la fila
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER trigg_compra_insert BEFORE INSERT ON compras FOR EACH ROW EXECUTE PROCEDURE validar_suma();

CREATE OR REPLACE FUNCTION validar_espacio()
RETURNS TRIGGER AS $$
DECLARE
    duracion_pelicula INT;
    total INT;
BEGIN
    -- Obtener la duración de la película correspondiente a la función que se está insertando
    SELECT duracion_en_segundos INTO duracion_pelicula
    FROM peliculas
    WHERE nombre_pelicula = NEW.nombre_pelicula AND director = NEW.director;

    -- Calcular las funciones con las que chocaría
    SELECT COUNT(*) INTO total
    FROM funciones fc
    LEFT JOIN peliculas pl ON pl.nombre_pelicula = fc.nombre_pelicula AND pl.director = fc.director
    WHERE NEW.id_sala = fc.id_sala AND NEW.id_cine = fc.id_cine AND
        ((EXTRACT(EPOCH FROM NEW.ts) + duracion_pelicula > EXTRACT(EPOCH FROM fc.ts) AND 
        EXTRACT(EPOCH FROM NEW.ts) < EXTRACT(EPOCH FROM fc.ts)) OR
        (EXTRACT(EPOCH FROM fc.ts) + pl.duracion_en_segundos > EXTRACT(EPOCH FROM NEW.ts) AND
        EXTRACT(EPOCH FROM fc.ts) + pl.duracion_en_segundos < EXTRACT(EPOCH FROM NEW.ts) + duracion_pelicula));

    -- Verificar si la suma supera el límite
    IF total > 0 THEN
        RAISE EXCEPTION 'La función se superpone con demasiadas funciones existentes';
    END IF;

    -- Si la suma está dentro del límite, permitir la inserción de la fila
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE or replace TRIGGER trigg_funcion_insert BEFORE INSERT ON funciones FOR EACH ROW EXECUTE PROCEDURE validar_espacio();
