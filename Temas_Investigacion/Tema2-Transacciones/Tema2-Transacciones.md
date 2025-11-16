# UNIVERSIDAD NACIONAL DEL NORDESTE  
## BASES DE DATOS I – PROYECTO DE ESTUDIO 

### Tema 2: Manejo de transacciones y transacciones anidadas   
**Grupo:** 41

**Año:** 2025  

## Tabla de contenidos

- [1. Introducción](#1-introducción)
- [2. Por qué usar transacciones SQL. Propiedades](#2-por-que-usar-transacciones-sql-propiedades)
- [3. Modo de transacciones](#3-modo-de-transacciones)
- [4. Control de transacciones](#4-control-de-transacciones)
- [5. Manejo de errores](#5-manejo-de-errores)
- [6. Aislamiento y Bloqueos (Isolation Levels)](#6-aislamiento-y-bloqueos-isolation-levels)
  - [6.1 Problemas de concurrencia](#61-problemas-de-concurrencia)
  - [6.2 Niveles de aislamiento](#62-niveles-de-aislamiento)
- [7. Transacciones anidadas y puntos de guardado](#7-transacciones-anidadas-y-puntos-de-guardado)
  - [7.1 Importancia de @@TRANCOUNT](#71-importancia-de-trancount)
  - [7.2 Reglas y ejemplos](#72-reglas-y-ejemplos)
- [8. Buenas prácticas en el uso de transacciones](#8-buenas-prácticas-en-el-uso-de-transacciones)
- [9. Conclusión](#9-conclusión)

## 1. Introducción
Una transacción es una unidad única de trabajo. Funciona de la manera en que, si una transacción tiene éxito, todas las modificaciones de los datos realizadas durante la transacción se confirman y se convierten en una parte permanente de la base de datos. Si una transacción encuentra errores y debe cancelarse o revertirse, se borran todas las modificaciones de los datos.
El uso de transacciones sirve mucho para garantizar la seguridad e integridad de la base de datos, permite evitar datos corruptos o inconsistentes, y asegurar procesos donde participan varias tablan dependientes entre si.

## 2. Por que usar transacciones SQL. Propiedades

Las transacciones SQL son primordiales en situaciones en las que la coherencia de los datos estaría en riesgo en caso de que fallara cualquiera de una secuencia de instrucciones SQL. Son necesarias porque garantizan que las operaciones sobre la base de datos se realicen de forma segura, consistente y confiable, incluso cuando ocurren errores, fallos del sistema o concurrencia entre múltiples usuarios.
Sin transacciones, la integridad de los datos estaría en riesgo.

Una transaccion debe cumplir las siguientes propiedades:

- Atomicidad: En una transaccion, se ejecutara TODO el bloque de comandos, o NINGUNA accion se realizara.

- Consistencia: La consistencia garantiza que la base de datos siempre pase de un estado válido a otro estado válido. Si antes de la transacción tus datos cumplían con todas las reglas después de la transacción también deben cumplirlas.

- Isolamiento	El aislamiento asegura que dos o más transacciones simultáneas no se estorben entre sí, y que el resultado sea el mismo que si se hubieran ejecutado una tras otra.

- Durabilidad	la durabilidad se refiere a que una vez que una transacción se ha completado, sus cambios son permanentes. Los datos quedan guardados de forma segura, y no hay riesgo de que desaparezcan de la nada.

## 3. Modo de transacciones
SQL Server funciona en los modos de transacción siguientes:

- Transacciones de confirmación automática: Cada instrucción individual es una transacción. Es el comportamiento por defecto de SQL Server. Significa que cada sentencia SQL (INSERT, UPDATE, DELETE, SELECT…) se ejecuta como una transacción individual

- Transacciones implícitas: Una nueva transacción se inicia implícitamente cuando se completa la transacción anterior, pero cada transacción se completa explícitamente con una COMMIT instrucción o ROLLBACK .
-- SET IMPLICIT_TRANSACTIONS ON

- Transacciones explícita: Cada transacción se inicia explícitamente con la BEGIN TRANSACTION instrucción y finaliza explícitamente con una COMMIT instrucción o ROLLBACK.
Este es el punto más importante

- Transacciones con ámbito por lotes: Una transacción implícita o explícita de Transact-SQL que se inicia en una sesión de MARS (conjuntos de resultados activos múltiples), que solo es aplicable a MARS, se convierte en una transacción de ámbito de lote. Sql Server revierte automáticamente una transacción de ámbito por lotes que no se confirma o revierte cuando se completa un lote.

## 4. Control de transacciones

Los siguientes comandos se utilizan para controlar las transacciones.

- COMMIT − archiva los cambios en la transacción.
- ROLLBACK - para revertir los cambios.
- SAVEPOINT - puede hacer puntos dentro de una transacción SQL, los cuales puede deshacer con ROLLBACK.
- SET TRANSACTION - puede nombrar una transacción.

Cada transacción SQL debe comenzar con la palabra clave SQL BEGIN TRANSACTION, BEGIN TRAN o BEGIN TRANSACTION.
Cada transacción en SQL Server debe terminar con instrucciones COMMIT o ROLLBACK.
COMMIT TRANSACTION: esta declaración le dice al SQL que guarde los cambios realizados entre BEGIN y COMMIT. Hay varias formas de escribir esta declaración. Puede escribir COMMIT, COMMIT TRAN, COMMIT TRANSACTION o COMMIT TRANSACTION.
ROLLBACK TRANSACTION: esta declaración le dice al SQL que borre todos los cambios realizados entre BEGIN y ROLLBACK. Hay varias formas de escribir esta declaración. Puede escribir ROLLBACK, ROLLBACK TRAN, ROLLBACK TRANSACTION o ROLLBACK TRANSACTION.

Sintaxis de una transicion simple: 

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Codigo de las acciones a realizar en la transaccion

        COMMIT TRANSACTION; -- Confirma los cambios
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION; -- Revierte los cambios si hay error
    END CATCH;

## 5. Manejo de errores

La declaración TRY-CATCH implementa el manejo de errores en SQL Server. Puede encerrar cualquier grupo de declaraciones en transacciones SQL en un TRYbloque. Luego, si ocurre un error en el TRYbloque, el control se pasa a otro grupo de sentencias que está encerrado en un CATCHbloque.

Usamos el CATCH bloque para revertir la transacción. Dado que está en el CATCHbloque, la reversión solo ocurre si hay un error.

El manejo de errores es fundamental porque una transacción debe cumplir Atomicidad (o se hace toda completa o no se hace nada).
Si no se maneja correctamente, podés quedar con datos insertados a medias o inconsistentes.
Si algo falla dentro del TRY → salta al CATCH, y siempre se realizara un ROLLBACK (nunca COMMIT). Tambien se suele mostrar el error captado para hacer DEBBUGING.

Ejemplo de una transaccion simple en nuestro sistema:


    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Usuario (nombre, email)
        VALUES ('Pablo', 'pablo@mail.com');

        INSERT INTO Perfil (id_usuario, descripcion)
        VALUES (SCOPE_IDENTITY(), 'Estudiante de Sistemas');

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;

        SELECT ERROR_MESSAGE() AS ErrorSQL;
    END CATCH;


## 6. Aislamiento y Bloqueos (Isolation Levels)

Las bases de datos permiten que varias transacciones trabajen al mismo tiempo.
Pero eso genera problemas de concurrencia.

Para controlarlo existen los Niveles de Aislamiento, que determinan:

- qué bloqueos se aplican
- qué fenómenos se permiten o no
- cuánto se afecta el rendimiento

Cuanto mas aislamiento se aplique, más seguridad y menos concurrencia

### 6.1 Problemas de concurrencia
- Lectura sucia (Dirty Read):
Leer datos que otra transacción aún no ha confirmado.
Si luego hace ROLLBACK , se ha leido datos falsos.

- Lectura no repetible (Non-Repeatable Read):
Volver a leer una fila y aparece modificada.

- Lectura fantasma (Phantom Read):
Volver a ejecutar la misma consulta y aparecen filas nuevas.

### 6.2 Niveles de aislamiento

- READ UNCOMMITTED: Es el nivel de aislamiento más bajo y permite que una transacción lea datos que otra transacción todavía no confirmó, lo que se conoce como lectura sucia. No aplica bloqueos de lectura. Este nivel es útil para consultas analíticas o informes donde se privilegia la velocidad sobre la exactitud total. Su desventaja principal es que una transacción puede devolver datos incorrectos si otra hace un ROLLBACK.

- READ COMMITTED: Es el nivel de aislamiento predeterminado en SQL Server. Evita las lecturas sucias al requerir que una transacción solo lea datos ya confirmados, aplicando bloqueos de lectura mientras se accede a las filas. Sin embargo, aún permite lecturas no repetibles y lecturas fantasma, ya que otra transacción podría modificar o insertar filas entre dos lecturas. Es un nivel equilibrado entre rendimiento y seguridad, adecuado para la mayoría de las aplicaciones transaccionales.

- REPEATABLE READ: Este nivel garantiza que si una transacción lee una fila, ninguna otra transacción podrá modificarla hasta que la primera termine. Así se evitan las lecturas no repetibles. Sin embargo, permite lecturas fantasma, ya que otras transacciones pueden insertar nuevas filas que coincidan con la condición de búsqueda. Implica más bloqueos que READ COMMITTED, por lo que ofrece mayor consistencia a costa de reducir la concurrencia.

- SERIALIZABLE: Es el nivel de aislamiento más estricto. Evita lecturas sucias, lecturas no repetibles y lecturas fantasma, garantizando que la ejecución concurrente de transacciones sea equivalente a ejecutarlas una tras otra. Para lograrlo, SQL Server aplica bloqueos de rango que impiden no solo leer o modificar filas existentes, sino también insertar nuevas que coincidan con la consulta. Aporta la mayor seguridad, pero también es el que más reduce la concurrencia y aumenta los bloqueos.

- SNAPSHOT: Este nivel ofrece un aislamiento lógico muy alto sin usar bloqueos de lectura. En lugar de bloquear, SQL Server trabaja con versiones de los datos almacenadas en tempdb mediante multiversionamiento (MVCC). La transacción siempre ve una “foto” consistente del estado de la base de datos en el momento en que comenzó, evitando lecturas sucias, no repetibles y fantasmas. Es ideal para sistemas con mucha concurrencia, aunque requiere más uso de espacio en disco y configuración adicional del servidor.

## 7. Transacciones anidadas y puntos de guardado
Transacciones anidadas son transacciones dentro de transacciones. Aunque no todos los RDBMS los admiten directamente, pueden simularse utilizando savepoints para proporcionar un control más fino de las operaciones.
Una transacción anidada ocurre cuando, dentro de una transacción principal ya iniciada, se ejecuta otro BEGIN TRAN.

SQL Server no crea realmente una transacción nueva: solo incrementa un contador interno (@@TRANCOUNT). Esto significa que todas las transacciones internas dependen de la externa: el COMMIT de una transacción interna no confirma los cambios, solo reduce el contador. La única transacción que realmente confirma o revierte los cambios es la transacción externa (la primera que se inició).

Los puntos de salvaguarda permiten retrocesos parciales dentro de una misma transacción, lo que te permite aislar y recuperarte de errores en partes concretas de una transacción más significativa. SQL Server permite crear Puntos de Guardado usando SAVE TRAN 'nombre'. Son esenciales para manejar errores parciales dentro de un mismo flujo.

Cómo funcionan los puntos de guardado:
- Inicia una transacción.
- Define puntos de guardado en etapas críticas de la transacción.
- Retrocede a un punto de guardado si surge un problema sin descartar toda la transacción.
- Confirma la transacción cuando todas las operaciones se hayan realizado correctamente.

Cuando se produce un error dentro de un bloque específico, SQL Server permite hacer ROLLBACK solo hasta un punto de guardado, en lugar de cancelar toda la transacción. Esto permite continuar el flujo sin perder las operaciones previas que ya estaban correctamente ejecutadas.

### 7.1 Importancia de @@TRANCOUNT 

@@TRANCOUNT indica cuántas transacciones están abiertas actualmente.

Es fundamental por dos razones:
Determinar si es seguro hacer COMMIT o ROLLBACK
Si @@TRANCOUNT = 0, no hay transacciones activas.

Evitar errores por ROLLBACK indebidos
Un ROLLBACK total hace que @@TRANCOUNT baje a 0, sin importar cuántos niveles anidados hubiera.
Esto implica que si un bloque interno ejecuta ROLLBACK sin control, puede cancelar toda la operación general.

    IF @@TRANCOUNT > 0
        ROLLBACK;

### 7.2 Reglas y ejemplos

Las transacciones anidadas siguen reglas estrictas:

Cada BEGIN TRAN incrementa @@TRANCOUNT.
Cada COMMIT decrementa @@TRANCOUNT, pero solo el último COMMIT (cuando @@TRANCOUNT llega a 1) confirma realmente los cambios en la base de datos.
Un ROLLBACK siempre revierte toda la transacción, sin importar cuántos niveles había, a menos que se use un savepoint.
Los COMMIT internos son “virtuales”: no confirman nada en la base hasta que la transacción externa haga su COMMIT real.
Un ROLLBACK elimina todos los savepoints creados previamente.
Esto significa que el control real siempre lo tiene la transacción más externa.

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO Publicacion (titulo) VALUES ('Apunte de Probabilidad');

        SAVE TRAN InsertArchivo;

        INSERT INTO Archivo (ruta) 
        VALUES ('/uploads/apunte.pdf');

        -- Algo falla acá
        DECLARE @x INT = 1/0;

        COMMIT;
    END TRY
    BEGIN CATCH
        -- Revierto solo el archivo, pero NO la publicación
        ROLLBACK TRAN InsertArchivo;

        COMMIT;  -- confirmo la parte que sí funciona
    END CATCH;

## 8. Buenas prácticas en el uso de transacciones

El uso adecuado de transacciones es fundamental para garantizar integridad, rendimiento y coherencia en la base de datos. A continuación se presentan las mejores prácticas recomendadas:

- Mantener las transacciones lo más cortas posible
- Evitar transacciones dentro de bucles
- Siempre utilizar TRY/CATCH
- No abusar del nivel SERIALIZABLE
- Registrar el estado y los errores
- Controlar @@TRANCOUNT
- Evitar operaciones interactivas dentro de una transacción

## 9. Conclusión

Las transacciones son un componente esencial en cualquier sistema que requiera fiabilidad, integridad y consistencia de los datos. Permiten que una serie de operaciones relacionadas se ejecuten como una unidad indivisible, asegurando que los cambios se apliquen completamente o no se apliquen en absoluto.
Los distintos modos de transacción, junto con los niveles de aislamiento, ofrecen herramientas poderosas para manejar concurrencia, evitar problemas de lectura y garantizar estabilidad incluso en escenarios complejos. El uso de TRY/CATCH, savepoints y transacciones anidadas brinda un control granular sobre el flujo de ejecución, permitiendo manejar errores de manera robusta.
Un diseño correcto de transacciones mejora la seguridad y confiabilidad de la base de datos; sin embargo, requiere equilibrio para evitar bloqueos excesivos, pérdida de concurrencia o deterioro de rendimiento. Con una estrategia adecuada, las transacciones se convierten en un pilar fundamental para el funcionamiento consistente y seguro de cualquier sistema de información.
