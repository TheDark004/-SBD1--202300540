-- Ofertas de plazas x empresa
-- Nombre de cada empresa + cantidad total de plazas que ofrece, ordenado de mayor a menor

SELECT 
    emp.NOMBRE AS EMPRESA,
    COUNT(p.ID_PLAZA) AS CANTIDAD_PLAZAS
FROM EMPRESA emp
JOIN PLAZA p ON emp.ID_EMPRESA = p.EMPRESA_ID_EMPRESA
GROUP BY emp.NOMBRE
ORDER BY CANTIDAD_PLAZAS DESC;