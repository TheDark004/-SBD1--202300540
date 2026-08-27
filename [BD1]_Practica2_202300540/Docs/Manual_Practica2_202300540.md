# Manual de Procedimiento — Práctica 2
### Consultas Avanzadas, Agrupaciones y Reportería Relacional (Sistema EPS)
**Bases de Datos 1 · USAC**
**Carné: 202300540**

---

## 1. Herramientas utilizadas

- **Motor de base de datos:** Oracle Database, corriendo en un contenedor Docker (`oracle-xe-21c`).
- **Cliente SQL:** Chat2DB, conectado directamente al contenedor Oracle.
- **Origen de datos:** archivo de Excel (`Dataset_Practica2.xlsx`) proporcionado, con una hoja por cada tabla del modelo.

---

## 2. Preparación de los datos de origen

El archivo de Excel traía una hoja por cada tabla (`SECTOR_ECONOMICO`, `DEPARTAMENTO`, `ESTADO_COLOCACION`, ....). Cada hoja se exportó a un archivo `.csv` independiente (uno por tabla), usando hojas de cálculo, para poder importarlos de forma individual a cada tabla de Oracle.

Al revisar los CSV con mi modelo relacional el que se construyo en la Práctica 1, noté que **los nombres de columnas no coincidían exactamente** con los nombres que yo había definido en mi diccionario de datos. Por ejemplo:

| Columna en el CSV | Columna en mi tabla | Tabla |
|---|---|---|
| `NOMBRE` | `NOMBRE_SECTOR` | SECTOR |
| `NOMBRE` | `NOMBRE_DEPARTAMENTO` | DEPARTAMENTO |
| `NOMBRE` | `NOMBRE_CRITERIO` | CRITERIO |
| `ID_SECTOR` | `SECTOR_ID_SECTOR` | EMPRESA |
| `ID_EMPRESA` | `EMPRESA_ID_EMPRESA` | CONTACTO / PLAZA |
| `CODIGO_AUTORIZACION` | `CODIGO_MINEDUC` | INSTITUTO |

Antes de importar, renombré los encabezados de cada CSV para que coincidieran exactamente con los nombres de columna de mi propio esquema, en lugar de modificar la estructura de mis tablas para copiar los nombres del dataset.

---

## 3. Ajustes al esquema de la Práctica 1

El dataset de esta práctica incluía información que mi modelo de la Práctica 1 no contemplaba, porque en ese momento no era necesaria para los requerimientos de esa entrega. Al revisar los reportes que pide esta Práctica 2, identifiqué que necesitaba estos cambios estructurales:

### 3.1 Agregar dirección a Empresa

Mi tabla `EMPRESA` no tenía un campo de dirección física.

```sql
ALTER TABLE EMPRESA ADD DIRECCION VARCHAR2(150 CHAR);
```

### 3.2 Relacionar Estudiante con Instituto directamente

En la Práctica 1 decidí no llevar una relación directa entre `ESTUDIANTE` e `INSTITUTO` (el instituto se podía inferir por otras vías). Sin embargo, el reporte de "Estudiantes en Repitencia" de esta práctica pide mostrar explícitamente el instituto de cada estudiante, así que agregué la relación:

```sql
ALTER TABLE ESTUDIANTE ADD INSTITUTO_ID_INSTITUTO NUMBER;

ALTER TABLE ESTUDIANTE 
    ADD CONSTRAINT ESTUDIANTE_INSTITUTO_FK 
    FOREIGN KEY (INSTITUTO_ID_INSTITUTO) 
    REFERENCES INSTITUTO(ID_INSTITUTO);
```

### 3.3 Normalizar el Estado de Colocación en un catálogo

Originalmente, `ESTADO` en la tabla `COLOCACION` era un campo de texto libre (`VARCHAR2`). Para evitar valores inconsistentes (por ejemplo "activa", "Activa", "ACTIVA" escritos distinto) y para que los reportes puedan filtrar de forma confiable, lo convertí en una tabla de catálogo con llave foránea:

```sql
CREATE TABLE ESTADO_COLOCACION (
    ID_ESTADO NUMBER NOT NULL,
    NOMBRE    VARCHAR2(20 CHAR) NOT NULL
);

ALTER TABLE ESTADO_COLOCACION 
    ADD CONSTRAINT ESTADO_COLOCACION_PK PRIMARY KEY (ID_ESTADO);

-- Se reemplaza la columna de texto por la llave foránea
ALTER TABLE COLOCACION ADD ESTADO_ID_ESTADO NUMBER;
ALTER TABLE COLOCACION DROP COLUMN ESTADO;

ALTER TABLE COLOCACION 
    ADD CONSTRAINT COLOCACION_ESTADO_FK 
    FOREIGN KEY (ESTADO_ID_ESTADO) 
    REFERENCES ESTADO_COLOCACION(ID_ESTADO);
```

