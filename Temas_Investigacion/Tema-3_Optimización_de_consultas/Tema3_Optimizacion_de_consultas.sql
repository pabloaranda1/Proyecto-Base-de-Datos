/* # PROYECTO UNIVIA – Optimización de consultas con índices
### A continuación se muestran los scripts utilizados para crear la tabla y generar un millón de filas:
 Este archivo contiene:
   1. Creación de tabla de prueba MaterialPrueba
   2. Inserción de 1.000.000 registros
   3. Consultas sin índice (baseline)
   4. Creación y prueba de índice no agrupado
   5. Creación y prueba de índice INCLUDE (índice cubriente) 
*/

/*
## 1. Creación de la tabla de prueba
Esta tabla es una copia simplificada de la tabla "Material" de nuestro
proyecto UNIVIA, y se utilizará exclusivamente para pruebas
de rendimiento con distintos tipos de índices.
*/
-- Creamos la tabla de prueba:
CREATE TABLE MaterialPrueba (
    id_material INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(150) NOT NULL,
    fecha_subida DATE NOT NULL,
    total_descargas INT DEFAULT 0
);

/*
## 2. Inserción Masiva de 1.000.000 de registros
Usamos ROW_NUMBER con sys.all_objects para generar un millón de filas sin necesidad de bucles WHILE.
Para fecha_subida creamos fechas aleatorias dentro de los últimos 1500 días
Para total_descargas creamos valores aleatorios entre 0 y 500
*/
-- Insertamos un millon de registros
WITH numeros AS (
   SELECT TOP (1000000)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
   FROM sys.all_objects a
   CROSS JOIN sys.all_objects b
)
INSERT INTO MaterialPrueba (titulo, fecha_subida, total_descargas)
SELECT 
   CONCAT('Apunte ', n),                                        --Genera nombres unicos
   DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1500, GETDATE()),     --Genera fecha aleatoria
   ABS(CHECKSUM(NEWID())) % 500                                 --Genera descargas aleatorias
FROM numeros;

/*
## 3. Consulta sin índices
Utilizaremos esta consulta para medir el rendimiento antes de agregar indices.
*/
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';
GO

/*
## 4. Índice no agrupado en fecha_subida
Este índice permite localizar las filas sin escanear toda la tabla,
aunque puede generar Key Lookups si en el SELECT se incluyen
columnas que no están en el índice.
*/
CREATE NONCLUSTERED INDEX idx_matprueba_fecha
ON MaterialPrueba(fecha_subida);
GO

-- Consultar nuevamente con el índice aplicado
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';
GO

/*
## 5. Índice INCLUDE (índice cubriente)
Incluye columnas adicionales dentro del índice, lo que elimina
los Key Lookups y hace la consulta aún más eficiente.
*/
    
-- Crear índice INCLUDE
CREATE NONCLUSTERED INDEX idx_matprueba_fecha_inc
ON MaterialPrueba(fecha_subida)
INCLUDE (titulo, total_descargas);
GO

-- Consultar nuevamente con índice cubriente
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';
GO


/*

*/

--Crear índice 
CREATE
ON



/* =============================================================
   6. LIMPIEZA OPCIONAL (si se desea repetir las pruebas)
   -------------------------------------------------------------
   DROP INDEX idx_matprueba_fecha ON MaterialPrueba;
   DROP INDEX idx_matprueba_fecha_inc ON MaterialPrueba;
   ============================================================= */
