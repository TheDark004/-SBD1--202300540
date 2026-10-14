-- =====================================================
-- Proyecto Fase 2 - Comercial La Estrella
-- Motor: Microsoft SQL Server 2025
-- Base de Datos: ComercialLaEstrella
-- =====================================================

-- =====================================================
-- 1. TABLAS CATÁLOGO (sin dependencias)
-- =====================================================

CREATE TABLE CARGO (
    id_cargo    INT             NOT NULL,
    nombre      NVARCHAR(50)    NOT NULL,
    CONSTRAINT CARGO_PK PRIMARY KEY (id_cargo)
);

CREATE TABLE CATEGORIA (
    id_categoria    INT             NOT NULL,
    nombre          NVARCHAR(50)    NOT NULL,
    CONSTRAINT CATEGORIA_PK PRIMARY KEY (id_categoria)
);

CREATE TABLE ESTADO_VENTA (
    id_estado_venta INT             NOT NULL,
    nombre          NVARCHAR(50)    NOT NULL,
    CONSTRAINT ESTADO_VENTA_PK PRIMARY KEY (id_estado_venta)
);

CREATE TABLE MARCA (
    id_marca    INT             NOT NULL,
    nombre      NVARCHAR(50)    NOT NULL,
    CONSTRAINT MARCA_PK PRIMARY KEY (id_marca)
);

CREATE TABLE METODO_PAGO (
    id_metodo_pago  INT             NOT NULL,
    nombre          NVARCHAR(20)    NOT NULL,
    CONSTRAINT METODO_PAGO_PK PRIMARY KEY (id_metodo_pago)
);

CREATE TABLE PAIS (
    id_pais INT             NOT NULL,
    nombre  NVARCHAR(100)   NOT NULL,
    CONSTRAINT PAIS_PK PRIMARY KEY (id_pais),
    CONSTRAINT PAIS_UN UNIQUE (nombre)
);

CREATE TABLE TIPO_IDENTIFICACION (
    id_tipo_ident   INT             NOT NULL,
    nombre          NVARCHAR(50)    NOT NULL,
    CONSTRAINT TIPO_IDENTIFICACION_PK PRIMARY KEY (id_tipo_ident)
);

CREATE TABLE TIPO_TIENDA (
    id_tipo_tienda  INT             NOT NULL,
    nombre          NVARCHAR(100)   NOT NULL,
    CONSTRAINT TIPO_TIENDA_PK PRIMARY KEY (id_tipo_tienda)
);

-- =====================================================
-- 2. TABLAS GEOGRÁFICAS (dependen de PAIS)
-- =====================================================

CREATE TABLE DEPARTAMENTO (
    id_departamento INT             NOT NULL,
    nombre          NVARCHAR(100)   NOT NULL,
    PAIS_id_pais    INT             NOT NULL,
    CONSTRAINT DEPARTAMENTO_PK PRIMARY KEY (id_departamento),
    CONSTRAINT DEPARTAMENTO__UN UNIQUE (nombre, PAIS_id_pais),
    CONSTRAINT DEPARTAMENTO_PAIS_FK FOREIGN KEY (PAIS_id_pais)
        REFERENCES PAIS (id_pais)
);

CREATE TABLE MUNICIPIO (
    id_municipio                    INT             NOT NULL,
    nombre                          NVARCHAR(100)   NOT NULL,
    DEPARTAMENTO_id_departamento    INT             NOT NULL,
    CONSTRAINT MUNICIPIO_PK PRIMARY KEY (id_municipio),
    CONSTRAINT MUNICIPIO__UN UNIQUE (nombre, DEPARTAMENTO_id_departamento),
    CONSTRAINT MUNICIPIO_DEPARTAMENTO_FK FOREIGN KEY (DEPARTAMENTO_id_departamento)
        REFERENCES DEPARTAMENTO (id_departamento)
);

-- =====================================================
-- 3. TABLAS DE ENTIDADES PRINCIPALES
-- =====================================================

CREATE TABLE CLIENTE (
    id_cliente                  INT             NOT NULL,
    nombres                     NVARCHAR(100)   NOT NULL,
    apellidos                   NVARCHAR(100)   NOT NULL,
    numero_identificacion       NVARCHAR(30)    NOT NULL,
    telefono                    NVARCHAR(15)    NULL,
    correo                      NVARCHAR(100)   NULL,
    direccion                   NVARCHAR(150)   NOT NULL,
    TIPO_IDENT_id_tipo_ident    INT             NOT NULL,
    MUNICIPIO_id_municipio      INT             NOT NULL,
    CONSTRAINT CLIENTE_PK PRIMARY KEY (id_cliente),
    CONSTRAINT CLIENTE__UN UNIQUE (TIPO_IDENT_id_tipo_ident, numero_identificacion),
    CONSTRAINT CLIENTE_MUNICIPIO_FK FOREIGN KEY (MUNICIPIO_id_municipio)
        REFERENCES MUNICIPIO (id_municipio),
    CONSTRAINT CLIENTE_TIPO_IDENTIFICACION_FK FOREIGN KEY (TIPO_IDENT_id_tipo_ident)
        REFERENCES TIPO_IDENTIFICACION (id_tipo_ident)
);

CREATE TABLE PRODUCTO (
    id_producto             INT             NOT NULL,
    nombre                  NVARCHAR(100)   NOT NULL,
    descripcion             NVARCHAR(300)   NULL,
    precio_vigente          DECIMAL(10,2)   NOT NULL,
    existencia              INT             NOT NULL,
    CATEGORIA_id_categoria  INT             NOT NULL,
    MARCA_id_marca          INT             NOT NULL,
    CONSTRAINT PRODUCTO_PK PRIMARY KEY (id_producto),
    CONSTRAINT PRODUCTO_CK_1 CHECK (precio_vigente > 0),
    CONSTRAINT PRODUCTO_CK_2 CHECK (existencia >= 0),
    CONSTRAINT PRODUCTO_CATEGORIA_FK FOREIGN KEY (CATEGORIA_id_categoria)
        REFERENCES CATEGORIA (id_categoria),
    CONSTRAINT PRODUCTO_MARCA_FK FOREIGN KEY (MARCA_id_marca)
        REFERENCES MARCA (id_marca)
);

