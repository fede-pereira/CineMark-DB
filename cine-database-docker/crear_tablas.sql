create table if not exists listen_events(
    sessionId int,
    itemInSession int,
    userId int,
    ts bigint,
    auth varchar(9),
    level varchar(4),
    trackId varchar(18),
    song varchar(500),
    artist varchar(500),
    zip varchar(9),
    city varchar(50),
    state char(2),
    userAgent varchar(200),
    lon numeric (6,3),
    lat numeric (6,3),
    lastname varchar(50),
    firstname varchar(50),
    gender char,
    registration bigint,
    duration numeric
);


create table if not exists auth_events(
    ts bigint,
    sessionId int,
    level varchar(4),
    itemInSession int,
    city varchar(50),
    zip varchar(9),
    state char(2),
    userAgent varchar(200),
    lon numeric (6,3),
    lat numeric (6,3),
    userId int,
    lastname varchar(50),
    firstname varchar(50),
    gender char,
    registration bigint,
    success bool 
);


create table if not exists status_change_events(
    ts bigint,
    sessionId int,
    level varchar(4),
    itemInSession int,
    city varchar(50),
    zip varchar(9),
    state char(2),
    userAgent varchar(200),
    lon numeric (6,3),
    lat numeric (6,3),
    userId int,
    lastname varchar(50),
    firstname varchar(50),
    gender char,
    registration bigint,
    auth varchar(20)
);

create table if not exists page_view_events(
    ts bigint,
    sessionId int,
    level varchar(4),
    itemInSession int,
    city varchar(50),
    zip varchar(9),
    state char(2),
    userAgent varchar(200),
    lon numeric (6,3),
    lat numeric (6,3),
    userId int,
    lastname varchar(50),
    firstname varchar(50),
    gender char,
    registration bigint,
    page varchar(30),
    auth varchar(20),
    method varchar(3),
    status int,
    trackId varchar(18),
    artist varchar(500),
    song varchar(500),
    duration numeric
);




create table if not exists salas(
    id_sala int,
    id_cine int,
    asientos int,
    nombre_cine varchar(200)

    CONSTRAINT ident_sala PRIMARY KEY(id_sala,id_cine)
);

create table if not exists peliculas(
    nombre_pelicula varchar(200),
    director varchar(200),
    duracion_en_segundos int,
    estudio varchar(200)
    presupuesto numeric,
    tiempo_de_realizacion int,
    ano_estreno int,
    genero_pelicula varchar(200)

    CONSTRAINT ident_pelicula PRIMARY KEY(nombre_pelicula,director)
);


create table if not exists actores(
    id_actor serial PRIMARY KEY,
    nombre varchar(50) not null,
    apellido varchar(50),
    edad int,
    genero varchar(1) check (genero in ('m','f','o'))

);

create table if not exists clientes(
    cuit int(10) PRIMARY KEY,
    nombre varchar (50),
    apellido varchar (50),
    edad int,
    nacionalidad varchar (200),
    genero varchar(1) check (genero in ('m','f', 'o'))
);

create table if not exists funciones(
    nombre_pelicula varchar(200) REFERENCES peliculas(nombre_pelicula),
    director varchar(200)  REFERENCES peliculas(director),
    id_sala int  REFERENCES salas(id_sala),
    id_cine int REFERENCES salas(id_cina)
    ts TIMESTAMP,

    CONSTRAINT ident_funcion PRIMARY KEY(nombre_pelicula,director,id_sala,id_cine,ts)
    --Falta constrain para que no se pisen los ts
);

create table if not exists compras(
    id_compra serial PRIMARY KEY,
    nombre_pelicula varchar(200)  REFERENCES peliculas(nombre_pelicula),
    director varchar(200)  REFERENCES peliculas(director),
    id_sala int  REFERENCES salas(id_sala),
    id_cine int REFERENCES salas(id_cine)
    ts TIMESTAMP REFERENCES funciones(ts),
    cuit int(10) REFERENCES clientes(cuit) ,
    cantidad int
);

create table if not exists actua(
    nombre_pelicula varchar(200) REFERENCES peliculas(nombre_pelicula),
    director varchar(200) REFERENCES peliculas(director),
    id_actor int REFERENCES actores(id_actor),
    salario numeric,
    CONSTRAINT ident_actua PRIMARY KEY(nombre_pelicula,director,id_actor)
);


-- nuevo

CREATE TABLE IF NOT EXISTS salas (
    id_sala INT,
    id_cine INT,
    asientos INT,
    nombre_cine VARCHAR(200),
    CONSTRAINT ident_sala PRIMARY KEY (id_sala, id_cine)
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


create table if not exists actores(
    id_actor serial PRIMARY KEY,
    nombre varchar(50) not null,
    apellido varchar(50),
    edad int,
    genero varchar(1) check (genero in ('m','f','o'))

);


CREATE TABLE IF NOT EXISTS clientes (
    cuit INT PRIMARY KEY CHECK (cuit > 9999999999 AND cuit < 100000000000),
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    edad INT,
    nacionalidad VARCHAR(200),
    genero VARCHAR(1) CHECK (genero IN ('m', 'f', 'o'))
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
    duracion_pelicula_segundos INT REFERENCES peliculas(duracion_en_segundos), --??
    CONSTRAINT ident_funcion PRIMARY KEY(nombre_pelicula, director, id_sala, id_cine, ts),
    EXCLUDE USING GIST (
        id_sala WITH =,
        id_cine WITH =,
        tsrange(ts, sumar_segundos(ts, duracion_pelicula_segundos), '[)') WITH &&
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
    cuit int(10) REFERENCES clientes(cuit) ,
    cantidad int,
    FOREIGN KEY (nombre_pelicula, director,id_sala, id_cine,ts) REFERENCES funciones(nombre_pelicula, director,id_sala, id_cine,ts)
    FOREIGN KEY (id_sala, id_cine) REFERENCES salas((id_sala, id_cine)



);

create table if not exists actua(
    nombre_pelicula varchar(200) REFERENCES peliculas(nombre_pelicula),
    director varchar(200) REFERENCES peliculas(director),
    id_actor int REFERENCES actores(id_actor),
    salario numeric,
    CONSTRAINT ident_actua PRIMARY KEY(nombre_pelicula,director,id_actor)
);
