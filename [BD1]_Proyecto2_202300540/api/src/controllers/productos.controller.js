import { getConnection, sql } from "../config/db.js";

// GET /api/productos
export async function listarProductos(req, res) {
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`
            SELECT
                p.id_producto,
                p.nombre,
                p.descripcion,
                p.precio_vigente,
                p.existencia,
                c.nombre AS categoria,
                m.nombre AS marca
            FROM dbo.PRODUCTO p
            JOIN dbo.CATEGORIA c ON c.id_categoria = p.CATEGORIA_id_categoria
            JOIN dbo.MARCA m ON m.id_marca = p.MARCA_id_marca
            ORDER BY p.id_producto
        `);
        res.json(result.recordset);
    } catch (error) {
        console.error('Error en listarProductos:', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/productos/:id
export async function obtenerProducto(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT * FROM dbo.PRODUCTO WHERE id_producto = @id');

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        res.json(result.recordset[0]);
    } catch (error) {
        console.error('Error en obtenerProducto:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/productos
export async function crearProducto(req, res) {
    try {
        const {
            id_producto, nombre, descripcion, precio_vigente, existencia,
            CATEGORIA_id_categoria, MARCA_id_marca
        } = req.body;

        const pool = await getConnection();
        await pool.request()
            .input('id_producto', sql.Int, id_producto)
            .input('nombre', sql.NVarChar, nombre)
            .input('descripcion', sql.NVarChar, descripcion)
            .input('precio_vigente', sql.Decimal(10, 2), precio_vigente)
            .input('existencia', sql.Int, existencia)
            .input('CATEGORIA_id_categoria', sql.Int, CATEGORIA_id_categoria)
            .input('MARCA_id_marca', sql.Int, MARCA_id_marca)
            .query(`
                INSERT INTO dbo.PRODUCTO
                    (id_producto, nombre, descripcion, precio_vigente, existencia,
                     CATEGORIA_id_categoria, MARCA_id_marca)
                VALUES
                    (@id_producto, @nombre, @descripcion, @precio_vigente, @existencia,
                     @CATEGORIA_id_categoria, @MARCA_id_marca)
            `);

        res.status(201).json({ mensaje: 'Producto creado exitosamente', id_producto });
    } catch (error) {
        console.error('Error en crearProducto:', error);
        res.status(400).json({ error: error.message });
    }
}

// PUT /api/productos/:id
export async function actualizarProducto(req, res) {
    try {
        const { id } = req.params;
        const {
            nombre, descripcion, precio_vigente, existencia,
            CATEGORIA_id_categoria, MARCA_id_marca
        } = req.body;

        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('nombre', sql.NVarChar, nombre)
            .input('descripcion', sql.NVarChar, descripcion)
            .input('precio_vigente', sql.Decimal(10, 2), precio_vigente)
            .input('existencia', sql.Int, existencia)
            .input('CATEGORIA_id_categoria', sql.Int, CATEGORIA_id_categoria)
            .input('MARCA_id_marca', sql.Int, MARCA_id_marca)
            .query(`
                UPDATE dbo.PRODUCTO
                SET nombre = @nombre,
                    descripcion = @descripcion,
                    precio_vigente = @precio_vigente,
                    existencia = @existencia,
                    CATEGORIA_id_categoria = @CATEGORIA_id_categoria,
                    MARCA_id_marca = @MARCA_id_marca
                WHERE id_producto = @id
            `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        res.json({ mensaje: 'Producto actualizado exitosamente' });
    } catch (error) {
        console.error('Error en actualizarProducto:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/productos/:id
export async function eliminarProducto(req, res) {
    try {
        const { id } = req.params;
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.PRODUCTO WHERE id_producto = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        res.json({ mensaje: 'Producto eliminado exitosamente' });
    } catch (error) {
        // Típico: el producto ya aparece en algún DETALLE_VENTA (FK)
        console.error('Error en eliminarProducto:', error);
        res.status(400).json({ error: error.message });
    }
}