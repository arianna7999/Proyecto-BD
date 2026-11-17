

USE paqueteria_db;


-- 1.1 WHERE con igualdad: paquetes que están en ruta
SELECT id_paquete, codigo_rastreo, descripcion, ciudad_destino, estado
FROM Paquetes
WHERE estado = 'En ruta';

-- 1.2 LIKE: búsqueda de clientes por texto en nombre o apellidos
--     (filtro de texto de la pantalla de Clientes)
SELECT id_cliente, CONCAT(nombre, ' ', apellidos) AS cliente, correo, ciudad
FROM Clientes
WHERE nombre LIKE '%Ma%' OR apellidos LIKE '%Ma%'
ORDER BY apellidos;

-- 1.3 LIKE con comodín "_": códigos de rastreo PQ-2026-0010 a PQ-2026-0019
SELECT codigo_rastreo, descripcion, estado
FROM Paquetes
WHERE codigo_rastreo LIKE 'PQ-2026-001_'
ORDER BY codigo_rastreo;

-- 1.4 BETWEEN con fechas: paquetes registrados en octubre de 2026
--     (filtro por rango de fechas de la pantalla de Paquetes)
SELECT id_paquete, codigo_rastreo, fecha_registro, estado
FROM Paquetes
WHERE fecha_registro BETWEEN '2026-10-01 00:00:00' AND '2026-10-31 23:59:59'
ORDER BY fecha_registro;

-- 1.5 BETWEEN con números: paquetes de entre 2 y 10 kg que cuestan de 150 a 300
SELECT codigo_rastreo, descripcion, peso_kg, costo_envio
FROM Paquetes
WHERE peso_kg BETWEEN 2 AND 10
  AND costo_envio BETWEEN 150 AND 300
ORDER BY costo_envio DESC;

-- 1.6 IN: paquetes con destino a alguna de estas ciudades
SELECT codigo_rastreo, nombre_destinatario, ciudad_destino, estado
FROM Paquetes
WHERE ciudad_destino IN ('Monterrey', 'Tijuana', 'Guadalajara')
ORDER BY ciudad_destino, codigo_rastreo;

-- 1.7 IN y NOT IN: conductores activos que no manejan motocicleta
SELECT id_conductor, CONCAT(nombre, ' ', apellidos) AS conductor, tipo_licencia, vehiculo, estado
FROM Conductores
WHERE estado IN ('Disponible', 'En ruta')
  AND tipo_licencia NOT IN ('Motociclista')
ORDER BY conductor;

-- 1.8 IS NULL: asignaciones que todavía no tienen fecha de entrega
SELECT id_asignacion, id_paquete, id_conductor, estado_entrega
FROM Asignacion_Entregas
WHERE fecha_entrega IS NULL
ORDER BY fecha_asignacion;

-- 1.9 BETWEEN: licencias que vencen entre el 1 de noviembre y el 31 de diciembre de 2026
--     (en la app se usaría CURDATE() y DATE_ADD(CURDATE(), INTERVAL 60 DAY))
SELECT id_conductor, CONCAT(nombre, ' ', apellidos) AS conductor, numero_licencia, vigencia_licencia, estado
FROM Conductores
WHERE vigencia_licencia BETWEEN '2026-11-01' AND '2026-12-31'
ORDER BY vigencia_licencia;



-- 2.1 REPORTE: resumen por ciudad de destino
--     GROUP BY + HAVING + COUNT/SUM/AVG/MAX + ORDER BY
--     Solo ciudades con 2 o más paquetes (sin contar los cancelados)
SELECT ciudad_destino                AS ciudad,
       COUNT(*)                      AS total_paquetes,
       SUM(costo_envio)              AS ingreso_total,
       ROUND(AVG(peso_kg), 2)        AS peso_promedio_kg,
       MAX(costo_envio)              AS envio_mas_caro
FROM Paquetes
WHERE estado <> 'Cancelado'
GROUP BY ciudad_destino
HAVING COUNT(*) >= 2
ORDER BY ingreso_total DESC;

-- 2.2 REPORTE mensual: funciones de fecha y CAST
SELECT DATE_FORMAT(fecha_registro, '%Y-%m')   AS mes,
       COUNT(*)                               AS paquetes_registrados,
       SUM(costo_envio)                       AS ingreso_total,
       CAST(AVG(peso_kg) AS DECIMAL(6,2))     AS peso_promedio_kg
