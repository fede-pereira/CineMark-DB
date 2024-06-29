-- SQLBook: Code
CREATE OR REPLACE FUNCTION validar_suma()
RETURNS TRIGGER AS $$
DECLARE
    total INT;
    maximo INT;
BEGIN
    -- Calcular la suma de las filas existentes más la nueva fila a ser insertada
    SELECT SUM(cm.cantidad) + NEW.cantidad INTO total
    FROM compras cm
    WHERE NEW.ts = cm.ts and NEW.sala_id = cm.sala_id and NEW.cine_id = cm.cine_id;

    -- Obtener el máximo de la columna asientos en función de la sala y el cine
    SELECT MAX(sl.asientos) INTO maximo
    FROM sala sl
    WHERE NEW.sala_id = sl.sala_id and NEW.cine_id = sl.cine_id;

    -- Verificar si la suma supera el límite
    IF total > maximo THEN
        -- Si la suma supera el límite, abortar la inserción de la fila
        RAISE EXCEPTION 'La suma total excede el límite permitido';
    END IF;
    
    -- Si la suma está dentro del límite, permitir la inserción de la fila
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION validar_espacio()
RETURNS TRIGGER AS $$
DECLARE
    duracion_pelicula INT;
    total INT;
BEGIN
    -- Obtener la duración de la película correspondiente a la función que se está insertando
    SELECT duracion INTO duracion_pelicula
    FROM peliculas
    WHERE nombre_pelicula = NEW.nombre_pelicula and director = NEW.director;

    -- Calcular las funciones con las que chocaría
    SELECT COUNT(*) INTO total
    FROM funciones fc
    LEFT JOIN peliculas pl ON pl.nombre_pelicula = fc.nombre_pelicula AND pl.director = fc.director
    WHERE NEW.sala_id = fc.sala_id AND NEW.cine_id = fc.cine_id AND
        (NEW.ts + duracion_pelicula > fc.ts OR fc.ts + pl.duracion > NEW.ts);

    -- Verificar si la suma supera el límite
    IF total > 0 THEN
        -- Si la suma supera el límite, abortar la inserción de la fila
        RAISE EXCEPTION 'Este horario está ocupado';
    END IF;
    
    -- Si la suma está dentro del límite, permitir la inserción de la fila
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

