CREATE DATABASE Univia;
GO

USE Univia;
GO


-- TABLA: Pais

CREATE TABLE Pais (
    id_pais INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL
);



-- TABLA: Ciudad
 
CREATE TABLE Ciudad (
    id_ciudad INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL,
    id_pais INT NOT NULL,
    CONSTRAINT FK_Ciudad_Pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
);


-- TABLA: Universidad
 
CREATE TABLE Universidad (
    id_universidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL,
    facultad NVARCHAR(200),
    id_pais INT NOT NULL,
    CONSTRAINT FK_Universidad_Pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais)
);


-- TABLA: Carrera
 
CREATE TABLE Carrera (
    id_carrera INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL,
    id_universidad INT NOT NULL,
    CONSTRAINT FK_Carrera_Universidad FOREIGN KEY (id_universidad) REFERENCES Universidad(id_universidad)
);


-- TABLA: Rol
 
CREATE TABLE Rol (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol NVARCHAR(200) NOT NULL
);


-- TABLA: Usuario
 
CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    correo NVARCHAR(200) NOT NULL,
    contrasena NVARCHAR(200) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    activo BIT NOT NULL DEFAULT 1,
    id_rol INT NOT NULL,
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (id_rol) REFERENCES Rol(id_rol),
    CONSTRAINT UQ_Usuario_correo UNIQUE (correo)
);


-- TABLA: Perfil
 
CREATE TABLE Perfil (
    id_perfil INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    reputacion DECIMAL(5,2) DEFAULT 0,
    id_usuario INT NOT NULL,
    id_carrera INT NOT NULL,
    CONSTRAINT FK_Perfil_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT UQ_Perfil_usuario UNIQUE (id_usuario),
    CONSTRAINT FK_Perfil_Carrera FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera)
);


-- TABLA: Material
 
CREATE TABLE Material (
    id_material INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(150) NOT NULL,
    descripcion NVARCHAR(500),
    tipo_archivo NVARCHAR(50),
    formato NVARCHAR(50),
    fecha_subida DATETIME DEFAULT GETDATE(),
    acceso NVARCHAR(50),
    estado NVARCHAR(50),
    id_usuario INT NOT NULL,
    id_carrera INT NOT NULL,
    CONSTRAINT FK_Material_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Material_Carrera FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera)
);


-- TABLA: Descarga
 
CREATE TABLE Descarga (
    id_descarga INT IDENTITY(1,1) PRIMARY KEY,
    fecha_descarga DATETIME DEFAULT GETDATE(),
    id_material INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT FK_Descarga_Material FOREIGN KEY (id_material) REFERENCES Material(id_material),
    CONSTRAINT FK_Descarga_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);


-- TABLA: Valoracion
 
CREATE TABLE Valoracion (
    id_valoracion INT IDENTITY(1,1) PRIMARY KEY,
    puntuacion INT CHECK (puntuacion BETWEEN 1 AND 5),
    comentario NVARCHAR(500),
    fecha_valoracion DATETIME DEFAULT GETDATE(),
    id_material INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT FK_Valoracion_Material FOREIGN KEY (id_material) REFERENCES Material(id_material),
    CONSTRAINT FK_Valoracion_Usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT UQ_Valoracion_usuario_material UNIQUE (id_usuario, id_material)
);


-- TABLA: Mensaje
 
CREATE TABLE Mensaje (
    id_mensaje INT IDENTITY(1,1) PRIMARY KEY,
    contenido NVARCHAR(1000) NOT NULL,
    fecha_envio DATETIME DEFAULT GETDATE(),
    leido BIT DEFAULT 0,
    id_usuario_receptor INT NOT NULL,
    id_usuario_emisor INT NOT NULL,
    CONSTRAINT FK_Mensaje_Receptor FOREIGN KEY (id_usuario_receptor) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Mensaje_Emisor FOREIGN KEY (id_usuario_emisor) REFERENCES Usuario(id_usuario)
);


USE Univia;
GO

-- 1. Países

INSERT INTO Pais (nombre)
VALUES 
('Argentina'),
('Chile'),
('México');

-- 2. Ciudades

INSERT INTO Ciudad (nombre, id_pais)
VALUES
('Buenos Aires', 1),
('Santiago', 2),
('Monterrey', 3);

-- ========================
-- 3. Universidades
-- ========================
INSERT INTO Universidad (nombre, facultad, id_pais)
VALUES
('Universidad de Buenos Aires', 'Facultad de Ingeniería', 1),
('Universidad de Chile', 'Facultad de Ciencias', 2),
('Tecnológico de Monterrey', 'Facultad de Informática', 3);

-- ========================
-- 4. Carreras
-- ========================
INSERT INTO Carrera (nombre, id_universidad)
VALUES
('Ingeniería en Sistemas', 1),
('Ciencias de la Computación', 2),
('Ingeniería de Software', 3);

-- ========================
-- 5. Roles
-- ========================
INSERT INTO Rol (nombre_rol)
VALUES
('Administrador'),
('Estudiante'),
('Profesor');

-- ========================
-- 6. Usuarios
-- ========================
INSERT INTO Usuario (correo, contrasena, id_rol)
VALUES
('admin@univia.com', 'admin123', 1),
('juan@univia.com', 'pass123', 2),
('maria@univia.com', 'maria456', 3);

-- ========================
-- 7. Perfiles
-- ========================
INSERT INTO Perfil (nombre, apellido, reputacion, id_usuario, id_carrera)
VALUES
('Admin', 'General', 5.00, 1, 1),
('Juan', 'Pérez', 3.75, 2, 1),
('María', 'Gómez', 4.20, 3, 3);

-- ========================
-- 8. Materiales
-- ========================
INSERT INTO Material (titulo, descripcion, tipo_archivo, formato, acceso, estado, id_usuario, id_carrera)
VALUES
('Apuntes de Programación', 'Notas de clase sobre estructuras de datos', 'Documento', 'PDF', 'Público', 'Activo', 2, 1),
('Guía de SQL', 'Material de consulta sobre bases de datos', 'Documento', 'DOCX', 'Privado', 'Activo', 3, 3);

-- ========================
-- 9. Descargas
-- ========================
INSERT INTO Descarga (id_material, id_usuario)
VALUES
(1, 3),
(2, 2);

-- ========================
-- 10. Valoraciones
-- ========================
INSERT INTO Valoracion (puntuacion, comentario, id_material, id_usuario)
VALUES
(5, 'Excelente material, muy claro', 1, 3),
(4, 'Buen contenido, pero algo largo', 2, 2);

-- ========================
-- 11. Mensajes
-- ========================
INSERT INTO Mensaje (contenido, id_usuario_receptor, id_usuario_emisor)
VALUES
('Hola Juan, ¿subiste el nuevo material?', 2, 3),
('Sí, ya lo publiqué. Revisión pendiente.', 3, 2);

select* from Mensaje;