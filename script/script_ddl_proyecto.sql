CREATE DATABASE Univia;
GO

USE Univia;
GO


CREATE TABLE Rol (
    id_rol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL
);

CREATE TABLE Universidad (
    id_universidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Carrera (
    id_carrera INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    estado BIT DEFAULT 1,
    id_rol INT NOT NULL,
    CONSTRAINT FK_Rol_Usuario FOREIGN KEY (id_rol) REFERENCES Rol(id_rol)
);

CREATE TABLE Perfil (
    id_usuario INT PRIMARY KEY,
    bio VARCHAR(500),
    reputacion INT DEFAULT 0,
    id_universidad INT,
    CONSTRAINT FK_Usuario_Perfil FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Universidad_Perfil FOREIGN KEY (id_universidad) REFERENCES Universidad(id_universidad)
);

CREATE TABLE Carrera_Usuario (
    id_usuario INT NOT NULL,
    id_carrera INT NOT NULL,
    CONSTRAINT PK_Carrera_Usuario PRIMARY KEY (id_usuario, id_carrera),
    CONSTRAINT FK_Usuario_CarreraUsuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Carrera_CarreraUsuario FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera)
);

CREATE TABLE Publicacion (
    id_publicacion INT IDENTITY(1,1) PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion VARCHAR(800),
    tipo_recurso VARCHAR(50),
    tipo_acceso VARCHAR(50),
    descargable BIT DEFAULT 0,
    precio DECIMAL(10,2),
    fecha_publicacion DATETIME DEFAULT GETDATE(),
    estado BIT DEFAULT 1,
    id_usuario INT NOT NULL,
    CONSTRAINT FK_Usuario_Publicacion FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Publicacion_Carrera (
    id_carrera INT NOT NULL,
    id_publicacion INT NOT NULL,
    CONSTRAINT PK_Carrera_Publicacion PRIMARY KEY (id_carrera, id_publicacion),
    CONSTRAINT FK_Carrera_PublicacionCarrera FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera),
    CONSTRAINT FK_Publicacion_Publicacion_Carrera FOREIGN KEY (id_publicacion) REFERENCES Publicacion(id_publicacion)
);

CREATE TABLE id_archivo (
    id_archivo INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(200),
    ruta VARCHAR(300) NOT NULL,
    tipo VARCHAR(50),
    id_publicacion INT NOT NULL,
    CONSTRAINT FK_Publicacion_Archivo FOREIGN KEY (id_publicacion) REFERENCES Publicacion(id_publicacion)
);

CREATE TABLE Valoracion (
    id_publicacion INT NOT NULL,
    id_usuario INT NOT NULL,
    puntuacion INT CHECK(puntuacion BETWEEN 1 AND 5),
    comentario VARCHAR(500),
    fecha DATETIME DEFAULT GETDATE(),
    CONSTRAINT PK_Valoracion PRIMARY KEY (id_publicacion, id_usuario),
    CONSTRAINT FK_Publicacion_Valoracion FOREIGN KEY (id_publicacion) REFERENCES Publicacion(id_publicacion),
    CONSTRAINT FK_Usuario_Valoracion FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

----------------------------------------
-- SISTEMA DE MENSAJERÍA (INBOX)
----------------------------------------

CREATE TABLE Conversacion (
    id_conversacion INT IDENTITY(1,1) PRIMARY KEY,
    fecha_creacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Conversacion_Usuario (
    id_conversacion INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT PK_ConversacionUsuario PRIMARY KEY (id_conversacion, id_usuario),
    CONSTRAINT FK_Conversacion_ConversacionUsuario FOREIGN KEY (id_conversacion) REFERENCES Conversacion(id_conversacion),
    CONSTRAINT FK__Usuario_ConversacionUsuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Mensaje (
    id_mensaje INT IDENTITY(1,1) PRIMARY KEY,
    contenido VARCHAR(MAX),
    fecha_envio DATETIME DEFAULT GETDATE(),
    leido BIT DEFAULT 0,
    id_conversacion INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT FK_Conversacion_Mensaje FOREIGN KEY (id_conversacion) REFERENCES Conversacion(id_conversacion),
    CONSTRAINT FK_Usuario_Mensaje FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Archivo_Mensaje (
    id_mensaje INT NOT NULL,
    id_archivo INT NOT NULL,
    CONSTRAINT PK_ArchivoMensaje PRIMARY KEY (id_mensaje, id_archivo),
    CONSTRAINT FK_Mensaje_ArchivoMensaje FOREIGN KEY (id_mensaje) REFERENCES Mensaje(id_mensaje),
    CONSTRAINT FK_Archivo_ArchivoMensaje FOREIGN KEY (id_archivo) REFERENCES id_archivo(id_archivo)
);



