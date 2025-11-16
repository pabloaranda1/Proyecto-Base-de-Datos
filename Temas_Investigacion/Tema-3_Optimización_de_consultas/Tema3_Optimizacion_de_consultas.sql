
A continuación se muestran los scripts utilizados para crear la tabla y generar un millón de filas:
```sql
-- Creamos la tabla de prueba:
CREATE TABLE MaterialPrueba (
    id_material INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(150) NOT NULL,
    fecha_subida DATE NOT NULL,
    total_descargas INT DEFAULT 0
);

-- Insertamos un millon de registros
WITH numeros AS (
   SELECT TOP (1000000)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
   FROM sys.all_objects a
   CROSS JOIN sys.all_objects b
)
INSERT INTO MaterialPrueba (titulo, fecha_subida, total_descargas)
SELECT 
   CONCAT('Apunte ', n),
   DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1500, GETDATE()),
   ABS(CHECKSUM(NEWID())) % 500
FROM numeros;
```
