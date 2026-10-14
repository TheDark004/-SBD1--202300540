import { getConnection, sql } from "../config/db.js";

// GET /api/pagos   (opcional: ?venta=5 para filtrar por venta)
export async function listarPagos(req, res) {
    try {
        const { venta } = req.query;
        const pool = await getConnection();
        const request = pool.request();
        let filtro = '';

        if (venta) {
            request.input('venta', sql.Int, venta);
            filtro = 'WHERE pg.VENTA_id_venta = @venta';
        }

        const result = await request.query(`
            SELECT
                pg.id_pago,
                pg.monto,
                pg.VENTA_id_venta,
                mp.nombre AS metodo_pago
            FROM dbo.PAGO pg
            JOIN dbo.METODO_PAGO mp ON mp.id_metodo_pago = pg.METODO_PAGO_id_metodo_pago
            ${filtro}
            ORDER BY pg.id_pago
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error en listarPagos:', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/pagos/:id
export async function obtenerPago(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM dbo.PAGO WHERE id_pago = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Pago no encontrado' });
        }
        res.json(result.recordset[0]);
    } catch (error) {
        console.error('Error en obtenerPago:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/pagos
// El INSERT dispara el trigger que marca la venta como PAGADA cuando los pagos cubren el total.
export async function crearPago(req, res) {
    try {
        const { id_pago, monto, VENTA_id_venta, METODO_PAGO_id_metodo_pago } = req.body;

        const pool = await getConnection();
        await pool.request()
            .input('id_pago', sql.Int, id_pago)
            .input('monto', sql.Decimal(10, 2), monto)
            .input('VENTA_id_venta', sql.Int, VENTA_id_venta)
            .input('METODO_PAGO_id_metodo_pago', sql.Int, METODO_PAGO_id_metodo_pago)
            .query(`
                INSERT INTO dbo.PAGO
                    (id_pago, monto, VENTA_id_venta, METODO_PAGO_id_metodo_pago)
                VALUES
                    (@id_pago, @monto, @VENTA_id_venta, @METODO_PAGO_id_metodo_pago)
            `);

        res.status(201).json({ mensaje: 'Pago registrado exitosamente', id_pago });
    } catch (error) {
        console.error('Error en crearPago:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/pagos/:id
// OJO: el trigger solo cubre INSERT; borrar un pago no revierte el estado PAGADA.
export async function eliminarPago(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.PAGO WHERE id_pago = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Pago no encontrado' });
        }
        res.json({ mensaje: 'Pago eliminado exitosamente' });
    } catch (error) {
        console.error('Error en eliminarPago:', error);
        res.status(400).json({ error: error.message });
    }
}