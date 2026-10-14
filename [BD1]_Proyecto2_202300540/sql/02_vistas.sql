/* ---------- Vista 1: ventas por tienda y ubicacion (sin anuladas) ---------- */
CREATE OR ALTER VIEW dbo.Vista_Ventas_Ubicacion AS
SELECT
    t.nombre                    AS tienda,
    m.nombre                    AS municipio,
    d.nombre                    AS departamento,
    p.nombre                    AS pais,
    COUNT(DISTINCT v.id_venta)  AS cantidad_ventas,   -- DISTINCT: cada venta se repite por cada linea de detalle
    SUM(dv.subtotal)            AS total_facturado
FROM dbo.TIENDA t
JOIN dbo.MUNICIPIO    m  ON m.id_municipio    = t.MUNICIPIO_id_municipio
JOIN dbo.DEPARTAMENTO d  ON d.id_departamento = m.DEPARTAMENTO_id_departamento
JOIN dbo.PAIS         p  ON p.id_pais         = d.PAIS_id_pais
JOIN dbo.VENTA        v  ON v.TIENDA_id_tienda = t.id_tienda
JOIN dbo.ESTADO_VENTA ev ON ev.id_estado_venta = v.ESTADO_VENTA_id_estado_venta
JOIN dbo.DETALLE_VENTA dv ON dv.VENTA_id_venta = v.id_venta
WHERE ev.nombre <> 'ANULADA'
GROUP BY t.id_tienda, t.nombre, m.nombre, d.nombre, p.nombre;


/* ---------- Vista 2: productos mas vendidos (sin anuladas) ---------- */
CREATE OR ALTER VIEW dbo.Vista_Top_Productos AS
SELECT
    pr.id_producto    AS codigo,
    pr.nombre         AS producto,
    c.nombre          AS categoria,
    ma.nombre         AS marca,
    SUM(dv.cantidad)  AS unidades_vendidas,   -- SUM de unidades, no COUNT de filas
    SUM(dv.subtotal)  AS monto_generado
FROM dbo.PRODUCTO pr
JOIN dbo.CATEGORIA     c  ON c.id_categoria = pr.CATEGORIA_id_categoria
JOIN dbo.MARCA         ma ON ma.id_marca    = pr.MARCA_id_marca
JOIN dbo.DETALLE_VENTA dv ON dv.PRODUCTO_id_producto = pr.id_producto
JOIN dbo.VENTA         v  ON v.id_venta     = dv.VENTA_id_venta
JOIN dbo.ESTADO_VENTA  ev ON ev.id_estado_venta = v.ESTADO_VENTA_id_estado_venta
WHERE ev.nombre <> 'ANULADA'
GROUP BY pr.id_producto, pr.nombre, c.nombre, ma.nombre;


/* ---------- Vista 3: saldos pendientes (solo ventas REGISTRADAS) ---------- */
CREATE OR ALTER VIEW dbo.Vista_Saldos_Pendientes AS
SELECT
    v.id_venta                                    AS venta,
    dt.total_venta                                AS total_venta,
    ISNULL(pg.total_pagado, 0)                    AS total_pagado,      -- ISNULL: equivalente de NVL en Oracle
    dt.total_venta - ISNULL(pg.total_pagado, 0)   AS saldo_pendiente
FROM dbo.VENTA v
JOIN dbo.ESTADO_VENTA ev ON ev.id_estado_venta = v.ESTADO_VENTA_id_estado_venta
-- totales calculados por separado (subconsultas) para no duplicar filas al unir detalle y pagos
JOIN (
    SELECT VENTA_id_venta, SUM(subtotal) AS total_venta
    FROM dbo.DETALLE_VENTA
    GROUP BY VENTA_id_venta
) dt ON dt.VENTA_id_venta = v.id_venta
-- LEFT JOIN: una venta sin ningun pago todavia debe aparecer igual
LEFT JOIN (
    SELECT VENTA_id_venta, SUM(monto) AS total_pagado
    FROM dbo.PAGO
    GROUP BY VENTA_id_venta
) pg ON pg.VENTA_id_venta = v.id_venta
WHERE ev.nombre = 'REGISTRADA';

