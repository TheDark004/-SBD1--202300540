-- Confirma las 17 tablas creadas del ddl
SELECT COUNT(*) AS TOTAL_TABLAS FROM user_tables;

-- Confirma que las FK, PK, UNIQUE y CHECK se crearon correctamente
SELECT constraint_type, COUNT(*) 
FROM user_constraints 
GROUP BY constraint_type;