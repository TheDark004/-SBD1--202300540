# Diccionario de Datos — Proyecto 1
### Sistema de Control de Ventas — Comercial La Estrella
**Bases de Datos 1 · Carné: 202300540**

---

## Catálogos 

### PAIS
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_pais | NUMBER | Identificador único del país | **PK** |
| nombre | VARCHAR2(100) | Nombre del país | NOT NULL, UNIQUE |

### DEPARTAMENTO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_departamento | NUMBER | Identificador único del departamento | **PK** |
| nombre | VARCHAR2(100) | Nombre del departamento | NOT NULL |
| PAIS_id_pais | NUMBER | País al que pertenece | **FK** → PAIS, NOT NULL |
| — | — | Combinación (nombre, PAIS_id_pais) | UNIQUE — el nombre no se repite dentro de un mismo país |

### MUNICIPIO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_municipio | NUMBER | Identificador único del municipio | **PK** |
| nombre | VARCHAR2(100) | Nombre del municipio | NOT NULL |
| DEPARTAMENTO_id_departamento | NUMBER | Departamento al que pertenece | **FK** → DEPARTAMENTO, NOT NULL |
| — | — | Combinación (nombre, DEPARTAMENTO_id_departamento) | UNIQUE |

---

## Catálogos de tienda y personal

### TIPO_TIENDA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_tipo_tienda | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(100) | Ej: conveniencia, supermercado, mayorista, especializada | NOT NULL, UNIQUE |

### CARGO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_cargo | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(50) | Ej: gerente, supervisor, vendedor, cajero | NOT NULL, UNIQUE |

### TIENDA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_tienda | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(100) | Nombre comercial de la tienda | NOT NULL |
| direccion | VARCHAR2(150) | Dirección física | NOT NULL |
| telefono | VARCHAR2(15) | Teléfono de contacto | NOT NULL |
| MUNICIPIO_id_municipio | NUMBER | Ubicación de la tienda | **FK** → MUNICIPIO, NOT NULL |
| TIPO_TIENDA_id_tipo_tienda | NUMBER | Clasificación de la tienda | **FK** → TIPO_TIENDA, NOT NULL |

### EMPLEADO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_empleado | NUMBER | Identificador único | **PK** |
| nombres | VARCHAR2(100) | Nombres del empleado | NOT NULL |
| apellidos | VARCHAR2(100) | Apellidos del empleado | NOT NULL |
| correo | VARCHAR2(100) | Correo electrónico | NOT NULL, UNIQUE |
| telefono | VARCHAR2(15) | Teléfono de contacto | NOT NULL |
| fecha_contratacion | DATE | Fecha de ingreso a la empresa | NOT NULL, CHECK (fecha_contratacion <= SYSDATE) |
| TIENDA_id_tienda | NUMBER | Tienda a la que pertenece | **FK** → TIENDA, NOT NULL |
| CARGO_id_cargo | NUMBER | Puesto que ocupa | **FK** → CARGO, NOT NULL |

---

## Catálogos de cliente

### TIPO_IDENTIFICACION
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_tipo_ident | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(50) | Ej: DPI, pasaporte, NIT | NOT NULL, UNIQUE |

### CLIENTE
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_cliente | NUMBER | Identificador único | **PK** |
| nombres | VARCHAR2(100) | Nombres del cliente | NOT NULL |
| apellidos | VARCHAR2(100) | Apellidos del cliente | NOT NULL |
| numero_identificacion | VARCHAR2(30) | Número del documento de identificación | NOT NULL |
| telefono | VARCHAR2(15) | Teléfono de contacto | *(opcional)* |
| correo | VARCHAR2(100) | Correo electrónico, si lo tiene registrado | *(opcional)*, UNIQUE cuando existe |
| direccion | VARCHAR2(150) | Dirección de residencia | NOT NULL |
| TIPO_IDENT_id_tipo_ident | NUMBER | Tipo de documento presentado | **FK** → TIPO_IDENTIFICACION, NOT NULL |
| MUNICIPIO_id_municipio | NUMBER | Municipio de residencia | **FK** → MUNICIPIO, NOT NULL |
| — | — | Combinación (TIPO_IDENT_id_tipo_ident, numero_identificacion) | UNIQUE |

---

## Catálogos de producto

### CATEGORIA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_categoria | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(50) | Ej: abarrotes, lácteos, electrónica | NOT NULL, UNIQUE |

### MARCA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_marca | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(50) | Marca comercial del producto | NOT NULL, UNIQUE |

### PRODUCTO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_producto | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(100) | Nombre del producto | NOT NULL |
| descripcion | VARCHAR2(300) | Descripción del producto | *(opcional)* |
| precio_vigente | NUMBER(10,2) | Precio de venta actual | NOT NULL, CHECK (precio_vigente > 0) |
| existencia | NUMBER | Cantidad disponible en inventario | NOT NULL, CHECK (existencia >= 0) |
| CATEGORIA_id_categoria | NUMBER | Categoría a la que pertenece | **FK** → CATEGORIA, NOT NULL |
| MARCA_id_marca | NUMBER | Marca a la que pertenece | **FK** → MARCA, NOT NULL |

