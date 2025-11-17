
INSERT INTO Pais (nombre)
VALUES 
('Argentina'),
('Chile'),
('México'),
('Uruguay'),
('Paraguay'),
('Bolivia'),
('Perú'),
('Colombia'),
('Venezuela'),
('Ecuador'),
('Brasil'),
('Guatemala'),
('Honduras'),
('El Salvador'),
('Nicaragua'),
('Costa Rica'),
('Panamá'),
('Cuba'),
('República Dominicana'),
('Puerto Rico')

-- 2. Ciudades

INSERT INTO Ciudad (nombre, id_pais)
VALUES
('Buenos Aires', 1),
('Córdoba', 1),
('Rosario', 1),

('Santiago', 2),
('Valparaíso', 2),
('Concepción', 2),

('Ciudad de México', 3),
('Guadalajara', 3),
('Monterrey', 3),

('Bogotá', 4),
('Medellín', 4),
('Cali', 4),

('Lima', 5),
('Arequipa', 5),
('Cusco', 5),

('La Paz', 6),
('Santa Cruz', 6),
('Cochabamba', 6),

('Asunción', 7),
('Ciudad del Este', 7),

('Montevideo', 8),
('Punta del Este', 8),

('São Paulo', 9),
('Rio de Janeiro', 9),
('Brasilia', 9),

('Quito', 10),
('Guayaquil', 10),

('Caracas', 11),
('Maracaibo', 11),

('San José', 12),

('Ciudad de Guatemala', 13),

('Tegucigalpa', 14),

('San Salvador', 15),

('Managua', 16),

('Panamá', 17),

('Santo Domingo', 18),

('La Habana', 19),

('San Juan', 20);


-- 3. Universidades

INSERT INTO Universidad (nombre, id_ciudad)
VALUES
('Universidad Nacional de Buenos Aires', 1),
('Universidad Nacional de Córdoba', 2),
('Universidad Nacional de Rosario', 3),
('Pontificia Universidad Católica de Chile', 4),
('Universidad de Valparaíso', 5),
('Universidad de Concepción', 6),
('Universidad Nacional Autónoma de México', 7),
('Universidad de Monterrey', 8),
('Universidad de Guadalajara', 9),
('Universidad Nacional de Colombia', 10),
('Universidad de Antioquia', 11),
('Universidad del Valle', 12),
('Pontificia Universidad Católica del Perú', 13),
('Universidad Nacional de San Agustín', 14),
('Universidad Nacional de San Antonio Abad del Cusco', 15),
('Universidad de la República', 16),
('Universidad Católica del Uruguay', 16),
('Universidad de la Empresa', 17),
('Universidad Tecnológica del Uruguay', 18);

INSERT INTO Facultad (nombre, id_universidad)
VALUES
-- UBA
('Facultad de Ciencias Económicas', 1),
('Facultad de Derecho', 1),
('Facultad de Ingeniería', 1),

-- UNC Córdoba
('Facultad de Arquitectura, Urbanismo y Diseño', 2),
('Facultad de Ciencias Exactas, Físicas y Naturales', 2),
('Facultad de Ciencias Médicas', 2),

-- UN Rosario
('Facultad de Humanidades y Artes', 3),
('Facultad de Ciencias Agrarias', 3),
('Facultad de Ciencias Bioquímicas', 3),

-- PUC Chile
('Facultad de Ingeniería', 4),
('Facultad de Ciencias Sociales', 4),
('Facultad de Medicina', 4),

-- Univ. Valparaíso
('Facultad de Ciencias del Mar', 5),
('Facultad de Farmacia', 5),
('Facultad de Arquitectura', 5),

-- Univ. Concepción
('Facultad de Ciencias Físicas y Matemáticas', 6),
('Facultad de Ciencias Forestales', 6),
('Facultad de Educación', 6),

-- UNAM
('Facultad de Ingeniería', 7),
('Facultad de Psicología', 7),
('Facultad de Medicina', 7),

-- Univ. de Monterrey
('Facultad de Negocios', 8),
('Facultad de Arte y Diseño', 8),
('Facultad de Ingeniería y Tecnologías', 8),

-- Univ. Guadalajara
('Facultad de Ciencias Económico Administrativas', 9),
('Facultad de Ciencias de la Salud', 9),
('Facultad de Arquitectura y Diseño', 9),

-- Univ. Nacional de Colombia
('Facultad de Ciencias', 10),
('Facultad de Derecho, Ciencias Políticas y Sociales', 10),
('Facultad de Ingeniería', 10),

