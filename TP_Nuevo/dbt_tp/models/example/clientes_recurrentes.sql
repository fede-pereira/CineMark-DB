-- SQLBook: Code
{{ config(materialized='table') }}

with compras_cliente as (
    select 
        cl.cuit,
        count(*) as cantidad_compras_cliente,
        sum(c.cantidad * f.precio) as plata_cliente
    from 
        
        {{source('postgres','compras')}} c
    join
        {{source('postgres','clientes')}} cl on c.cuit = cl.cuit
    join 
        {{source('postgres','funciones')}} f on f.nombre_pelicula = c.nombre_pelicula and f.director = c.director and f.id_sala = c.id_sala and f.id_cine = c.id_cine and c.ts=f.ts
    group by 
        cl.cuit
)
select 
    cuit,
    case 
        when cantidad_compras_cliente > 2 then 'Cinemark Fan'
        when cantidad_compras_cliente = 2 then 'Aficionado al cine'
        else 'Primera cita'
    end as categoria,
    plata_cliente
from compras_cliente

