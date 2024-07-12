-- SQLBook: Code
{{ config(materialized='table') }}


with compras_genero as (
    select 
        p.genero_pelicula as genero_pelicula,
        sum(c.cantidad * f.precio) as total_revenue
    from 
        {{source('postgres','compras')}} c
    join 
        {{source('postgres','funciones')}} f on f.nombre_pelicula = c.nombre_pelicula and f.director = c.director and f.id_sala = c.id_sala and f.id_cine = c.id_cine and c.ts=f.ts
    join 
        {{source('postgres','peliculas')}} p on c.nombre_pelicula = p.nombre_pelicula
    WHERE c.ts >= CURRENT_DATE - INTERVAL '30 days'
    group by 
        p.genero_pelicula, f.precio
)

select 
    genero_pelicula,
    sum(total_revenue) as total_revenue
from 
    compras_genero
group by 
    genero_pelicula
order by 
    total_revenue desc