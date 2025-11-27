

-- 1. LIMPIEZA DEL ENTORNO DE PRUEBA
USE master;
GO

IF DB_ID('Univia') IS NOT NULL
BEGIN
    ALTER DATABASE Univia SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Univia;
END

IF DB_ID('Univia_Restaurada') IS NOT NULL
BEGIN
    ALTER DATABASE Univia_Restaurada SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Univia_Restaurada;
END

IF DB_ID('Univia_Restaurada_Completa') IS NOT NULL
BEGIN
    ALTER DATABASE Univia_Restaurada_Completa SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Univia_Restaurada_Completa;
END
GO

-- 2. CREACIÓN DE BASE DE DATOS Y TABLAS

CREATE DATABASE Univia;
GO
USE Univia;
GO

CREATE TABLE Rol ( 
id_rol INT IDENTITY(1,1) PRIMARY KEY,
nombre_rol VARCHAR(50) NOT NULL 
);
go
CREATE TABLE Universidad ( 
id_universidad INT IDENTITY(1,1) PRIMARY KEY, 
nombre VARCHAR(100) NOT NULL );
go
CREATE TABLE Carrera ( 
id_carrera INT IDENTITY(1,1) PRIMARY KEY, 
nombre VARCHAR(100) NOT NULL 
);
go
CREATE TABLE Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY, 
    nombre VARCHAR(100) NOT NULL, 
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    fecha_registro DATETIME DEFAULT GETDATE(),
    estado BIT DEFAULT 1, id_rol INT NOT NULL, 
    CONSTRAINT FK_Rol_Usuario FOREIGN KEY (id_rol) REFERENCES Rol(id_rol)
);
go
CREATE TABLE Perfil (
    id_usuario INT PRIMARY KEY,
    bio VARCHAR(500),
    reputacion INT DEFAULT 0, 
    id_universidad INT,
    CONSTRAINT FK_Usuario_Perfil FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Universidad_Perfil FOREIGN KEY (id_universidad) REFERENCES Universidad(id_universidad)
);
go
CREATE TABLE Carrera_Usuario (
    id_usuario INT NOT NULL,
    id_carrera INT NOT NULL,
    CONSTRAINT PK_Carrera_Usuario PRIMARY KEY (id_usuario, id_carrera),
    CONSTRAINT FK_Usuario_CarreraUsuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    CONSTRAINT FK_Carrera_CarreraUsuario FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera)
);
go
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
go
CREATE TABLE Publicacion_Carrera (
    id_carrera INT NOT NULL,
    id_publicacion INT NOT NULL, 
    CONSTRAINT PK_Carrera_Publicacion PRIMARY KEY (id_carrera, id_publicacion),
    CONSTRAINT FK_Carrera_PublicacionCarrera FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera),
    CONSTRAINT FK_Publicacion_Publicacion_Carrera FOREIGN KEY (id_publicacion) REFERENCES Publicacion(id_publicacion)
);
go
CREATE TABLE id_archivo (
    id_archivo INT IDENTITY(1,1) PRIMARY KEY, 
    nombre VARCHAR(200), 
    ruta VARCHAR(300) NOT NULL, 
    tipo VARCHAR(50),
    id_publicacion INT NOT NULL,
    CONSTRAINT FK_Publicacion_Archivo FOREIGN KEY (id_publicacion) REFERENCES Publicacion(id_publicacion)
);
go
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
go
CREATE TABLE Conversacion ( 
id_conversacion INT IDENTITY(1,1) PRIMARY KEY, 
fecha_creacion DATETIME DEFAULT GETDATE() 
);
go
CREATE TABLE Conversacion_Usuario (
    id_conversacion INT NOT NULL, 
    id_usuario INT NOT NULL, 
    CONSTRAINT PK_ConversacionUsuario PRIMARY KEY (id_conversacion, id_usuario),
    CONSTRAINT FK_Conversacion_ConversacionUsuario FOREIGN KEY (id_conversacion) REFERENCES Conversacion(id_conversacion),
    CONSTRAINT FK__Usuario_ConversacionUsuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);
go
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
go
CREATE TABLE Archivo_Mensaje (
    id_mensaje INT NOT NULL, id_archivo INT NOT NULL, 
    CONSTRAINT PK_ArchivoMensaje PRIMARY KEY (id_mensaje, id_archivo),
    CONSTRAINT FK_Mensaje_ArchivoMensaje FOREIGN KEY (id_mensaje) REFERENCES Mensaje(id_mensaje),
    CONSTRAINT FK_Archivo_ArchivoMensaje FOREIGN KEY (id_archivo) REFERENCES id_archivo(id_archivo)
);

GO

-- 3. DATOS INICIALES (PREPARACIÓN)
INSERT INTO Rol (nombre_rol) VALUES ('Estudiante');
INSERT INTO Usuario (nombre, apellido, email, contrasena, id_rol) VALUES ('Juan', 'Perez', 'juan.perez@univia.com', 'pass123', 1);
INSERT INTO Universidad (nombre) VALUES ('Universidad Nacional del Nordeste');
INSERT INTO Perfil (id_usuario, id_universidad) VALUES (1, 1);
INSERT INTO Carrera (nombre) VALUES ('Ingeniería en Informática');
INSERT INTO Carrera_Usuario (id_usuario, id_carrera) VALUES (1, 1);
GO