CREATE TABLE TIENDA (
    id_tienda                   INT             NOT NULL,
    nombre                      NVARCHAR(100)   NOT NULL,
    direccion                   NVARCHAR(150)   NOT NULL,
    telefono                    NVARCHAR(15)    NOT NULL,
    MUNICIPIO_id_municipio      INT             NOT NULL,
    TIPO_TIENDA_id_tipo_tienda  INT             NOT NULL,
    CONSTRAINT TIENDA_PK PRIMARY KEY (id_tienda),
    CONSTRAINT TIENDA_MUNICIPIO_FK FOREIGN KEY (MUNICIPIO_id_municipio)
        REFERENCES MUNICIPIO (id_municipio),
    CONSTRAINT TIENDA_TIPO_TIENDA_FK FOREIGN KEY (TIPO_TIENDA_id_tipo_tienda)
        REFERENCES TIPO_TIENDA (id_tipo_tienda)
);

CREATE TABLE EMPLEADO (
    id_empleado         INT             NOT NULL,
    nombres             NVARCHAR(100)   NOT NULL,
    apellidos           NVARCHAR(100)   NOT NULL,
    correo              NVARCHAR(100)   NOT NULL,
    telefono            NVARCHAR(15)    NOT NULL,
    fecha_contratacion  DATE            NOT NULL,
    TIENDA_id_tienda    INT             NOT NULL,
    CARGO_id_cargo      INT             NOT NULL,
    CONSTRAINT EMPLEADO_PK PRIMARY KEY (id_empleado),
    CONSTRAINT EMPLEADO__UN UNIQUE (correo),
    CONSTRAINT EMPLEADO_CARGO_FK FOREIGN KEY (CARGO_id_cargo)
        REFERENCES CARGO (id_cargo),
    CONSTRAINT EMPLEADO_TIENDA_FK FOREIGN KEY (TIENDA_id_tienda)
        REFERENCES TIENDA (id_tienda)
);

-- =====================================================
-- 4. TABLAS TRANSACCIONALES
-- =====================================================

CREATE TABLE VENTA (
    id_venta                        INT             NOT NULL,
    fecha                           DATETIME2       NOT NULL,
    TIENDA_id_tienda                INT             NOT NULL,
    CLIENTE_id_cliente              INT             NOT NULL,
    EMPLEADO_id_empleado            INT             NOT NULL,
    ESTADO_VENTA_id_estado_venta    INT             NOT NULL,
    CONSTRAINT VENTA_PK PRIMARY KEY (id_venta),
    CONSTRAINT VENTA_CLIENTE_FK FOREIGN KEY (CLIENTE_id_cliente)
        REFERENCES CLIENTE (id_cliente),
    CONSTRAINT VENTA_EMPLEADO_FK FOREIGN KEY (EMPLEADO_id_empleado)
        REFERENCES EMPLEADO (id_empleado),
    CONSTRAINT VENTA_ESTADO_VENTA_FK FOREIGN KEY (ESTADO_VENTA_id_estado_venta)
        REFERENCES ESTADO_VENTA (id_estado_venta),
    CONSTRAINT VENTA_TIENDA_FK FOREIGN KEY (TIENDA_id_tienda)
        REFERENCES TIENDA (id_tienda)
);

CREATE TABLE DETALLE_VENTA (
    id_detalle_venta        INT             NOT NULL,
    cantidad                INT             NOT NULL,
    precio_unitario         DECIMAL(10,2)   NOT NULL,
    subtotal                DECIMAL(10,2)   NOT NULL,
    VENTA_id_venta          INT             NOT NULL,
    PRODUCTO_id_producto    INT             NOT NULL,
    CONSTRAINT DETALLE_VENTA_PK PRIMARY KEY (id_detalle_venta),
    CONSTRAINT DETALLE_VENTA_CK_1 CHECK (cantidad > 0),
    CONSTRAINT DETALLE_VENTA_CK_2 CHECK (precio_unitario > 0),
    CONSTRAINT DETALLE_VENTA__UN UNIQUE (VENTA_id_venta, PRODUCTO_id_producto),
    CONSTRAINT DETALLE_VENTA_PRODUCTO_FK FOREIGN KEY (PRODUCTO_id_producto)
        REFERENCES PRODUCTO (id_producto),
    CONSTRAINT DETALLE_VENTA_VENTA_FK FOREIGN KEY (VENTA_id_venta)
        REFERENCES VENTA (id_venta)
);

CREATE TABLE PAGO (
    id_pago                         INT             NOT NULL,
    monto                           DECIMAL(10,2)   NOT NULL,
    VENTA_id_venta                  INT             NOT NULL,
    METODO_PAGO_id_metodo_pago      INT             NOT NULL,
    CONSTRAINT PAGO_PK PRIMARY KEY (id_pago),
    CONSTRAINT PAGO_CK_1 CHECK (monto > 0),
    CONSTRAINT PAGO_METODO_PAGO_FK FOREIGN KEY (METODO_PAGO_id_metodo_pago)
        REFERENCES METODO_PAGO (id_metodo_pago),
    CONSTRAINT PAGO_VENTA_FK FOREIGN KEY (VENTA_id_venta)
        REFERENCES VENTA (id_venta)
);

