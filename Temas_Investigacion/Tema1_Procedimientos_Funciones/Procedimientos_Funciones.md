# **UNIVERSIDAD NACIONAL DEL NORDESTE**  
## **BASES DE DATOS I – PROYECTO DE ESTUDIO**  

### **Tema 1: Procedimientos y Funciones Almacenadas**  
**Base de datos:** Univia  
**Grupo:** 41  
**Año:** 2025  

---

## **Tabla de Contenidos**

1. [Introducción](#1-introducción)  
2. [Marco Teórico](#2-marco-teórico)  
   - [2.1 ¿Qué es un Procedimiento Almacenado?](#21-qué-es-un-procedimiento-almacenado)  
   - [2.2 ¿Qué es una Función Definida por el Usuario?](#22-qué-es-una-función-definida-por-el-usuario)  
3. [Funciones Implementadas](#3-funciones-implementadas)  
   - [3.1 fn_usuario_publicaciones_activas](#31-fn_usuario_publicaciones_activas)  
   - [3.2 fn_publicacion_promedio_puntuacion](#32-fn_publicacion_promedio_puntuacion)  
   - [3.3 fn_cantidad_valoraciones_publicacion](#33-fn_cantidad_valoraciones_publicacion) 
4. [Procedimientos Implementados](#4-procedimientos-implementados)  
   - [4.1 sp_publicacion_insertar](#41-sp_publicacion_insertar)  
   - [4.2 sp_publicacion_actualizar](#42-sp_publicacion_actualizar)  
   - [4.3 sp_publicacion_baja_logica](#43-sp_publicacion_baja_logica)  
5. [Pruebas y Evidencia](#5-pruebas-y-evidencia)  
   - [5.1 Pruebas de funciones](#51-pruebas-de-funciones)  
   - [5.2 Lote de inserts directos (sin procedimientos)](#52-lote-de-inserts-directos-sin-procedimientos)  
   - [5.3 Lote de inserts vía procedimientos](#53-lote-de-inserts-vía-procedimientos)  
   - [5.4 Update sobre registros insertados (vía procedimiento)](#54-update-sobre-registros-insertados-vía-procedimiento)  
   - [5.5 Delete (baja lógica) sobre registros insertados (vía procedimiento)](#55-delete-baja-lógica-sobre-registros-insertados-vía-procedimiento)  
   - [5.6 Comparación de eficiencia: insert directo vs procedimiento](#56-comparación-de-eficiencia-insert-directo-vs-procedimiento)  
   - [5.7 Comparación de eficiencia: consulta directa vs función escalar](#57-comparación-de-eficiencia-consulta-directa-vs-función-escalar)  
6. [Conclusiones](#6-conclusiones)  

---

## **1. Introducción**

UNIVIA es una plataforma académica donde los estudiantes pueden subir **publicaciones** (apuntes, guías, resúmenes), valorar el material y consumir contenido.  
A medida que el proyecto crece, también aumenta la lógica que debe ejecutarse cada vez que se inserta, actualiza o consulta información.

En lugar de repetir esa lógica en cada pantalla o script, se decidió concentrarla dentro del propio motor SQL Server usando:

- **Procedimientos almacenados (Stored Procedures)**  
- **Funciones definidas por el usuario (User Defined Functions)**  

En este capítulo se describe el marco teórico básico y se documentan las funciones y procedimientos creados específicamente para el módulo de **Publicaciones** de UNIVIA.

---

## **2. Marco Teórico**

En una base de datos relacional, no alcanza con “tener tablas”: también hay que decidir **dónde** se programa la lógica.  
Una estrategia común es dejar gran parte de esa lógica en el propio servidor SQL para:

- Asegurar que todos los clientes usen las mismas reglas  
- Validar datos **antes** de modificar las tablas  
- Mejorar rendimiento  
- Evitar duplicación  

Las dos herramientas estándar para esto en SQL Server son **procedimientos** y **funciones**.

---

### **2.1 ¿Qué es un Procedimiento Almacenado?**

Un **procedimiento almacenado** es un bloque T-SQL almacenado en el servidor.  
Se ejecuta con `EXEC nombre_procedimiento`, y puede incluir:

- INSERT  
- UPDATE  
- DELETE  
- SELECT  
- Validaciones  
- Control de flujo  

UNIVIA los usa para gestionar el ciclo completo de las publicaciones.

#### **Tipos de procedimientos según parámetros**

---

#### **a) Procedimiento sin parámetros**

Siempre ejecuta la misma acción.

```sql
CREATE PROCEDURE sp_listar_roles
AS
BEGIN
    SELECT id_rol, nombre_rol
    FROM Rol;
END;


Este SP **no necesita datos de entrada**; sirve para consultas fijas o tareas de mantenimiento.

##### b) Procedimiento con parámetros de entrada (INPUT)

Es el más usado. Recibe valores para trabajar (por ejemplo, los datos de una publicación a insertar).

En UNIVIA, los tres procedimientos implementados pertenecen a esta categoría:

- `sp_publicacion_insertar`  
- `sp_publicacion_actualizar`  
- `sp_publicacion_baja_logica`  

Ejemplo (simplificado) de procedimiento con parámetros de entrada:

```sql
CREATE PROCEDURE sp_publicacion_insertar
    @titulo       VARCHAR(200),
    @descripcion  VARCHAR(800),
    @tipo_recurso VARCHAR(50),
    @tipo_acceso  VARCHAR(50),
    @descargable  BIT,
    @precio       DECIMAL(10,2),
    @id_usuario   INT
AS
BEGIN
    -- Lógica de validación + INSERT
END;
```

##### c) Procedimiento con parámetros de salida (OUTPUT)

Además de recibir datos, puede devolver resultados a través de parámetros marcados como `OUTPUT`.  
Se usa, por ejemplo, para devolver un conteo o el ID generado.

Ejemplo teórico aplicado a UNIVIA:

```sql
CREATE PROCEDURE sp_contar_publicaciones_usuario
    @id_usuario INT,
    @total INT OUTPUT
AS
BEGIN
    SELECT @total = COUNT(*)
    FROM Publicacion
    WHERE id_usuario = @id_usuario;
END;
```

Al ejecutar este SP, la aplicación obtiene en `@total` la cantidad de publicaciones del usuario.

---

### 2.2 ¿Qué es una Función Definida por el Usuario?

Una **función definida por el usuario** (User Defined Function o UDF) es un objeto que:

- Siempre devuelve **un valor** (escalar o una tabla).  
- No puede modificar datos (no hace `INSERT`, `UPDATE` ni `DELETE`).  
- Puede usarse dentro de `SELECT`, `WHERE`, `JOIN`, etc.

En UNIVIA las funciones se utilizan para obtener **métricas** a partir de las tablas, por ejemplo:

- ¿Cuántas publicaciones activas tiene un usuario?  
- ¿Cuál es el promedio de puntuación de una publicación?

#### Tipos de funciones (teoría)

1. **Escalar**: devuelve un solo valor (INT, DECIMAL, VARCHAR, etc.).  
2. **Inline table-valued**: devuelve una tabla definida por una sola consulta.  
3. **Multisentencia table-valued**: devuelve una tabla generada con varias sentencias dentro de un bloque `BEGIN…END`.

En este proyecto se implementaron **funciones escalares**, porque necesitamos un número puntual (cantidad, promedio) para mostrar en la interfaz.

---

## 3. Funciones Implementadas

En la base de datos UNIVIA se definieron dos funciones escalares directamente relacionadas con el módulo de publicaciones.

---

### 3.1 fn_usuario_publicaciones_activas

**Objetivo funcional**

Calcular cuántas publicaciones **activas** (`estado = 1`) tiene un usuario determinado.  
Esto puede usarse, por ejemplo, en:

- El perfil del usuario (“cantidad de apuntes publicados”).  
- Controles de reputación mínima.  

**Definición**

```sql
CREATE FUNCTION fn_usuario_publicaciones_activas (@id_usuario INT)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;

    SELECT @cantidad = COUNT(*)
    FROM Publicacion
    WHERE id_usuario = @id_usuario
      AND estado = 1;

    RETURN ISNULL(@cantidad, 0);
END;
```

**Entradas**

- `@id_usuario`: identificador del autor.

**Salida**

- Cantidad de publicaciones activas (entero).

**Uso típico**

```sql
SELECT u.id_usuario,
       u.nombre,
       dbo.fn_usuario_publicaciones_activas(u.id_usuario) AS publicaciones_activas
FROM Usuario AS u;
```

---

### 3.2 fn_publicacion_promedio_puntuacion

**Objetivo funcional**

Obtener el **promedio de puntuación** (1 a 5) de una publicación a partir de las valoraciones cargadas en la tabla `Valoracion`.

Esto permite mostrar en UNIVIA algo como: ? 4,3 sobre 5.

**Definición**

```sql
CREATE FUNCTION fn_publicacion_promedio_puntuacion (@id_publicacion INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @promedio DECIMAL(5,2);

    SELECT @promedio = AVG(CONVERT(DECIMAL(5,2), puntuacion))
    FROM Valoracion
    WHERE id_publicacion = @id_publicacion;

    RETURN ISNULL(@promedio, 0);
END;
```

**Entradas**

- `@id_publicacion`: identificador del material publicado.

**Salida**

- Promedio de puntuación con dos decimales.  
  Si no tiene valoraciones, devuelve 0.

**Uso típico**

```sql
SELECT p.id_publicacion,
       p.titulo,
       dbo.fn_publicacion_promedio_puntuacion(p.id_publicacion) AS promedio_puntuacion
FROM Publicacion AS p;
```

---
### 3.3 fn_cantidad_valoraciones_publicacion

**Objetivo funcional**

Obtener **cuántas valoraciones** (cantidad de registros en `Valoracion`) tiene una publicación.  
Esta métrica complementa al promedio de puntuación: no es lo mismo un promedio de 5 con 1 valoración que con 100 valoraciones.

**Definición**

    CREATE FUNCTION fn_cantidad_valoraciones_publicacion (@id_publicacion INT)
    RETURNS INT
    AS
    BEGIN
        DECLARE @cantidad INT;

        SELECT @cantidad = COUNT(*)
        FROM Valoracion
        WHERE id_publicacion = @id_publicacion;

        RETURN ISNULL(@cantidad, 0);
    END;

**Entradas**

- `@id_publicacion`: identificador de la publicación.

**Salida**

- Cantidad total de valoraciones (entero).  
  Si no tiene valoraciones, devuelve 0.

**Uso típico**

    SELECT p.id_publicacion,
           p.titulo,
           dbo.fn_cantidad_valoraciones_publicacion(p.id_publicacion) AS cantidad_valoraciones
    FROM Publicacion AS p;

---

## 4. Procedimientos Implementados

Los procedimientos trabajan sobre la tabla `Publicacion` y controlan el ciclo de vida del material compartido por los usuarios.

---

### 4.1 sp_publicacion_insertar

**Rol en el proyecto**

Centraliza el *alta* de una publicación.  
Antes de insertar verifica que el usuario exista y esté activo.

**Definición**

```sql
CREATE PROCEDURE sp_publicacion_insertar
    @titulo       VARCHAR(200),
    @descripcion  VARCHAR(800),
    @tipo_recurso VARCHAR(50),
    @tipo_acceso  VARCHAR(50),
    @descargable  BIT,
    @precio       DECIMAL(10,2),
    @id_usuario   INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de existencia y estado del usuario
    IF NOT EXISTS (
        SELECT 1
        FROM Usuario
        WHERE id_usuario = @id_usuario
          AND estado = 1
    )
    BEGIN
        PRINT 'ERROR: El usuario no existe o está inactivo.';
        RETURN;
    END;

    -- Inserción de la publicación
    INSERT INTO Publicacion
        (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
        (@titulo, @descripcion, @tipo_recurso, @tipo_acceso, @descargable, @precio, @id_usuario);

    PRINT 'Publicación insertada correctamente.';
END;
```

**Tipo de SP**  
Procedimiento **con parámetros de entrada** (recibe todos los datos de la publicación).

---

### 4.2 sp_publicacion_actualizar

**Rol en el proyecto**

Permite modificar los datos principales de una publicación ya existente.  
Se usa, por ejemplo, cuando el autor corrige un título o actualiza la descripción.

**Definición**

```sql
CREATE PROCEDURE sp_publicacion_actualizar
    @id_publicacion INT,
    @titulo         VARCHAR(200),
    @descripcion    VARCHAR(800),
    @tipo_recurso   VARCHAR(50),
    @tipo_acceso    VARCHAR(50),
    @descargable    BIT,
    @precio         DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación de existencia de la publicación
    IF NOT EXISTS (
        SELECT 1
        FROM Publicacion
        WHERE id_publicacion = @id_publicacion
    )
    BEGIN
        PRINT 'ERROR: La publicación no existe.';
        RETURN;
    END;

    -- Actualización de campos editables
    UPDATE Publicacion
    SET titulo       = @titulo,
        descripcion  = @descripcion,
        tipo_recurso = @tipo_recurso,
        tipo_acceso  = @tipo_acceso,
        descargable  = @descargable,
        precio       = @precio
    WHERE id_publicacion = @id_publicacion;

    PRINT 'Publicación actualizada correctamente.';
END;
```

**Tipo de SP**  
Procedimiento **con parámetros de entrada**, utilizado para operaciones de actualización.

---

### 4.3 sp_publicacion_baja_logica

**Rol en el proyecto**

Realiza la **baja lógica** de una publicación: en vez de borrarla de la tabla, cambia el campo `estado` a 0.  
Así se conserva el historial y se mantienen las referencias de valoraciones y mensajes.

**Definición**

```sql
CREATE PROCEDURE sp_publicacion_baja_logica
    @id_publicacion INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM Publicacion
        WHERE id_publicacion = @id_publicacion
    )
    BEGIN
        PRINT 'ERROR: La publicación no existe.';
        RETURN;
    END;

    UPDATE Publicacion
    SET estado = 0
    WHERE id_publicacion = @id_publicacion;

    PRINT 'Publicación dada de baja (estado = 0).';
END;
```

**Tipo de SP**  
Procedimiento **con parámetro de entrada** que ejecuta una actualización controlada sobre la tabla.

---
## 5. Pruebas y Evidencia

Para comprobar el correcto funcionamiento de las funciones y procedimientos, se realizaron pruebas sobre la base **Univia**, cumpliendo con todas las tareas pedidas:

- Uso de **al menos tres procedimientos**: insertar, modificar, baja lógica.  
- **Lote de inserts directos** y **lote de inserts vía procedimientos**.  
- **Update** y **delete (baja lógica)** sobre registros insertados usando procedimientos.  
- **Al menos tres funciones**: publicaciones activas, promedio de puntuación y cantidad de valoraciones.  
- **Comparación de eficiencia** de operaciones directas versus uso de procedimientos y funciones, usando `SET STATISTICS TIME` y `SET STATISTICS IO`.

---


### 5.1 Pruebas de funciones

Se ejecutaron consultas para verificar el resultado de cada función:

- Cantidad de publicaciones activas por usuario.  
- Promedio de puntuación por publicación.  
- Cantidad total de valoraciones por publicación.

Ejemplos de uso:

    -- Cantidad de publicaciones activas por usuario
    SELECT u.id_usuario,
           u.nombre,
           dbo.fn_usuario_publicaciones_activas(u.id_usuario) AS publicaciones_activas
    FROM Usuario AS u;

    -- Promedio de puntuación por publicación
    SELECT p.id_publicacion,
           p.titulo,
           dbo.fn_publicacion_promedio_puntuacion(p.id_publicacion) AS promedio_puntuacion
    FROM Publicacion AS p;

    -- Cantidad total de valoraciones por publicación
    SELECT p.id_publicacion,
           p.titulo,
           dbo.fn_cantidad_valoraciones_publicacion(p.id_publicacion) AS cantidad_valoraciones
    FROM Publicacion AS p;

---

### 5.2 Lote de inserts directos (sin procedimientos)

Para cumplir con “Insertar un lote de datos con sentencias INSERT”, se cargaron varias publicaciones directamente:

    INSERT INTO Publicacion
    (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
    ('Apunte Matemática Discreta', 'Resumen examen final', 'archivo', 'publico', 1, 0, 2),
    ('Guía Base de Datos I', 'Guía con ejercicios resueltos', 'archivo', 'privado', 1, 0, 3),
    ('Física II - Problemas', 'Colección de problemas resueltos', 'archivo', 'publico', 1, 0, 1);

---

### 5.3 Lote de inserts vía procedimientos

Para el punto “otro lote invocando a los procedimientos creados”, se ejecutaron tres altas usando `sp_publicacion_insertar`:

    EXEC sp_publicacion_insertar
        @titulo = 'Manual de Programación II',
        @descripcion = 'Ejercicios de repaso',
        @tipo_recurso = 'archivo',
        @tipo_acceso = 'publico',
        @descargable = 1,
        @precio = 0,
        @id_usuario = 2;

    EXEC sp_publicacion_insertar
        @titulo = 'Resumen de Estadística',
        @descripcion = 'Incluye teoría y ejercicios',
        @tipo_recurso = 'archivo',
        @tipo_acceso = 'publico',
        @descargable = 1,
        @precio = 0,
        @id_usuario = 2;

    EXEC sp_publicacion_insertar
        @titulo = 'Apuntes de Arquitectura de Computadoras',
        @descripcion = 'Unidad 1 a 5',
        @tipo_recurso = 'archivo',
        @tipo_acceso = 'privado',
        @descargable = 1,
        @precio = 0,
        @id_usuario = 2;

---

### 5.4 Update sobre registros insertados (vía procedimiento)

Se probó la modificación de una publicación usando `sp_publicacion_actualizar`.  
Antes y después del `EXEC` se consulta el mismo registro para evidenciar el cambio.

    -- Antes del UPDATE
    SELECT id_publicacion, titulo, descripcion, tipo_acceso, estado
    FROM Publicacion
    WHERE id_publicacion = 1;

    EXEC sp_publicacion_actualizar
        @id_publicacion = 1,
        @titulo = 'Apunte Matemática Discreta (Actualizado)',
        @descripcion = 'Resumen actualizado con nuevos ejercicios',
        @tipo_recurso = 'archivo',
        @tipo_acceso = 'publico',
        @descargable = 1,
        @precio = 0;

    -- Después del UPDATE
    SELECT id_publicacion, titulo, descripcion, tipo_acceso, estado
    FROM Publicacion
    WHERE id_publicacion = 1;

---

### 5.5 Delete (baja lógica) sobre registros insertados (vía procedimiento)

En lugar de borrar físicamente, se hace una baja lógica cambiando el campo `estado` a 0 mediante `sp_publicacion_baja_logica`:

    -- Antes de la baja lógica
    SELECT id_publicacion, titulo, estado
    FROM Publicacion
    WHERE id_publicacion = 5;

    EXEC sp_publicacion_baja_logica
        @id_publicacion = 5;

    -- Después de la baja lógica
    SELECT id_publicacion, titulo, estado
    FROM Publicacion
    WHERE id_publicacion = 5;

---

### 5.6 Comparación de eficiencia: insert directo vs procedimiento

Para comparar la eficiencia entre un `INSERT` directo y un `INSERT` vía procedimiento almacenado, se activaron las estadísticas de tiempo y E/S:

    SET STATISTICS TIME ON;
    SET STATISTICS IO ON;

    ------------------------------------------------------------
    -- INSERT DIRECTO (SIN PROCEDIMIENTO)
    ------------------------------------------------------------
    PRINT '--- INSERT DIRECTO ---';

    INSERT INTO Publicacion
    (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
    ('Prueba eficiencia directa', 'Insert directo sin SP', 'archivo', 'publico', 1, 0, 2);

    ------------------------------------------------------------
    -- INSERT VIA PROCEDIMIENTO ALMACENADO
    ------------------------------------------------------------
    PRINT '--- INSERT VIA PROCEDIMIENTO ---';

    EXEC sp_publicacion_insertar
        @titulo = 'Prueba eficiencia SP',
        @descripcion = 'Insert usando procedimiento almacenado',
        @tipo_recurso = 'archivo',
        @tipo_acceso = 'publico',
        @descargable = 1,
        @precio = 0,
        @id_usuario = 2;

    SET STATISTICS TIME OFF;
    SET STATISTICS IO OFF;

En las salidas se observa que el procedimiento almacenado puede implicar un pequeño costo extra de compilación, pero permite centralizar validaciones y lógica de negocio, lo cual es más importante que la diferencia mínima de tiempo en este contexto académico.

---

### 5.7 Comparación de eficiencia: consulta directa vs función escalar

También se comparó la obtención del promedio de puntuación de una publicación de dos maneras:

1. Consulta directa con `AVG()` sobre la tabla `Valoracion`.  
2. Llamando a la función escalar `fn_publicacion_promedio_puntuacion`.

    SET STATISTICS TIME ON;
    SET STATISTICS IO ON;

    -- PROMEDIO DE PUNTUACIÓN - CONSULTA DIRECTa
    SELECT id_publicacion,
           AVG(CONVERT(DECIMAL(5,2), puntuacion)) AS PromedioDirecto
    FROM Valoracion
    WHERE id_publicacion = 1
    GROUP BY id_publicacion;

    -- PROMEDIO DE PUNTUACIÓN - USANDO FUNCIÓN ESCALAR
    SELECT dbo.fn_publicacion_promedio_puntuacion(1) AS PromedioFuncion;

    SET STATISTICS TIME OFF;
    SET STATISTICS IO OFF;

En bases pequeñas, los tiempos suelen ser similares. Sin embargo, la función aporta **reutilización** y **claridad**: la misma lógica se puede usar en muchos SELECT sin repetir la expresión `AVG(...)`.

---

## 6. Conclusiones

El uso de **procedimientos almacenados** y **funciones definidas por el usuario** en la base de datos UNIVIA permitió:

- Encapsular la lógica de negocio relacionada con las publicaciones.  
- Asegurar que solo usuarios válidos puedan crear contenido.  
- Evitar duplicar código SQL en distintas capas de la aplicación.  
- Calcular métricas reutilizables (cantidad de publicaciones y promedio de puntuación) de forma simple y consistente.  

Estos objetos son una base sólida para seguir ampliando el proyecto (por ejemplo, agregando procedimientos con parámetros de salida o nuevas funciones para estadísticas más complejas).
```
