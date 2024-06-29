-- SQLBook: Code
COPY actores (
    id_actor, 
    nombre, 
    apellido, 
    edad, 
    genero
)
FROM '/data/actores.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';

COPY peliculas (
    nombre_pelicula, 
    director, 
    duracion_en_segundos,
    estudio,
    presupuesto,
    tiempo_de_realizacion,
    ano_estreno,
    genero_pelicula
)
FROM '/data/peliculas.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';

COPY actua (
    nombre_pelicula, 
    director, 
    id_actor, 
    salario
)
FROM '/data/actua.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';

COPY clientes (
    cuit, 
    nombre, 
    apellido, 
    edad,
    nacionalidad,
    genero
)
FROM '/data/clientes.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';

COPY salas (
    id_sala, 
    id_cine, 
    asientos
)
FROM '/data/salas.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';

COPY funciones (
    nombre_pelicula, 
    director, 
    id_sala,
    id_cine,
    ts
)
FROM '/data/funciones.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';


COPY compras (
    id_compra, 
    nombre_pelicula, 
    director, 
    id_sala,
    id_cine,
    ts,
    cuit,
    cantidad
)
FROM '/data/compras.csv'
DELIMITER ';'
CSV HEADER
--para indicar que la primera lı́nea es el encabezado
ENCODING 'LATIN1';

