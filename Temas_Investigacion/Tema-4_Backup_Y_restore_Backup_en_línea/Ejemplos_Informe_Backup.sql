/*
===================================================================
SCRIPT DE EJEMPLOS - INFORME BACKUP Y RESTORE (Base de Datos Univia)
===================================================================
*/

-- ---
-- 3.1 Preparación del Entorno
-- ---

-- Creación de la base de datos
CREATE DATABASE Univia;
GO
USE Univia;
GO

/*
-- [Aquí irían todos los CREATE TABLE del modelo de datos]
-- ... (Omitidos para este script de backup, pero necesarios para ejecutar los INSERT)
-- Asumimos que las tablas ya existen
*/


-- Inserción de datos de referencia (FKs)
-- (Necesarios para que los INSERT en 'Material' funcionen)
/*
INSERT INTO Pais (nombre) VALUES ('Argentina');
GO
INSERT INTO Universidad (nombre, facultad, id_pais) 
VALUES ('Universidad Nacional del Nordeste', 'Facultad de Ingeniería', 1);
GO
INSERT INTO Carrera (nombre, id_universidad) 
VALUES ('Ingeniería en Informática', 1);
GO
INSERT INTO Rol (nombre_rol) VALUES ('Estudiante');
GO
INSERT INTO Usuario (correo, contrasena, id_rol) 
VALUES ('estudiante.prueba@univia.com', 'pass123', 1);
GO
*/
-- Con esto, asumimos que id_carrera = 1 y id_usuario = 1 existen.


-- ---
-- 3.2 Tarea 1: Verificar y Establecer Modelo de Recuperación
-- ---

-- 1. Verificar el modelo actual
SELECT name, recovery_model_desc 
FROM sys.databases 
WHERE name = 'Univia';
GO

-- 2. Establecer el modelo a FULL (si no lo estuviera)
ALTER DATABASE Univia SET RECOVERY FULL;
GO


-- ---
-- 3.3 Tarea 2: Realizar un Backup Full
-- ---

/* NOTA: La ruta 'C:\Backups\' debe existir en el servidor */
BACKUP DATABASE Univia
TO DISK = 'C:\Backups\Univia_Full.bak'
WITH NAME = 'Univia - Backup Full Inicial',
     DESCRIPTION = 'Base para la cadena de logs';
GO


-- ---
-- 3.4 Tarea 3: Generar 10 Inserts (Lote 1)
-- ---

