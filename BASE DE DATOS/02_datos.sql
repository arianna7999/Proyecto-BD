/* =============================================================================
   02_datos.sql
   Proyecto Final - Taller de Base de Datos
   Competencia 2 (2.1): Inserción, modificación y eliminación de datos

   Requiere haber ejecutado antes 01_esquema.sql.
   Todos los datos son ficticios.

   Registros cargados:
     Clientes            15
     Conductores         15
     Paquetes            20
     Asignacion_Entregas 20

   El script se puede ejecutar varias veces: vacía las tablas antes de cargar.
   ============================================================================= */

USE paqueteria_db;
SET NAMES utf8mb4;


/* -----------------------------------------------------------------------------
   0. LIMPIEZA (permite volver a cargar los datos sin recrear el esquema)
   ----------------------------------------------------------------------------- */
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Asignacion_Entregas;
TRUNCATE TABLE Paquetes;
TRUNCATE TABLE Conductores;
TRUNCATE TABLE Clientes;
SET FOREIGN_KEY_CHECKS = 1;


/* -----------------------------------------------------------------------------
   1. CLIENTES (15)
   Los clientes 13 y 15 están inactivos. Los clientes 13, 14 y 15 no tienen
   paquetes (sirven para probar consultas con LEFT JOIN).
   ----------------------------------------------------------------------------- */
INSERT INTO Clientes (nombre, apellidos, telefono, correo, direccion, ciudad, fecha_registro, activo) VALUES
('María Fernanda',  'López Hernández',  '6621234501', 'maria.lopez@ejemplo.com',       'Av. Reforma 215, Col. Centro',             'Hermosillo',       '2026-01-12', 1),
('Carlos Alberto',  'Ramírez Soto',     '3312345602', 'carlos.ramirez@ejemplo.com',    'Calle Hidalgo 48, Col. Americana',         'Guadalajara',      '2026-01-20', 1),
('Lucía Alejandra', 'Gámez Valenzuela', '8112345703', 'lucia.gamez@ejemplo.com',       'Calle Morelos 120, Col. Obispado',         'Monterrey',        '2026-02-03', 1),
('Jorge Luis',      'Medina Cota',      '5512345804', 'jorge.medina@ejemplo.com',      'Av. Insurgentes 330, Col. Roma Norte',     'Ciudad de México', '2026-02-17', 1),
('Ana Patricia',    'Castro Ibarra',    '6641234905', 'ana.castro@ejemplo.com',        'Blvd. Agua Caliente 1500, Col. Revolución','Tijuana',          '2026-03-05', 1),
('Luis Enrique',    'Beltrán Ochoa',    '6671235006', 'luis.beltran@ejemplo.com',      'Calle Rosales 92, Col. Tierra Blanca',     'Culiacán',         '2026-03-22', 1),
('Sofía Guadalupe', 'Quintero Parra',   '6861235107', 'sofia.quintero@ejemplo.com',    'Calzada Independencia 410, Col. Nueva',    'Mexicali',         '2026-04-09', 1),
('Miguel Ángel',    'Torres Félix',     '6141235208', 'miguel.torres@ejemplo.com',     'Av. Universidad 1200, Col. Campestre',     'Chihuahua',        '2026-04-28', 1),
('Daniela',         'Ruiz Montoya',     '4421235309', 'daniela.ruiz@ejemplo.com',      'Calle Corregidora 58, Col. Centro',        'Querétaro',        '2026-05-14', 1),
('Ricardo',         'Salazar Duarte',   '2221235410', 'ricardo.salazar@ejemplo.com',   'Av. 11 Sur 2305, Col. Santiago',           'Puebla',           '2026-06-02', 1),
('Valeria',         'Mendoza Cruz',     '9991235511', 'valeria.mendoza@ejemplo.com',   'Calle 60 No. 450, Col. Centro',            'Mérida',           '2026-06-19', 1),
('Fernando',        'Aguilar Peña',     '8711235612', 'fernando.aguilar@ejemplo.com',  'Av. Hidalgo 305, Col. Centro',             'Torreón',          '2026-07-08', 1),
('Paola',           'Domínguez Lara',   '4771235713', 'paola.dominguez@ejemplo.com',   'Blvd. López Mateos 2020, Col. Jardines',   'León',             '2026-07-25', 0),
('Héctor Manuel',   'Velázquez Rojas',  '8441235814', 'hector.velazquez@ejemplo.com',  'Calle Allende 140, Zona Centro',           'Saltillo',         '2026-08-11', 1),
('Gabriela',        'Nieblas Acosta',   '2291235915', 'gabriela.nieblas@ejemplo.com',  'Calle Independencia 75, Col. Centro',      'Veracruz',         '2026-09-01', 0);