### 3.4 Normalizar el Tipo de Evaluación en un catálogo, y vincular al catedrático evaluador

Igual que con el estado, `TIPO_EVALUACION` era texto libre en la tabla `EVALUACION`. Lo convertí en catálogo. Además, agregué una relación directa con `CATEDRATICO`, para dejar explícito quién realizó cada evaluación (en mi modelo original esto se inferría indirectamente a través de la Colocación):

```sql
CREATE TABLE TIPO_EVALUACION_CAT (
    ID_TIPO_EVALUACION NUMBER NOT NULL,
    NOMBRE              VARCHAR2(20 CHAR) NOT NULL
);

ALTER TABLE TIPO_EVALUACION_CAT 
    ADD CONSTRAINT TIPO_EVALUACION_CAT_PK PRIMARY KEY (ID_TIPO_EVALUACION);

ALTER TABLE EVALUACION ADD TIPO_EVAL_ID NUMBER;
ALTER TABLE EVALUACION DROP COLUMN TIPO_EVALUACION;

ALTER TABLE EVALUACION 
    ADD CONSTRAINT EVALUACION_TIPO_FK 
    FOREIGN KEY (TIPO_EVAL_ID) 
    REFERENCES TIPO_EVALUACION_CAT(ID_TIPO_EVALUACION);

ALTER TABLE EVALUACION ADD CATEDRATICO_ID_CATEDRATICO NUMBER;

ALTER TABLE EVALUACION 
    ADD CONSTRAINT EVALUACION_CATEDRATICO_FK 
    FOREIGN KEY (CATEDRATICO_ID_CATEDRATICO) 
    REFERENCES CATEDRATICO(ID_CATEDRATICO);
```

### 3.5 Agregar el contacto validador a Bitácora

Mi tabla `BITACORA` solo llevaba un campo `VALIDADA` (sí/no), pero no registraba **quién** validó la entrada. Agregué la relación con `CONTACTO`, necesaria para el reporte de "Carga de Validación por Contacto Empresarial":

```sql
ALTER TABLE BITACORA ADD CONTACTO_ID_CONTACTO_VALIDADOR NUMBER;

ALTER TABLE BITACORA 
    ADD CONSTRAINT BITACORA_CONTACTO_FK 
    FOREIGN KEY (CONTACTO_ID_CONTACTO_VALIDADOR) 
    REFERENCES CONTACTO(ID_CONTACTO);
```

### 3.6 Ajustes de restricciones NOT NULL, encontrados durante la carga real

Al importar los datos reales, Oracle rechazó algunas filas por restricciones `NOT NULL` que, al ver los datos reales, resultaron ser demasiado estrictas para el negocio:

**a) `FECHA_FIN` en `COLOCACION`:** una colocación que todavía está en estado "Activa" lógicamente **no tiene** fecha de finalización todavía (el estudiante sigue practicando). La restricción original no contemplaba este caso.

```sql
ALTER TABLE COLOCACION MODIFY FECHA_FIN NULL;
```

**b) `OBSERVACIONES` en `BITACORA`:** no todos los días de práctica generan una observación especial por parte del supervisor — es un campo que debería ser opcional.

```sql
ALTER TABLE BITACORA MODIFY OBSERVACIONES NULL;
```

Este tipo de hallazgo es normal en un proceso real de carga de datos: el diseño en papel a veces no contempla todos los casos hasta que se prueba con datos reales.

---

## 4. Decisión de diseño: ¿modificar mi esquema o el dataset?

Decidí **mantener la estructura y nombres de columna definidos en mi Práctica 1**, y en su lugar transformar los datos de origen (CSV) para que encajaran en mi modelo — en vez de alterar mi diseño para copiar los nombres genéricos del dataset del profesor.

La razón es que el enunciado de esta práctica indica que se trabaja *"en base al modelo relacional construido e implementado durante la Práctica 1"* — es decir, mi modelo ya definido es el punto de partida, y el dataset es solo el insumo de datos crudos que debo adaptar a él. Esto es equivalente a un proceso real de **ETL (Extract, Transform, Load)**: los datos de origen casi nunca llegan ya en el formato exacto del sistema destino, y adaptarlos es parte del trabajo.

---

## 5. Orden de importación utilizado

Se respetó el siguiente orden para no violar las restricciones de llave foránea (las tablas catálogo primero, y las tablas que dependen de otras al final):

