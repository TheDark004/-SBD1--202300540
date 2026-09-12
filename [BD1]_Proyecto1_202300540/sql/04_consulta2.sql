--Ventas por tipo de tienda
--Tipo de tienda, cantidad de tiendas, cantidad de ventas y monto facturado

SELECT 
    tt.nombre AS TIPO_TIENDA,
    COUNT(DISTINCT t.id_tienda) AS CANTIDAD_TIENDAS,
    COUNT(DISTINCT v.id_venta) AS CANTIDAD_VENTAS,
    SUM(dv.subtotal) AS MONTO_FACTURADO
FROM TIPO_TIENDA tt
JOIN TIENDA t ON t.TIPO_TIENDA_id_tipo_tienda = tt.id_tipo_tienda
JOIN VENTA v ON v.TIENDA_id_tienda = t.id_tienda
JOIN DETALLE_VENTA dv ON dv.VENTA_id_venta = v.id_venta
GROUP BY tt.nombre
ORDER BY MONTO_FACTURADO DESC;