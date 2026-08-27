-- Carga de Validación por Contacto Empresarial
--Nombre del contacto, empresa a la que pertenece, y suma de horas que ha validado en bitácoras 
-- filtrando julio a agosto 2026

SELECT 
    ct.NOMBRE AS CONTACTO,
    emp.NOMBRE AS EMPRESA,
    SUM(b.HORAS_TRABAJADAS) AS TOTAL_HORAS_VALIDADAS
FROM BITACORA b
JOIN CONTACTO ct ON b.CONTACTO_ID_CONTACTO_VALIDADOR = ct.ID_CONTACTO
JOIN EMPRESA emp ON ct.EMPRESA_ID_EMPRESA = emp.ID_EMPRESA
WHERE b.FECHA BETWEEN TO_DATE('2026-07-01', 'YYYY-MM-DD') AND TO_DATE('2026-08-31', 'YYYY-MM-DD')
GROUP BY ct.NOMBRE, emp.NOMBRE
ORDER BY TOTAL_HORAS_VALIDADAS DESC;