/* -----------------------------------------------------------------------------
   2. CONDUCTORES (15)
   - Conductores 1, 2, 4 y 9 están "En ruta" (tienen una entrega en curso).
   - Conductores 10 y 15 están "Inactivo"; la licencia del 15 ya venció y la
     del 10 vence el 2026-11-30.
   - Conductores 10, 11, 14 y 15 no tienen asignaciones (sirven para LEFT JOIN).
   ----------------------------------------------------------------------------- */
INSERT INTO Conductores (nombre, apellidos, telefono, numero_licencia, tipo_licencia, vigencia_licencia, vehiculo, placas, estado, fecha_contratacion) VALUES
('Roberto Carlos',   'Ibarra Millán',      '6621001001', 'LIC-0001001', 'Chofer',        '2028-03-15', 'Nissan NP300 2021',          'SNA-101-A', 'En ruta',    '2023-02-10'),
('Juan Pablo',       'Valdez Ruiz',        '6621001002', 'LIC-0001002', 'Chofer',        '2027-08-30', 'Ford Transit 2020',          'SNB-202-B', 'En ruta',    '2023-05-22'),
('Karla Yesenia',    'Moreno Salcido',     '6621001003', 'LIC-0001003', 'Automovilista', '2029-01-10', 'Nissan March 2020',          'SNC-303-C', 'Disponible', '2023-09-04'),
('Édgar Iván',       'Burgos Lizárraga',   '6621001004', 'LIC-0001004', 'Motociclista',  '2026-12-20', 'Italika FT150 2022',         'SND-404-D', 'En ruta',    '2024-01-15'),
('Rosa Elena',       'Camacho Rivera',     '6621001005', 'LIC-0001005', 'Chofer',        '2028-06-05', 'Chevrolet Express 2019',     'SNE-505-E', 'Disponible', '2022-11-28'),
('Alan Daniel',      'Espinoza Bojórquez', '6621001006', 'LIC-0001006', 'Chofer',        '2027-02-14', 'RAM ProMaster 2022',         'SNF-606-F', 'Disponible', '2024-03-18'),
('Teresa de Jesús',  'Armenta Corral',     '6621001007', 'LIC-0001007', 'Automovilista', '2029-09-09', 'Renault Kangoo 2021',        'SNG-707-G', 'Disponible', '2024-06-03'),
('Omar Alejandro',   'Lugo Estrada',       '6621001008', 'LIC-0001008', 'Motociclista',  '2027-05-25', 'Honda CG 150 2021',          'SNH-808-H', 'Disponible', '2024-08-12'),
('Brenda Lizeth',    'Sandoval Ochoa',     '6621001009', 'LIC-0001009', 'Chofer',        '2028-10-17', 'Mercedes-Benz Sprinter 2019','SNJ-909-J', 'En ruta',    '2023-12-01'),
('Gilberto',         'Ponce Acuña',        '6621001010', 'LIC-0001010', 'Chofer',        '2026-11-30', 'Hyundai H100 2020',          'SNK-010-K', 'Inactivo',   '2021-04-19'),
('Mónica Alejandra', 'Urías Verdugo',      '6621001011', 'LIC-0001011', 'Automovilista', '2029-04-22', 'Volkswagen Saveiro 2020',    'SNL-111-L', 'Disponible', '2024-10-07'),
('Sergio Iván',      'Cota Palomares',     '6621001012', 'LIC-0001012', 'Chofer',        '2027-11-11', 'Kia K2500 2019',             'SNM-212-M', 'Disponible', '2022-07-25'),
('Lorena Isabel',    'Figueroa Tapia',     '6621001013', 'LIC-0001013', 'Chofer',        '2028-12-01', 'Toyota Hiace 2021',          'SNN-313-N', 'Disponible', '2025-01-13'),
('Mauricio',         'Zazueta Leyva',      '6621001014', 'LIC-0001014', 'Motociclista',  '2028-02-28', 'Italika DM200 2023',         'SNP-414-P', 'Disponible', '2025-03-24'),
('Dulce María',      'Rendón Galaz',       '6621001015', 'LIC-0001015', 'Automovilista', '2026-09-30', 'Chevrolet Tornado 2018',     'SNQ-515-Q', 'Inactivo',   '2022-02-14');


