# UNIVERSIDAD NACIONAL DEL NORDESTE  
## BASES DE DATOS I – PROYECTO DE ESTUDIO 

### Tema 2: Optimización de consultas a través de índices   
**Grupo:** 41

**Año:** 2025  

## Tabla de contenidos

- [1. Introducción](#1-introducción)
- [2. Tipos de índices](#2-tipos-de-índices)
- [3. Creación de índices en SQL Server](#3-creación-de-inidices-en-sql-server)
  - [3.1 Índice agrupado](#31-índice-agrupado)
  - [3.2 Índice no agrupado](#32-índice-no-agrupado)
  - [3.3 Índice único](#33-índice-único)
  - [3.4 Índice filtrado](#34-índice-filtrado)
  - [3.5 Índice con columnas incluidas](#35-índice-con-columnas-incluidas)
  - [3.6 Índice Columnstore](#36-índice-columnstore)
- [4. Comparación de rendimientos con y sin índices](#4-comparación-de-rendimientos-con-y-sin-índices)
  - [4.1 Consulta sin índices](#41-consulta-sin-índices)
  - [4.2 Consulta con índice no agrupado](#42-consulta-con-indice-no-agrupado-en-fecha_subida)
  - [4.3 Consulta con índice include](#43-consulta-con-un--índice-include-índice-cubriente)
- [5. Análisis de resultados](#5-analisis-de-resultados)
- [6. Conclusiones](#6-conclusiones)


## 1. Introducción
En SQL Server, un índice es una estructura auxiliar que el motor de la base de datos utiliza para localizar registros de forma más rápida, evitando recorrer 
toda la tabla. Esto reduce significativamente los tiempos de respuesta, especialmente en consultas con filtros, búsquedas por rangos o grandes volúmenes 
de datos. De esta manera, la optimización de consultas a través de índices se convierte en una técnica fundamental en los sistemas de bases de datos 
relacionales para mejorar el rendimiento y la eficiencia en el acceso a la información.


## 2. Tipos de índices
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

Para crear índices en SQL Server se utiliza el comando CREATE INDEX.  
Cada tipo de índice tiene una sintaxis particular y sirve para situaciones diferentes.  
A continuación incluyo ejemplos que podrian utilizarse en nuestro proyecto UNIVIA.

### **3.1 Índice agrupado**
Ordena los datos físicamente. Ideal para búsquedas por rango de fechas.

```sql
CREATE CLUSTERED INDEX idx_fecha
ON VentaMasiva(fecha);
```
### **3.2 Índice no agrupado**
Crea una estructura aparte para acelerar búsquedas específicas.

```sql
CREATE NONCLUSTERED INDEX idx_titulo
ON Apunte(titulo);
```
### **3.3 Índice único**
Garantiza que no existan valores repetidos.

```sql
CREATE UNIQUE INDEX idx_usuario_email
ON Usuario(email);
```
### **3.4 Índice filtrado**
Apunta solo a un subconjunto de datos.

```sql
CREATE NONCLUSTERED INDEX idx_publicados
ON Apunte(materia_id)
WHERE estado = 'Publicado';
```
### **3.5 Índice con columnas incluidas**
Evita tener que acceder a la tabla para columnas adicionales.

```sql
CREATE NONCLUSTERED INDEX idx_fecha_total
ON VentaMasiva(fecha)
INCLUDE (total);
```
### **3.6 Índice Columnstore**
Pensado para análisis y tablas muy grandes.

```sql
CREATE CLUSTERED COLUMNSTORE INDEX idx_colstore
ON VentaMasiva;
```

## 4. Comparación de rendimientos con y sin índices

Para analizar el impacto real de los índices en el rendimiento de las consultas, utilicé una tabla llamada MaterialPrueba, que es una copia simplificada de la tabla Material de nuestro proyecto UNIVIA.
Decidí trabajar sobre esta tabla para evitar sobrecargar los datos reales del sistema y poder generar una carga masiva de registros sin afectar el modelo principal. 
Esta tabla contiene las siguientes columnas: `id_material` `titulo` `fecha_subida` `total_descargas`.

### **4.1 Consulta sin índices**
```sql
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';
```
Tiempo de ejecución: ms
<img width="377" height="44" alt="image" src="https://github.com/user-attachments/assets/de9fd271-0ca6-42b9-8ecb-20727eb08ed9" />

<img width="432" height="163" alt="image" src="https://github.com/user-attachments/assets/64ccbbdf-acba-4c83-bc7c-eba93a2d9c1c" />

Interpretación:
La consulta realiza un Clustered Index Scan, lo que significa que SQL Server recorre secuencialmente todas las páginas del índice agrupado (que en este caso es equivalente a recorrer toda la tabla).

En las métricas capturadas se observa:

-662 lecturas lógicas, lo que indica que SQL Server debió leer un gran número de páginas en memoria.
-Costo estimado del 100 %, que representa el plan menos eficiente.
-Tiempo de ejecución de ~171 ms, más alto debido a la necesidad de recorrer toda la estructura.

En resumen, la consulta es lenta porque no existe un índice adecuado sobre fecha_subida, obligando al motor a examinar todos los registros para encontrar los que cumplen la condición del filtro.

### **4.2 Consulta con indice NO agrupado en fecha_subida**
```sql
-- Creamos un indice no agrupado
CREATE NONCLUSTERED INDEX idx_matprueba_fecha
ON MaterialPrueba(fecha_subida);

-- hacemos la misma consulta pero ya con el indice creado:
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';
```

Tiempo de ejecución: ms
<img width="360" height="52" alt="image" src="https://github.com/user-attachments/assets/8c59d020-8384-49f1-a28b-36f4b6ca8bc8" />

<img width="675" height="295" alt="image" src="https://github.com/user-attachments/assets/b9d6ad3c-6781-4e9a-ba9d-760956df7c62" />

Interpretación:
La consulta deja de realizar un escaneo completo y pasa a usar un Index Seek, lo que permite localizar rápidamente las filas que coinciden con fecha_subida.
Sin embargo, como la consulta selecciona todas las columnas (SELECT *), SQL Server necesita obtener datos adicionales que no están dentro del índice.
Por ese motivo aparece el operador Key Lookup dentro de un Nested Loop, lo que significa que:
el índice encuentra los registros por fecha_subida,
pero debe volver a la tabla base (índice clustered de la PK) para obtener las columnas faltantes.

Esto genera un costo adicional, pero aun así:
se reducen las lecturas innecesarias,
disminuye el uso de CPU,
el tiempo de ejecución es significativamente más bajo,
el plan es mucho más eficiente que el Clustered Index Scan sin índice.

Esto demuestra por qué los índices no agrupados son ideales para acelerar búsquedas basadas en columnas del WHERE.

### **4.3 Consulta con un  índice INCLUDE (índice cubriente)**
```sql
-- Creamos un  índice INCLUDE
CREATE NONCLUSTERED INDEX idx_matprueba_fecha_inc
ON MaterialPrueba(fecha_subida)
INCLUDE (titulo, total_descargas);

-- hacemos la misma consulta pero ya con el indice creado:
SELECT *
FROM MaterialPrueba
WHERE fecha_subida = '2024-01-15';
```
Tiempo de ejecución: ms
<img width="346" height="35" alt="image" src="https://github.com/user-attachments/assets/1a046386-488f-4ccc-a652-c20e000812d7" />

<img width="449" height="145" alt="image" src="https://github.com/user-attachments/assets/f14faefe-4c57-48b8-9acd-3dc0e2c34b12" />

Interpretacion:
En este caso, el índice creado sobre fecha_subida incluye también las columnas titulo y total_descargas, lo que lo convierte en un índice cubriente.
Gracias a esto, SQL Server ya no necesita realizar Key Lookups, porque todas las columnas que requiere el SELECT están almacenadas dentro del índice.

El resultado se refleja en tu plan de ejecución:
solo aparece un Index Seek (NonClustered),
desaparece el operador de “Búsqueda de claves”,
no hay necesidad de acceder a la tabla base,
se reducen aún más las lecturas lógicas,
y el tiempo de ejecución baja notablemente (61 ms en este caso).

Este es el escenario más eficiente de los tres, y muestra claramente cómo un índice INCLUDE puede cubrir completamente la consulta, evitando operaciones adicionales y mejorando al máximo el rendimiento.

## 5. Analisis de resultados
Los resultados obtenidos muestran claramente cómo los índices impactan en el rendimiento:
Sin índice:
La consulta realiza un Table Scan, leyendo toda la tabla.
Es el método más lento, especialmente con tablas grandes.

Con índice no agrupado:
La consulta cambia a un Index Seek.
Se reduce drásticamente el número de páginas leídas.
El tiempo de ejecución mejora notablemente.

Con índice INCLUDE:
El motor ya no necesita acceder a la tabla principal.
Todos los datos están cubiertos por el índice.
Es el plan más eficiente y el más recomendado para consultas muy frecuentes.

## 6. Conclusiones
La optimización mediante índices es esencial en cualquier base de datos relacional que maneje grandes cantidades de información.
En el contexto de UNIVIA, donde los estudiantes buscan constantemente materiales académicos, la velocidad de respuesta es clave para una buena experiencia de usuario.

Los resultados muestran que:
Los índices no agrupados mejoran significativamente el rendimiento en consultas basadas en filtros específicos.
Los índices INCLUDE ofrecen una optimización superior al evitar accesos adicionales a la tabla, convirtiéndose en la mejor alternativa para consultas repetitivas.
La ausencia de índices provoca Table Scans, lo cual impacta negativamente en la eficiencia y escalabilidad del sistema.

En conclusión, la correcta elección, creación y mantenimiento de índices permite:
disminuir los tiempos de ejecución,
reducir la carga del servidor,
mejorar el rendimiento global del sistema,
y asegurar que aplicaciones como UNIVIA puedan manejar altas cargas de datos sin perder eficiencia.
