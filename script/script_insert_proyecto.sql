-- SCRIPT "UNIVIA"
-- INSERCIÓN DEL LOTE DE DATOS

USE Univia;
GO

-- 1. Países

INSERT INTO Pais (nombre)
VALUES 
('Argentina'),
('Chile'),
('México');

-- 2. Ciudades

INSERT INTO Ciudad (nombre, id_pais)
VALUES
('Buenos Aires', 1),
('Santiago', 2),
('Monterrey', 3);

-- ========================
-- 3. Universidades
-- ========================
INSERT INTO Universidad (nombre, facultad, id_pais)
VALUES
('Universidad de Buenos Aires', 'Facultad de Ingeniería', 1),
('Universidad de Chile', 'Facultad de Ciencias', 2),
('Tecnológico de Monterrey', 'Facultad de Informática', 3);

-- ========================
-- 4. Carreras
-- ========================
INSERT INTO Carrera (nombre, id_universidad)
VALUES
('Ingeniería en Sistemas', 1),
('Ciencias de la Computación', 2),
('Ingeniería de Software', 3);

-- ========================
-- 5. Roles
-- ========================
INSERT INTO Rol (nombre_rol)
VALUES
('Administrador'),
('Estudiante'),
('Profesor');

-- ========================
-- 6. Usuarios
-- ========================
INSERT INTO Usuario (correo, contrasena, id_rol)
VALUES
('admin@univia.com', 'admin123', 1),
('juan@univia.com', 'pass123', 2),
('maria@univia.com', 'maria456', 3);

-- ========================
-- 7. Perfiles
-- ========================
INSERT INTO Perfil (nombre, apellido, reputacion, id_usuario, id_carrera)
VALUES
('Admin', 'General', 5.00, 1, 1),
('Juan', 'Pérez', 3.75, 2, 1),
('María', 'Gómez', 4.20, 3, 3);

-- ========================
-- 8. Materiales
-- ========================
INSERT INTO Material (titulo, descripcion, tipo_archivo, formato, acceso, estado, id_usuario, id_carrera)
VALUES
('Apuntes de Programación', 'Notas de clase sobre estructuras de datos', 'Documento', 'PDF', 'Público', 'Activo', 2, 1),
('Guía de SQL', 'Material de consulta sobre bases de datos', 'Documento', 'DOCX', 'Privado', 'Activo', 3, 3);

-- ========================
-- 9. Descargas
-- ========================
INSERT INTO Descarga (id_material, id_usuario)
VALUES
(1, 3),
(2, 2);

-- ========================
-- 10. Valoraciones
-- ========================
INSERT INTO Valoracion (puntuacion, comentario, id_material, id_usuario)
VALUES
(5, 'Excelente material, muy claro', 1, 3),
(4, 'Buen contenido, pero algo largo', 2, 2);

-- ========================
-- 11. Mensajes
-- ========================
INSERT INTO Mensaje (contenido, id_usuario_receptor, id_usuario_emisor)
VALUES
('Hola Juan, ¿subiste el nuevo material?', 2, 3),
('Sí, ya lo publiqué. Revisión pendiente.', 3, 2);

select* from Mensaje;
