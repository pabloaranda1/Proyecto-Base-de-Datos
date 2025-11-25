USE Univia;
GO

/* =========================================================
   PROCEDIMIENTOS ALMACENADOS - UNIVIA
   ========================================================= */

------------------------------------------------------------
-- DROP SI EXISTEN
------------------------------------------------------------
IF OBJECT_ID('sp_publicacion_insertar', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_insertar;

IF OBJECT_ID('sp_publicacion_actualizar', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_actualizar;

IF OBJECT_ID('sp_publicacion_baja_logica', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_baja_logica;
GO


/* =========================================================
   PROCEDIMIENTO 1: INSERTAR PUBLICACIÓN
   (OPERACIÓN CRUD: CREATE)
   ========================================================= */
CREATE PROCEDURE sp_publicacion_insertar
    @titulo        VARCHAR(200),
    @descripcion   VARCHAR(800),
    @tipo_recurso  VARCHAR(50),
    @tipo_acceso   VARCHAR(50),
    @descargable   BIT,
    @precio        DECIMAL(10,2),
    @id_usuario    INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar usuario activo
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

    INSERT INTO Publicacion
        (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
        (@titulo, @descripcion, @tipo_recurso, @tipo_acceso, @descargable, @precio, @id_usuario);

    PRINT 'Publicación insertada correctamente.';
END;
GO


/* =========================================================
   PROCEDIMIENTO 2: ACTUALIZAR PUBLICACIÓN
   (OPERACIÓN CRUD: UPDATE)
   ========================================================= */
CREATE PROCEDURE sp_publicacion_actualizar
    @id_publicacion INT,
    @titulo        VARCHAR(200),
    @descripcion   VARCHAR(800),
    @tipo_recurso  VARCHAR(50),
    @tipo_acceso   VARCHAR(50),
    @descargable   BIT,
    @precio        DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
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
    SET titulo       = @titulo,
        descripcion  = @descripcion,
        tipo_recurso = @tipo_recurso,
        tipo_acceso  = @tipo_acceso,
        descargable  = @descargable,
        precio       = @precio
    WHERE id_publicacion = @id_publicacion;

    PRINT 'Publicación actualizada correctamente.';
END;
GO


/* =========================================================
   PROCEDIMIENTO 3: BAJA LÓGICA DE PUBLICACIÓN
   (OPERACIÓN CRUD: DELETE ? baja lógica)
   ========================================================= */
CREATE PROCEDURE sp_publicacion_baja_logica
    @id_publicacion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia
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
GO


/* =========================================================
   LOTE DE INSERTS DIRECTOS (SIN PROCEDIMIENTOS)
   - CUMPLE: "Insertar un lote de datos con sentencias INSERT"
   ========================================================= */

INSERT INTO Publicacion
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
VALUES
('Apunte Matemática Discreta', 'Resumen examen final', 'archivo', 'publico', 1, 0, 2);

INSERT INTO Publicacion
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
VALUES
('Guía Base de Datos I', 'Guía con ejercicios resueltos', 'archivo', 'privado', 1, 0, 3);

INSERT INTO Publicacion
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
VALUES
('Física II - Problemas', 'Colección de problemas resueltos', 'archivo', 'publico', 1, 0, 1);
GO


/* =========================================================
   LOTE DE INSERTS VIA PROCEDIMIENTOS
   - CUMPLE: "otro lote invocando a los procedimientos creados"
   ========================================================= */

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
GO


/* =========================================================
   UPDATE Y DELETE SOBRE REGISTROS INSERTADOS (VIA SP)
   ========================================================= */

------------------------------------------------------------
-- UPDATE VIA PROCEDIMIENTO
------------------------------------------------------------

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


------------------------------------------------------------
-- DELETE / BAJA LÓGICA VIA PROCEDIMIENTO
------------------------------------------------------------

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
GO

/* =========================================================
   COMPARACIÓN DE EFICIENCIA: DIRECTO vs PROCEDIMIENTO
  
   ========================================================= */

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
GO
