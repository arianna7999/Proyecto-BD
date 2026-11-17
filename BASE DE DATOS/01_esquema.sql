/* =============================================================================
   01_esquema.sql
   Proyecto Final - Taller de Base de Datos
   Competencia 1: Lenguaje de definición de datos (DDL)

   Tema:   Sistema de paquetería (clientes, conductores, paquetes y asignación
           de entregas)
   Equipo: Jose Ricardo Juárez López    (24130068)
           Arianna Jazmin Alcaraz Feliz (24130034)

   ----------------------------------------------------------------------------- */
DROP DATABASE IF EXISTS paqueteria_db;

CREATE DATABASE paqueteria_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE paqueteria_db;

CREATE TABLE Clientes (
    id_cliente      INT          NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(60)  NOT NULL,
    apellidos       VARCHAR(80)  NOT NULL,
    telefono        VARCHAR(10)  NOT NULL,
    correo          VARCHAR(100) NOT NULL,
    direccion       VARCHAR(150) NOT NULL,
    ciudad          VARCHAR(60)  NOT NULL,
    fecha_registro  DATE         NOT NULL DEFAULT (CURRENT_DATE),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,

    CONSTRAINT pk_clientes          PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_correo   UNIQUE (correo),
    CONSTRAINT ck_clientes_telefono CHECK (telefono REGEXP '^[0-9]{10}$'),
    CONSTRAINT ck_clientes_activo   CHECK (activo IN (0, 1))
) ENGINE = InnoDB;


CREATE TABLE Conductores (
    id_conductor        INT          NOT NULL AUTO_INCREMENT,
    nombre              VARCHAR(60)  NOT NULL,
    apellidos           VARCHAR(80)  NOT NULL,
    telefono            VARCHAR(10)  NOT NULL,
    numero_licencia     VARCHAR(20)  NOT NULL,
    tipo_licencia       VARCHAR(15)  NOT NULL,
    vigencia_licencia   DATE         NOT NULL,
    vehiculo            VARCHAR(50)  NOT NULL,
    placas              VARCHAR(10)  NOT NULL,
    estado              VARCHAR(12)  NOT NULL DEFAULT 'Disponible',
    fecha_contratacion  DATE         NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT pk_conductores           PRIMARY KEY (id_conductor),
    CONSTRAINT uq_conductores_licencia  UNIQUE (numero_licencia),
    CONSTRAINT ck_conductores_tipo      CHECK (tipo_licencia IN ('Automovilista', 'Chofer', 'Motociclista')),
    CONSTRAINT ck_conductores_estado    CHECK (estado IN ('Disponible', 'En ruta', 'Inactivo'))
) ENGINE = InnoDB;


