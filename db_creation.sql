CREATE SCHEMA `sases` ;

USE sases;

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
    genre INT NOT NULL,
    author INT NOT NULL,
    sku INT,  -- Numero ISBN del libro
    book_description TEXT,
    title VARCHAR(80) NOT NULL,
    CONSTRAINT fk_genre FOREIGN KEY(genre) REFERENCES libro_genero(id_genre) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_author FOREIGN KEY(author) REFERENCES libro_autor(id_author) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_publisher FOREIGN KEY(publisher) REFERENCES libro_editorial(id_publisher) ON UPDATE CASCADE ON DELETE CASCADE
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

# Parte 2: CREACION DE LOS OBJETOS DE LA BASE DE DATOS

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
	SELECT f.id_book, f.title, f.sku, f.book_description, g.genre, a.author, e.publisher
	FROM ficha_libro f
	JOIN libro_genero g ON f.genre = g.id_genre
	JOIN libro_autor a ON f.author = a.id_author
	JOIN libro_editorial e ON f.publisher = e.id_publisher;
    
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
    WHERE f.genre = id_genero;
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