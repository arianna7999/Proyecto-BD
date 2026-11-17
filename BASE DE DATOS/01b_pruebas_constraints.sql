/* =============================================================================
   01b_pruebas_constraints.sql
   Proyecto Final - Taller de Base de Datos
   Evidencia de que las restricciones del esquema funcionan.

   Requiere haber ejecutado antes 01_esquema.sql y 02_datos.sql.

   IMPORTANTE: las pruebas de la parte A están hechas para FALLAR. Ejecútalas
   una por una (selecciona la sentencia y Ctrl+Enter en Workbench) y toma
   captura del mensaje de error. Si ejecutas todo el archivo de golpe, el
   script se detendrá en el primer error.

   Los números de error son los que MySQL devuelve en el campo Number de
   MySqlException; la aplicación C# los usará para mostrar mensajes claros.
   ============================================================================= */

USE paqueteria_db;

-- A1. UNIQUE: correo de cliente repetido
-- Esperado: ERROR 1062 (23000): Duplicate entry ... for key ... uq_clientes_correo
INSERT INTO Clientes (nombre, apellidos, telefono, correo, direccion, ciudad)
VALUES ('Prueba', 'Duplicado', '6620000001', 'maria.lopez@ejemplo.com', 'Calle 1 #1', 'Hermosillo');

-- A2. UNIQUE: número de licencia repetido
INSERT INTO Conductores (nombre, apellidos, telefono, numero_licencia, tipo_licencia, vigencia_licencia, vehiculo, placas)
VALUES ('Prueba', 'Duplicado', '6620000002', 'LIC-0001001', 'Chofer', '2030-01-01', 'Vehiculo de prueba', 'ZZZ-000-Z');

-- A3. UNIQUE (agregada con ALTER): placas repetidas
INSERT INTO Conductores (nombre, apellidos, telefono, numero_licencia, tipo_licencia, vigencia_licencia, vehiculo, placas)
VALUES ('Prueba', 'Placas', '6620000003', 'LIC-9999999', 'Chofer', '2030-01-01', 'Vehiculo de prueba', 'SNA-101-A');

-- A4. FOREIGN KEY (hija): paquete de un cliente que no existe
INSERT INTO Paquetes (codigo_rastreo, id_cliente, descripcion, peso_kg, costo_envio, nombre_destinatario, direccion_destino, ciudad_destino)
VALUES ('PQ-2026-9001', 999, 'Paquete de prueba', 1.00, 100.00, 'Destinatario', 'Calle 2 #2', 'Monterrey');

-- A5. FOREIGN KEY con ON DELETE RESTRICT: borrar un cliente que tiene paquetes
DELETE FROM Clientes WHERE id_cliente = 1;

-- A6. FOREIGN KEY con ON DELETE RESTRICT: borrar un conductor con historial de entregas
DELETE FROM Conductores WHERE id_conductor = 1;

-- CHECK: peso fuera del rango permitido (máximo 70 kg)
INSERT INTO Paquetes (codigo_rastreo, id_cliente, descripcion, peso_kg, costo_envio, nombre_destinatario, direccion_destino, ciudad_destino)
VALUES ('PQ-2026-9002', 1, 'Paquete demasiado pesado', 150.00, 500.00, 'Destinatario', 'Calle 3 #3', 'Monterrey');

-- A8. CHECK: costo de envío negativo
UPDATE Paquetes SET costo_envio = -10 WHERE id_paquete = 1;

-- A9. CHECK: estado que no existe en el catálogo
-- Esperado: ERROR 3819 (HY000): Check constraint 'ck_paquetes_estado' is violated.
UPDATE Paquetes SET estado = 'Perdido' WHERE id_paquete = 1;

-- A10. CHECK: teléfono que no tiene 10 dígitos
INSERT INTO Clientes (nombre, apellidos, telefono, correo, direccion, ciudad)
VALUES ('Prueba', 'Telefono', '123', 'telefono.malo@ejemplo.com', 'Calle 4 #4', 'Hermosillo');

-- A11. CHECK: fecha de entrega anterior a la fecha de asignación
UPDATE Asignacion_Entregas SET fecha_entrega = '2020-01-01 00:00:00' WHERE id_asignacion = 1;

-- A12. CHECK: una entrega "Entregada" debe tener fecha de entrega
UPDATE Asignacion_Entregas SET fecha_entrega = NULL WHERE id_asignacion = 1;

-- A13. NOT NULL: nombre de cliente nulo
INSERT INTO Clientes (nombre, apellidos, telefono, correo, direccion, ciudad)
VALUES (NULL, 'Sin nombre', '6620000004', 'sin.nombre@ejemplo.com', 'Calle 5 #5', 'Hermosillo');

INSERT INTO Clientes (nombre, apellidos, telefono, correo, direccion)
VALUES ('Prueba', 'Sin ciudad', '6620000005', 'sin.ciudad@ejemplo.com', 'Calle 6 #6');


START TRANSACTION;
INSERT INTO Paquetes (codigo_rastreo, id_cliente, descripcion, peso_kg, costo_envio, nombre_destinatario, direccion_destino, ciudad_destino)
VALUES ('PQ-2026-9003', 1, 'Paquete para probar DEFAULT', 2.00, 120.00, 'Destinatario', 'Calle 7 #7', 'Monterrey');
SELECT codigo_rastreo, estado, fragil, fecha_registro FROM Paquetes WHERE codigo_rastreo = 'PQ-2026-9003';
ROLLBACK;


START TRANSACTION;
UPDATE Clientes SET id_cliente = 100 WHERE id_cliente = 1;
-- Esperado: id_cliente = 100 en el paquete PQ-2026-0001
SELECT codigo_rastreo, id_cliente FROM Paquetes WHERE codigo_rastreo = 'PQ-2026-0001';
ROLLBACK;


START TRANSACTION;

SELECT COUNT(*) AS asignaciones_antes FROM Asignacion_Entregas WHERE id_paquete = 14;
DELETE FROM Paquetes WHERE id_paquete = 14;
-- Después: 0 asignaciones
SELECT COUNT(*) AS asignaciones_despues FROM Asignacion_Entregas WHERE id_paquete = 14;
ROLLBACK;


SELECT COUNT(*) AS asignaciones_paquete_14 FROM Asignacion_Entregas WHERE id_paquete = 14;