/* -----------------------------------------------------------------------------
   3. PAQUETES (20)
   Estados: 1-11 Entregado | 12-15 En ruta | 16-17 Asignado |
            18-19 Registrado | 20 Cancelado
   Los clientes 13, 14 y 15 no tienen paquetes.
   (La columna fragil se agregó con ALTER TABLE en 01_esquema.sql.)
   ----------------------------------------------------------------------------- */
INSERT INTO Paquetes (codigo_rastreo, id_cliente, descripcion, peso_kg, fragil, costo_envio, nombre_destinatario, direccion_destino, ciudad_destino, fecha_registro, estado) VALUES
('PQ-2026-0001',  1, 'Laptop en caja sellada',              3.50, 1, 185.00, 'Andrea Salas Peña',              'Calle Morelos 120, Col. Centro',      'Guadalajara',      '2026-10-02 09:15:00', 'Entregado'),
('PQ-2026-0002',  2, 'Documentos legales (sobre)',          0.30, 0,  95.00, 'Notaría Pública No. 14',         'Av. Reforma 800, Piso 3',             'Hermosillo',       '2026-10-03 10:40:00', 'Entregado'),
('PQ-2026-0003',  3, 'Caja de refacciones automotrices',   12.80, 0, 320.00, 'Taller El Rápido',               'Calle Industria 55, Col. Obrera',     'Monterrey',        '2026-10-05 12:05:00', 'Entregado'),
('PQ-2026-0004',  4, 'Ropa deportiva (2 cajas)',            6.20, 0, 210.00, 'Mariana Tovar Leyva',           'Av. Universidad 410, Col. Campestre', 'Chihuahua',        '2026-10-07 08:30:00', 'Entregado'),
('PQ-2026-0005',  5, 'Equipo de audio',                     8.40, 1, 275.50, 'Estudio Sonoro MX',              'Calle Amsterdam 45, Col. Condesa',    'Ciudad de México', '2026-10-09 16:20:00', 'Entregado'),
('PQ-2026-0006',  1, 'Libros universitarios',               4.75, 0, 140.00, 'Biblioteca Municipal',           'Calle Corregidora 30, Col. Centro',   'Querétaro',        '2026-10-12 11:10:00', 'Entregado'),
('PQ-2026-0007',  6, 'Artesanías de cerámica',              5.60, 1, 230.00, 'Casa de Arte Talavera',          'Av. 2 Poniente 310, Col. Centro',     'Puebla',           '2026-10-14 13:45:00', 'Entregado'),
('PQ-2026-0008',  7, 'Medicamento refrigerado',             1.20, 1, 310.00, 'Clínica Santa Fe',               'Av. del Mar 1010, Zona Dorada',       'Mazatlán',         '2026-10-16 07:50:00', 'Entregado'),
('PQ-2026-0009',  8, 'Herramienta eléctrica',               9.90, 0, 260.00, 'Ferretería La Esperanza',        'Blvd. Díaz Ordaz 2200, Col. Libertad','Tijuana',          '2026-10-19 09:25:00', 'Entregado'),
('PQ-2026-0010',  2, 'Cámara fotográfica',                  2.10, 1, 190.00, 'Foto Estudio Luna',              'Calle 62 No. 305, Col. Centro',       'Mérida',           '2026-10-21 15:00:00', 'Entregado'),
('PQ-2026-0011',  9, 'Material de papelería',               7.30, 0, 175.00, 'Escuela Primaria Benito Juárez', 'Calle Zaragoza 85, Col. Centro',      'Torreón',          '2026-10-26 10:10:00', 'Entregado'),
('PQ-2026-0012',  3, 'Impresora multifuncional',           11.50, 1, 295.00, 'Oficinas Garza y Asociados',     'Av. Constitución 700, Col. Centro',   'Monterrey',        '2026-11-09 09:00:00', 'En ruta'),
('PQ-2026-0013', 10, 'Despensa no perecedera',             15.00, 0, 340.00, 'Comedor Comunitario San José',   'Calle Rosales 410, Col. Las Quintas', 'Culiacán',         '2026-11-10 08:45:00', 'En ruta'),
('PQ-2026-0014',  5, 'Documentos de contrato',              0.45, 0, 110.00, 'Despacho Contable Ortega',       'Calle Serdán 22, Col. Centro',        'Hermosillo',       '2026-11-10 14:20:00', 'En ruta'),
('PQ-2026-0015', 11, 'Vestido de novia (caja)',             4.10, 1, 260.00, 'Salón Bella Novia',              'Av. Chapultepec 1450, Col. Americana','Guadalajara',      '2026-11-12 10:30:00', 'En ruta'),
('PQ-2026-0016', 12, 'Bicicleta infantil desarmada',       13.40, 0, 365.00, 'Carlos Mejía Ortiz',             'Calle Juárez 18, Col. Centro',        'Veracruz',         '2026-11-13 11:15:00', 'Asignado'),
('PQ-2026-0017',  6, 'Libros de texto',                     5.90, 0, 165.00, 'Colegio Horizonte',              'Calzada Independencia 980',           'Mexicali',         '2026-11-13 16:40:00', 'Asignado'),
('PQ-2026-0018',  7, 'Kit de herramientas manuales',       10.20, 0, 285.00, 'Taller Mecánico Rivera',         'Blvd. Agua Caliente 300',             'Tijuana',          '2026-11-14 09:05:00', 'Registrado'),
('PQ-2026-0019',  8, 'Lámpara de decoración',               2.60, 1, 175.00, 'Interiores Casa Nova',           'Av. 5 de Mayo 505, Col. Centro',      'Puebla',           '2026-11-14 13:50:00', 'Registrado'),
('PQ-2026-0020',  9, 'Teléfono celular',                    0.60, 1, 120.00, 'Ana Lucía Barrera',              'Blvd. López Mateos 1100',             'León',             '2026-11-11 17:10:00', 'Cancelado');


