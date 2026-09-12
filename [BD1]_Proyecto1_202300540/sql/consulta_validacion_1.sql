-- Ventas cuyo empleado no pertenece a la misma tienda (regla de negocio)
SELECT v.id_venta, v.TIENDA_id_tienda AS tienda_venta, e.TIENDA_id_tienda AS tienda_empleado
FROM VENTA v
JOIN EMPLEADO e ON v.EMPLEADO_id_empleado = e.id_empleado
WHERE v.TIENDA_id_tienda != e.TIENDA_id_tienda;