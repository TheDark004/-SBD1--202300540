import { getConnection, sql } from "../config/db.js";

// GET /api/detalles   (opcional: ?venta=5 para filtrar por venta)
export async function listarDetalles(req, res) {
    try {
        const { venta } = req.query;
        const pool = await getConnection();
        const request = pool.request();
        let filtro = '';

        if (venta) {
            request.input('venta', sql.Int, venta);
            filtro = 'WHERE d.VENTA_id_venta = @venta';
        }

        const result = await request.query(`
            SELECT
                d.id_detalle_venta,
                d.VENTA_id_venta,
                d.PRODUCTO_id_producto,
                p.nombre AS producto,
                d.cantidad,
                d.precio_unitario,
                d.subtotal
            FROM dbo.DETALLE_VENTA d
            JOIN dbo.PRODUCTO p ON p.id_producto = d.PRODUCTO_id_producto
            ${filtro}
            ORDER BY d.id_detalle_venta
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error en listarDetalles:', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/detalles/:id
export async function obtenerDetalle(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM dbo.DETALLE_VENTA WHERE id_detalle_venta = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Detalle no encontrado' });
        }
        res.json(result.recordset[0]);
    } catch (error) {
        console.error('Error en obtenerDetalle:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/detalles
// El INSERT dispara el trigger que descuenta el inventario del producto.
// El subtotal se calcula aquí (cantidad * precio_unitario), no lo manda el cliente.
export async function crearDetalle(req, res) {
    try {
        const {
            id_detalle_venta, cantidad, precio_unitario,
            VENTA_id_venta, PRODUCTO_id_producto
        } = req.body;

        const subtotal = cantidad * precio_unitario;

        const pool = await getConnection();
        await pool.request()
            .input('id_detalle_venta', sql.Int, id_detalle_venta)
            .input('cantidad', sql.Int, cantidad)
            .input('precio_unitario', sql.Decimal(10, 2), precio_unitario)
            .input('subtotal', sql.Decimal(10, 2), subtotal)
            .input('VENTA_id_venta', sql.Int, VENTA_id_venta)
            .input('PRODUCTO_id_producto', sql.Int, PRODUCTO_id_producto)
            .query(`
                INSERT INTO dbo.DETALLE_VENTA
                    (id_detalle_venta, cantidad, precio_unitario, subtotal,
                     VENTA_id_venta, PRODUCTO_id_producto)
                VALUES
                    (@id_detalle_venta, @cantidad, @precio_unitario, @subtotal,
                     @VENTA_id_venta, @PRODUCTO_id_producto)
            `);

        res.status(201).json({
            mensaje: 'Detalle creado exitosamente',
            id_detalle_venta,
            subtotal
        });
    } catch (error) {
        
        console.error('Error en crearDetalle:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/detalles/:id
export async function eliminarDetalle(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.DETALLE_VENTA WHERE id_detalle_venta = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Detalle no encontrado' });
        }
        res.json({ mensaje: 'Detalle eliminado exitosamente' });
    } catch (error) {
        console.error('Error en eliminarDetalle:', error);
        res.status(400).json({ error: error.message });
    }
}