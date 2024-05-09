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


