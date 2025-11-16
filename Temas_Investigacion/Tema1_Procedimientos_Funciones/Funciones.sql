USE Univia;
GO

/* =========================================================
   FUNCIONES DEFINIDAS POR EL USUARIO - UNIVIA
   ========================================================= */

------------------------------------------------------------
-- DROP SI EXISTEN
------------------------------------------------------------
IF OBJECT_ID('fn_usuario_publicaciones_activas', 'FN') IS NOT NULL
    DROP FUNCTION fn_usuario_publicaciones_activas;

IF OBJECT_ID('fn_publicacion_promedio_puntuacion', 'FN') IS NOT NULL
    DROP FUNCTION fn_publicacion_promedio_puntuacion;
GO


/* =========================================================
   FUNCION 1: fn_usuario_publicaciones_activas
   ========================================================= */
CREATE FUNCTION fn_usuario_publicaciones_activas
(
    @id_usuario INT
)
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
GO




/* =========================================================
   FUNCION 2: fn_publicacion_promedio_puntuacion
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
   PRUEBAS (comentadas)
   ========================================================= */

-- SELECT dbo.fn_usuario_publicaciones_activas(1);
-- SELECT dbo.fn_publicacion_promedio_puntuacion(3);


--------------------------------------------------------------------------------
----------PRUEBA ---------------------



/* =========================================================
   PRUEBAS Y EVIDENCIA - TEMA 1
   ========================================================= */

------------------------------------------------------------
-- 1. Crear publicación
------------------------------------------------------------
EXEC sp_publicacion_insertar
    @titulo = 'Introducción a SQL Server',
    @descripcion = 'Apunte del módulo 1',
    @tipo_recurso = 'Documento',
    @tipo_acceso = 'Publico',
    @descargable = 1,
    @precio = 0,
    @id_usuario = 2;

  SELECT * FROM Publicacion;

------------------------------------------------------------
-- 2. Actualizar publicación
------------------------------------------------------------
EXEC sp_publicacion_actualizar
    @id_publicacion = 1,
    @titulo = 'Guía SQL I - Actualizada',
    @descripcion = 'Versión revisada',
    @tipo_recurso = 'Documento',
    @tipo_acceso = 'privado',
    @descargable = 1,
    @precio = 0;


------------------------------------------------------------
-- 3. Baja lógica
------------------------------------------------------------
EXEC sp_publicacion_baja_logica
    @id_publicacion = 1;


------------------------------------------------------------
-- 4. Usar funciones
------------------------------------------------------------
SELECT dbo.fn_publicacion_promedio_puntuacion(1) AS PromedioPuntuacion;

SELECT dbo.fn_usuario_publicaciones_activas(2);

-----------------------------------------------------------------------------------------------------
SELECT id_publicacion, id_usuario, estado
FROM Publicacion;



SELECT * FROM Valoracion;
INSERT INTO Valoracion (id_publicacion, id_usuario, puntuacion)
VALUES (1, 2, 1);
