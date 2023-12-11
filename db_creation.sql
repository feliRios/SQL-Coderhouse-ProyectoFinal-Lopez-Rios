CREATE SCHEMA `success_mindset` ;

USE success_mindset;

# Parte 1: CREACION DE LAS TABLAS DE LA BASE DE DATOS (INCLUIDAS TABLAS DE AUDITORIA)

-- Tabla USUARIO
CREATE Table usuario (
	id_user INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    username VARCHAR(30) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    email VARCHAR(60) NOT NULL,
    date_joined DATETIME DEFAULT CURRENT_TIMESTAMP,
    user_password VARCHAR(255) NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    is_staff BOOL DEFAULT 0 NOT NULL
);

-- Tabla LIBRO_GENERO
CREATE Table libro_genero (
	id_genre INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    genre VARCHAR(30) UNIQUE NOT NULL
);

-- Tabla LIBRO_AUTOR
CREATE Table libro_autor (
	id_author INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    author VARCHAR(60) UNIQUE NOT NULL
);

-- Tabla LIBRO_EDITORIAL
CREATE Table libro_editorial (
	id_publisher INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    publisher VARCHAR(30) UNIQUE NOT NULL
);

-- Tabla FICHA_LIBRO
CREATE Table ficha_libro (
	id_book INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    publisher INT NOT NULL,
    sku INT,  -- Numero ISBN del libro
    book_description TEXT,
    title VARCHAR(80) NOT NULL,
    CONSTRAINT fk_publisher FOREIGN KEY(publisher) REFERENCES libro_editorial(id_publisher) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabla libro_autor_relacion (para expresar relacion intermedia en muchos a muchos)
CREATE Table libro_autor_relacion (
    id_relacion INT PRIMARY KEY AUTO_INCREMENT,
    id_libro INT NOT NULL,
    id_autor INT NOT NULL,
    CONSTRAINT fk_libro_autor FOREIGN KEY (id_libro) REFERENCES ficha_libro(id_book) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_autor FOREIGN KEY (id_autor) REFERENCES libro_autor(id_author) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabla libro_genero_relacion (para expresar relacion intermedia en muchos a muchos)
CREATE Table libro_genero_relacion (
    id_relacion INT PRIMARY KEY AUTO_INCREMENT,
    id_libro INT NOT NULL,
    id_genero INT NOT NULL,
    CONSTRAINT fk_libro_genero FOREIGN KEY (id_libro) REFERENCES ficha_libro(id_book) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_genero FOREIGN KEY (id_genero) REFERENCES libro_genero(id_genre) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabla PUBLICACION
CREATE Table publicacion (
	id_publication INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    id_user INT NOT NULL,
    book INT NOT NULL,
    price FLOAT NOT NULL,
    stock INT NOT NULL,
    publication_description TEXT,
    date_publication DATETIME DEFAULT CURRENT_TIMESTAMP,
    img VARCHAR(255) DEFAULT 'https://i.imgur.com/tOj1c0U.jpg',
    CONSTRAINT fk_user FOREIGN KEY(id_user) REFERENCES usuario(id_user) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_book FOREIGN KEY(book) REFERENCES ficha_libro(id_book) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabla MENSAJE
CREATE Table mensaje (
	id_message INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    id_user INT NOT NULL,
    id_publication INT NOT NULL,
    content TEXT NOT NULL,
    reply TEXT,
    date_of_message DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sender_user FOREIGN KEY(id_user) REFERENCES usuario(id_user) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_publication FOREIGN KEY(id_publication) REFERENCES publicacion(id_publication) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Tabla ENVIO
CREATE Table envio (
	id_shipping INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    price FLOAT NOT NULL,
    shipping_address VARCHAR(120) NOT NULL,
    date_of_shipping DATETIME NOT NULL
);

-- Tabla COMPRA_METODO
CREATE Table compra_metodo (
	id_payment_method INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    payment_method VARCHAR(15) UNIQUE NOT NULL
);

-- Tabla COMPRA
CREATE Table compra (
	id_purchase INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    id_publication INT NOT NULL,
    id_user INT NOT NULL,
    id_shipping INT NOT NULL,
    date_of_purchase DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method INT NOT NULL,
    quantity INT NOT NULL,
    subtotal FLOAT NOT NULL,
    CONSTRAINT fk_purchase_publication FOREIGN KEY(id_publication) REFERENCES publicacion(id_publication) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_buyer FOREIGN KEY(id_user) REFERENCES usuario(id_user) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_shipping FOREIGN KEY(id_shipping) REFERENCES envio(id_shipping) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_payment_method FOREIGN KEY(payment_method) REFERENCES compra_metodo(id_payment_method) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Tabla de auditoria AUD_USUARIO
CREATE TABLE AUD_USUARIO(
	id_audit INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT UNIQUE,
	user VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL
);

-- Tabla de auditoria AUD_PUBLICACION
CREATE TABLE AUD_PUBLICACION(
	id_audit INT AUTO_INCREMENT PRIMARY KEY,
    id_publication INT UNIQUE,
    user VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL
);


# Parte 2: CREACION DE OTROS OBJETOS DE LA BASE DE DATOS

-- VISTAS
-- Vista USUARIO_COMPRAS (permite visualizar los usuarios y sus compras: compras particulares)
CREATE VIEW usuario_compras AS
	SELECT u.id_user, u.username, u.first_name, u.last_name, c.id_purchase, f.title, c.date_of_purchase, c.quantity, c.subtotal
    FROM usuario u
    JOIN compra c ON u.id_user = c.id_user
    JOIN publicacion p ON c.id_publication = p.id_publication
    JOIN ficha_libro f ON p.book = f.id_book;
;

-- Vista INFO_LIBRO (permite visualizar los libros y su informacion de publicacion)
CREATE VIEW info_libro AS
	SELECT f.id_book, f.title, f.sku, f.book_description, GROUP_CONCAT(g.genre) AS genres, GROUP_CONCAT(a.author) AS authors, e.publisher
		FROM ficha_libro f
		JOIN libro_editorial e ON f.publisher = e.id_publisher
		LEFT JOIN libro_genero_relacion gr ON f.id_book = gr.id_libro
		LEFT JOIN libro_genero g ON gr.id_genero = g.id_genre
		LEFT JOIN libro_autor_relacion ar ON f.id_book = ar.id_libro
		LEFT JOIN libro_autor a ON ar.id_autor = a.id_author
		GROUP BY f.id_book;
    
-- Vista PUBLICACION_MENSAJES (permite visualizar todos los mensajes de cada publicacion)
CREATE VIEW publicacion_mensaje AS
	SELECT p.id_publication, u.id_user, u.first_name, m.content, m.date_of_message, m.reply
    FROM publicacion p
    JOIN mensaje m ON p.id_publication = m.id_publication
    JOIN usuario u ON m.id_user = u.id_user;
    
-- Vista USUARIO_COMPRAS_TOTALES (permite visualizar EL TOTAL de las compras realizadas por usuario: precio total)
CREATE VIEW usuario_compras_totales AS
	SELECT u.id_user, u.username, u.first_name, u.last_name, SUM(c.subtotal) AS total_sales
    FROM usuario u
    JOIN compra c ON u.id_user = c.id_user
    GROUP BY u.username;
    
-- Vista USUARIO_CANTIDAD_COMPRAS (permite visualizar la cantidad de compras realizadas por un usuario: cantidad de compras)
CREATE VIEW usuario_cantidad_compras AS
	SELECT u.id_user, u.username, u.email, COUNT(c.id_purchase) AS purchase_count
	FROM usuario u
	LEFT JOIN compra c ON u.id_user = c.id_user
	GROUP BY u.id_user;
    
    
-- FUNCIONES
-- Funcion STOCK_GENERO (permite calcular la cantidad total de libros en stock de un determinado genero)
DELIMITER $$
CREATE FUNCTION stock_genero(id_genero INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE stock_total INT;
    SELECT SUM(stock) INTO stock_total
    FROM publicacion p
    JOIN ficha_libro f ON p.book = f.id_book
    JOIN libro_genero_relacion gr ON f.id_book = gr.id_libro
    JOIN libro_genero g ON gr.id_genero = g.id_genre
    WHERE g.id_genre = id_genero;
    RETURN stock_total;
END $$
DELIMITER ;

-- Funcion PRECIO_PROMEDIO (permite calcular el promedio de precio de un libro en especifico)
DELIMITER $$
CREATE FUNCTION precio_promedio(libro_id INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE prom FLOAT;
    SELECT AVG(p.price) INTO prom
    FROM publicacion p
    WHERE p.book = libro_id;
    RETURN prom;
END $$
DELIMITER ;


-- STORED PROCEDURES
-- S.P. sp_ordenar_tabla (ordena una tabla segun un campo)
DELIMITER $$
CREATE PROCEDURE sp_ordenar_tabla(IN nombre_tabla VARCHAR(50), IN orden_campo VARCHAR(50))
BEGIN
	SET @q = CONCAT('SELECT * FROM ', nombre_tabla, ' ORDER BY ', orden_campo);
    PREPARE stmt FROM @q;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- S.P. sp_eliminar_envio_hasta_fecha (elimina todos los envios viejos de la tabla hasta la fecha ingresada)
DELIMITER $$
CREATE PROCEDURE sp_eliminar_envio_hasta_fecha(IN fecha DATETIME)
BEGIN
	IF fecha <= CURRENT_TIMESTAMP() THEN
		DELETE FROM envio
        WHERE date_of_shipping <= fecha;
    END IF;
END$$
DELIMITER ;


-- TRIGGERS
-- TR_CONTRASENA_SEGURA: este trigger sirve para generar el encriptado de la contrasena del usuario
-- al momento de insertar el registro
DELIMITER //
CREATE TRIGGER tr_contrasena_segura
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
	DECLARE encrypted_password VARCHAR(255);
    SET encrypted_password = SHA2(NEW.user_password, 256);
    SET NEW.user_password = encrypted_password;
END//
DELIMITER ;

-- TR_NUEVO_USUARIO: este trigger sirve para llevar un trackeo de los usuarios que se van registrando en
-- la pagina web.
CREATE TRIGGER tr_nuevo_usuario
AFTER INSERT ON usuario
FOR EACH ROW
INSERT INTO AUD_USUARIO
VALUES (NULL, NEW.id_user, SESSION_USER(), CURRENT_TIMESTAMP());

-- TR_VALIDACIONES_PUBLICACION: este trigger sirve para realizar validaciones adicionales al momento de insertar
-- una publicacion, tales como control de cantidad de stock y de precios
DELIMITER //
CREATE TRIGGER tr_validaciones_publicacion
BEFORE INSERT ON publicacion
FOR EACH ROW
BEGIN
	IF NEW.stock <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El stock no puede ser un valor negativo o cero';
    END IF;
    IF NEW.price <= 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El precio no puede ser un valor negativo o cero';
    END IF;
END//
DELIMITER ;

-- TR_NUEVA_PUBLICACION: este trigger sirve para llevar un trackeo de las publicaciones nuevas en la pagina web
CREATE TRIGGER tr_nueva_publicacion
AFTER INSERT ON publicacion
FOR EACH ROW
INSERT INTO AUD_PUBLICACION
VALUES(NULL, NEW.id_publication, SESSION_USER(), CURRENT_TIMESTAMP());


# Parte 3: INSERCION DE DATOS

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