CREATE TABLE Paquetes (
    id_paquete           INT           NOT NULL AUTO_INCREMENT,
    codigo_rastreo       VARCHAR(20)   NOT NULL,
    id_cliente           INT           NOT NULL,
    descripcion          VARCHAR(150)  NOT NULL,
    peso_kg              DECIMAL(6,2)  NOT NULL,
    costo_envio          DECIMAL(10,2) NOT NULL,
    nombre_destinatario  VARCHAR(100)  NOT NULL,
    direccion_destino    VARCHAR(200)  NOT NULL,
    ciudad_destino       VARCHAR(60)   NOT NULL,
    fecha_registro       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado               VARCHAR(12)   NOT NULL DEFAULT 'Registrado',

    CONSTRAINT pk_paquetes          PRIMARY KEY (id_paquete),
    CONSTRAINT uq_paquetes_rastreo  UNIQUE (codigo_rastreo),
    CONSTRAINT ck_paquetes_peso     CHECK (peso_kg > 0 AND peso_kg <= 70),
    CONSTRAINT ck_paquetes_costo    CHECK (costo_envio >= 0),
    CONSTRAINT ck_paquetes_estado   CHECK (estado IN ('Registrado', 'Asignado', 'En ruta', 'Entregado', 'Cancelado')),


    CONSTRAINT fk_paquetes_cliente  FOREIGN KEY (id_cliente)
        REFERENCES Clientes (id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


CREATE TABLE Asignacion_Entregas (
    id_asignacion     INT          NOT NULL AUTO_INCREMENT,
    id_paquete        INT          NOT NULL,
    id_conductor      INT          NOT NULL,
    fecha_asignacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega     DATETIME     NULL,
    estado_entrega    VARCHAR(12)  NOT NULL DEFAULT 'Pendiente',
    observaciones     VARCHAR(200) NULL,

    CONSTRAINT pk_asignacion          PRIMARY KEY (id_asignacion),
    CONSTRAINT uq_asignacion_unica    UNIQUE (id_paquete, id_conductor, fecha_asignacion),
    CONSTRAINT ck_asignacion_estado   CHECK (estado_entrega IN ('Pendiente', 'En ruta', 'Entregada', 'Fallida')),
    CONSTRAINT ck_asignacion_fechas   CHECK (fecha_entrega IS NULL OR fecha_entrega >= fecha_asignacion),
    CONSTRAINT ck_asignacion_entregada CHECK (estado_entrega <> 'Entregada' OR fecha_entrega IS NOT NULL),

    -- ON DELETE CASCADE: una asignación no tiene sentido sin su paquete; si el
    --   paquete se elimina (p. ej. se capturó por error), se eliminan también
    --   sus asignaciones.
    -- ON UPDATE CASCADE: se propaga el cambio de id del paquete.
    CONSTRAINT fk_asignacion_paquete   FOREIGN KEY (id_paquete)
        REFERENCES Paquetes (id_paquete)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- ON DELETE RESTRICT: un conductor con entregas en su historial no se
    --   puede borrar; se da de baja con estado = 'Inactivo'.
    -- ON UPDATE CASCADE: se propaga el cambio de id del conductor.
    CONSTRAINT fk_asignacion_conductor FOREIGN KEY (id_conductor)
        REFERENCES Conductores (id_conductor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;



ALTER TABLE Paquetes
    ADD COLUMN fragil TINYINT(1) NOT NULL DEFAULT 0 AFTER peso_kg;

ALTER TABLE Paquetes
    ADD CONSTRAINT ck_paquetes_fragil CHECK (fragil IN (0, 1));


ALTER TABLE Conductores
    ADD CONSTRAINT uq_conductores_placas UNIQUE (placas);


ALTER TABLE Conductores
    ADD CONSTRAINT ck_conductores_telefono CHECK (telefono REGEXP '^[0-9]{10}$');

ALTER TABLE Clientes
    MODIFY COLUMN direccion VARCHAR(200) NOT NULL;


ALTER TABLE Paquetes
    ADD INDEX idx_paquetes_estado (estado),
    ADD INDEX idx_paquetes_fecha  (fecha_registro);

ALTER TABLE Asignacion_Entregas
    ADD INDEX idx_asignacion_estado (estado_entrega);



SELECT VERSION() AS version_mysql;
SHOW VARIABLES LIKE 'port';
SELECT DATABASE() AS base_de_datos_actual;


SHOW TABLES;
DESCRIBE Clientes;
DESCRIBE Conductores;
DESCRIBE Paquetes;
DESCRIBE Asignacion_Entregas;

-- 4.3 Todas las restricciones por tabla (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
SELECT tc.table_name      AS tabla,
       tc.constraint_type AS tipo,
       tc.constraint_name AS restriccion
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'paqueteria_db'
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;


SELECT rc.table_name            AS tabla_hija,
       rc.constraint_name       AS llave_foranea,
       rc.referenced_table_name AS tabla_padre,
       rc.delete_rule           AS on_delete,
       rc.update_rule           AS on_update
FROM information_schema.referential_constraints rc
WHERE rc.constraint_schema = 'paqueteria_db'
ORDER BY rc.table_name;


SELECT cc.constraint_name AS restriccion,
       cc.check_clause    AS condicion
FROM information_schema.check_constraints cc
WHERE cc.constraint_schema = 'paqueteria_db'
ORDER BY cc.constraint_name;
