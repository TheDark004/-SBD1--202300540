-- Productos más vendidos
-- Código, producto, categoría, marca, unidades vendidas y monto generado; excluir anuladas

SELECT 
    p.id_producto AS CODIGO,
    p.nombre AS PRODUCTO,
    c.nombre AS CATEGORIA,
    m.nombre AS MARCA,
    SUM(dv.cantidad) AS UNIDADES_VENDIDAS,
    SUM(dv.subtotal) AS MONTO_GENERADO
FROM PRODUCTO p
JOIN CATEGORIA c ON p.CATEGORIA_id_categoria = c.id_categoria
JOIN MARCA m ON p.MARCA_id_marca = m.id_marca
JOIN DETALLE_VENTA dv ON dv.PRODUCTO_id_producto = p.id_producto
JOIN VENTA v ON dv.VENTA_id_venta = v.id_venta
JOIN ESTADO_VENTA ev ON v.ESTADO_VENTA_id_estado_venta = ev.id_estado_venta
WHERE ev.nombre != 'ANULADA'
GROUP BY p.id_producto, p.nombre, c.nombre, m.nombre
ORDER BY UNIDADES_VENDIDAS DESC;