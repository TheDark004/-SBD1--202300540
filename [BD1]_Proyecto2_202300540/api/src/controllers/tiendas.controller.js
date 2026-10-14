import { getConnection, sql } from "../config/db.js";

// GET /api/tiendas
export async function listarTiendas(req, res) {
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`
            SELECT
                t.id_tienda,
                t.nombre,
                t.direccion,
                t.telefono,
                m.nombre AS municipio,
                tt.nombre AS tipo_tienda
            FROM dbo.TIENDA t
            JOIN dbo.MUNICIPIO m ON m.id_municipio = t.MUNICIPIO_id_municipio
            JOIN dbo.TIPO_TIENDA tt ON tt.id_tipo_tienda = t.TIPO_TIENDA_id_tipo_tienda
            ORDER BY t.id_tienda
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error en listarTiendas:', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/tiendas/:id
export async function obtenerTienda(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM dbo.TIENDA WHERE id_tienda = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Tienda no encontrada' });
        }
        res.json(result.recordset[0]);
    } catch (error) {
        console.error('Error en obtenerTienda:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/tiendas
export async function crearTienda(req, res) {
    try {
        const {
            id_tienda, nombre, direccion, telefono,
            MUNICIPIO_id_municipio, TIPO_TIENDA_id_tipo_tienda
        } = req.body;

        const pool = await getConnection();
        await pool.request()
            .input('id_tienda', sql.Int, id_tienda)
            .input('nombre', sql.NVarChar, nombre)
            .input('direccion', sql.NVarChar, direccion)
            .input('telefono', sql.NVarChar, telefono)
            .input('MUNICIPIO_id_municipio', sql.Int, MUNICIPIO_id_municipio)
            .input('TIPO_TIENDA_id_tipo_tienda', sql.Int, TIPO_TIENDA_id_tipo_tienda)
            .query(`
                INSERT INTO dbo.TIENDA
                    (id_tienda, nombre, direccion, telefono,
                     MUNICIPIO_id_municipio, TIPO_TIENDA_id_tipo_tienda)
                VALUES
                    (@id_tienda, @nombre, @direccion, @telefono,
                     @MUNICIPIO_id_municipio, @TIPO_TIENDA_id_tipo_tienda)
            `);

        res.status(201).json({ mensaje: 'Tienda creada exitosamente', id_tienda });
    } catch (error) {
        console.error('Error en crearTienda:', error);
        res.status(400).json({ error: error.message });
    }
}

// PUT /api/tiendas/:id
export async function actualizarTienda(req, res) {
    try {
        const { id } = req.params;
        const {
            nombre, direccion, telefono,
            MUNICIPIO_id_municipio, TIPO_TIENDA_id_tipo_tienda
        } = req.body;

        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('nombre', sql.NVarChar, nombre)
            .input('direccion', sql.NVarChar, direccion)
            .input('telefono', sql.NVarChar, telefono)
            .input('MUNICIPIO_id_municipio', sql.Int, MUNICIPIO_id_municipio)
            .input('TIPO_TIENDA_id_tipo_tienda', sql.Int, TIPO_TIENDA_id_tipo_tienda)
            .query(`
                UPDATE dbo.TIENDA
                SET nombre = @nombre,
                    direccion = @direccion,
                    telefono = @telefono,
                    MUNICIPIO_id_municipio = @MUNICIPIO_id_municipio,
                    TIPO_TIENDA_id_tipo_tienda = @TIPO_TIENDA_id_tipo_tienda
                WHERE id_tienda = @id
            `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Tienda no encontrada' });
        }
        res.json({ mensaje: 'Tienda actualizada exitosamente' });
    } catch (error) {
        console.error('Error en actualizarTienda:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/tiendas/:id
export async function eliminarTienda(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.TIENDA WHERE id_tienda = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Tienda no encontrada' });
        }
        res.json({ mensaje: 'Tienda eliminada exitosamente' });
    } catch (error) {
        // Típico: la tienda tiene empleados o ventas asociadas (FK)
        console.error('Error en eliminarTienda:', error);
        res.status(400).json({ error: error.message });
    }
}