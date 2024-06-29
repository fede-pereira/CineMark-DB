-- SQLBook: Code
-- 1) Ganancias totales por genero de peliculas
SELECT p.genero_pelicula, SUM(c.cantidad) * 4000 AS ingresos_totales
FROM compras c
JOIN funciones f ON c.id_sala = f.id_sala AND c.id_cine = f.id_cine AND c.ts = f.ts
JOIN peliculas p ON c.nombre_pelicula = p.nombre_pelicula AND c.director = p.director
GROUP BY p.genero_pelicula;
   
-- 2) Edad promedio de clientes por genero de peliculas   
SELECT p.genero_pelicula, AVG(c.edad) AS edad_promedio
FROM compras cm
JOIN funciones f ON cm.id_sala = f.id_sala AND cm.id_cine = f.id_cine AND cm.ts = f.ts
JOIN peliculas p ON cm.nombre_pelicula = p.nombre_pelicula AND cm.director = p.director
JOIN clientes c ON cm.cuit = c.cuit
GROUP BY p.genero_pelicula;

-- 3) Las 5 peliculas con mas ganancia total
SELECT nombre_pelicula, director, ingresos_totales
FROM (SELECT c.nombre_pelicula, c.director, SUM(cantidad) * 4000 AS ingresos_totales, 
ROW_NUMBER() OVER (ORDER BY SUM(cantidad) * 4000 DESC) AS RANK
FROM compras c
JOIN funciones f ON c.id_sala = f.id_sala AND c.id_cine = f.id_cine AND c.ts = f.ts
GROUP BY c.nombre_pelicula, c.director) AS ranked_movies
WHERE rank <= 5;

-- 4) Porcentaje y cantidad de clientes por rango etario
WITH rango_etario AS (
SELECT CASE
    WHEN edad BETWEEN 0 AND 18 THEN '0-18'
    WHEN edad BETWEEN 19 AND 30 THEN '19-30'
    WHEN edad BETWEEN 31 AND 45 THEN '31-45'
    WHEN edad BETWEEN 46 AND 60 THEN '46-60'
    ELSE 'Above 60'
END AS grupo_etario, COUNT(*) AS cantidad
FROM clientes
GROUP BY grupo_etario)
SELECT grupo_etario, cantidad, CONCAT(ROUND(cantidad::numeric / SUM(cantidad) OVER () * 100, 2),'%') AS porcentaje
FROM rango_etario;

-- 5) Orden de franjas horarias segun cuanta gente va al cine en ese horario.
SELECT CONCAT(EXTRACT(HOUR FROM f.ts),':00') AS franja_horaria, SUM(c.cantidad) AS ventas
FROM compras c
JOIN funciones f ON c.id_sala = f.id_sala AND c.id_cine = f.id_cine AND c.ts = f.ts
GROUP BY EXTRACT(HOUR FROM f.ts)
ORDER BY SUM(c.cantidad) DESC;

-- 6) 10 actores que mas plata acumularon
WITH salarios AS (SELECT id_actor, SUM(salario) AS salario_total
FROM actua
GROUP BY id_actor),
ranking_salarios AS (SELECT nombre, apellido, salario_total, ROW_NUMBER() OVER (ORDER BY salario_total DESC) AS ranking
FROM actores a
JOIN salarios s ON a.id_actor = s.id_actor)
SELECT * 
FROM ranking_salarios
WHERE ranking <= 10

-- 7) Edad promedio de clientes por año de estreno de pelicula
SELECT p.ano_estreno , ROUND(AVG(cl.edad)) AS edad_promedio
FROM peliculas p
LEFT JOIN compras cm ON cm.nombre_pelicula = p.nombre_pelicula AND cm.director = p.director
LEFT JOIN clientes cl ON cm.cuit = cl.cuit
GROUP BY p.ano_estreno;

-- 8) Director mas popular del mes
SELECT p.director
FROM peliculas p 
LEFT JOIN compras cm ON cm.nombre_pelicula = p.nombre_pelicula AND cm.director = p.director
WHERE cm.ts >= CURRENT_DATE - INTERVAL '30 days' AND cm.id_compra IS NOT NULL
GROUP BY p.director 
ORDER BY SUM(cantidad) DESC
LIMIT 1;

-- 9) Versatilidad de distintos actores (Definida por cantidad de generos distintos en los que actuan)
WITH actores_y_generos AS (SELECT a.nombre,a.apellido, COUNT(DISTINCT p.genero_pelicula) AS cantidad_genero
FROM actores a
JOIN actua act ON a.id_actor = act.id_actor
JOIN peliculas p ON act.nombre_pelicula = p.nombre_pelicula AND act.director = p.director
GROUP BY a.nombre, a.apellido 
ORDER BY cantidad_genero DESC)
SELECT nombre, apellido, cantidad_genero, 
CASE 
	WHEN cantidad_genero > AVG(cantidad_genero) OVER () THEN 'Versátil'
	WHEN cantidad_genero < AVG(cantidad_genero) OVER () THEN 'Limitado'
	ELSE 'Promedio'
END AS versatilidad_actoral
FROM actores_y_generos;

-- 10) Diferencia de ventas con el mes anterior
WITH ventas_mes_anio_cine AS (
SELECT sl.id_cine,
EXTRACT(MONTH FROM c.ts) AS mes ,
EXTRACT(YEAR FROM c.ts) AS anio,
sum(c.cantidad) AS cantidad_total
FROM salas sl
LEFT JOIN compras c on c.id_sala = sl.id_sala AND c.id_cine = sl.id_cine
group BY sl.id_cine, anio, mes
ORDER BY sl.id_cine, anio, mes DESC 
)
SELECT id_cine, mes, anio, cantidad_total as mes_actual, lag(cantidad_total, 1) OVER (PARTITION BY id_cine) AS mes_anterior,
(cantidad_total - lag(cantidad_total, 1) OVER (PARTITION BY id_cine ORDER BY anio, mes desc)) AS dif_mes
FROM ventas_mes_anio_cine;
