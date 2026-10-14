-- Trigger que vive en PAGO y se ejecuta DESPUÉS de un INSERT
CREATE OR ALTER TRIGGER TR_Insert_Pago
ON PAGO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    
    -- PASO 1: Obtener el id del estado "PAGADA" dinámicamente

    -- En lugar de escribir un número fijo (que podría cambiar),
    -- consultamos la tabla ESTADO_VENTA para encontrarlo
    DECLARE @id_pagada INT;
    SELECT @id_pagada = id_estado_venta 
    FROM ESTADO_VENTA 
    WHERE nombre = 'PAGADA';

  
    -- PASO 2: Actualizar el estado de las ventas que ya están cubiertas
   
    -- Hacemos un UPDATE sobre VENTA solo para las ventas afectadas
    -- por el pago recién insertado (las que están en INSERTED)
    UPDATE v
    SET v.ESTADO_VENTA_id_estado_venta = @id_pagada
    FROM VENTA v
    -- Subconsulta 1: total pagado por cada venta (suma de PAGO agrupada)
    JOIN (
        SELECT VENTA_id_venta, SUM(monto) AS total_pagado
        FROM PAGO
        GROUP BY VENTA_id_venta
    ) pagos ON pagos.VENTA_id_venta = v.id_venta
    -- Subconsulta 2: total de cada venta (suma de DETALLE_VENTA agrupada)
    JOIN (
        SELECT VENTA_id_venta, SUM(subtotal) AS total_venta
        FROM DETALLE_VENTA
        GROUP BY VENTA_id_venta
    ) detalle ON detalle.VENTA_id_venta = v.id_venta
    -- Solo ventas que están actualmente en estado "REGISTRADA"
    -- (para no tocar las que ya están PAGADAS o ANULADAS)
    JOIN ESTADO_VENTA ev ON ev.id_estado_venta = v.ESTADO_VENTA_id_estado_venta
    WHERE ev.nombre = 'REGISTRADA'
      -- Condición final: solo actualiza si el pago cubre el total
      AND pagos.total_pagado >= detalle.total_venta
      -- Y solo para ventas afectadas por el insert actual
      AND v.id_venta IN (SELECT VENTA_id_venta FROM inserted);
END;