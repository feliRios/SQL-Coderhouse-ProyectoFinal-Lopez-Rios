USE success_mindset;

-- Caso de prueba 1: se necesita realizar una revision del correcto funcionamiento de la plataforma.
-- Por lo tanto, lo mejor seria revisar la veracidad de los datos (por ejemplo, si las fechas y/o los montos de compra son consistentes)
-- Para esto, se podria utilizar la vista USUARIO_COMPRAS y revisar que los datos sean coincidentes

SELECT * FROM usuario_compras;

-- Caso de prueba 2: un analista y un equipo de marketing estan interesados en conocer la disponibilidad de libros de un genero en especifico para
-- planificar estrategias promocionales. 
-- Para esto, se podria utilizar la funcion STOCK_GENERO para tener nocion de la cantidad de libros de un genero en especifico que se encuentra publicada (en este caso, genero = DESARROLLO PERSONAL)

SELECT stock_genero(2) AS 'Stock genero DESARROLLO PERSONAL';

-- Caso de prueba 3: un equipo de marketing esta interesado en conocer la actividad de compra de un usuario en especifico para planificar
-- estrategias publicitarias.
-- Para esto, se podria utilizar la vista USUARIO_CANTIDAD_COMPRAS para conocer si un usuario es comprador compulsivo y/o recurrente

SELECT * FROM usuario_cantidad_compras
WHERE id_user = 11;

-- Caso de prueba 4: un cliente desea realizar una publicacion en su cuenta para comenzar a vender.
-- Por lo tanto, el cliente desea saber si su libro se encuentra cargado en la base de datos. Caso contrario, lo agregaria ingresando los datos correspondientes.
-- Para esto, el cliente pone en el buscador el nombre del libro. Por lo tanto, es preciso utilizar la vista INFO_LIBRO, la cual provee informacion detallada sobre 
-- todos los libros pre-cargados en la base de datos.

SELECT * FROM info_libro
WHERE title LIKE '%El metodo %';

-- Caso de prueba 5: se necesita liberar espacio y optimizar la base de datos, deshaciendonos de registros obsoletos.
-- Para esto, podriamos utilizar el procedimiento almacenado SP_ELIMINAR_ENVIO_HASTA_FECHA para deshacernos de envios ya concretados.

CALL sp_eliminar_envio_hasta_fecha(NOW());
