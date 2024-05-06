
### 1. Analisis de requerimientos

Dado que nuestro objetivo con esta base de datos es modelar un sistema funcional de gestion y analisis de un cine, debemos analizar los aspectos fundamentales de uso diario de este tipo de negocio. Es por esto que concluimos necesarios los siguientes requerimientos:
- Contar con clientes representados por una entidad para que puedan efectuar sus compras
- Tener una compra, la cual vincula a los clientes con las peliculas, salas y funciones.
- Poder acceder a una entidad pelicula, una entidad sala y una funcion la cual pricipalmente relaciona una pelicula con una sala, agregando el comienzo de esta.
- Generar datos acerca de la fidelidad/gastos de distintos clientes, en base a que tan seguido asisten, cuanto dinero gastaron en el establecimiento, etc.
- Obtener insight acerca de cuales son las peliculas mas taquilleras, que edades de PG se venden mas (Agregar atributo en pelicula) o hasta conocer los directores mas vendidos.
No sera necesario involucrarse en el terreno de las transacciones/entidades bancarias, simplemente mantener registro del costo unitario de las distintas funciones.


![[ER-1.png]]
![[Relacional.png]]
![[ER-2.png]]