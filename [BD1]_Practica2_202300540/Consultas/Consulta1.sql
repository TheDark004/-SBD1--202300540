-- Directorio de Estudiantes Activos
-- Carné, nombre completo, empresa, especialidad de la plaza --> solo colocaciones en estado "Activa"


SELECT 
    e.CARNET,
    e.NOMBRE_COMPLETO,
    emp.NOMBRE AS EMPRESA,
    p.ESPECIALIDAD_TECNICA
FROM COLOCACION c
JOIN ESTUDIANTE e ON c.ESTUDIANTE_CARNET = e.CARNET
JOIN PLAZA p ON c.PLAZA_ID_PLAZA = p.ID_PLAZA
JOIN EMPRESA emp ON p.EMPRESA_ID_EMPRESA = emp.ID_EMPRESA
JOIN ESTADO_COLOCACION ec ON c.ESTADO_ID_ESTADO = ec.ID_ESTADO
WHERE ec.NOMBRE = 'Activa';