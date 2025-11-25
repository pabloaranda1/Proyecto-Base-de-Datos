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

IF OBJECT_ID('fn_cantidad_valoraciones_publicacion', 'FN') IS NOT NULL
    DROP FUNCTION fn_cantidad_valoraciones_publicacion;
GO


/* =========================================================
   FUNCIÓN 1: fn_usuario_publicaciones_activas
   - Devuelve cantidad de publicaciones ACTIVAS de un usuario
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
   FUNCIÓN 2: fn_publicacion_promedio_puntuacion
   - Devuelve promedio de puntuación (1 a 5) de una publicación
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
   FUNCIÓN 3: fn_cantidad_valoraciones_publicacion
   - Devuelve cuántas valoraciones tiene una publicación
   ========================================================= */
CREATE FUNCTION fn_cantidad_valoraciones_publicacion
(
    @id_publicacion INT
)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;

    SELECT @cantidad = COUNT(*)
    FROM Valoracion
    WHERE id_publicacion = @id_publicacion;

    RETURN ISNULL(@cantidad, 0);
END;
GO


/* =========================================================
   PRUEBAS Y EVIDENCIA DE USO DE FUNCIONES
   ========================================================= */

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

-- Cantidad de valoraciones por publicación
SELECT p.id_publicacion,
       p.titulo,
       dbo.fn_cantidad_valoraciones_publicacion(p.id_publicacion) AS cantidad_valoraciones
FROM Publicacion AS p;


 /* =========================================================
    COMPARACIÓN DE EFICIENCIA: CONSULTA DIRECTA vs FUNCIÓN
  
    ========================================================= */

  SET STATISTICS TIME ON;
  SET STATISTICS IO ON;

------------------------------------------------------------
-- PROMEDIO DE PUNTUACIÓN - CONSULTA DIRECTA
------------------------------------------------------------
 SELECT id_publicacion,
        AVG(CONVERT(DECIMAL(5,2), puntuacion)) AS PromedioDirecto
 FROM Valoracion
 WHERE id_publicacion = 1
 GROUP BY id_publicacion;

------------------------------------------------------------
-- PROMEDIO DE PUNTUACIÓN - USANDO FUNCIÓN ESCALAR
------------------------------------------------------------
 SELECT dbo.fn_publicacion_promedio_puntuacion(1) AS PromedioFuncion;

 SET STATISTICS TIME OFF;
 SET STATISTICS IO OFF;
