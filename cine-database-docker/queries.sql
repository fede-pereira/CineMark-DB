-- Ganancias totales por genero de peliculas
SELECT p.genero_pelicula, SUM(c.cantidad) * 4000 AS ingresos_totales
FROM compras c
JOIN funciones f ON c.id_sala = f.id_sala AND c.id_cine = f.id_cine AND c.ts = f.ts
JOIN peliculas p ON c.nombre_pelicula = p.nombre_pelicula AND c.director = p.director
GROUP BY p.genero_pelicula;
   
-- Edad promedio de clientes por genero de peliculas   
SELECT p.genero_pelicula, AVG(c.edad) AS avg_age
FROM compras cm
JOIN funciones f ON cm.id_sala = f.id_sala AND cm.id_cine = f.id_cine AND cm.ts = f.ts
JOIN peliculas p ON cm.nombre_pelicula = p.nombre_pelicula AND cm.director = p.director
JOIN clientes c ON cm.cuit = c.cuit
GROUP BY p.genero_pelicula;

-- Las 5 peliculas con mas ganancia total
SELECT nombre_pelicula, director, ingresos_totales
FROM (SELECT c.nombre_pelicula, c.director,
        SUM(cantidad) * 4000 AS ingresos_totales,
        ROW_NUMBER() OVER (ORDER BY SUM(cantidad) * 4000 DESC) AS RANK
        FROM compras c
        JOIN funciones f ON c.id_sala = f.id_sala AND c.id_cine = f.id_cine AND c.ts = f.ts
    GROUP BY
        c.nombre_pelicula, c.director
) AS ranked_movies
WHERE rank <= 5;

-- Porcentaje y cantidad de clientes por rango etario
WITH rango_etario AS (
SELECT
CASE
    WHEN edad BETWEEN 0 AND 18 THEN '0-18'
    WHEN edad BETWEEN 19 AND 30 THEN '19-30'
    WHEN edad BETWEEN 31 AND 45 THEN '31-45'
    WHEN edad BETWEEN 46 AND 60 THEN '46-60'
    ELSE 'Above 60'
END AS grupo_etario, COUNT(*) AS cantidad
FROM clientes
GROUP BY grupo_etario)
SELECT grupo_etario, cantidad, ROUND(count::numeric / SUM(cantidad) OVER () * 100, 2) AS porcentaje
FROM rango_etario;

--comentario, creo q no se permiten menos de 18 en los datos. Veria de relacionarlo con la cantidadd de entradas compradas por cliente mas que por el cliente en si


--ideas
-- cliente con mas compras (mmuy simple)
-- director mas famoso del ultimo mes
-- peliculas que atraen a grupos, (ver cantidad promedio de entrasdas por compra por pelicula)
-- dias de la semana con mayor cantidad de clientes
-- 