FROM Paquetes
GROUP BY DATE_FORMAT(fecha_registro, '%Y-%m')
ORDER BY mes;

-- 2.3 Funciones de cadena: formato de nombre, dominio del correo y teléfono
SELECT id_cliente,
       UPPER(CONCAT(nombre, ' ', apellidos))                       AS nombre_completo,
       CHAR_LENGTH(CONCAT(nombre, ' ', apellidos))                 AS longitud_nombre,
       SUBSTRING_INDEX(correo, '@', -1)                            AS dominio_correo,
       CONCAT('(', LEFT(telefono, 3), ') ', SUBSTRING(telefono, 4, 3), '-', RIGHT(telefono, 4)) AS telefono_formato
FROM Clientes
ORDER BY nombre_completo;

-- 2.4 Funciones de fecha y CONVERT/CAST: tiempo que tardó cada entrega
SELECT id_asignacion,
       id_paquete,
       CONVERT(fecha_asignacion, DATE)                                        AS dia_asignacion,
       DATE_FORMAT(fecha_asignacion, '%d/%m/%Y %H:%i')                        AS asignacion_formato,
       DAYNAME(fecha_asignacion)                                              AS dia_semana,
       TIMESTAMPDIFF(HOUR, fecha_asignacion, fecha_entrega)                   AS horas_para_entregar,
       CAST(TIMESTAMPDIFF(MINUTE, fecha_asignacion, fecha_entrega) / 60 AS DECIMAL(6,1)) AS horas_decimal
FROM Asignacion_Entregas
WHERE estado_entrega = 'Entregada'
ORDER BY horas_para_entregar DESC, id_asignacion;

-- 2.5 REPORTE: gasto por cliente (HAVING sobre una suma)
--     Clientes que han gastado más de $300 en envíos no cancelados
SELECT c.id_cliente,
       CONCAT(c.nombre, ' ', c.apellidos)      AS cliente,
       COUNT(p.id_paquete)                     AS paquetes,
       SUM(p.costo_envio)                      AS gasto_total,
       CAST(AVG(p.costo_envio) AS DECIMAL(10,2)) AS ticket_promedio
FROM Clientes c
INNER JOIN Paquetes p ON p.id_cliente = c.id_cliente
WHERE p.estado <> 'Cancelado'
GROUP BY c.id_cliente, c.nombre, c.apellidos
HAVING SUM(p.costo_envio) > 300
ORDER BY gasto_total DESC;

-- 2.6 REPORTE: desempeño de conductores (solo entregas exitosas)
SELECT co.id_conductor,
       CONCAT(co.nombre, ' ', co.apellidos)                                   AS conductor,
       COUNT(*)                                                               AS entregas_exitosas,
       ROUND(AVG(TIMESTAMPDIFF(HOUR, a.fecha_asignacion, a.fecha_entrega)), 1) AS horas_promedio
FROM Asignacion_Entregas a
INNER JOIN Conductores co ON co.id_conductor = a.id_conductor
WHERE a.estado_entrega = 'Entregada'
GROUP BY co.id_conductor, co.nombre, co.apellidos
HAVING COUNT(*) >= 2
ORDER BY horas_promedio ASC;


-- 3.1 INNER JOIN (2 tablas): paquetes con el nombre de su remitente
SELECT p.codigo_rastreo,
       CONCAT(c.nombre, ' ', c.apellidos) AS remitente,
       c.ciudad                           AS ciudad_origen,
       p.ciudad_destino,
       p.costo_envio,
       p.estado
FROM Paquetes p
INNER JOIN Clientes c ON c.id_cliente = p.id_cliente
ORDER BY p.fecha_registro DESC;

-- 3.2 INNER JOIN (3 tablas): asignaciones con paquete y conductor
SELECT a.id_asignacion,
       p.codigo_rastreo,
       CONCAT(co.nombre, ' ', co.apellidos) AS conductor,
       co.placas,
       a.fecha_asignacion,
       a.estado_entrega
FROM Asignacion_Entregas a
INNER JOIN Paquetes    p  ON p.id_paquete   = a.id_paquete
INNER JOIN Conductores co ON co.id_conductor = a.id_conductor
ORDER BY a.fecha_asignacion DESC;