-- Univ. de Antioquia
('Facultad de Artes', 11),
('Facultad de Ingeniería', 11),
('Facultad de Ciencias Agrarias', 11),

-- Univ. del Valle (Cali)
('Facultad de Salud', 12),
('Facultad de Ingeniería', 12),
('Facultad de Ciencias Naturales y Exactas', 12),

-- PUC del Perú
('Facultad de Ciencias e Ingeniería', 13),
('Facultad de Gestión y Alta Dirección', 13),
('Facultad de Letras y Ciencias Humanas', 13),

-- Universidad San Agustín (Arequipa)
('Facultad de Medicina', 14),
('Facultad de Ingeniería de Producción y Servicios', 14),
('Facultad de Ciencias Contables y Financieras', 14),

-- Universidad Cusco (UNSAAC)
('Facultad de Derecho y Ciencias Políticas', 15),
('Facultad de Ciencias Agrarias', 15),
('Facultad de Arquitectura e Ingeniería Civil', 15),

-- Univ. de la República (Montevideo)
('Facultad de Ciencias', 16),
('Facultad de Ingeniería', 16),
('Facultad de Humanidades y Ciencias de la Educación', 16),

-- Univ. Católica Uruguay
('Facultad de Ciencias Empresariales', 17),
('Facultad de Psicología', 17),
('Facultad de Derecho', 17),

-- Universidad de la Empresa
('Facultad de Ingeniería y Tecnologías', 18),
('Facultad de Ciencias Empresariales', 18),

-- UTEC Uruguay
('Facultad de Tecnologías de la Información', 19),
('Facultad de Energías y Mecatrónica', 19);

SELECT * FROM Pais
ORDER BY id_pais;

INSERT INTO Carrera (nombre)
VALUES
('Ingeniería en Sistemas de Información'),
('Ingeniería Industrial'),
('Ingeniería Civil'),
('Ingeniería Mecánica'),
('Ingeniería Electrónica'),
('Ingeniería Química'),
('Licenciatura en Administración'),
('Licenciatura en Economía'),
('Licenciatura en Contabilidad'),
('Licenciatura en Comercio Internacional'),
('Medicina'),
('Enfermería'),
('Odontología'),
('Farmacia'),
('Nutrición'),
('Kinesiología y Fisiatría'),
('Licenciatura en Psicología'),
('Licenciatura en Sociología'),
('Ciencia Política'),
('Trabajo Social'),
('Abogacía'),
('Criminología'),
('Arquitectura'),
('Diseño Industrial'),
('Diseño Gráfico'),
('Licenciatura en Educación'),
('Profesorado de Matemática'),
('Profesorado de Historia'),
('Licenciatura en Física'),
('Licenciatura en Química'),
('Licenciatura en Ciencias de la Computación');

INSERT INTO Carrera_Facultad (id_carrera, id_facultad)
VALUES
-- Facultad 1: Ciencias Económicas (UBA)
(7,1),(8,1),(9,1),(10,1),

-- Facultad 2: Derecho (UBA)
(21,2),(22,2),

-- Facultad 3: Ingeniería (UBA)
(1,3),(2,3),(3,3),(4,3),(5,3),(6,3),(31,3),

-- Facultad 4: Arquitectura, Urbanismo y Diseño (UNC)
(23,4),(24,4),(25,4),

-- Facultad 5: Ciencias Exactas, Físicas y Naturales (UNC)
(29,5),(30,5),(31,5),

-- Facultad 6: Ciencias Médicas (UNC)
(11,6),(12,6),(13,6),(14,6),(15,6),(16,6),

-- Facultad 7: Humanidades y Artes (UN Rosario)
(17,7),(18,7),(20,7),(26,7),(27,7),(28,7),

-- Facultad 8: Ciencias Agrarias (UN Rosario)
(16,8),(9,8),(15,8),

-- Facultad 9: Ciencias Bioquímicas (UN Rosario)
(14,9),(29,9),(30,9),

-- Facultad 10: Ingeniería (PUC Chile)
(1,10),(2,10),(3,10),(4,10),(5,10),(6,10),(31,10),

-- Facultad 11: Ciencias Sociales (PUC Chile)
(17,11),(18,11),(19,11),(20,11),

-- Facultad 12: Medicina (PUC Chile)
(11,12),(12,12),(13,12),(14,12),(15,12),(16,12),

-- Facultad 13: Ciencias del Mar (Valparaíso)
(29,13),(30,13),

