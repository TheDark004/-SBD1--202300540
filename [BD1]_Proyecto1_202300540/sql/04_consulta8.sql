SELECT 
    v.id_venta AS VENTA,
    dv_totales.total_venta AS TOTAL_VENTA,
    NVL(pg_totales.total_pagado, 0) AS TOTAL_PAGADO,
    dv_totales.total_venta - NVL(pg_totales.total_pagado, 0) AS DIFERENCIA_PENDIENTE
FROM VENTA v
JOIN ESTADO_VENTA ev ON v.ESTADO_VENTA_id_estado_venta = ev.id_estado_venta
JOIN (
    SELECT VENTA_id_venta, SUM(subtotal) AS total_venta
    FROM DETALLE_VENTA GROUP BY VENTA_id_venta
) dv_totales ON dv_totales.VENTA_id_venta = v.id_venta
LEFT JOIN (
    SELECT VENTA_id_venta, SUM(monto) AS total_pagado
    FROM PAGO GROUP BY VENTA_id_venta
) pg_totales ON pg_totales.VENTA_id_venta = v.id_venta
WHERE ev.nombre = 'REGISTRADA'
ORDER BY DIFERENCIA_PENDIENTE DESC;