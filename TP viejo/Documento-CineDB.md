
### 1. Análisis de requerimientos

#### Dominio del problema
Nuestro objetivo con esta base de datos es modelar un sistema funcional de gestión y análisis de un cine, debemos entender los aspectos fundamentales de uso diario de este tipo de negocio.

 Es por esto que concluimos necesarios los siguientes requerimientos:
- Contar con clientes representados por una entidad para que puedan efectuar sus compras.
- Tener una compra, la cual vincula a los clientes con las películas, salas y funciones.
- Poder acceder a una entidad película, una entidad sala y una función. Esta principalmente relaciona una película con una sala, agregando el comienzo de esta.
- Lograr entender que le interesa en las películas a los clientes a través de los estudios más vistos, los presupuestos de las películas, sus géneros, entre otros.
- Obtener información acerca distintos actores y actrices que interactúan con las películas, sus edades y géneros. Que actores actuaron en más películas, que salarios tienen, etc.
- Generar datos acerca de la fidelidad/gastos de distintos clientes, en base a que tan seguido asisten, cuánto dinero gastaron en el establecimiento, etc.
- Obtener insight acerca de cuáles son las películas más taquilleras, que edades de PG se venden más o hasta conocer los directores más vendidos.
No será necesario involucrarse en el terreno de las transacciones/entidades bancarias, simplemente mantener registro del costo unitario de las distintas funciones.

### 2. Modelo Entidad-Interrelación

![[DIAGRAMA-ER-FINAL.png]]

### 3. Modelo Relacional

![[MODELO-RELACIONAL.png]]

### 4. Modelado Físico

#### Pasos para levantar la base:
#### Usuario: cine
Password: Buscar en el archivo `docker-compose.yaml`

1. Moverse al directorio `cine-database-docker`
2. Correr `docker compose up`
3. Crear las tablas con `crear_tablas.sql`
4. Popular las tablas con `cargar_datos_desde_csv.sql`
### Observación
Para evitar que se excedan el limite de entradas vendidas, acorde a la cantidad de asientos disponibles en una sala, se incluyeron triggers por si se intenta sobrepasar esta cantidad.

### 5. Consultas SQL
1. Las consultas se encuentran en `queries.sql`.