-- Clientes con mayores compras
-- cliente, municipio, cantidad de ventas pagadas y monto total comprado
SELECT 
    cl.nombres || ' ' || cl.apellidos AS CLIENTE,
    m.nombre AS MUNICIPIO_RESIDENCIA,
    COUNT(DISTINCT v.id_venta) AS CANTIDAD_VENTAS_PAGADAS,
    SUM(dv.subtotal) AS MONTO_TOTAL_COMPRADO
FROM CLIENTE cl
JOIN MUNICIPIO m ON cl.MUNICIPIO_id_municipio = m.id_municipio
JOIN VENTA v ON v.CLIENTE_id_cliente = cl.id_cliente
JOIN ESTADO_VENTA ev ON v.ESTADO_VENTA_id_estado_venta = ev.id_estado_venta
JOIN DETALLE_VENTA dv ON dv.VENTA_id_venta = v.id_venta
WHERE ev.nombre = 'PAGADA'
GROUP BY cl.nombres, cl.apellidos, m.nombre
ORDER BY MONTO_TOTAL_COMPRADO DESC;