# UNIVERSIDAD NACIONAL DEL NORDESTE
## BASES DE DATOS I – PROYECTO DE ESTUDIO

### Tema 1: Procedimientos y Funciones Almacenadas
**Base de datos:** Univia  
**Grupo:** 41  
**Año:** 2025

---

## ?? Tabla de Contenidos

1.  [Introducción](#1-introducción)
2.  [Marco Teórico](#2-marco-teórico)
    -   [2.1 ¿Qué es un Procedimiento Almacenado?](#21-qué-es-un-procedimiento-almacenado)
    -   [2.2 ¿Qué es una Función Definida por el Usuario?](#22-qué-es-una-función-definida-por-el-usuario)
3.  [Funciones Implementadas](#3-funciones-implementadas)
    -   [3.1 fn_usuario_publicaciones_activas](#31-fn_usuario_publicaciones_activas)
    -   [3.2 fn_publicacion_promedio_puntuacion](#32-fn_publicacion_promedio_puntuacion)
4.  [Procedimientos Implementados](#4-procedimientos-implementados)
    -   [4.1 sp_publicacion_insertar](#41-sp_publicacion_insertar)
    -   [4.2 sp_publicacion_actualizar](#42-sp_publicacion_actualizar)
    -   [4.3 sp_publicacion_baja_lógica](#43-sp_publicacion_baja_lógica)
5.  [Pruebas y Evidencia](#5-pruebas-y-evidencia)
6.  [Conclusiones](#6-conclusiones)

---

## 1. Introducción

Los procedimientos almacenados y las funciones definidas por el usuario son elementos esenciales en SQL Server para encapsular la lógica, mejorar el rendimiento y garantizar la integridad de los datos.

En el proyecto **UNIVIA**, estos objetos permiten:

* centralizar operaciones de negocio,
* validar información antes de actualizar tablas,
* calcular métricas,
* simplificar consultas complejas,
* mejorar seguridad y consistencia.

Este documento presenta el marco teórico y la implementación de procedimientos y funciones diseñados para gestionar las **publicaciones académicas** dentro del sistema.

---

## 2. Marco Teórico

En sistemas como UNIVIA, donde usuarios publican materiales, dejan valoraciones y consultan contenido, es importante organizar la lógica en el servidor para asegurar:

* rendimiento,
* mantenibilidad,
* integridad de datos,
* seguridad.

Esto se logra mediante **procedimientos almacenados** y **funciones definidas por el usuario**, que son objetos que encapsulan lógica reutilizable.

---

### 2.1 ¿Qué es un Procedimiento Almacenado?

Un **procedimiento almacenado (Stored Procedure o SP)** es un bloque de instrucciones SQL que se guarda en el servidor y se ejecuta mediante un nombre.

Los procedimientos se utilizan para:

* insertar datos,
* actualizar registros,
* realizar borrados lógicos,
* validar información,
* ejecutar operaciones complejas,
* aplicar reglas de negocio.

#### ?? Tipos de procedimientos almacenados

##### a) Procedimiento sin parámetros
Ejecuta siempre la misma instrucción.

``sql
CREATE PROCEDURE sp_listar_roles
AS
BEGIN
    SELECT id_rol, nombre_rol FROM Rol;
END;

#####      b) Procedimiento con parámetros de entrada (INPUT)
Permite enviar valores desde el exterior. Son los más utilizados y son los que implementa UNIVIA.

Ejemplo real del proyecto:
CREATE PROCEDURE sp_publicacion_insertar
    @titulo VARCHAR(200),
    @descripcion VARCHAR(800),
    @tipo_recurso VARCHAR(50),
    @tipo_acceso VARCHAR(50),
    @descargable BIT,
    @precio DECIMAL(10,2),
    @id_usuario INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario)
    BEGIN
        PRINT 'ERROR: El usuario no existe.';
        RETURN;
    END;

    INSERT INTO Publicacion
        (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
        (@titulo, @descripcion, @tipo_recurso, @tipo_acceso, @descargable, @precio, @id_usuario);
END;

#####   c) Procedimiento con parámetros de salida (OUTPUT)
Sirve para devolver un valor al finalizar.

Ejemplo
CREATE PROCEDURE sp_contar_publicaciones_usuario
    @id_usuario INT,
    @total INT OUTPUT
AS
BEGIN
    SELECT @total = COUNT(*)
    FROM Publicacion
    WHERE id_usuario = @id_usuario;
END;

##### 2.2 ¿Qué es una Función Definida por el Usuario?
Una función (UDF) es un objeto que siempre devuelve un valor. A diferencia de los procedimientos, una función no puede modificar tablas, solo consultar datos.

Las funciones son útiles para:

cálculos reutilizables,

estadísticas,

valores derivados,

ser usadas dentro de:

SELECT

WHERE

JOIN

##### ?? Tipos de funciones
##### a) Función escalar
Devuelve un único valor. UNIVIA usa este tipo.

Ejemplo real:

SQL

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
Otra función real:

SQL

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
b) Función tipo tabla (inline table-valued)
Devuelve una tabla.

Ejemplo teórico:

SQL

CREATE FUNCTION fn_publicaciones_por_usuario (@id_usuario INT)
RETURNS TABLE
AS
RETURN (
    SELECT *
    FROM Publicacion
    WHERE id_usuario = @id_usuario
);
c) Función tipo tabla multisentencia
Permite lógica más compleja antes de devolver la tabla.

Ejemplo teórico:

SQL

CREATE FUNCTION fn_materiales_filtrados ()
RETURNS @result TABLE (id INT, titulo VARCHAR(200))
AS
BEGIN
    INSERT INTO @result
    SELECT id_publicacion, titulo
    FROM Publicacion
    WHERE estado = 1;

    RETURN;
END;
3. Funciones Implementadas
3.1 fn_usuario_publicaciones_activas
SQL

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
3.2 fn_publicacion_promedio_puntuacion
SQL

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
4. Procedimientos Implementados
4.1 sp_publicacion_insertar
SQL

CREATE PROCEDURE sp_publicacion_insertar
    @titulo VARCHAR(200),
    @descripcion VARCHAR(800),
    @tipo_recurso VARCHAR(50),
    @tipo_acceso VARCHAR(50),
    @descargable BIT,
    @precio DECIMAL(10,2),
    @id_usuario INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario)
    BEGIN
        PRINT 'ERROR: El usuario no existe.';
        RETURN;
    END;

    INSERT INTO Publicacion
        (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
        (@titulo, @descripcion, @tipo_recurso, @tipo_acceso, @descargable, @precio, @id_usuario);
END;
4.2 sp_publicacion_actualizar
SQL

CREATE PROCEDURE sp_publicacion_actualizar
    @id_publicacion INT,
    @titulo VARCHAR(200),
    @descripcion VARCHAR(800),
    @tipo_recurso VARCHAR(50),
    @tipo_acceso VARCHAR(50),
    @descargable BIT,
    @precio DECIMAL(10,2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Publicacion WHERE id_publicacion = @id_publicacion)
    BEGIN
        PRINT 'ERROR: La publicación no existe.';
        RETURN;
    END;

    UPDATE Publicacion
    SET titulo = @titulo,
        descripcion = @descripcion,
        tipo_recurso = @tipo_recurso,
        tipo_acceso = @tipo_acceso,
        descargable = @descargable,
        precio = @precio
    WHERE id_publicacion = @id_publicacion;
END;
4.3 sp_publicacion_baja_lógica
SQL

CREATE PROCEDURE sp_publicacion_baja_logica
    @id_publicacion INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Publicacion WHERE id_publicacion = @id_publicacion)
    BEGIN
        PRINT 'ERROR: La publicación no existe.';
        RETURN;
    END;

    UPDATE Publicacion
    SET estado = 0
    WHERE id_publicacion = @id_publicacion;
END;
5. Pruebas y Evidencia
Inserción correcta:

SQL

EXEC sp_publicacion_insertar
    'Introducción a BD',
    'Apuntes módulo 1',
    'Documento',
    'Publico',
    1,
    0,
    1;
Resultado esperado:

Plaintext

Publicación insertada correctamente.
6. Conclusiones
Las funciones y procedimientos desarrollados permiten gestionar de manera segura, validada y organizada las publicaciones dentro del sistema UNIVIA.

Se aplicaron buenas prácticas tales como:

validación previa de datos,

encapsulación de reglas de negocio,

modularización del código,

uso de funciones para métricas y cálculos,

uso de procedimientos para operaciones CRUD.

Estas implementaciones contribuyen directamente a la integridad y rendimiento del sistema