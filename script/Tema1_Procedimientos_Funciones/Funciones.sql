USE Univia;
GO

---------------------------------------------------------
-- DROP si existen
---------------------------------------------------------
IF OBJECT_ID('sp_publicacion_insertar', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_insertar;
IF OBJECT_ID('sp_publicacion_actualizar', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_actualizar;
IF OBJECT_ID('sp_publicacion_baja_logica', 'P') IS NOT NULL
    DROP PROCEDURE sp_publicacion_baja_logica;
GO

/* =========================================================
   PROCEDIMIENTO 1: sp_publicacion_insertar
   Inserta una nueva publicación validando usuario
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

    IF NOT EXISTS (
        SELECT 1 FROM Usuario
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
   PROCEDIMIENTO 2: sp_publicacion_actualizar
   Actualiza una publicación existente
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

    IF NOT EXISTS (
        SELECT 1 FROM Publicacion
        WHERE id_publicacion = @id_publicacion
    )
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

    PRINT 'Publicación actualizada correctamente.';
END;
GO


/* =========================================================
   PROCEDIMIENTO 3: sp_publicacion_baja_logica
   Baja lógica (estado = 0)
   ========================================================= */
CREATE PROCEDURE sp_publicacion_baja_logica
    @id_publicacion INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Publicacion
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
