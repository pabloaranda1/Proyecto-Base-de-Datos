USE Univia;
GO

/* =========================================================
   TEMA 1 - PROCEDIMIENTOS Y FUNCIONES ALMACENADAS
   Base: Univia
   ========================================================= */

------------------------------------------------------------
-- LIMPIEZA PREVIA (DROP SI EXISTEN)
------------------------------------------------------------
IF OBJECT_ID('fn_usuario_publicaciones_activas', 'FN') IS NOT NULL
    DROP FUNCTION fn_usuario_publicaciones_activas;
IF OBJECT_ID('fn_publicacion_promedio_puntuacion', 'FN') IS NOT NULL
    DROP FUNCTION fn_publicacion_promedio_puntuacion;

IF OBJECT_ID('sp_publicacion_insertar', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_insertar;
IF OBJECT_ID('sp_publicacion_actualizar', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_actualizar;
IF OBJECT_ID('sp_publicacion_baja_logica', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_baja_logica;
GO

/* =========================================================
   FUNCION 1: fn_usuario_publicaciones_activas
   Devuelve la cantidad de publicaciones activas de un usuario
   ========================================================= */
CREATE FUNCTION fn_usuario_publicaciones_activas
(
    @id_usuario INT
)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;

    -- Cuenta publicaciones activas (estado = 1) del usuario
    SELECT @cantidad = COUNT(*)
    FROM Publicacion
    WHERE id_usuario = @id_usuario
      AND estado = 1;

    RETURN ISNULL(@cantidad, 0);
END;
GO

/* =========================================================
   FUNCION 2: fn_publicacion_promedio_puntuacion
   Devuelve el promedio de puntuación (1 a 5) de una publicación
   ========================================================= */
CREATE FUNCTION fn_publicacion_promedio_puntuacion
(
    @id_publicacion INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @promedio DECIMAL(5,2);

    SELECT @promedio = AVG(CONVERT(DECIMAL(5,2), puntuacion))
    FROM Valoracion
    WHERE id_publicacion = @id_publicacion;

    RETURN ISNULL(@promedio, 0);
END;
GO

/* =========================================================
   PROCEDIMIENTO 1: sp_publicacion_insertar
   Inserta una nueva publicación validando el usuario
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

    -- Validación: que exista el usuario
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

    -- Inserta la publicación
    INSERT INTO Publicacion
        (titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
    VALUES
        (@titulo, @descripcion, @tipo_recurso, @tipo_acceso, @descargable, @precio, @id_usuario);

    PRINT 'Publicación insertada correctamente.';
END;
GO

/* =========================================================
   PROCEDIMIENTO 2: sp_publicacion_actualizar
   Actualiza datos básicos de una publicación existente
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

    -- Validación: que exista la publicación
    IF NOT EXISTS (
        SELECT 1
        FROM Publicacion
        WHERE id_publicacion = @id_publicacion
    )
    BEGIN
        PRINT 'ERROR: La publicación no existe.';
        RETURN;
    END;

    -- Actualiza la publicación
    UPDATE Publicacion
    SET
        titulo       = @titulo,
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
   PROCEDIMIENTO 3: sp_publicacion_baja_logica
   Realiza borrado lógico de una publicación (estado = 0)
   ========================================================= */
CREATE PROCEDURE sp_publicacion_baja_logica
    @id_publicacion INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación: que exista la publicación
    IF NOT EXISTS (
        SELECT 1
        FROM Publicacion
        WHERE id_publicacion = @id_publicacion
    )
    BEGIN
        PRINT 'ERROR: La publicación no existe.';
        RETURN;
    END;

    -- Baja lógica
    UPDATE Publicacion
    SET estado = 0
    WHERE id_publicacion = @id_publicacion;

    PRINT 'Publicación dada de baja (estado = 0).';
END;
GO

/* =========================================================
   PRUEBAS RÁPIDAS (OPCIONAL, SOLO PARA VOS)
   Descomentar y ejecutar si querés probar
   ========================================================= */
-- SELECT * FROM Usuario;
-- SELECT * FROM Publicacion;

-- EXEC sp_publicacion_insertar
--     @titulo = 'Introducción a Base de Datos',
--     @descripcion = 'Apuntes del módulo I',
--     @tipo_recurso = 'Documento',
--     @tipo_acceso = 'Publico',
--     @descargable = 1,
--     @precio = 0,
--     @id_usuario = 2;

-- EXEC sp_publicacion_actualizar
--     @id_publicacion = 1,
--     @titulo = 'BD I - Unidad 1',
--     @descripcion = 'Apuntes actualizados',
--     @tipo_recurso = 'Documento',
--     @tipo_acceso = 'Publico',
--     @descargable = 1,
--     @precio = 0;

-- EXEC sp_publicacion_baja_logica
--     @id_publicacion = 1;

-- SELECT dbo.fn_usuario_publicaciones_activas(2) AS Publicaciones_Activas_Usuario2;
-- SELECT dbo.fn_publicacion_promedio_puntuacion(1) AS Promedio_Puntuacion_Pub1;
