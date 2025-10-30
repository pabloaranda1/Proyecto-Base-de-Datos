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
    fecha_subida DATETIME DEFAULT GETDATE()
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