-- Facultad 14: Farmacia (Valparaíso)
(14,14),

-- Facultad 15: Arquitectura (Valparaíso)
(23,15),(24,15),(25,15),

-- Facultad 16: Ciencias Físicas y Matemáticas (Concepción)
(29,16),(30,16),(31,16),

-- Facultad 17: Ciencias Forestales (Concepción)
(16,17),(29,17),

-- Facultad 18: Educación (Concepción)
(26,18),(27,18),(28,18),

-- Facultad 19: Ingeniería (UNAM)
(1,19),(2,19),(3,19),(4,19),(5,19),(6,19),(31,19),

-- Facultad 20: Psicología (UNAM)
(17,20),

-- Facultad 21: Medicina (UNAM)
(11,21),(12,21),(13,21),(14,21),(15,21),(16,21),

-- Facultad 22: Negocios (Monterrey)
(7,22),(8,22),(9,22),(10,22),

-- Facultad 23: Arte y Diseño (Monterrey)
(23,23),(24,23),(25,23),

-- Facultad 24: Ingeniería y Tecnologías (Monterrey)
(1,24),(2,24),(3,24),(4,24),(5,24),(6,24),(31,24),

-- Facultad 25: Ciencias Económico Administrativas (Guadalajara)
(7,25),(8,25),(9,25),(10,25),

-- Facultad 26: Ciencias de la Salud (Guadalajara)
(11,26),(12,26),(13,26),(14,26),(15,26),(16,26),

-- Facultad 27: Arquitectura y Diseño (Guadalajara)
(23,27),(24,27),(25,27),

-- Facultad 28: Ciencias (Nacional Colombia)
(29,28),(30,28),(31,28),

-- Facultad 29: Derecho y Ciencias Políticas (Nacional Colombia)
(21,29),(19,29),(22,29),

-- Facultad 30: Ingeniería (Nacional Colombia)
(1,30),(2,30),(3,30),(4,30),(5,30),(6,30),(31,30),

-- Facultad 31: Artes (Antioquia)
(23,31),(24,31),(25,31),

-- Facultad 32: Ingeniería (Antioquia)
(1,32),(2,32),(3,32),(4,32),(5,32),(6,32),(31,32),

-- Facultad 33: Ciencias Agrarias (Antioquia)
(16,33),(15,33),(29,33),

-- Facultad 34: Salud (Valle)
(11,34),(12,34),(13,34),(14,34),(15,34),(16,34),

-- Facultad 35: Ingeniería (Valle)
(1,35),(2,35),(3,35),(4,35),(5,35),(6,35),(31,35),

-- Facultad 36: Ciencias Naturales y Exactas (Valle)
(29,36),(30,36),(31,36),

-- Facultad 37: Ciencias e Ingeniería (PUCP Perú)
(1,37),(2,37),(3,37),(29,37),(31,37),

-- Facultad 38: Gestión y Alta Dirección (PUCP Perú)
(7,38),(8,38),(10,38),

-- Facultad 39: Letras y Ciencias Humanas (PUCP Perú)
(17,39),(18,39),(19,39),(20,39),(27,39),(28,39),

-- Facultad 40: Medicina (San Agustín)
(11,40),(12,40),(13,40),(14,40),(15,40),(16,40),

-- Facultad 41: Ingeniería de Producción (San Agustín)
(1,41),(2,41),(6,41),(31,41),

-- Facultad 42: Ciencias Contables (San Agustín)
(7,42),(9,42),

-- Facultad 43: Derecho y Ciencias Políticas (UNSAAC Cusco)
(21,43),(22,43),(19,43),

-- Facultad 44: Ciencias Agrarias (UNSAAC Cusco)
(16,44),(15,44),(29,44),

-- Facultad 45: Arquitectura e Ingeniería Civil (UNSAAC Cusco)
(23,45),(3,45),(24,45),

-- Facultad 46: Ciencias (UDELAR Uruguay)
(29,46),(30,46),(31,46),

-- Facultad 47: Ingeniería (UDELAR Uruguay)
(1,47),(2,47),(3,47),(4,47),(5,47),(6,47),(31,47),

-- Facultad 48: Humanidades y Educación (UDELAR Uruguay)
(17,48),(18,48),(20,48),(26,48),(27,48),(28,48),

-- Facultad 49: Ciencias Empresariales (Católica Uruguay)
(7,49),(8,49),(9,49),(10,49),

-- Facultad 50: Psicología (Católica Uruguay)
(17,50),

