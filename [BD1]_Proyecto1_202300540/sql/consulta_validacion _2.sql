-- Ventas PAGADAS donde la suma de pagos NO coincide con el total de la venta
SELECT 
    v.id_venta,
    ev.nombre AS estado,
    SUM(dv.subtotal) AS total_venta,
    NVL((SELECT SUM(p.monto) FROM PAGO p WHERE p.VENTA_id_venta = v.id_venta), 0) AS total_pagado
FROM VENTA v
JOIN ESTADO_VENTA ev ON v.ESTADO_VENTA_id_estado_venta = ev.id_estado_venta
JOIN DETALLE_VENTA dv ON dv.VENTA_id_venta = v.id_venta
WHERE ev.nombre = 'PAGADA'
GROUP BY v.id_venta, ev.nombre
HAVING SUM(dv.subtotal) != NVL((SELECT SUM(p.monto) FROM PAGO p WHERE p.VENTA_id_venta = v.id_venta), 0);