PRINT '>>> Base de datos creada y datos semilla insertados.';
GO

-- 4. CONFIGURAR MODELO FULL
ALTER DATABASE Univia SET RECOVERY FULL;
GO

-- 5. BACKUP FULL INICIAL
BACKUP DATABASE Univia
TO DISK = 'C:\Backups\Univia_Full.bak'
WITH NAME = 'Univia - Backup Full Inicial', INIT;
GO
PRINT '>>> Backup Full completado.';
GO

-- 6. GENERAR 10 INSERTS (LOTE 1) - UNO POR UNO
USE Univia;
GO

DECLARE @id_pub INT; -- Variable temporal para capturar el ID

-- Insert 1
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Apuntes S.O.', 'Resumen U1', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 2
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Parcial Algebra', 'Resuelto 2022', 'IMG', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 3
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Guia TPs Redes', 'Ejercicios prácticos', 'DOCX', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 4
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Resumen BDD', 'Modelo Relacional', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 5
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Final Paradigmas', 'Preguntas y Respuestas', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 6
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Intro a IA', 'Capítulo 1 Libro', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 7
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Ejemplo UML', 'Diagrama de Clases', 'IMG', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 8
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) values ('Tutorial Git', 'Comandos básicos', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 9
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) values ('Template Tesis', 'Formato APA', 'DOCX', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 10
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) values ('Video Fisica 1', 'Link a clase MRU', 'Link', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);
GO

PRINT '>>> Lote 1 (10 publicaciones) insertado uno por uno.';
GO

-- 7. BACKUP LOG 1
BACKUP LOG Univia
TO DISK = 'C:\Backups\Univia_Log1.trn'
WITH NAME = 'Univia - Log 1 (Post Lote 1)', INIT;
GO
PRINT '>>> Backup Log 1 completado.';
GO



-- 8. GENERAR 10 INSERTS (LOTE 2) - UNO POR UNO
USE Univia;
GO
DECLARE @id_pub INT; 

-- Insert 11
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Guia S.O. U2', 'Administración de Procesos', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 12
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Modelo ER', 'Diagrama BD Restaurante', 'IMG', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 13
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Taller Python', 'Ejercicios POO', 'ZIP', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 14
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Audio Ingles', 'Listening Practice B2', 'MP3', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 15
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Parcial Calculo II', 'Resuelto 2023', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 16
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Resumen Arqui', 'Modelo Von Neumann', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 17
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Presentacion Redes', 'Modelo OSI vs TCP/IP', 'PPTX', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 18
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Libro Estadistica', 'Probabilidad y Muestreo', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 19
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Final Ing. Software', 'Metodologías Ágiles', 'PDF', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);

-- Insert 20
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Plan de Negocios', 'Template Emprendimiento', 'DOCX', 'Publico', 1);
SET @id_pub = SCOPE_IDENTITY();
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @id_pub);
GO

PRINT '>>> Lote 2 (10 publicaciones) insertado uno por uno.';
GO

-- 9. BACKUP LOG 2
BACKUP LOG Univia
TO DISK = 'C:\Backups\Univia_Log2.trn'
WITH NAME = 'Univia - Log 2 (Post Lote 2)', INIT;
GO
PRINT '>>> Backup Log 2 completado.';
GO


-- PRUEBAS DE RESTAURACIÓN


USE master;
GO

-- ESCENARIO 1: RESTAURAR SÓLO HASTA EL LOG 1 (10 ITEMS)
PRINT '>>> Iniciando Restauración Escenario 1';

RESTORE DATABASE Univia_Restaurada
FROM DISK = 'C:\Backups\Univia_Full.bak'
WITH NORECOVERY,
MOVE 'Univia' TO 'C:\Backups\Univia_Rest.mdf',     
MOVE 'Univia_log' TO 'C:\Backups\Univia_Rest.ldf', 
REPLACE;

RESTORE LOG Univia_Restaurada
FROM DISK = 'C:\Backups\Univia_Log1.trn'
WITH RECOVERY;
GO

-- ESCENARIO 2: RESTAURAR COMPLETO (20 ITEMS)
PRINT '>>> Iniciando Restauración Escenario 2';

RESTORE DATABASE Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Full.bak'
WITH NORECOVERY,
MOVE 'Univia' TO 'C:\Backups\Univia_Rest_Full.mdf',
MOVE 'Univia_log' TO 'C:\Backups\Univia_Rest_Full.ldf',
REPLACE;

RESTORE LOG Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Log1.trn'
WITH NORECOVERY;

RESTORE LOG Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Log2.trn'
WITH RECOVERY;
GO


-- VERIFICACIÓN FINAL



SELECT  COUNT(*) AS Total_Registros 
FROM Univia_Restaurada.dbo.Publicacion;

SELECT  COUNT(*) AS Total_Registros 
FROM Univia_Restaurada_Completa.dbo.Publicacion;
GO