USE Univia;
GO
-- Insertamos el primer lote de 10 materiales
INSERT INTO Material (titulo, descripcion, tipo_archivo, formato, acceso, estado, id_usuario, id_carrera)
VALUES
('Apuntes S.O.', 'Resumen U1', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Parcial Algebra', 'Resuelto 2022', 'IMG', '.jpg', 'Publico', 'Aprobado', 1, 1),
('Guia TPs Redes', 'Ejercicios prácticos', 'DOCX', '.docx', 'Publico', 'Aprobado', 1, 1),
('Resumen BDD', 'Modelo Relacional', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Final Paradigmas', 'Preguntas y Respuestas', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Intro a IA', 'Capítulo 1 Libro', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Ejemplo UML', 'Diagrama de Clases', 'IMG', '.png', 'Publico', 'Aprobado', 1, 1),
('Tutorial Git', 'Comandos básicos', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Template Tesis', 'Formato APA', 'DOCX', '.docx', 'Publico', 'Aprobado', 1, 1),
('Video Fisica 1', 'Link a clase MRU', 'Link', '.url', 'Publico', 'Aprobado', 1, 1);
GO


-- ---
-- 3.5 Tarea 4: Primer Backup del Archivo de Log (Log 1)
-- ---

BACKUP LOG Univia
TO DISK = 'C:\Backups\Univia_Log1.trn'
WITH NAME = 'Univia - Log 1 (Post Lote 1)';
GO


-- ---
-- 3.6 Tarea 5: Generar otros 10 Inserts (Lote 2)
-- ---

USE Univia;
GO
-- Insertamos el segundo lote de 10 materiales
INSERT INTO Material (titulo, descripcion, tipo_archivo, formato, acceso, estado, id_usuario, id_carrera)
VALUES
('Guia S.O. U2', 'Administración de Procesos', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Modelo ER', 'Diagrama BD Restaurante', 'IMG', '.png', 'Publico', 'Aprobado', 1, 1),
('Taller Python', 'Ejercicios POO', 'ZIP', '.zip', 'Publico', 'Aprobado', 1, 1),
('Audio Ingles', 'Listening Practice B2', 'MP3', '.mp3', 'Publico', 'Aprobado', 1, 1),
('Parcial Calculo II', 'Resuelto 2023', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Resumen Arqui', 'Modelo Von Neumann', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Presentacion Redes', 'Modelo OSI vs TCP/IP', 'PPTX', '.pptx', 'Publico', 'Aprobado', 1, 1),
('Libro Estadistica', 'Probabilidad y Muestreo', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Final Ing. Software', 'Metodologías Ágiles', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Plan de Negocios', 'Template Emprendimiento', 'DOCX', '.docx', 'Publico', 'Aprobado', 1, 1);
GO


-- ---
-- 3.7 Tarea 6: Segundo Backup del Archivo de Log (Log 2)
-- ---

BACKUP LOG Univia
TO DISK = 'C:\Backups\Univia_Log2.trn'
WITH NAME = 'Univia - Log 2 (Post Lote 2)';
GO


-- ---
-- 4.1 Tarea 7: Restaurar al Momento del Primer Backup de Log
-- ---

/*
-- !! IMPORTANTE !!
-- Los comandos RESTORE no pueden ejecutarse sobre la base de datos
-- que estás intentando restaurar. Debes ejecutarlos desde 'master'.
-- Además, la base de datos 'Univia' debe estar sin conexiones activas.
-- Por eso, restauramos en una NUEVA base de datos 'Univia_Restaurada'.
*/

USE master;
GO
-- Paso 1: Restaurar el Full sin recuperación
RESTORE DATABASE Univia_Restaurada
FROM DISK = 'C:\Backups\Univia_Full.bak'
WITH NORECOVERY,
MOVE 'Univia' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest.mdf',
MOVE 'Univia_log' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest.ldf';
GO

-- Paso 2: Aplicar el Log 1 y poner la DB en línea
RESTORE LOG Univia_Restaurada
FROM DISK = 'C:\Backups\Univia_Log1.trn'
WITH RECOVERY;
GO


-- ---
-- 4.2 Tarea 8: Verificación del Resultado (Escenario 1)
-- ---

USE Univia_Restaurada;
GO
SELECT COUNT(*) AS TotalMateriales FROM Material;
GO
-- El resultado esperado es 10


-- ---
-- 4.3 Tarea 9: Restaurar Aplicando Ambos Archivos de Log
-- ---

/*
-- (Se asume que se borró 'Univia_Restaurada' o se usa un nombre nuevo
-- para este segundo escenario de prueba)
*/
USE master;
GO

-- Paso 1: Restaurar el Full (NORECOVERY)
RESTORE DATABASE Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Full.bak'
WITH NORECOVERY,
MOVE 'Univia' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest_Full.mdf',
MOVE 'Univia_log' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest_Full.ldf';
GO

-- Paso 2: Aplicar el Log 1 (NORECOVERY)
RESTORE LOG Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Log1.trn'
WITH NORECOVERY;
GO

-- Paso 3: Aplicar el Log 2 (RECOVERY)
RESTORE LOG Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Log2.trn'
WITH RECOVERY;
GO


-- ---
-- 4.4 Verificación (Escenario 2)
-- ---

USE Univia_Restaurada_Completa;
GO
SELECT COUNT(*) AS TotalMateriales FROM Material;
GO
-- El resultado esperado es 20