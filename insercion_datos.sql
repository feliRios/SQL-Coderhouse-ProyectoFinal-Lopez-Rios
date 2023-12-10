 USE sases;
 
-- Datos para USUARIO (insercion de datos externos)
LOAD DATA LOCAL INFILE 'registros_usuario.csv'
INTO TABLE usuario
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Datos para LIBRO_GENERO
INSERT INTO libro_genero 
VALUES (1, 'Riqueza'),
	   (2, 'Desarrollo Personal'),
       (3, 'Liderazgo'),
       (4, 'Emprendimiento'),
       (5, 'Habitos'),
       (6, 'Analisis tecnico & Trading');
       
-- Datos para LIBRO_AUTOR
INSERT INTO libro_autor
VALUES (1, 'Eric Ries'),
	   (2, 'James Clear'),
       (3, 'John Murphy'),
       (4, 'Brian Tracy'),
       (5, 'Napoleon Hill'),
       (6, 'John Maxwell');

-- Datos para LIBRO_EDITORIAL
INSERT INTO libro_editorial
VALUES (1, 'Planeta'),
	   (2, 'Debolsillo'),
       (3, 'Galerna'),
       (4, 'Aguilar');

-- Datos para FICHA_LIBRO
INSERT INTO ficha_libro
VALUES (NULL, 1, 097895074, 'Un gran libro para comenzar un empredimiento', 'El Metodo Learn Startup'),
       (NULL, 2, 097826352, 'El mejor libro para crear riquezas desde cero', 'Piense y hagase rico'),
       (NULL, 3, 097823166, 'La joyita del desarrollo personal', 'Traguese ese sapo'),
       (NULL, 4, 097826491, 'Sea el mejor lider de su generacion', 'Las 21 leyes irrefutables del liderazgo'),
       (NULL, 1, 097816231, 'Construya habitos saludables', 'Habitos atomicos'),
       (NULL, 2, 097811111, 'Aprenda a analizar los mercados como un profesional', 'Analisis tecnico de los Mercados Financieros');

-- Datos para LIBRO_GENERO_RELACION
INSERT INTO libro_genero_relacion
VALUES (NULL, 1, 4),
	   (NULL, 2, 1),
       (NULL, 3, 2),
       (NULL, 4, 3),
       (NULL, 5, 5),
       (NULL, 6, 6),
       (NULL, 1, 2);
       
-- Datos para LIBRO_AUTOR_RELACION
INSERT INTO libro_autor_relacion
VALUES (NULL, 1, 4),
	   (NULL, 2, 1),
       (NULL, 3, 2),
       (NULL, 4, 3),
       (NULL, 5, 5),
       (NULL, 6, 6);


-- Datos para PUBLICACION
INSERT INTO publicacion
VALUES (NULL, 6, 1, 4899.99, 10, 'Nuevo. Viene sellado. Local a la calle en la zona de Caballito', CURRENT_TIMESTAMP(), 'https://i.imgur.com/ESSkOdv.jpeg'),
	   (NULL, 5, 2, 2600.00, 1, 'Esta usado en perfecto estado.', CURRENT_TIMESTAMP(),'https://i.imgur.com/ngExKHr.jpeg'),
       (NULL, 4, 3, 9120.00, 3, NULL, CURRENT_TIMESTAMP(), 'https://i.imgur.com/ngExKHr.jpeg' ),
       (NULL, 2, 4, 899.90, 28, 'Nos encontramos en la zona de Lomas de Zamora', CURRENT_TIMESTAMP(), 'https://i.imgur.com/1jD7zfq.jpeg'),
       (NULL, 3, 5, 14500.50, 90, 'Con tu compra de 5 libros, te llevas 1 de regalo!', CURRENT_TIMESTAMP(), 'https://i.imgur.com/G9uU13g.png'),
       (NULL, 1, 6, 3999.99, 10, NULL, current_timestamp(), 'https://i.imgur.com/LpS6tOd.jpeg');

-- Datos para MENSAJE
INSERT INTO mensaje
VALUES (NULL, 1, 1, 'Hola. Buen dia. Haces envios a Santiago del Estero?', 'Si hacemos', CURRENT_TIMESTAMP()),
       (NULL, 2, 2, 'Por que zona te encontras?', NULL, CURRENT_TIMESTAMP()),
       (NULL, 3, 3, 'Hola. Envias a capital federal?', 'Hola. Por el momento no tenemos envios a capital federal', CURRENT_TIMESTAMP()),
       (NULL, 4, 4, 'Buenas noches. Lo tenes en la 5ta edicion?', 'Entran la semana que viene', CURRENT_TIMESTAMP());

-- Datos para ENVIO
INSERT INTO envio
VALUES (NULL, 899, 'Avenida Juan B. Alberdi 2932', CURRENT_TIMESTAMP()),
       (NULL, 340, 'Espinosa 432', CURRENT_TIMESTAMP()),
       (NULL, 1099, 'San Justo 9090', CURRENT_TIMESTAMP()),
       (NULL, 888, 'Paysando 8900', CURRENT_TIMESTAMP()),
       (NULL, 1000, 'N. Oronio 2000', CURRENT_TIMESTAMP()),
       (NULL, 188, '9 de Julio 23', CURRENT_TIMESTAMP());

-- Datos para COMPRA_METODO
INSERT INTO compra_metodo
VALUES (1, 'Efectivo'),
       (2, 'Transferencia'),
       (3, 'Debito'),
       (4, 'Credito');

-- Datos para COMPRA
INSERT INTO compra
VALUES (NULL, 1, 14, 6, CURRENT_TIMESTAMP(), 1, 1, 5087.99),
	   (NULL, 2, 15, 5, CURRENT_TIMESTAMP(), 3, 1, 3600),
       (NULL, 3, 16, 4, CURRENT_TIMESTAMP(), 2, 1, 10008),
       (NULL, 4, 19, 3, CURRENT_TIMESTAMP(), 2, 1, 1998.9),
       (NULL, 5, 11, 2, CURRENT_TIMESTAMP(), 1, 1, 14840.5),
       (NULL, 6, 12, 1, CURRENT_TIMESTAMP(), 4, 1, 4898.99);