/* -----------------------------------------------------------------------------
   4. ASIGNACION_ENTREGAS (20)
   - Los paquetes 5, 10 y 14 tuvieron un primer intento fallido y se
     reasignaron a otro conductor (por eso la relación Paquetes-Conductores es
     N:M).
   - Los paquetes 18, 19 y 20 no tienen asignación.
   ----------------------------------------------------------------------------- */
INSERT INTO Asignacion_Entregas (id_paquete, id_conductor, fecha_asignacion, fecha_entrega, estado_entrega, observaciones) VALUES
( 1,  1, '2026-10-02 11:00:00', '2026-10-03 14:30:00', 'Entregada', 'Entregado en recepción'),
( 2,  3, '2026-10-03 12:00:00', '2026-10-04 10:15:00', 'Entregada', 'Recibió la notaria personalmente'),
( 3,  2, '2026-10-05 14:00:00', '2026-10-06 17:20:00', 'Entregada', NULL),
( 4,  5, '2026-10-07 10:00:00', '2026-10-08 12:40:00', 'Entregada', NULL),
( 5,  4, '2026-10-09 18:00:00', NULL,                  'Fallida',   'Destinatario ausente, se reprograma'),
( 5,  6, '2026-10-10 09:30:00', '2026-10-10 16:45:00', 'Entregada', 'Segundo intento exitoso'),
( 6,  3, '2026-10-12 13:00:00', '2026-10-13 11:05:00', 'Entregada', NULL),
( 7,  7, '2026-10-14 15:30:00', '2026-10-16 10:50:00', 'Entregada', 'Paquete frágil entregado sin daños'),
( 8, 12, '2026-10-16 08:30:00', '2026-10-16 18:10:00', 'Entregada', 'Cadena de frío mantenida'),
( 9,  6, '2026-10-19 11:00:00', '2026-10-20 15:35:00', 'Entregada', NULL),
(10,  8, '2026-10-21 16:30:00', NULL,                  'Fallida',   'Dirección incorrecta'),
(10, 13, '2026-10-22 09:00:00', '2026-10-22 17:25:00', 'Entregada', 'Dirección corregida con el cliente'),
(11,  5, '2026-10-26 12:00:00', '2026-10-27 13:00:00', 'Entregada', NULL),
(12,  1, '2026-11-09 11:00:00', NULL,                  'En ruta',   NULL),
(13,  2, '2026-11-10 10:00:00', NULL,                  'En ruta',   NULL),
(14, 13, '2026-11-10 16:00:00', NULL,                  'Fallida',   'Oficina cerrada al momento de la entrega'),
(14,  4, '2026-11-12 09:00:00', NULL,                  'En ruta',   'Segundo intento'),
(15,  9, '2026-11-12 12:00:00', NULL,                  'En ruta',   NULL),
(16,  3, '2026-11-14 10:00:00', NULL,                  'Pendiente', NULL),
(17,  6, '2026-11-14 11:30:00', NULL,                  'Pendiente', NULL);