-- Facultad 51: Derecho (Católica Uruguay)
(21,51),(22,51),

-- Facultad 52: Ingeniería y Tecnologías (UDE Uruguay)
(1,52),(2,52),(3,52),(4,52),(5,52),(6,52),(31,52),

-- Facultad 53: Ciencias Empresariales (UDE Uruguay)
(7,53),(8,53),(10,53),(9,53),

-- Facultad 54: Tecnologías de la Información (UTEC Uruguay)
(1,54),(31,54),

-- Facultad 55: Energías y Mecatrónica (UTEC Uruguay)
(4,55),(2,55),(6,55);

-- ========================
-- 5. Roles
-- ========================
INSERT INTO Rol (nombre)
VALUES
('Administrador'),
('Usuario');


-- 6. Usuarios

INSERT INTO Usuario (nombre, apellido, email, contrasena, id_rol, id_ciudad)
VALUES
('Admin', 'General', 'admin@univia.com', 'admin123', 1, 1),
('Juan', 'Pérez', 'juan@univia.com', 'pass123', 2, 1),
('María', 'Gómez', 'maria@univia.com', 'maria456', 2, 1);


-- 7. Perfiles

INSERT INTO Perfil (id_usuario)
VALUES
(1),
(2),
(3);

INSERT INTO Carrera_Usuario (id_usuario, id_carrera) VALUES
(1, 1),
(1, 7),
(1, 17);

INSERT INTO Carrera_Usuario (id_usuario, id_carrera) VALUES
(2, 1),
(2, 31);

INSERT INTO Carrera_Usuario (id_usuario, id_carrera) VALUES
(3, 17);

INSERT INTO Publicacion 
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, id_usuario)
VALUES
('Apuntes de Álgebra I', 'Resumen completo de la materia con ejercicios resueltos', 'archivo', 'publico', 1, 2);

INSERT INTO Publicacion 
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
VALUES
('Guía de Programación I', 'Guía básica para parciales, incluye ejemplos en C', 'libro_fisico', 'privado', 1, 10000, 3);

INSERT INTO Publicacion 
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, precio, id_usuario)
VALUES
('Libro de cálculo diferencial', 'Versión digital para estudio', 'libro_fisico', 'privado', 1, 15000.00, 1);

INSERT INTO Publicacion 
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, id_usuario)
VALUES
('Resumen Historia Económica', 'Resumen para el parcial final', 'archivo', 'publico', 1, 3);

INSERT INTO Publicacion 
(titulo, descripcion, tipo_recurso, tipo_acceso, descargable, id_usuario)
VALUES
('Ejercicios de Física I', 'Colección de problemas resueltos', 'archivo', 'Privado', 1, 3);

INSERT INTO Archivo (nombre, ruta, tipo, id_publicacion)
VALUES
('apuntes_algebra.pdf', 'uploads/publicaciones/1/apuntes_algebra.pdf', 'pdf', 1),

('resumen_historia_economica.docx', 'uploads/publicaciones/4/histora_econ.docx', 'docx', 4),

('ejercicios_fisica.zip', 'uploads/publicaciones/5/ejercicios.zip', 'zip', 5);

INSERT INTO Publicacion_Carrera (id_carrera, id_publicacion)
VALUES
(1, 1), -- Apuntes de Álgebra I → Carrera 1 (por ej. Ingeniería)
(1, 5), -- Ejercicios de Física I → Carrera 1

(1, 2), -- Guía de Programación I → Carrera 2 (por ej. Sistemas)
(2, 3), -- Libro de cálculo → Carrera 2

(8, 4), -- Resumen Historia Económica → Carrera 3

(4, 3), -- Libro de cálculo → Carrera 4 (otra carrera compatible)
(5, 1); -- Apuntes de Álgebra también válido para otra carrera

INSERT INTO Valoracion (id_publicacion, id_usuario, puntuacion, comentario)
VALUES
(1, 2, 5, 'Muy buenos apuntes, súper claros.'),
(1, 1, 4, 'Buen material, aunque le faltan algunos ejemplos.'),

(2, 1, 5, 'Excelente guía de programación, muy completa.'),
(2, 2, 3, 'Útil, pero podría estar mejor organizada.'),

(3, 2, 4, 'El libro está bien resumido y fácil de leer.'),

(4, 1, 5, 'Material impecable, me sirvió muchísimo.'),
(5, 2, 4, 'Me ayudó a aprobar la materia. Gracias!');
