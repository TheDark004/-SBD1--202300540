--Ventas por tienda y ubicación
--Tienda, municipio, departamento, país, cantidad de ventas y total facturado; excluir anuladas

SELECT 
    t.nombre AS TIENDA,
    m.nombre AS MUNICIPIO,
    d.nombre AS DEPARTAMENTO,
    p.nombre AS PAIS,
    COUNT(DISTINCT v.id_venta) AS CANTIDAD_VENTAS,
    SUM(dv.subtotal) AS TOTAL_FACTURADO
FROM TIENDA t
JOIN MUNICIPIO m ON t.MUNICIPIO_id_municipio = m.id_municipio
JOIN DEPARTAMENTO d ON m.DEPARTAMENTO_id_departamento = d.id_departamento
JOIN PAIS p ON d.PAIS_id_pais = p.id_pais
JOIN VENTA v ON v.TIENDA_id_tienda = t.id_tienda
JOIN ESTADO_VENTA ev ON v.ESTADO_VENTA_id_estado_venta = ev.id_estado_venta
JOIN DETALLE_VENTA dv ON dv.VENTA_id_venta = v.id_venta
WHERE ev.nombre != 'ANULADA'
GROUP BY t.nombre, m.nombre, d.nombre, p.nombre
ORDER BY TOTAL_FACTURADO DESC;