-- 3.3 INNER JOIN (4 tablas): recorrido completo cliente -> paquete -> conductor
--     de las entregas ya realizadas
SELECT CONCAT(c.nombre, ' ', c.apellidos)   AS remitente,
       p.codigo_rastreo,
       p.nombre_destinatario,
       p.ciudad_destino,
       CONCAT(co.nombre, ' ', co.apellidos) AS conductor,
       a.fecha_entrega
FROM Asignacion_Entregas a
INNER JOIN Paquetes    p  ON p.id_paquete    = a.id_paquete
INNER JOIN Clientes    c  ON c.id_cliente    = p.id_cliente
INNER JOIN Conductores co ON co.id_conductor = a.id_conductor
WHERE a.estado_entrega = 'Entregada'
ORDER BY a.fecha_entrega DESC;

-- 3.4 LEFT JOIN: clientes que nunca han enviado un paquete
SELECT c.id_cliente,
       CONCAT(c.nombre, ' ', c.apellidos) AS cliente,
       c.ciudad,
       c.activo
FROM Clientes c
LEFT JOIN Paquetes p ON p.id_cliente = c.id_cliente
WHERE p.id_paquete IS NULL
ORDER BY c.id_cliente;

-- 3.5 LEFT JOIN + GROUP BY: todos los conductores con su número de asignaciones
--     (incluye a los que tienen 0)
SELECT co.id_conductor,
       CONCAT(co.nombre, ' ', co.apellidos) AS conductor,
       co.estado,
       COUNT(a.id_asignacion)               AS total_asignaciones
FROM Conductores co
LEFT JOIN Asignacion_Entregas a ON a.id_conductor = co.id_conductor
GROUP BY co.id_conductor, co.nombre, co.apellidos, co.estado
ORDER BY total_asignaciones DESC, conductor;

-- 3.6 RIGHT JOIN: paquetes que no tienen ninguna asignación
SELECT p.id_paquete, p.codigo_rastreo, p.ciudad_destino, p.estado
FROM Asignacion_Entregas a
RIGHT JOIN Paquetes p ON p.id_paquete = a.id_paquete
WHERE a.id_asignacion IS NULL
ORDER BY p.id_paquete;


-- 4.1 Subconsulta en WHERE (escalar): paquetes con costo mayor al promedio
SELECT codigo_rastreo, descripcion, costo_envio
FROM Paquetes
WHERE costo_envio > (SELECT AVG(costo_envio) FROM Paquetes)
ORDER BY costo_envio DESC;

-- 4.2 Subconsulta en WHERE con IN: clientes que han enviado paquetes frágiles
SELECT id_cliente, CONCAT(nombre, ' ', apellidos) AS cliente, ciudad
FROM Clientes
WHERE id_cliente IN (SELECT id_cliente FROM Paquetes WHERE fragil = 1)
ORDER BY cliente;

-- 4.3 Subconsulta CORRELACIONADA: última asignación de cada conductor
SELECT a.id_conductor,
       CONCAT(co.nombre, ' ', co.apellidos) AS conductor,
       a.id_paquete,
       a.fecha_asignacion,
       a.estado_entrega
FROM Asignacion_Entregas a
INNER JOIN Conductores co ON co.id_conductor = a.id_conductor
WHERE a.fecha_asignacion = (SELECT MAX(a2.fecha_asignacion)
                            FROM Asignacion_Entregas a2
                            WHERE a2.id_conductor = a.id_conductor)
ORDER BY a.fecha_asignacion DESC;

-- 4.4 Subconsulta en FROM (tabla derivada): total por cliente y luego se une
--     con Clientes para mostrar el nombre; solo clientes con 2 o más paquetes
SELECT c.id_cliente,
       CONCAT(c.nombre, ' ', c.apellidos) AS cliente,
       t.total_paquetes,
       t.gasto_total
FROM (SELECT id_cliente,
             COUNT(*)         AS total_paquetes,
             SUM(costo_envio) AS gasto_total
      FROM Paquetes
      GROUP BY id_cliente) AS t
INNER JOIN Clientes c ON c.id_cliente = t.id_cliente
WHERE t.total_paquetes >= 2
ORDER BY t.gasto_total DESC;

-- 4.5 EXISTS / NOT EXISTS: conductores con entregas asignadas y sin ningún intento fallido
SELECT co.id_conductor, CONCAT(co.nombre, ' ', co.apellidos) AS conductor, co.estado
FROM Conductores co
WHERE EXISTS (SELECT 1
              FROM Asignacion_Entregas a
              WHERE a.id_conductor = co.id_conductor)
  AND NOT EXISTS (SELECT 1
                  FROM Asignacion_Entregas a2
                  WHERE a2.id_conductor = co.id_conductor
                    AND a2.estado_entrega = 'Fallida')
