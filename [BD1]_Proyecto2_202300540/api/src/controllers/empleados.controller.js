import { getConnection, sql } from "../config/db.js";

// GET /api/empleados
export async function listarEmpleados(req, res) {
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`
            SELECT
                e.id_empleado,
                e.nombres,
                e.apellidos,
                e.correo,
                e.telefono,
                e.fecha_contratacion,
                t.nombre AS tienda,
                c.nombre AS cargo
            FROM dbo.EMPLEADO e
            JOIN dbo.TIENDA t ON t.id_tienda = e.TIENDA_id_tienda
            JOIN dbo.CARGO c ON c.id_cargo = e.CARGO_id_cargo
            ORDER BY e.id_empleado
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error en listarEmpleados:', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/empleados/:id
export async function obtenerEmpleado(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM dbo.EMPLEADO WHERE id_empleado = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Empleado no encontrado' });
        }
        res.json(result.recordset[0]);
    } catch (error) {
        console.error('Error en obtenerEmpleado:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/empleados
export async function crearEmpleado(req, res) {
    try {
        const {
            id_empleado, nombres, apellidos, correo, telefono,
            fecha_contratacion, TIENDA_id_tienda, CARGO_id_cargo
        } = req.body;

        const pool = await getConnection();
        await pool.request()
            .input('id_empleado', sql.Int, id_empleado)
            .input('nombres', sql.NVarChar, nombres)
            .input('apellidos', sql.NVarChar, apellidos)
            .input('correo', sql.NVarChar, correo)
            .input('telefono', sql.NVarChar, telefono)
            .input('fecha_contratacion', sql.Date, fecha_contratacion)   // formato "YYYY-MM-DD"
            .input('TIENDA_id_tienda', sql.Int, TIENDA_id_tienda)
            .input('CARGO_id_cargo', sql.Int, CARGO_id_cargo)
            .query(`
                INSERT INTO dbo.EMPLEADO
                    (id_empleado, nombres, apellidos, correo, telefono,
                     fecha_contratacion, TIENDA_id_tienda, CARGO_id_cargo)
                VALUES
                    (@id_empleado, @nombres, @apellidos, @correo, @telefono,
                     @fecha_contratacion, @TIENDA_id_tienda, @CARGO_id_cargo)
            `);

        res.status(201).json({ mensaje: 'Empleado creado exitosamente', id_empleado });
    } catch (error) {
        console.error('Error en crearEmpleado:', error);
        res.status(400).json({ error: error.message });
    }
}

// PUT /api/empleados/:id
export async function actualizarEmpleado(req, res) {
    try {
        const { id } = req.params;
        const {
            nombres, apellidos, correo, telefono,
            fecha_contratacion, TIENDA_id_tienda, CARGO_id_cargo
        } = req.body;

        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('nombres', sql.NVarChar, nombres)
            .input('apellidos', sql.NVarChar, apellidos)
            .input('correo', sql.NVarChar, correo)
            .input('telefono', sql.NVarChar, telefono)
            .input('fecha_contratacion', sql.Date, fecha_contratacion)
            .input('TIENDA_id_tienda', sql.Int, TIENDA_id_tienda)
            .input('CARGO_id_cargo', sql.Int, CARGO_id_cargo)
            .query(`
                UPDATE dbo.EMPLEADO
                SET nombres = @nombres,
                    apellidos = @apellidos,
                    correo = @correo,
                    telefono = @telefono,
                    fecha_contratacion = @fecha_contratacion,
                    TIENDA_id_tienda = @TIENDA_id_tienda,
                    CARGO_id_cargo = @CARGO_id_cargo
                WHERE id_empleado = @id
            `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Empleado no encontrado' });
        }
        res.json({ mensaje: 'Empleado actualizado exitosamente' });
    } catch (error) {
        console.error('Error en actualizarEmpleado:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/empleados/:id
export async function eliminarEmpleado(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.EMPLEADO WHERE id_empleado = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Empleado no encontrado' });
        }
        res.json({ mensaje: 'Empleado eliminado exitosamente' });
    } catch (error) {
        // Típico: el empleado tiene ventas registradas (FK)
        console.error('Error en eliminarEmpleado:', error);
        res.status(400).json({ error: error.message });
    }
}