/*

SCRIPT DE PRUEBA INTEGRAL - INFORME DE BACKUP (MODELO PUBLICACION)

*/

-- 1. CONFIGURACIÓN
DECLARE @RutaBackups NVARCHAR(MAX) = 'C:\Backups\'; -- debe haber una carpeta llamada backup en el disco c para que funcione
DECLARE @RutaDatos NVARCHAR(MAX) = 'C:\Users\Diame\'; -- (Ruta de tu .mdf)
DECLARE @RutaLog NVARCHAR(MAX) = 'C:\Users\Diame\'; -- (Ruta de tu .ldf)



-- 2. LIMPIEZA DEL ENTORNO DE PRUEBA
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

-- 3. CREACIÓN DE BASE DE DATOS Y TABLAS (NUEVO MODELO

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


-- 4. TAREA 3.1: PREPARACIÓN DEL ENTORNO (INSERTS INICIALES)
USE Univia;
GO
INSERT INTO Rol (nombre_rol) VALUES ('Estudiante');
INSERT INTO Usuario (nombre, apellido, email, contrasena, id_rol) VALUES ('Juan', 'Perez', 'juan.perez@univia.com', 'pass123', 1);
INSERT INTO Universidad (nombre) VALUES ('Universidad Nacional del Nordeste');
INSERT INTO Perfil (id_usuario, id_universidad) VALUES (1, 1);
INSERT INTO Carrera (nombre) VALUES ('Ingeniería en Informática');
INSERT INTO Carrera_Usuario (id_usuario, id_carrera) VALUES (1, 1);
GO
PRINT '>>> 4. Tarea 3.1: Inserts de preparación completados (Usuario 1 y Carrera 1 listos).';
GO

-- 5. TAREA 3.2: VERIFICAR Y ESTABLECER MODELO DE RECUPERACIÓN
ALTER DATABASE Univia SET RECOVERY FULL;
GO
PRINT 'Modelo de recuperación establecido a FULL.';
GO

-- 6. TAREA 3.3: REALIZAR UN BACKUP FULL
-- FIX: Volvemos a declarar las variables de configuración para este lote
DECLARE @RutaBackups NVARCHAR(MAX) = 'C:\Backups\';
DECLARE @RutaDatos NVARCHAR(MAX) = 'C:\Users\Diame\';
DECLARE @RutaLog NVARCHAR(MAX) = 'C:\Users\Diame\';

DECLARE @RutaBackupFull NVARCHAR(MAX);
SET @RutaBackupFull = @RutaBackups + N'Univia_Full.bak'; 
BACKUP DATABASE Univia
TO DISK = @RutaBackupFull
WITH NAME = 'Univia - Backup Full Inicial';
GO
PRINT 'Backup Full completado.';
GO

-- 7. TAREA 3.4: GENERAR 10 INSERTS (LOTE 1)
USE Univia;
GO

INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Apuntes S.O.', 'Resumen U1', 'PDF', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Parcial Algebra', 'Resuelto 2022', 'IMG', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Guia TPs Redes', 'Ejercicios prácticos', 'DOCX', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Resumen BDD', 'Modelo Relacional', 'PDF', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Final Paradigmas', 'Preguntas y Respuestas', 'PDF', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Intro a IA', 'Capítulo 1 Libro', 'PDF', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Ejemplo UML', 'Diagrama de Clases', 'IMG', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) values ('Tutorial Git', 'Comandos básicos', 'PDF', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) values ('Template Tesis', 'Formato APA', 'DOCX', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) values ('Video Fisica 1', 'Link a clase MRU', 'Link', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, 6), (1, 7), (1, 8), (1, 9), (1, 10);
GO
PRINT ' Lote 1 (10 publicaciones) completado.';
GO

-- 8. TAREA 3.5: PRIMER BACKUP DEL ARCHIVO DE LOG (LOG 1)
-- FIX: Volvemos a declarar las variables de configuración para este lote
DECLARE @RutaBackups NVARCHAR(MAX) = 'C:\Backups\';
DECLARE @RutaDatos NVARCHAR(MAX) = 'C:\Users\Diame\';
DECLARE @RutaLog NVARCHAR(MAX) = 'C:\Users\Diame\';

DECLARE @RutaBackupLog1 NVARCHAR(MAX);
SET @RutaBackupLog1 = @RutaBackups + N'Univia_Log1.trn';
BACKUP LOG Univia
TO DISK = @RutaBackupLog1
WITH NAME = 'Univia - Log 1 (Post Lote 1)';
GO
PRINT '>>> 8. Tarea 3.5: Backup Log 1 completado.';
GO

-- 9. TAREA 3.6: GENERAR OTROS 10 INSERTS (LOTE 2)
USE Univia;
GO


INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Guia S.O. U2', 'Administración de Procesos', 'PDF', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Modelo ER', 'Diagrama BD Restaurante', 'IMG', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, @new_pub_id);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Taller Python', 'Ejercicios POO', 'ZIP', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Audio Ingles', 'Listening Practice B2', 'MP3', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Parcial Calculo II', 'Resuelto 2023', 'PDF', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Resumen Arqui', 'Modelo Von Neumann', 'PDF', 'Publico', 1), ('Presentacion Redes', 'Modelo OSI vs TCP/IP', 'PPTX', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Libro Estadistica', 'Probabilidad y Muestreo', 'PDF', 'Publico', 1), ('Final Ing. Software', 'Metodologías Ágiles', 'PDF', 'Publico', 1);
INSERT INTO Publicacion (titulo, descripcion, tipo_recurso, tipo_acceso, id_usuario) VALUES ('Plan de Negocios', 'Template Emprendimiento', 'DOCX', 'Publico', 1);
INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion) VALUES (1, 13), (1, 14), (1, 15), (1, 16), (1, 17), (1, 18), (1, 19), (1, 20);
GO
PRINT 'Lote 2 (10 publicaciones) completado.';
GO

