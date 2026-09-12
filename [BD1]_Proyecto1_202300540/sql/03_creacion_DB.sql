-- Generado por Oracle SQL Developer Data Modeler 24.3.1.351.0831
--   en:        2026-09-08 02:08:30 CST
--   sitio:      Oracle Database 21c
--   tipo:      Oracle Database 21c



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE CARGO 
    ( 
     id_cargo NUMBER  NOT NULL , 
     nombre   VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE CARGO 
    ADD CONSTRAINT CARGO_PK PRIMARY KEY ( id_cargo ) ;

CREATE TABLE CATEGORIA 
    ( 
     id_categoria NUMBER  NOT NULL , 
     nombre       VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE CATEGORIA 
    ADD CONSTRAINT CATEGORIA_PK PRIMARY KEY ( id_categoria ) ;

CREATE TABLE CLIENTE 
    ( 
     id_cliente               NUMBER  NOT NULL , 
     nombres                  VARCHAR2 (100)  NOT NULL , 
     apellidos                VARCHAR2 (100)  NOT NULL , 
     numero_identificacion    VARCHAR2 (30)  NOT NULL , 
     telefono                 VARCHAR2 (15) , 
     correo                   VARCHAR2 (100) , 
     direccion                VARCHAR2 (150)  NOT NULL , 
     TIPO_IDENT_id_tipo_ident NUMBER  NOT NULL , 
     MUNICIPIO_id_municipio   NUMBER  NOT NULL 
    ) 
;

ALTER TABLE CLIENTE 
    ADD CONSTRAINT CLIENTE_PK PRIMARY KEY ( id_cliente ) ;

ALTER TABLE CLIENTE 
    ADD CONSTRAINT CLIENTE__UN UNIQUE ( TIPO_IDENT_id_tipo_ident , numero_identificacion ) ;

CREATE TABLE DEPARTAMENTO 
    ( 
     id_departamento NUMBER  NOT NULL , 
     nombre          VARCHAR2 (100)  NOT NULL , 
     PAIS_id_pais    NUMBER  NOT NULL 
    ) 
;

ALTER TABLE DEPARTAMENTO 
    ADD CONSTRAINT DEPARTAMENTO_PK PRIMARY KEY ( id_departamento ) ;

ALTER TABLE DEPARTAMENTO 
    ADD CONSTRAINT DEPARTAMENTO__UN UNIQUE ( nombre , PAIS_id_pais ) ;

CREATE TABLE DETALLE_VENTA 
    ( 
     id_detalle_venta     NUMBER  NOT NULL , 
     cantidad             NUMBER  NOT NULL , 
     precio_unitario      NUMBER (10,2)  NOT NULL , 
     subtotal             NUMBER (10,2)  NOT NULL , 
     VENTA_id_venta       NUMBER  NOT NULL , 
     PRODUCTO_id_producto NUMBER  NOT NULL 
    ) 
;

ALTER TABLE DETALLE_VENTA 
    ADD CONSTRAINT DETALLE_VENTA_CK_1 
    CHECK (cantidad>0)
;


ALTER TABLE DETALLE_VENTA 
    ADD CONSTRAINT DETALLE_VENTA_CK_2 
    CHECK (precio_unitario>0)
;
ALTER TABLE DETALLE_VENTA 
    ADD CONSTRAINT DETALLE_VENTA_PK PRIMARY KEY ( id_detalle_venta ) ;

ALTER TABLE DETALLE_VENTA 
    ADD CONSTRAINT DETALLE_VENTA__UN UNIQUE ( VENTA_id_venta , PRODUCTO_id_producto ) ;

CREATE TABLE EMPLEADO 
    ( 
     id_empleado        NUMBER  NOT NULL , 
     nombres            VARCHAR2 (100)  NOT NULL , 
     apellidos          VARCHAR2 (100)  NOT NULL , 
     correo             VARCHAR2 (100)  NOT NULL , 
     telefono           VARCHAR2 (15)  NOT NULL , 
     fecha_contratacion DATE  NOT NULL , 
     TIENDA_id_tienda   NUMBER  NOT NULL , 
     CARGO_id_cargo     NUMBER  NOT NULL 
    ) 
;

ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO_CK_1 
    CHECK (fecha_contratacion<=SYSDATE)
;
ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO_PK PRIMARY KEY ( id_empleado ) ;

ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO__UN UNIQUE ( correo ) ;

CREATE TABLE ESTADO_VENTA 
    ( 
     id_estado_venta NUMBER  NOT NULL , 
     nombre          VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE ESTADO_VENTA 
    ADD CONSTRAINT ESTADO_VENTA_PK PRIMARY KEY ( id_estado_venta ) ;

CREATE TABLE MARCA 
    ( 
     id_marca NUMBER  NOT NULL , 
     nombre   VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE MARCA 
    ADD CONSTRAINT MARCA_PK PRIMARY KEY ( id_marca ) ;

CREATE TABLE METODO_PAGO 
    ( 
     id_metodo_pago NUMBER  NOT NULL , 
     nombre         VARCHAR2 (20)  NOT NULL 
    ) 
;

ALTER TABLE METODO_PAGO 
    ADD CONSTRAINT METODO_PAGO_PK PRIMARY KEY ( id_metodo_pago ) ;

CREATE TABLE MUNICIPIO 
    ( 
     id_municipio                 NUMBER  NOT NULL , 
     nombre                       VARCHAR2 (100)  NOT NULL , 
     DEPARTAMENTO_id_departamento NUMBER  NOT NULL 
    ) 
;

ALTER TABLE MUNICIPIO 
    ADD CONSTRAINT MUNICIPIO_PK PRIMARY KEY ( id_municipio ) ;

ALTER TABLE MUNICIPIO 
    ADD CONSTRAINT MUNICIPIO__UN UNIQUE ( nombre , DEPARTAMENTO_id_departamento ) ;

CREATE TABLE PAGO 
    ( 
     id_pago                    NUMBER  NOT NULL , 
     monto                      NUMBER (10,2)  NOT NULL , 
     VENTA_id_venta             NUMBER  NOT NULL , 
     METODO_PAGO_id_metodo_pago NUMBER  NOT NULL 
    ) 
;

ALTER TABLE PAGO 
    ADD CONSTRAINT PAGO_CK_1 
    CHECK (monto>0)
;
ALTER TABLE PAGO 
    ADD CONSTRAINT PAGO_PK PRIMARY KEY ( id_pago ) ;

CREATE TABLE PAIS 
    ( 
     id_pais NUMBER  NOT NULL , 
     nombre  VARCHAR2 (100)  NOT NULL 
    ) 
;

ALTER TABLE PAIS 
    ADD CONSTRAINT PAIS_PK PRIMARY KEY ( id_pais ) ;

ALTER TABLE PAIS 
    ADD CONSTRAINT PAIS__UN UNIQUE ( nombre ) ;

CREATE TABLE PRODUCTO 
    ( 
     id_producto            NUMBER  NOT NULL , 
     nombre                 VARCHAR2 (100)  NOT NULL , 
     descripcion            VARCHAR2 (300) , 
     precio_vigente         NUMBER (10,2)  NOT NULL , 
     existencia             NUMBER  NOT NULL , 
     CATEGORIA_id_categoria NUMBER  NOT NULL , 
     MARCA_id_marca         NUMBER  NOT NULL 
    ) 
;

ALTER TABLE PRODUCTO 
    ADD CONSTRAINT PRODUCTO_CK_1 
    CHECK (precio_vigente>0)
;


ALTER TABLE PRODUCTO 
    ADD CONSTRAINT PRODUCTO_CK_2 
    CHECK (existencia>=0 
)
;
ALTER TABLE PRODUCTO 
    ADD CONSTRAINT PRODUCTO_PK PRIMARY KEY ( id_producto ) ;

CREATE TABLE TIENDA 
    ( 
     id_tienda                  NUMBER  NOT NULL , 
     nombre                     VARCHAR2 (100)  NOT NULL , 
     direccion                  VARCHAR2 (150)  NOT NULL , 
     telefono                   VARCHAR2 (15)  NOT NULL , 
     MUNICIPIO_id_municipio     NUMBER  NOT NULL , 
     TIPO_TIENDA_id_tipo_tienda NUMBER  NOT NULL 
    ) 
;

ALTER TABLE TIENDA 
    ADD CONSTRAINT TIENDA_PK PRIMARY KEY ( id_tienda ) ;

CREATE TABLE TIPO_IDENTIFICACION 
    ( 
     id_tipo_ident NUMBER  NOT NULL , 
     nombre        VARCHAR2 (50)  NOT NULL 
    ) 
;

ALTER TABLE TIPO_IDENTIFICACION 
    ADD CONSTRAINT TIPO_IDENTIFICACION_PK PRIMARY KEY ( id_tipo_ident ) ;

CREATE TABLE TIPO_TIENDA 
    ( 
     id_tipo_tienda NUMBER  NOT NULL , 
     nombre         VARCHAR2 (100)  NOT NULL 
    ) 
;

ALTER TABLE TIPO_TIENDA 
    ADD CONSTRAINT TIPO_TIENDA_PK PRIMARY KEY ( id_tipo_tienda ) ;

CREATE TABLE VENTA 
    ( 
     id_venta                     NUMBER  NOT NULL , 
     fecha                        DATE  NOT NULL , 
     TIENDA_id_tienda             NUMBER  NOT NULL , 
     CLIENTE_id_cliente           NUMBER  NOT NULL , 
     EMPLEADO_id_empleado         NUMBER  NOT NULL , 
     ESTADO_VENTA_id_estado_venta NUMBER  NOT NULL 
    ) 
;

ALTER TABLE VENTA 
    ADD CONSTRAINT VENTA_PK PRIMARY KEY ( id_venta ) ;

ALTER TABLE CLIENTE 
    ADD CONSTRAINT CLIENTE_MUNICIPIO_FK FOREIGN KEY 
    ( 
     MUNICIPIO_id_municipio
    ) 
    REFERENCES MUNICIPIO 
    ( 
     id_municipio
    ) 
;

ALTER TABLE CLIENTE 
    ADD CONSTRAINT CLIENTE_TIPO_IDENTIFICACION_FK FOREIGN KEY 
    ( 
     TIPO_IDENT_id_tipo_ident
    ) 
    REFERENCES TIPO_IDENTIFICACION 
    ( 
     id_tipo_ident
    ) 
;

ALTER TABLE DEPARTAMENTO 
    ADD CONSTRAINT DEPARTAMENTO_PAIS_FK FOREIGN KEY 
    ( 
     PAIS_id_pais
    ) 
    REFERENCES PAIS 
    ( 
     id_pais
    ) 
;

ALTER TABLE DETALLE_VENTA 
    ADD CONSTRAINT DETALLE_VENTA_PRODUCTO_FK FOREIGN KEY 
    ( 
     PRODUCTO_id_producto
    ) 
    REFERENCES PRODUCTO 
    ( 
     id_producto
    ) 
;

ALTER TABLE DETALLE_VENTA 
    ADD CONSTRAINT DETALLE_VENTA_VENTA_FK FOREIGN KEY 
    ( 
     VENTA_id_venta
    ) 
    REFERENCES VENTA 
    ( 
     id_venta
    ) 
;

ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO_CARGO_FK FOREIGN KEY 
    ( 
     CARGO_id_cargo
    ) 
    REFERENCES CARGO 
    ( 
     id_cargo
    ) 
;

ALTER TABLE EMPLEADO 
    ADD CONSTRAINT EMPLEADO_TIENDA_FK FOREIGN KEY 
    ( 
     TIENDA_id_tienda
    ) 
    REFERENCES TIENDA 
    ( 
     id_tienda
    ) 
;

ALTER TABLE MUNICIPIO 
    ADD CONSTRAINT MUNICIPIO_DEPARTAMENTO_FK FOREIGN KEY 
    ( 
     DEPARTAMENTO_id_departamento
    ) 
    REFERENCES DEPARTAMENTO 
    ( 
     id_departamento
    ) 
;

ALTER TABLE PAGO 
    ADD CONSTRAINT PAGO_METODO_PAGO_FK FOREIGN KEY 
    ( 
     METODO_PAGO_id_metodo_pago
    ) 
    REFERENCES METODO_PAGO 
    ( 
     id_metodo_pago
    ) 
;

ALTER TABLE PAGO 
    ADD CONSTRAINT PAGO_VENTA_FK FOREIGN KEY 
    ( 
     VENTA_id_venta
    ) 
    REFERENCES VENTA 
    ( 
     id_venta
    ) 
;

ALTER TABLE PRODUCTO 
    ADD CONSTRAINT PRODUCTO_CATEGORIA_FK FOREIGN KEY 
    ( 
     CATEGORIA_id_categoria
    ) 
    REFERENCES CATEGORIA 
    ( 
     id_categoria
    ) 
;

ALTER TABLE PRODUCTO 
    ADD CONSTRAINT PRODUCTO_MARCA_FK FOREIGN KEY 
    ( 
     MARCA_id_marca
    ) 
    REFERENCES MARCA 
    ( 
     id_marca
    ) 
;

ALTER TABLE TIENDA 
    ADD CONSTRAINT TIENDA_MUNICIPIO_FK FOREIGN KEY 
    ( 
     MUNICIPIO_id_municipio
    ) 
    REFERENCES MUNICIPIO 
    ( 
     id_municipio
    ) 
;

ALTER TABLE TIENDA 
    ADD CONSTRAINT TIENDA_TIPO_TIENDA_FK FOREIGN KEY 
    ( 
     TIPO_TIENDA_id_tipo_tienda
    ) 
    REFERENCES TIPO_TIENDA 
    ( 
     id_tipo_tienda
    ) 
;

ALTER TABLE VENTA 
    ADD CONSTRAINT VENTA_CLIENTE_FK FOREIGN KEY 
    ( 
     CLIENTE_id_cliente
    ) 
    REFERENCES CLIENTE 
    ( 
     id_cliente
    ) 
;

ALTER TABLE VENTA 
    ADD CONSTRAINT VENTA_EMPLEADO_FK FOREIGN KEY 
    ( 
     EMPLEADO_id_empleado
    ) 
    REFERENCES EMPLEADO 
    ( 
     id_empleado
    ) 
;

ALTER TABLE VENTA 
    ADD CONSTRAINT VENTA_ESTADO_VENTA_FK FOREIGN KEY 
    ( 
     ESTADO_VENTA_id_estado_venta
    ) 
    REFERENCES ESTADO_VENTA 
    ( 
     id_estado_venta
    ) 
;

ALTER TABLE VENTA 
    ADD CONSTRAINT VENTA_TIENDA_FK FOREIGN KEY 
    ( 
     TIENDA_id_tienda
    ) 
    REFERENCES TIENDA 
    ( 
     id_tienda
    ) 
;



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            17
-- CREATE INDEX                             0
-- ALTER TABLE                             47
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
