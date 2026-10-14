import { getConnection, sql } from "../config/db.js";

// GET /api/ventas
export async function listarVentas(req, res) {
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`
            SELECT
                v.id_venta,
                v.fecha,
                t.nombre AS tienda,
                c.nombres + ' ' + c.apellidos AS cliente,
                e.nombres + ' ' + e.apellidos AS empleado,
                ev.nombre AS estado
            FROM dbo.VENTA v
            JOIN dbo.TIENDA t ON t.id_tienda = v.TIENDA_id_tienda
            JOIN dbo.CLIENTE c ON c.id_cliente = v.CLIENTE_id_cliente
            JOIN dbo.EMPLEADO e ON e.id_empleado = v.EMPLEADO_id_empleado
            JOIN dbo.ESTADO_VENTA ev ON ev.id_estado_venta = v.ESTADO_VENTA_id_estado_venta
            ORDER BY v.id_venta
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error en listarVentas:', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/ventas/:id  (devuelve la venta con sus detalles y pagos)
export async function obtenerVenta(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();

        const venta = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM dbo.VENTA WHERE id_venta = @id');

        if (venta.recordset.length === 0) {
            return res.status(404).json({ error: 'Venta no encontrada' });
        }

        const detalles = await pool.request()
            .input('id', sql.Int, id)
            .query(`
                SELECT d.id_detalle_venta, d.PRODUCTO_id_producto, p.nombre AS producto,
                       d.cantidad, d.precio_unitario, d.subtotal
                FROM dbo.DETALLE_VENTA d
                JOIN dbo.PRODUCTO p ON p.id_producto = d.PRODUCTO_id_producto
                WHERE d.VENTA_id_venta = @id
            `);

        const pagos = await pool.request()
            .input('id', sql.Int, id)
            .query(`
                SELECT pg.id_pago, pg.monto, mp.nombre AS metodo_pago
                FROM dbo.PAGO pg
                JOIN dbo.METODO_PAGO mp ON mp.id_metodo_pago = pg.METODO_PAGO_id_metodo_pago
                WHERE pg.VENTA_id_venta = @id
            `);

        res.json({
            ...venta.recordset[0],
            detalles: detalles.recordset,
            pagos: pagos.recordset
        });
    } catch (error) {
        console.error('Error en obtenerVenta:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/ventas
// Crea la venta y, opcionalmente, sus detalles en UNA transacción:
// si un detalle falla (sin stock, producto inexistente...), se deshace todo.
// Body: { id_venta, fecha?, TIENDA_id_tienda, CLIENTE_id_cliente, EMPLEADO_id_empleado,
//         ESTADO_VENTA_id_estado_venta,
//         detalles?: [{ id_detalle_venta, PRODUCTO_id_producto, cantidad, precio_unitario }] }
export async function crearVenta(req, res) {
    const {
        id_venta, fecha, TIENDA_id_tienda, CLIENTE_id_cliente,
        EMPLEADO_id_empleado, ESTADO_VENTA_id_estado_venta,
        detalles = []
    } = req.body;

    let transaction;
    try {
        const pool = await getConnection();
        transaction = new sql.Transaction(pool);
        await transaction.begin();

        await new sql.Request(transaction)
            .input('id_venta', sql.Int, id_venta)
            .input('fecha', sql.DateTime2, fecha ? new Date(fecha) : new Date())
            .input('TIENDA_id_tienda', sql.Int, TIENDA_id_tienda)
            .input('CLIENTE_id_cliente', sql.Int, CLIENTE_id_cliente)
            .input('EMPLEADO_id_empleado', sql.Int, EMPLEADO_id_empleado)
            .input('ESTADO_VENTA_id_estado_venta', sql.Int, ESTADO_VENTA_id_estado_venta)
            .query(`
                INSERT INTO dbo.VENTA
                    (id_venta, fecha, TIENDA_id_tienda, CLIENTE_id_cliente,
                     EMPLEADO_id_empleado, ESTADO_VENTA_id_estado_venta)
                VALUES
                    (@id_venta, @fecha, @TIENDA_id_tienda, @CLIENTE_id_cliente,
                     @EMPLEADO_id_empleado, @ESTADO_VENTA_id_estado_venta)
            `);

        // Cada INSERT dispara el trigger que descuenta inventario
        for (const d of detalles) {
            await new sql.Request(transaction)
                .input('id_detalle_venta', sql.Int, d.id_detalle_venta)
                .input('cantidad', sql.Int, d.cantidad)
                .input('precio_unitario', sql.Decimal(10, 2), d.precio_unitario)
                .input('subtotal', sql.Decimal(10, 2), d.cantidad * d.precio_unitario)
                .input('VENTA_id_venta', sql.Int, id_venta)
                .input('PRODUCTO_id_producto', sql.Int, d.PRODUCTO_id_producto)
                .query(`
                    INSERT INTO dbo.DETALLE_VENTA
                        (id_detalle_venta, cantidad, precio_unitario, subtotal,
                         VENTA_id_venta, PRODUCTO_id_producto)
                    VALUES
                        (@id_detalle_venta, @cantidad, @precio_unitario, @subtotal,
                         @VENTA_id_venta, @PRODUCTO_id_producto)
                `);
        }

        await transaction.commit();

        res.status(201).json({
            mensaje: 'Venta creada exitosamente',
            id_venta,
            detalles_insertados: detalles.length
        });
    } catch (error) {
        if (transaction) {
            try { await transaction.rollback(); } catch (_) { /* ya estaba revertida */ }
        }
        console.error('Error en crearVenta:', error);
        res.status(400).json({ error: error.message });
    }
}

// PUT /api/ventas/:id
export async function actualizarVenta(req, res) {
    try {
        const { id } = req.params;
        const {
            fecha, TIENDA_id_tienda, CLIENTE_id_cliente,
            EMPLEADO_id_empleado, ESTADO_VENTA_id_estado_venta
        } = req.body;

        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('fecha', sql.DateTime2, new Date(fecha))
            .input('TIENDA_id_tienda', sql.Int, TIENDA_id_tienda)
            .input('CLIENTE_id_cliente', sql.Int, CLIENTE_id_cliente)
            .input('EMPLEADO_id_empleado', sql.Int, EMPLEADO_id_empleado)
            .input('ESTADO_VENTA_id_estado_venta', sql.Int, ESTADO_VENTA_id_estado_venta)
            .query(`
                UPDATE dbo.VENTA
                SET fecha = @fecha,
                    TIENDA_id_tienda = @TIENDA_id_tienda,
                    CLIENTE_id_cliente = @CLIENTE_id_cliente,
                    EMPLEADO_id_empleado = @EMPLEADO_id_empleado,
                    ESTADO_VENTA_id_estado_venta = @ESTADO_VENTA_id_estado_venta
                WHERE id_venta = @id
            `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Venta no encontrada' });
        }
        res.json({ mensaje: 'Venta actualizada exitosamente' });
    } catch (error) {
        console.error('Error en actualizarVenta:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/ventas/:id
export async function eliminarVenta(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.VENTA WHERE id_venta = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Venta no encontrada' });
        }
        res.json({ mensaje: 'Venta eliminada exitosamente' });
    } catch (error) {
        // Típico: la venta tiene detalles o pagos asociados (FK)
        console.error('Error en eliminarVenta:', error);
        res.status(400).json({ error: error.message });
    }
}