> **Nota de diseño:** el dataset de origen manejaba precio y existencia por tienda (tabla `CATALOGO_PRODUCTO`). Dado que el enunciado define `precio_vigente` y `existencia` como atributos únicos por producto, se consolidaron: `precio_vigente` = promedio de precios entre tiendas; `existencia` = suma de existencias entre tiendas.

---

## Catálogos de venta

### ESTADO_VENTA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_estado_venta | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(50) | REGISTRADA, PAGADA o ANULADA | NOT NULL, UNIQUE |

### METODO_PAGO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_metodo_pago | NUMBER | Identificador único | **PK** |
| nombre | VARCHAR2(20) | Efectivo, débito, crédito o transferencia | NOT NULL, UNIQUE |

---

## Entidades transaccionales

### VENTA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_venta | NUMBER | Identificador único de la venta | **PK** |
| fecha | DATE | Fecha en que se realizó la venta | NOT NULL |
| TIENDA_id_tienda | NUMBER | Tienda donde se realizó | **FK** → TIENDA, NOT NULL |
| CLIENTE_id_cliente | NUMBER | Cliente que realizó la compra | **FK** → CLIENTE, NOT NULL |
| EMPLEADO_id_empleado | NUMBER | Empleado que atendió la venta | **FK** → EMPLEADO, NOT NULL |
| ESTADO_VENTA_id_estado_venta | NUMBER | Estado actual de la venta | **FK** → ESTADO_VENTA, NOT NULL |

> **Regla de negocio verificada por consulta (no declarativa):** el empleado que atiende la venta debe pertenecer a la misma tienda donde se registra. Validado con `Consulta_Validacion_1.sql` — 0 inconsistencias encontradas.

### DETALLE_VENTA
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_detalle_venta | NUMBER | Identificador único de la línea de detalle | **PK** |
| cantidad | NUMBER | Unidades vendidas de ese producto | NOT NULL, CHECK (cantidad > 0) |
| precio_unitario | NUMBER(10,2) | Precio aplicado al momento de la venta (histórico, no depende del precio actual del producto) | NOT NULL, CHECK (precio_unitario > 0) |
| subtotal | NUMBER(10,2) | cantidad × precio_unitario | NOT NULL |
| VENTA_id_venta | NUMBER | Venta a la que pertenece | **FK** → VENTA, NOT NULL |
| PRODUCTO_id_producto | NUMBER | Producto vendido | **FK** → PRODUCTO, NOT NULL |
| — | — | Combinación (VENTA_id_venta, PRODUCTO_id_producto) | UNIQUE — un producto no se repite en la misma venta |

> **Regla de negocio verificada por consulta (no declarativa):** subtotal = cantidad × precio_unitario. No se implementó como CHECK porque involucra el cálculo entre dos columnas de la misma fila mediante multiplicación, fuera del alcance de restricciones declarativas simples solicitadas; se documenta como criterio de carga de datos.

### PAGO
| Atributo | Tipo/Dominio | Descripción | Restricción |
|---|---|---|---|
| id_pago | NUMBER | Identificador único del pago | **PK** |
| monto | NUMBER(10,2) | Monto pagado | NOT NULL, CHECK (monto > 0) |
| VENTA_id_venta | NUMBER | Venta que se está pagando | **FK** → VENTA, NOT NULL |
| METODO_PAGO_id_metodo_pago | NUMBER | Método utilizado | **FK** → METODO_PAGO, NOT NULL |

> **Regla de negocio verificada por consulta (no declarativa):** la suma de pagos de una venta en estado PAGADA debe ser igual al total de sus detalles. Validado con `Consulta_Validacion_2.sql` — 0 inconsistencias encontradas.

---

## Resumen de normalización aplicada

- **1FN:** todos los atributos son atómicos (`nombres` y `apellidos` se guardan por separado, no como "nombre completo" en un solo campo); no existen grupos repetitivos (los productos de una venta viven en filas separadas de `DETALLE_VENTA`, no en columnas repetidas dentro de `VENTA`).
- **2FN:** todos los atributos no clave dependen de la llave primaria completa. En tablas con llave compuesta implícita como `DETALLE_VENTA` (identificada de forma natural por venta+producto, aunque se usa un id surrogado), ningún atributo depende solo de una parte de esa combinación.
- **3FN:** se eliminaron dependencias transitivas mediante catálogos — por ejemplo, el sector/tipo de tienda, categoría y marca de producto, y la jerarquía geográfica (país->departamento->municipio) se separaron en tablas propias en vez de repetir esos datos como texto libre en las tablas principales.
