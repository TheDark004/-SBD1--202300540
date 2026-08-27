-- Auditoría de Bitácoras
-- Colocaciones en estado "Activa" que "No" tienen ningún registro de bitácora en el último mes mostrando al catedratico 

SELECT 
    c.ID_COLOCACION,
    e.NOMBRE_COMPLETO AS ESTUDIANTE,
    cat.NOMBRE AS CATEDRATICO_SUPERVISOR
FROM COLOCACION c
JOIN ESTUDIANTE e ON c.ESTUDIANTE_CARNET = e.CARNET
JOIN CATEDRATICO cat ON c.CATEDRATICO_ID_CATEDRATICO = cat.ID_CATEDRATICO
JOIN ESTADO_COLOCACION ec ON c.ESTADO_ID_ESTADO = ec.ID_ESTADO
WHERE ec.NOMBRE = 'Activa'
AND NOT EXISTS (
    SELECT 1
    FROM BITACORA b
    WHERE b.COLOCACION_ID_COLOCACION = c.ID_COLOCACION
    AND b.FECHA >= ADD_MONTHS(SYSDATE, -1) // esto se usa para identificar la fecha actual al hoy x hoy
);