-- 10. TAREA 3.7: SEGUNDO BACKUP DEL ARCHIVO DE LOG (LOG 2)
-- FIX: Volvemos a declarar las variables de configuración para este lote
DECLARE @RutaBackups NVARCHAR(MAX) = 'C:\Backups\';
DECLARE @RutaDatos NVARCHAR(MAX) = 'C:\Users\Diame\';
DECLARE @RutaLog NVARCHAR(MAX) = 'C:\Users\Diame\';

DECLARE @RutaBackupLog2 NVARCHAR(MAX);
SET @RutaBackupLog2 = @RutaBackups + N'Univia_Log2.trn'; 
BACKUP LOG Univia
TO DISK = @RutaBackupLog2
WITH NAME = 'Univia - Log 2 (Post Lote 2)';
GO
PRINT 'Backup Log 2 completado.';
GO


-- 11. TAREAS 4.1 y 4.2: PRUEBA DE RESTAURACIÓN (ESCENARIO 1: SÓLO LOTE 1)

PRINT 'Restaurar hasta Log 1 (10 publicaciones).';
USE master;
GO
-- FIX: Volvemos a declarar las variables de configuración para este lote
DECLARE @RutaBackups NVARCHAR(MAX) = 'C:\Backups\';
DECLARE @RutaDatos NVARCHAR(MAX) = 'C:\Users\Diame\';
DECLARE @RutaLog NVARCHAR(MAX) = 'C:\Users\Diame\';

-- Variables de ruta dinámicas
DECLARE @RutaBackupFull NVARCHAR(MAX) = @RutaBackups + N'Univia_Full.bak';
DECLARE @RutaBackupLog1 NVARCHAR(MAX) = @RutaBackups + N'Univia_Log1.trn';
DECLARE @RutaDatosMDF NVARCHAR(MAX) = @RutaDatos + N'Univia_Rest.mdf';
DECLARE @RutaDatosLDF NVARCHAR(MAX) = @RutaLog + N'Univia_Rest.ldf';

-- Paso 1: Restaurar el Full (NORECOVERY)
RESTORE DATABASE Univia_Restaurada
FROM DISK = @RutaBackupFull
WITH NORECOVERY,
MOVE 'Univia' TO @RutaDatosMDF,
MOVE 'Univia_log' TO @RutaDatosLDF;
GO
-- Paso 2: Aplicar el Log 1 (RECOVERY)
RESTORE LOG Univia_Restaurada
FROM DISK = N'C:\Backups\Univia_Log1.trn'
WITH RECOVERY;
GO

-- Verificación Tarea 4.2

PRINT ' RESULTADO ESCENARIO 1 (Debería ser 10):';
USE Univia_Restaurada;
GO
SELECT COUNT(*) AS TotalPublicaciones_Escenario_1 FROM Publicacion;
GO

-- 12. TAREAS 4.3 y 4.4: PRUEBA DE RESTAURACIÓN (ESCENARIO 2: LOTE 1 + LOTE 2)

PRINT ' Restaurar hasta Log 2 (20 publicaciones).';
USE master;
GO
-- Declaramos las variables para ESTE LOTE
DECLARE @RutaBackups NVARCHAR(MAX) = 'C:\Backups\';
DECLARE @RutaDatos NVARCHAR(MAX) = 'C:\Users\Diame\';
DECLARE @RutaLog NVARCHAR(MAX) = 'C:\Users\Diame\';

-- Variables de ruta dinámicas
DECLARE @RutaBackupFull NVARCHAR(MAX) = @RutaBackups + N'Univia_Full.bak';
DECLARE @RutaBackupLog1 NVARCHAR(MAX) = @RutaBackups + N'Univia_Log1.trn';
DECLARE @RutaBackupLog2 NVARCHAR(MAX) = @RutaBackups + N'Univia_Log2.trn';
DECLARE @RutaDatosMDF_C NVARCHAR(MAX) = @RutaDatos + N'Univia_Rest_Full.mdf';
DECLARE @RutaDatosLDF_C NVARCHAR(MAX) = @RutaLog + N'Univia_Rest_Full.ldf';

-- Paso 1: Restaurar el Full (NORECOVERY)
RESTORE DATABASE Univia_Restaurada_Completa
FROM DISK = @RutaBackupFull
WITH NORECOVERY,
MOVE 'Univia' TO @RutaDatosMDF_C,
MOVE 'Univia_log' TO @RutaDatosLDF_C;


-- Paso 2: Aplicar el Log 1 (NORECOVERY)
RESTORE LOG Univia_Restaurada_Completa
FROM DISK = @RutaBackupLog1
WITH NORECOVERY;


-- Paso 3: Aplicar el Log 2 (RECOVERY)
RESTORE LOG Univia_Restaurada_Completa
FROM DISK = @RutaBackupLog2
WITH RECOVERY;
GO 

-- Verificación Tarea 4.4

PRINT '>>> RESULTADO ESCENARIO 2 (Debería ser 20):';
USE Univia_Restaurada_Completa;
GO
SELECT COUNT(*) AS TotalPublicaciones_Escenario_2 FROM Publicacion;
GO