--Facturación por categoría y marca
--Categoría, marca, unidades vendidas y total facturado
SELECT 
    c.nombre AS CATEGORIA,
    m.nombre AS MARCA,
    SUM(dv.cantidad) AS UNIDADES_VENDIDAS,
    SUM(dv.subtotal) AS TOTAL_FACTURADO
FROM CATEGORIA c
JOIN PRODUCTO p ON p.CATEGORIA_id_categoria = c.id_categoria
JOIN MARCA m ON p.MARCA_id_marca = m.id_marca
JOIN DETALLE_VENTA dv ON dv.PRODUCTO_id_producto = p.id_producto
GROUP BY c.nombre, m.nombre
ORDER BY TOTAL_FACTURADO DESC;