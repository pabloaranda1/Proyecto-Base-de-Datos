# UNIVERSIDAD NACIONAL DEL NORDESTE  
## BASES DE DATOS I – PROYECTO DE ESTUDIO 

### Tema 3: Optimización de consultas a través de índices   
**Grupo:** 41

**Año:** 2025  

## 1. Introducción
En SQL Server, un índice es una estructura auxiliar que el motor de la base de datos utiliza para localizar registros de forma más rápida, evitando recorrer 
toda la tabla. Esto reduce significativamente los tiempos de respuesta, especialmente en consultas con filtros, búsquedas por rangos o grandes volúmenes 
de datos. De esta manera, la optimización de consultas a través de índices se convierte en una técnica fundamental en los sistemas de bases de datos 
relacionales para mejorar el rendimiento y la eficiencia en el acceso a la información.


### 2. Tipos de índices
Algunos tipos de inices que exiten en SQL Server son:
1. Índice Agrupado (Clustered Index)

El índice agrupado define el orden físico en el que se almacenan las filas de una tabla.
Básicamente, la tabla se guarda directamente ordenada según la columna del índice.
Esto permite que las búsquedas por rangos (por ejemplo, por fechas) sean mucho más rápidas.
SQL Server solo permite un índice agrupado por tabla. En mi caso, lo utilicé sobre una columna de tipo fecha para analizar cómo cambia el rendimiento en una tabla grande.

2. Índice No Agrupado (Nonclustered Index)

Un índice no agrupado es una estructura separada que contiene la clave indexada y un puntero a los datos reales.
A diferencia del agrupado, no modifica el orden físico de la tabla.
Sirve para acelerar consultas que filtran por columnas específicas, como búsquedas por título, materia, usuario, etc.
En mi proyecto sería útil, por ejemplo, para las búsquedas de apuntes dentro de UNIVIA.

3. Índice Único (Unique Index)

Este tipo de índice garantiza que una columna no tenga valores duplicados.
SQL Server lo utiliza mucho para claves naturales como correos electrónicos o nombres de usuario.
Además de reforzar la integridad de los datos, hace más rápidas las búsquedas porque el motor sabe que cada valor aparece como máximo una vez.

4. Índice Filtrado (Filtered Index)

El índice filtrado es una variante del índice no agrupado, pero aplicado solo a un subconjunto de filas utilizando una condición WHERE.
Es ideal cuando siempre se consulta el mismo subconjunto de datos, como apuntes “publicados” o usuarios “activos”.
Estos índices ocupan menos espacio y su mantenimiento es menor que el de un índice completo.

5. Índice No Agrupado con Columnas Incluidas (INDEX WITH INCLUDE)

Este índice agrega columnas adicionales solo para lectura, convirtiéndose en un índice cubriente.
La ventaja es que SQL Server no necesita ir a la tabla a buscar los datos faltantes (evita los “key lookups”).
Lo usé en la parte práctica para comparar el rendimiento de la consulta cuando la información necesaria está completamente dentro del índice.

6. Índice Columnstore

El índice Columnstore almacena los datos por columnas en lugar de por filas, logrando una gran compresión y un rendimiento excelente para consultas analíticas y de lectura intensiva.
Se usa mucho en escenarios de almacenamiento de datos o reportes.
Aunque no lo implementé en mi tabla masiva, lo incluyo porque representa un tipo de índice moderno y muy utilizado en sistemas donde se manejan grandes volúmenes de información.

## 3. Creación de inidices en SQL Server:

Para crear índices en SQL Server se utiliza el comando `CREATE INDEX`.  
Cada tipo de índice tiene una sintaxis particular y sirve para situaciones diferentes.  
A continuación incluyo ejemplos que podrian utilizarse en nuestro proyecto UNIVIA.

### **3.1 Índice agrupado**
Ordena los datos físicamente. Ideal para búsquedas por rango de fechas.

```sql
CREATE CLUSTERED INDEX idx_fecha
ON VentaMasiva(fecha);

### **3.2 Índice no agrupado**
Crea una estructura aparte para acelerar búsquedas específicas.

```sql
CREATE NONCLUSTERED INDEX idx_titulo
ON Apunte(titulo);

### **3.3 Índice único**
Garantiza que no existan valores repetidos.

```sql
CREATE UNIQUE INDEX idx_usuario_email
ON Usuario(email);

### **3.4 Índice filtrado*
Apunta solo a un subconjunto de datos.

```sql
CREATE NONCLUSTERED INDEX idx_publicados
ON Apunte(materia_id)
WHERE estado = 'Publicado';

### **3.5 Índice con columnas incluidas**
Evita tener que acceder a la tabla para columnas adicionales.

```sql
CREATE NONCLUSTERED INDEX idx_fecha_total
ON VentaMasiva(fecha)
INCLUDE (total);

## **3.6 Índice Columnstore**
Pensado para análisis y tablas muy grandes.

```sql
CREATE CLUSTERED COLUMNSTORE INDEX idx_colstore
ON VentaMasiva;


### 4. Comparación de rendimientos con y sin índices

Para analizar el impacto real de los índices en el rendimiento, utilicé una tabla llamada **MaterialPrueba**, que es la copia de la tabla "Material" 
de nuestro proyecto, pero para no dañar nuestra estructura ni sobrecargar cn datos, decidi crear una tabla de ejemplo, cargada con aproximadamente un millón de registros.  
Esta tabla contiene cuatro columnas: `id_material`, `titulo`, `fecha_subida` y `total_descargas`.
-- Creamos la tabla de prueba:
```sql
CREATE TABLE MaterialPrueba (
    id_material INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(150) NOT NULL,
    fecha_subida DATE NOT NULL,
    total_descargas INT DEFAULT 0
);


-- Cargamos un millon de registros. 7
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

A continuación se presentan tres escenarios distintos y la comparación de sus tiempos de ejecución.

## 4.1 ** Consulta sin índices**
```sql
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';

Tiempo de ejecución: ms


### 5. Analisis de resultados
Mi analisis de resultados

### 6. Conclusiones
mi conclusion


