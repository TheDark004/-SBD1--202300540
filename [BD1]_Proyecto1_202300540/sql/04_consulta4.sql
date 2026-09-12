-- Desempeño de empleados
-- Empleado, cargo, tienda, cantidad de ventas atendidas y total facturado

SELECT 
    e.nombres || ' ' || e.apellidos AS EMPLEADO,
    c.nombre AS CARGO,
    t.nombre AS TIENDA,
    COUNT(DISTINCT v.id_venta) AS CANTIDAD_VENTAS_ATENDIDAS,
    SUM(dv.subtotal) AS TOTAL_FACTURADO
FROM EMPLEADO e
JOIN CARGO c ON e.CARGO_id_cargo = c.id_cargo
JOIN TIENDA t ON e.TIENDA_id_tienda = t.id_tienda
JOIN VENTA v ON v.EMPLEADO_id_empleado = e.id_empleado
JOIN DETALLE_VENTA dv ON dv.VENTA_id_venta = v.id_venta
GROUP BY e.nombres, e.apellidos, c.nombre, t.nombre
ORDER BY TOTAL_FACTURADO DESC;