ORDER BY conductor;

-- 5.1 Directorio de contactos: clientes y conductores en un solo listado
SELECT 'Cliente' AS tipo, CONCAT(nombre, ' ', apellidos) AS nombre_completo, telefono
FROM Clientes
UNION
SELECT 'Conductor', CONCAT(nombre, ' ', apellidos), telefono
FROM Conductores
ORDER BY tipo, nombre_completo;

-- 5.2 Ciudades que intervienen en la operación (origen o destino), sin repetir
SELECT ciudad AS ciudad
FROM Clientes
UNION
SELECT ciudad_destino
FROM Paquetes
ORDER BY ciudad;


-- 6.1 Paquetes con los datos del remitente (Clientes + Paquetes)
CREATE OR REPLACE VIEW vw_paquetes_detalle AS
SELECT p.id_paquete,
       p.codigo_rastreo,
       CONCAT(c.nombre, ' ', c.apellidos) AS remitente,
       c.ciudad                           AS ciudad_origen,
       p.descripcion,
       p.peso_kg,
       p.fragil,
       p.costo_envio,
       p.nombre_destinatario,
       p.ciudad_destino,
       p.fecha_registro,
       p.estado
FROM Paquetes p
INNER JOIN Clientes c ON c.id_cliente = p.id_cliente;

-- 6.2 Entregas con datos del paquete y del conductor (Asignacion_Entregas + Paquetes + Conductores)
CREATE OR REPLACE VIEW vw_entregas_conductor AS
SELECT a.id_asignacion,
       p.codigo_rastreo,
       co.id_conductor,
       CONCAT(co.nombre, ' ', co.apellidos)                    AS conductor,
       co.vehiculo,
       co.placas,
       p.ciudad_destino,
       a.fecha_asignacion,
       a.fecha_entrega,
       a.estado_entrega,
       TIMESTAMPDIFF(HOUR, a.fecha_asignacion, a.fecha_entrega) AS horas_entrega,
       a.observaciones
FROM Asignacion_Entregas a
INNER JOIN Paquetes    p  ON p.id_paquete    = a.id_paquete
INNER JOIN Conductores co ON co.id_conductor = a.id_conductor;

-- 6.3 Uso de la vista vw_paquetes_detalle: paquetes pendientes de salir
SELECT codigo_rastreo, remitente, ciudad_destino, costo_envio, estado
FROM vw_paquetes_detalle
WHERE estado IN ('Registrado', 'Asignado')
ORDER BY fecha_registro;

-- 6.4 Uso de la vista vw_entregas_conductor: entregas exitosas por conductor
SELECT conductor,
       COUNT(*)                     AS entregas,
       ROUND(AVG(horas_entrega), 1) AS horas_promedio
FROM vw_entregas_conductor
WHERE estado_entrega = 'Entregada'
GROUP BY id_conductor, conductor
ORDER BY entregas DESC, conductor;


/* -----------------------------------------------------------------------------
   7. CONSULTAS PARAMETRIZADAS
   En C# se enviarán con MySqlCommand y parámetros (@texto, @desde, @hasta...),
   nunca concatenando el texto del usuario. Aquí se simulan con variables de
   sesión para ver el resultado.
   ----------------------------------------------------------------------------- */

-- 7.1 Filtro por texto (pantalla de Clientes)
SET @texto = 'ez';
SELECT id_cliente, CONCAT(nombre, ' ', apellidos) AS cliente, correo, ciudad
FROM Clientes
WHERE nombre    LIKE CONCAT('%', @texto, '%')
   OR apellidos LIKE CONCAT('%', @texto, '%')
   OR correo    LIKE CONCAT('%', @texto, '%')
ORDER BY apellidos;

-- 7.2 Filtro por rango de fechas y de peso (pantalla de Paquetes)
SET @desde = '2026-10-01';
SET @hasta = '2026-11-10';
SET @peso_min = 1;
SET @peso_max = 10;
SELECT codigo_rastreo, descripcion, peso_kg, fecha_registro, estado
FROM Paquetes
WHERE DATE(fecha_registro) BETWEEN @desde AND @hasta
  AND peso_kg BETWEEN @peso_min AND @peso_max
ORDER BY fecha_registro;
