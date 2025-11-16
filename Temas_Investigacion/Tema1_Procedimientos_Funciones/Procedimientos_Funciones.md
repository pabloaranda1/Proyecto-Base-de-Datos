```md
# UNIVERSIDAD NACIONAL DEL NORDESTE  
## BASES DE DATOS I – PROYECTO DE ESTUDIO 

### Tema 1: Procedimientos y Funciones Almacenadas  
**Base de datos:** Univia  
**Grupo:** 41  
**Año:** 2025  

---

## Tabla de Contenidos

1. Introducción  
2. Marco Teórico  
   2.1 ¿Qué es un Procedimiento Almacenado?  
   2.2 ¿Qué es una Función Definida por el Usuario?  
3. Funciones Implementadas  
   3.1 fn_usuario_publicaciones_activas  
   3.2 fn_publicacion_promedio_puntuacion  
4. Procedimientos Implementados  
   4.1 sp_publicacion_insertar  
   4.2 sp_publicacion_actualizar  
   4.3 sp_publicacion_baja_logica  
5. Pruebas y Evidencia  
6. Conclusiones  

---

## 1. Introducción

En SQL Server, los procedimientos almacenados y las funciones permiten modularizar la lógica, validar datos y mejorar el rendimiento.  
En **UNIVIA**, son utilizados para gestionar publicaciones, verificar integridad y obtener estadísticas sobre los recursos.

Este documento presenta el marco conceptual, las implementaciones y evidencia de funcionamiento.

---

## 2. Marco Teórico

Los sistemas que manejan lógica compleja, como UNIVIA, requieren objetos SQL para organizar reglas del negocio.  
Los dos principales son:

- **Procedimientos almacenados (Stored Procedures)**  
- **Funciones definidas por el usuario (User Defined Functions)**  

Ambos permiten centralizar la lógica y evitar duplicación.

---

## 2.1 ¿Qué es un Procedimiento Almacenado?

Un **procedimiento almacenado** es un bloque T-SQL almacenado bajo un nombre.  
Sirve para ejecutar lógica compleja:

- Insertar datos  
- Actualizar o eliminar  
- Validar condiciones  
- Aplicar reglas del negocio  
- Encapsular operaciones reutilizables  

### Tipos de procedimientos almacenados

#### a) Procedimiento sin parámetros
Siempre ejecuta la misma tarea.

```sql
CREATE PROCEDURE sp_listar_roles
AS
BEGIN
    SELECT id_rol, nombre_rol FROM Rol;
END;
```

#### b) Procedimiento con parámetros de entrada (INPUT)
Es el más común.

```sql
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
```

#### c) Procedimiento con parámetros de salida (OUTPUT)

Devuelve un valor al exterior.

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

---

## 2.2 ¿Qué es una Función Definida por el Usuario?

Una **función** devuelve SIEMPRE un valor y NO puede modificar datos.  
Sirve para cálculos y valores derivados.

### Tipos de funciones

- **Escalar** ? devuelve un valor (las utilizadas en UNIVIA)  
- **Inline table-valued** ? devuelve una tabla  
- **Multisentencia** ? tabla más lógica compleja  

Ejemplo de UNIVIA en la siguiente sección.

---

## 3. Funciones Implementadas

### 3.1 fn_usuario_publicaciones_activas

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

---

### 3.2 fn_publicacion_promedio_puntuacion

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

---

## 4. Procedimientos Implementados

### 4.1 sp_publicacion_insertar

```sql
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
```

---

### 4.2 sp_publicacion_actualizar

```sql
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
```

---

### 4.3 sp_publicacion_baja_logica

```sql
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
```

---

## 5. Pruebas y Evidencia

Se ejecutaron las siguientes pruebas:

```sql
EXEC sp_publicacion_insertar
    'Introducción a BD', 'Apuntes', 'PDF', 'Publico', 1, 0, 1;

EXEC sp_publicacion_actualizar
    1, 'BD I', 'Actualizado', 'PDF', 'Publico', 1, 0;

EXEC sp_publicacion_baja_logica 1;

SELECT dbo.fn_usuario_publicaciones_activas(1);
SELECT dbo.fn_publicacion_promedio_puntuacion(1);
```

Todas las pruebas se ejecutaron correctamente en SQL Server.

---

## 6. Conclusiones

El uso de procedimientos y funciones almacenadas permitió:

- encapsular reglas del negocio  
- validar integridad antes de modificar datos  
- reutilizar cálculos mediante funciones  
- mejorar el orden y mantenimiento del código SQL  

Estos objetos son esenciales para garantizar un funcionamiento seguro y eficiente en sistemas como UNIVIA.

```

