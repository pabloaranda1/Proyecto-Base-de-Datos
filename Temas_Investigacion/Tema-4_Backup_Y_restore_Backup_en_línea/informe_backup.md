# Implementación y Verificación de Estrategias de Backup y Restore

**Implementación y Verificación de Estrategias de Backup y Restore, incluyendo Backup en Línea en la Base de Datos Univia**

---

### Tabla de Contenidos

1.  [Resumen](#resumen)
2.  [Introducción](#i-introducción)
3.  [Marco Teórico](#ii-marco-teórico)
    * [2.1 Definición de Backup y Restore](#21-definición-de-backup-y-restore)
    * [2.2 Backup en Línea y Modelos de Recuperación](#22-backup-en-línea-y-modelos-de-recuperación)
    * [2.3 Comparativa y Casos de Uso](#23-comparativa-y-casos-de-uso)
4.  [Metodología y Ejecución de Tareas](#iii-metodología-y-ejecución-de-tareas)
    * [3.1 Preparación del Entorno](#31-preparación-del-entorno)
    * [3.2 Tarea 1: Verificar y Establecer Modelo de Recuperación](#32-tarea-1-verificar-y-establecer-modelo-de-recuperación)
    * [3.3 Tarea 2: Realizar un Backup Full](#33-tarea-2-realizar-un-backup-full)
    * [3.4 Tarea 3: Generar 10 Inserts (Lote 1)](#34-tarea-3-generar-10-inserts-lote-1)
    * [3.5 Tarea 4: Primer Backup del Archivo de Log (Log 1)](#35-tarea-4-primer-backup-del-archivo-de-log-log-1)
    * [3.6 Tarea 5: Generar otros 10 Inserts (Lote 2)](#36-tarea-5-generar-otros-10-inserts-lote-2)
    * [3.7 Tarea 6: Segundo Backup del Archivo de Log (Log 2)](#37-tarea-6-segundo-backup-del-archivo-de-log-log-2)
5.  [Resultados y Verificación de la Restauración](#iv-resultados-y-verificación-de-la-restauración)
    * [4.1 Tarea 7: Restaurar al Momento del Primer Backup de Log](#41-tarea-7-restaurar-al-momento-del-primer-backup-de-log)
    * [4.2 Tarea 8: Verificación del Resultado (Escenario 1)](#42-tarea-8-verificación-del-resultado-escenario-1)
    * [4.3 Tarea 9: Restaurar Aplicando Ambos Archivos de Log](#43-tarea-9-restaurar-aplicando-ambos-archivos-de-log)
    * [4.4 Verificación (Escenario 2)](#44-verificación-escenario-2)
6.  [Conclusiones](#v-conclusiones)
7.  [Referencias](#vi-referencias)

---

## Resumen

Este informe detalla la implementación práctica y la validación de las técnicas de backup y restore en un entorno de SQL Server,
utilizando la base de datos `Univia` como modelo de estudio. El objetivo principal  es conocer y aplicar estrategias de respaldo para asegurar la integridad y recuperación de datos, 
con un enfoque específico en el "backup en línea" mediante el uso de copias de seguridad del log de transacciones. Se configuró el modelo de recuperación de la base de datos a `Full`,
se ejecutó un backup completo, y posteriormente se realizaron backups de log incrementales tras la inserción de datos en la tabla `Material`. 
Los procedimientos de restauración se validaron en dos puntos distintos del tiempo, demostrando la capacidad de recuperación granular. Los resultados verificaron la restauración exitosa
de los datos a los puntos indicados, cumpliendo con los objetivos de aprendizaje y demostrando la efectividad del proceso.

---

## I. Introducción

En la administración de bases de datos, la garantía de la continuidad del negocio depende fundamentalmente de la capacidad de recuperar datos ante fallos de hardware, 
errores humanos o desastres. La pérdida de información puede ser un problema muy grave. Por lo tanto, el diseño e implementación de una estrategia robusta de respaldo (backup) 
y recuperación (restore) es una competencia esencial.

Este informe se centra en la aplicación práctica de dichas estrategias en la base de datos `Univia`. Los objetivos de aprendizaje específicos son:

* Conocer las técnicas de backup y restore.
* Comprender y aplicar el concepto de backup en línea (mediante copias de log).
* Implementar una estrategia de respaldo para asegurar la integridad y la capacidad de recuperación de los datos.

Para alcanzar estos objetivos, se ejecutó una serie de tareas predefinidas en SQL Server, documentando cada comando y verificando los resultados de la restauración en la tabla `Material`.

---

## II. Marco Teórico

### 2.1 Definición de Backup y Restore

Un **backup** (copia de seguridad) es el proceso de crear una copia de los datos de la base de datos en un instante específico. Esta copia se almacena en un medio separado y
su propósito es permitir la restauración de los datos en caso de que los datos originales se pierdan o corrompan.

El **restore** (restauración) es el proceso inverso. Consiste en utilizar una copia de seguridad para devolver la base de datos a un estado anterior, utilizable y coherente.

### 2.2 Backup en Línea y Modelos de Recuperación

El término **"backup en línea"** (Online Backup) se refiere a la capacidad de realizar un backup mientras la base de datos sigue siendo operada y accesible para los usuarios.
En el contexto de SQL Server y la recuperación granular, este término se asocia directamente con las **copias de seguridad del log de transacciones**.

El log de transacciones es un archivo que registra cada modificación realizada en la base de datos. La capacidad de respaldar este log depende del **Modelo de Recuperación** configurado:

* **Modelo Simple:** Trunca el log automáticamente después de que las transacciones se escriben en el archivo de datos. No permite backups de log.
* La recuperación solo es posible hasta el último backup *full* o *diferencial*, implicando una alta probabilidad de pérdida de datos.
* **Modelo Completo (Full):** Registra y retiene todas las transacciones en el log hasta que este sea respaldado. Es el requisito indispensable para el "backup en línea" granular,
* ya que permite la **recuperación a un punto específico en el tiempo**.

### 2.3 Comparativa y Casos de Uso

| Característica | Backup Full (Completo) | Backup de Log (Backup en Línea) |
| :--- | :--- | :--- |
| **Contenido** | Copia completa de todas las páginas de datos de la base de datos. | Copia de todas las transacciones ocurridas desde el último backup de log. |
| **Requisito** | Ninguno especial. | Modelo de Recuperación "Full" o "Bulk-Logged". |
| **Tamaño** | Grande. | Pequeño (depende de la actividad). |
| **Frecuencia** | Baja (ej: diario, semanal). | Alta (ej: cada 15 min, cada hora). |
| **Pérdida de Datos (RPO)** | Alta. Se pierden todos los cambios desde el último backup full. | Muy baja. Se pierden solo los cambios desde el último backup de log. |

¿Cuál es mejor? No son excluyentes, son complementarios y se usan en conjunto.

* Se debe usar **Backup Full** como base de cualquier estrategia (ej: uno al día a la medianoche).
* Se debe usar **Backup de Log** en entornos críticos (producción, sistemas transaccionales como `Univia`) donde la pérdida de datos es inaceptable. 
* Una estrategia común es: 1 Backup Full diario y Backups de Log cada 15 minutos.

---

## III. Metodología y Ejecución de Tareas

A continuación, se documenta el proceso práctico realizado nuestra base de datos `Univia`.

### 3.1 Preparación del Entorno

Antes de iniciar los backups, se creó la base de datos `Univia` y se insertaron los datos primarios necesarios en las tablas `Pais`, `Universidad`, `Carrera`, `Rol` y `Usuario`
para permitir inserciones en la tabla `Material`.

```-- Creación de la base de datos
CREATE DATABASE Univia;
GO
USE Univia;
GO

-- Inserción de datos de referencia (FKs)
-- Estos inserts deben seguir el orden de dependencia del nuevo modelo

-- 1. Pais (ID = 1)
INSERT INTO Pais (nombre) VALUES ('Argentina');
GO

-- 2. Universidad (ID = 1, depende de Pais 1)
INSERT INTO Universidad (nombre, facultad, id_pais) 
VALUES ('Universidad Nacional del Nordeste', 'Facultad de Ingeniería', 1);
GO

-- 3. Carrera (ID = 1, depende de Universidad 1)
INSERT INTO Carrera (nombre, id_universidad) 
VALUES ('Ingeniería en Informática', 1);
GO

-- 4. Rol (ID = 1)
INSERT INTO Rol (nombre_rol) VALUES ('Estudiante');
GO

-- 5. Usuario (ID = 1, depende de Rol 1)
INSERT INTO Usuario (correo, contrasena, id_rol) 
VALUES ('estudiante.prueba@univia.com', 'pass123', 1);
GO

-- 6. Perfil (NUEVO INSERT REQUERIDO POR EL NUEVO MODELO)
-- (ID = 1, depende de Usuario 1 y Carrera 1)
INSERT INTO Perfil (nombre, apellido, id_usuario, id_carrera)
VALUES ('Juan', 'Perez', 1, 1);
GO

-- Con esto, tenemos id_carrera = 1 y id_usuario = 1 listos para usar en la tabla Material.
```

### 3.2 Tarea 1: Verificar y establecer modelo de recuperación

Para permitir el backup de logs (backup en línea), el modelo debe ser `Full`.

**Comando:**
```sql
-- 1. Verificar el modelo actual
SELECT name, recovery_model_desc 
FROM sys.databases 
WHERE name = 'Univia';
GO

-- 2. Establecer el modelo a FULL (si no lo estuviera)
ALTER DATABASE Univia SET RECOVERY FULL;
GO
```

### 3.3 Tarea 2: Realizar un Backup Full

Se genera el backup completo inicial, que sirve como base para todas las restauraciones futuras.

**Comando:**
```sql
/* NOTA: La ruta 'C:\Backups\' debe existir en el servidor */
BACKUP DATABASE Univia
TO DISK = 'C:\Backups\Univia_Full.bak'
WITH NAME = 'Univia - Backup Full Inicial',
     DESCRIPTION = 'Base para la cadena de logs';
GO
```

### 3.4 Tarea 3: Generar 10 inserts (Lote 1)

Se simula actividad transaccional insertando 10 registros en la tabla `Material`.

**Comando:**
```sql
USE Univia;
GO
-- Insertamos el primer lote de 10 materiales
INSERT INTO Material (titulo, descripcion, tipo_archivo, formato, acceso, estado, id_usuario, id_carrera)
VALUES
('Apuntes S.O.', 'Resumen U1', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Parcial Algebra', 'Resuelto 2022', 'IMG', '.jpg', 'Publico', 'Aprobado', 1, 1),
('Guia TPs Redes', 'Ejercicios prácticos', 'DOCX', '.docx', 'Publico', 'Aprobado', 1, 1),
('Resumen BDD', 'Modelo Relacional', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Final Paradigmas', 'Preguntas y Respuestas', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Intro a IA', 'Capítulo 1 Libro', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Ejemplo UML', 'Diagrama de Clases', 'IMG', '.png', 'Publico', 'Aprobado', 1, 1),
('Tutorial Git', 'Comandos básicos', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Template Tesis', 'Formato APA', 'DOCX', '.docx', 'Publico', 'Aprobado', 1, 1),
('Video Fisica 1', 'Link a clase MRU', 'Link', '.url', 'Publico', 'Aprobado', 1, 1);
GO
```

### 3.5 Tarea 4: Primer Backup del archivo de Log (Log 1)

Se respalda el log de transacciones, capturando los 10 *inserts* del Lote 1.

**Comando:**
```sql
BACKUP LOG Univia
TO DISK = 'C:\Backups\Univia_Log1.trn'
WITH NAME = 'Univia - Log 1 (Post Lote 1)';
GO
```
*Hora de Backup Registrada: [15/11/2025 11:30:05 AM]*
*(Nota: Se debe registrar la hora exacta en que finaliza este comando).*

### 3.6 Tarea 5: Generar otros 10 inserts (Lote 2)

Se simula mas actividad en la base de datos.

**Comando:**
```sql
USE Univia;
GO
-- Insertamos el segundo lote de 10 materiales
INSERT INTO Material (titulo, descripcion, tipo_archivo, formato, acceso, estado, id_usuario, id_carrera)
VALUES
('Guia S.O. U2', 'Administración de Procesos', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Modelo ER', 'Diagrama BD Restaurante', 'IMG', '.png', 'Publico', 'Aprobado', 1, 1),
('Taller Python', 'Ejercicios POO', 'ZIP', '.zip', 'Publico', 'Aprobado', 1, 1),
('Audio Ingles', 'Listening Practice B2', 'MP3', '.mp3', 'Publico', 'Aprobado', 1, 1),
('Parcial Calculo II', 'Resuelto 2023', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Resumen Arqui', 'Modelo Von Neumann', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Presentacion Redes', 'Modelo OSI vs TCP/IP', 'PPTX', '.pptx', 'Publico', 'Aprobado', 1, 1),
('Libro Estadistica', 'Probabilidad y Muestreo', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Final Ing. Software', 'Metodologías Ágiles', 'PDF', '.pdf', 'Publico', 'Aprobado', 1, 1),
('Plan de Negocios', 'Template Emprendimiento', 'DOCX', '.docx', 'Publico', 'Aprobado', 1, 1);
GO
```

### 3.7 Tarea 6: Segundo Backup del archivo de Log (Log 2)

Se respalda el log nuevamente, capturando solo las 10 transacciones del Lote 2.

**Comando:**
```sql
BACKUP LOG Univia
TO DISK = 'C:\Backups\Univia_Log2.trn'
WITH NAME = 'Univia - Log 2 (Post Lote 2)';
GO
```

---

## IV. Resultados y verificación de la restauración

Se realizan dos escenarios de restauración para validar el proceso. Para no sobrescribir la base de datos original, las restauraciones se realizan con un nuevo nombre (`Univia_Restaurada`).

### 4.1 Tarea 7: Restaurar al momento del primer Backup de Log

**Objetivo:** Restaurar la base de datos al estado exacto después del Lote 1 (solo 10 registros).

**Proceso de Restauración:**
* **Paso 1:** Restaurar el Backup Full `WITH NORECOVERY`. Esto deja la base de datos en estado "Restaurando", lista para recibir logs.
* **Paso 2:** Aplicar el Log 1 `WITH RECOVERY`. Esto aplica las transacciones del Log 1 y pone la base de datos en línea.

**Comandos:**
```sql
/* NOTA IMPORTANTE: Se debe usar la cláusula MOVE 
para renombrar los archivos físicos y evitar conflictos 
con la base de datos 'Univia' original.
Las rutas deben ser válidas en el servidor.
*/
USE master;
GO
-- Paso 1: Restaurar el Full sin recuperación
RESTORE DATABASE Univia_Restaurada
FROM DISK = 'C:\Backups\Univia_Full.bak'
WITH NORECOVERY,
MOVE 'Univia' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest.mdf',
MOVE 'Univia_log' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest.ldf';
GO

-- Paso 2: Aplicar el Log 1 y poner la base de datos en línea
RESTORE LOG Univia_Restaurada
FROM DISK = 'C:\Backups\Univia_Log1.trn'
WITH RECOVERY;
GO
```

### 4.2 Tarea 8: Verificación del resultado (Escenario 1)

Se verifica el conteo de registros en la tabla `Material` de la base de datos restaurada.

**Comando:**
```sql
USE Univia_Restaurada;
GO
SELECT COUNT(*) AS TotalMateriales FROM Material;
GO
```

**Resultado Obtenido:**
> TotalMateriales
>---------------
> 10

*Este resultado confirma que la base de datos se restauró exitosamente al punto en el tiempo deseado, conteniendo únicamente el Lote 1 de inserciones.*

### 4.3 Tarea 9: Restaurar Aplicando Ambos Archivos de Log

**Objetivo:** Restaurar la base de datos a su estado más reciente, conteniendo los 20 *inserts* (Lote 1 + Lote 2).

**Proceso de Restauración:**
* **Paso 1:** Restauramos el Backup Full `WITH NORECOVERY`.
* **Paso 2:** Aplicamos el Log 1 `WITH NORECOVERY`. (Se mantiene en modo "Restaurando").
* **Paso 3:** Aplicamos el Log 2 `WITH RECOVERY`. (Aplica el Lote 2 y pone la base de datos en línea).

**Comandos:**
```sql
USE master;
GO
-- (Se asume que se borró 'Univia_Restaurada' o se usa un nombre nuevo)
-- Paso 1: Restaurar el Full (NORECOVERY)
RESTORE DATABASE Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Full.bak'
WITH NORECOVERY,
MOVE 'Univia' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest_Full.mdf',
MOVE 'Univia_log' TO 'C:\Program Files\Microsoft SQL Server\...\DATA\Univia_Rest_Full.ldf';
GO

-- Paso 2: Aplicar el Log 1 (NORECOVERY)
RESTORE LOG Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Log1.trn'
WITH NORECOVERY;
GO

-- Paso 3: Aplicar el Log 2 (RECOVERY)
RESTORE LOG Univia_Restaurada_Completa
FROM DISK = 'C:\Backups\Univia_Log2.trn'
WITH RECOVERY;
GO
```

### 4.4 Verificación (Escenario 2)

**Comando:**
```sql
USE Univia_Restaurada_Completa;
GO
SELECT COUNT(*) AS TotalMateriales FROM Material;
GO
```
**Resultado Obtenido:**
> TotalMateriales
>---------------
> 20

*Este resultado confirma que la cadena completa de logs se aplicó correctamente, restaurando todos los datos generados (Lote 1 y Lote 2).*

---

## V. Conclusiones

Tras la ejecución de las tareas y la verificación de los resultados en nuestra base de datos `Univia`, se llego a las siguientes conclusiones:

1.  **Efectividad del Proceso:** La implementación de los procedimientos de backup y restore fue exitosa.
    Los criterios de evaluación se cumplieron, ya que la restauración de datos a los puntos indicados (10 registros tras el Log 1, y 20 registros tras el Log 2) 
    fue verificada correctamente mediante consultas `SELECT COUNT(*)`.
2.  **Importancia del Modelo "Full":** Se demostró empíricamente que el modelo de recuperación `Full` es el requisito indispensable para la estrategia de "backup en línea". 
   Sin este modelo, la Tarea 4 (Backup Log) habría fallado.
3.  **Valor del Backup en Línea (Logs):** La estrategia de backups de log permite una recuperación granular, conocida como "Point-in-Time Recovery" (PITR). 
 Esto se demostró en la Tarea 7, donde se recuperó la base de datos a un estado intermedio (solo 10 registros), ignorando la actividad posterior (el Lote 2),
 esto es crítico para entornos de producción como lo es `Univia`, ya que minimiza la pérdida de datos (RPO) de horas a minutos.
4.  **Cumplimiento de Objetivos:** Se cumplieron los objetivos de aprendizaje, logrando un conocimiento práctico de las técnicas de backup 
 (`BACKUP DATABASE`, `BACKUP LOG`) y restore (`RESTORE DATABASE`, `RESTORE LOG`), y la importancia de la secuencia de comandos (`NORECOVERY` vs. `RECOVERY`).

En resumen, la combinación de backups *full* periódicos y backups de *log* frecuentes constituyen la estrategia de recuperación de desastres más robusta y esencial
para cualquier sistema de base de datos transaccional.

---

## VI. Referencias

* Microsoft. (2023, Septiembre 27). *Modelos de recuperación (SQL Server)*. Microsoft Learn. https://learn.microsoft.com/es-es/sql/relational-databases/backup-restore/recovery-models-sql-server
* Microsoft. (2023, Septiembre 27). *Restaurar copias de seguridad de registros de transacciones (SQL Server)*. Microsoft Learn. https://learn.microsoft.com/es-es/sql/relational-databases/backup-restore/restore-a-transaction-log-backup-sql-server
* Microsoft. (2024, Mayo 13). *Información general de copia de seguridad (SQL Server)*. Microsoft Learn. https://learn.microsoft.com/es-es/sql/relational-databases/backup-restore/backup-overview-sql-server