/* -----------------------------------------------------------------------------
   5. VERIFICACIÓN DE LA CARGA
   ----------------------------------------------------------------------------- */
SELECT 'Clientes'            AS tabla, COUNT(*) AS registros FROM Clientes
UNION ALL
SELECT 'Conductores'         AS tabla, COUNT(*) AS registros FROM Conductores
UNION ALL
SELECT 'Paquetes'            AS tabla, COUNT(*) AS registros FROM Paquetes
UNION ALL
SELECT 'Asignacion_Entregas' AS tabla, COUNT(*) AS registros FROM Asignacion_Entregas;


/* -----------------------------------------------------------------------------
   6. EJEMPLOS DE UPDATE Y DELETE
   Se ejecutan dentro de una transacción y terminan con ROLLBACK para que los
   datos de prueba queden intactos. En la aplicación C# estas mismas sentencias
   se enviarán con parámetros (@id, @estado, ...), nunca concatenando texto.
   ----------------------------------------------------------------------------- */
START TRANSACTION;

-- 6.1 UPDATE: cambiar el estado de un paquete registrado a asignado
UPDATE Paquetes
SET estado = 'Asignado'
WHERE id_paquete = 18;

-- 6.2 UPDATE: corregir el teléfono de un cliente
UPDATE Clientes
SET telefono = '6621239999'
WHERE id_cliente = 1;

-- 6.3 UPDATE de varias filas: aumento del 10 % a los paquetes que aún no salen
UPDATE Paquetes
SET costo_envio = ROUND(costo_envio * 1.10, 2)
WHERE estado IN ('Registrado', 'Asignado');

-- 6.4 DELETE: eliminar un paquete cancelado que no tiene asignaciones
DELETE FROM Paquetes
WHERE id_paquete = 20 AND estado = 'Cancelado';

-- Revisar el efecto de los cambios dentro de la transacción
SELECT id_paquete, codigo_rastreo, estado, costo_envio FROM Paquetes WHERE id_paquete IN (16, 17, 18, 19, 20);
SELECT id_cliente, telefono FROM Clientes WHERE id_cliente = 1;

-- Deshacer todo: los datos vuelven a su estado original
ROLLBACK;

SELECT id_paquete, codigo_rastreo, estado FROM Paquetes WHERE id_paquete IN (18, 20);