1. SECTOR
2. DEPARTAMENTO
3. ESTADO_COLOCACION
4. TIPO_EVALUACION_CAT
5. CRITERIO
6. INSTITUTO
7. MUNICIPIO
8. EMPRESA
9. CATEDRATICO
10. CONTACTO
11. PLAZA
12. ESTUDIANTE
13. COLOCACION
14. BITACORA
15. EVALUACION
16. DETALLE_EVALUACION

---

## 6. Método de carga

El asistente de importación visual de Chat2DB solo empareja automáticamente las columnas cuyo nombre coincide **exacto** entre el CSV y la tabla destino, y **descarta en silencio** cualquier columna sin coincidencia exacta, en lugar de pedir un mapeo manual. Esto causó un primer intento fallido en la tabla `SECTOR`, donde solo se insertó el `ID_SECTOR` y se dejó `NOMBRE_SECTOR` vacío, generando un error de restricción `NOT NULL`.

Para evitar repetir este problema en las 15 tablas restantes, renombré los encabezados de cada CSV para que coincidieran exactamente con los nombres de columna de mis tablas, y luego generé sentencias `INSERT` a partir de esos datos ya alineados, ejecutándolas directamente en Chat2DB en el orden de dependencias descrito arriba.

![Import](capturas/import.png)
![Exito](capturas/exito.png)

---

## 7. Consultas desarrolladas

### Consulta 1 — Directorio de Estudiantes Activos

Muestra el carné, nombre, empresa y especialidad de la plaza, solo para colocaciones en estado "Activa".

```sql
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
```

**Resultado:**

![Consulta 1](capturas/consulta1.png)

---

### Consulta 2 — Oferta de Plazas por Empresa

Cuenta cuántas plazas ofrece cada empresa, ordenado de mayor a menor.

```sql
SELECT 
    emp.NOMBRE AS EMPRESA,
    COUNT(p.ID_PLAZA) AS CANTIDAD_PLAZAS
FROM EMPRESA emp
JOIN PLAZA p ON emp.ID_EMPRESA = p.EMPRESA_ID_EMPRESA
GROUP BY emp.NOMBRE
ORDER BY CANTIDAD_PLAZAS DESC;
```

**Resultado:**

![Consulta 2](capturas/consulta2.png)

---

### Consulta 3 — Carga de Validación por Contacto Empresarial

Suma las horas validadas por cada contacto empresarial, filtrando bitácoras de julio a agosto de 2026.

```sql
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
```

**Resultado:**

![Consulta 3](capturas/consulta3.png)

---

### Consulta 4 — Estudiantes en Repitencia

Lista a los estudiantes marcados como repitentes, con su instituto, contacto validador y estado de colocación.

```sql
SELECT 
    e.NOMBRE_COMPLETO AS ESTUDIANTE,
    i.NOMBRE AS INSTITUTO,
    ct.NOMBRE AS CONTACTO_VALIDADOR,
    ec.NOMBRE AS ESTADO_COLOCACION
FROM ESTUDIANTE e
JOIN INSTITUTO i ON e.INSTITUTO_ID_INSTITUTO = i.ID_INSTITUTO
JOIN COLOCACION c ON e.CARNET = c.ESTUDIANTE_CARNET
JOIN PLAZA p ON c.PLAZA_ID_PLAZA = p.ID_PLAZA
JOIN CONTACTO ct ON p.CONTACTO_ID_CONTACTO = ct.ID_CONTACTO
JOIN ESTADO_COLOCACION ec ON c.ESTADO_ID_ESTADO = ec.ID_ESTADO
WHERE e.REPITENCIA = 'S';
```

**Resultado:**

![Consulta 4](capturas/consulta4.png)

---

### Consulta 5 — Auditoría de Bitácoras

Identifica colocaciones activas que no tienen ningún registro de bitácora en el último mes, mostrando al catedrático responsable.

```sql
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
    AND b.FECHA >= ADD_MONTHS(SYSDATE, -1)
);
```

**Resultado:**

![Consulta 5](capturas/consulta5.png)

---

## 8. Conclusión

Se logró importar la totalidad de los datos proporcionados respetando la integridad referencial del modelo definido en la Práctica 1, ajustando el esquema donde fue necesario para soportar los nuevos requerimientos analíticos, y se desarrollaron las 5 consultas solicitadas utilizando `JOIN` explícitos, funciones de agregación (`COUNT`, `SUM`) y subconsultas (`NOT EXISTS`) para resolver los reportes de negocio pedidos por la Dirección Académica.
