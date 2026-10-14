import { getConnection,sql } from "../config/db.js";

// GET /api/clientes

export async function listarClientes(req,res) {
    try{
        const pool = await getConnection();

       const result = await pool.request().query(`
            SELECT 
                c.id_cliente,
                c.nombres,
                c.apellidos,
                c.numero_identificacion,
                c.telefono,
                c.correo,
                c.direccion,
                ti.nombre AS tipo_identificacion,
                m.nombre AS municipio
            FROM dbo.CLIENTE c
            JOIN dbo.TIPO_IDENTIFICACION ti 
                ON ti.id_tipo_ident = c.TIPO_IDENT_id_tipo_ident
            JOIN dbo.MUNICIPIO m 
                ON m.id_municipio = c.MUNICIPIO_id_municipio
            ORDER BY c.id_cliente
        `);

        res.json(result.recordset);

    }catch (error){
        console.error ( ' Error en listar Clientes: ', error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/clientes/:id
export async function obtenerCliente(req, res) {
    try {
        // Sacar el id de los parámetros de la URL
        // Si la ruta es /api/clientes/5, `req.params.id` es "5" (string)
        const { id } = req.params;

        // Conectar y ejecutar la consulta PARAMETRIZADA
        // Los `.input(...)` protegen contra SQL Injection
        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)                // (nombre, tipo, valor)
            .query('SELECT * FROM dbo.CLIENTE WHERE id_cliente = @id');

        // Si no hay resultados, devolvemos 404
        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Cliente no encontrado' });
        }

        // Devolvemos el primer (y único) resultado
        res.json(result.recordset[0]);

    } catch (error) {
        console.error('Error en obtenerCliente:', error);
        res.status(500).json({ error: error.message });
    }
}

// POST /api/clientes
export async function crearCliente(req, res) {
    try {
        // Sacar los datos del cuerpo de la petición (body)
        const {
            id_cliente,
            nombres,
            apellidos,
            numero_identificacion,
            telefono,
            correo,
            direccion,
            TIPO_IDENT_id_tipo_ident,
            MUNICIPIO_id_municipio
        } = req.body;

        // Conectar y ejecutar el INSERT parametrizado
        const pool = await getConnection();
        await pool.request()
            .input('id_cliente', sql.Int, id_cliente)
            .input('nombres', sql.NVarChar, nombres)
            .input('apellidos', sql.NVarChar, apellidos)
            .input('numero_identificacion', sql.NVarChar, numero_identificacion)
            .input('telefono', sql.NVarChar, telefono)
            .input('correo', sql.NVarChar, correo)
            .input('direccion', sql.NVarChar, direccion)
            .input('TIPO_IDENT_id_tipo_ident', sql.Int, TIPO_IDENT_id_tipo_ident)
            .input('MUNICIPIO_id_municipio', sql.Int, MUNICIPIO_id_municipio)
            .query(`
                INSERT INTO dbo.CLIENTE 
                    (id_cliente, nombres, apellidos, numero_identificacion,
                     telefono, correo, direccion,
                     TIPO_IDENT_id_tipo_ident, MUNICIPIO_id_municipio)
                VALUES 
                    (@id_cliente, @nombres, @apellidos, @numero_identificacion,
                     @telefono, @correo, @direccion,
                     @TIPO_IDENT_id_tipo_ident, @MUNICIPIO_id_municipio)
            `);

        // Devolvemos 201 (Created) con el id del nuevo cliente
        res.status(201).json({ 
            mensaje: 'Cliente creado exitosamente', 
            id_cliente 
        });

    } catch (error) {
        // Los errores de BD (FK que no existe, UNIQUE duplicado) caen acá
        console.error('Error en crearCliente:', error);
        res.status(400).json({ error: error.message });
    }
}

// PUT /api/clientes/:id
export async function actualizarCliente(req, res) {
    try {
        const { id } = req.params;
        const {
            nombres,
            apellidos,
            numero_identificacion,
            telefono,
            correo,
            direccion,
            TIPO_IDENT_id_tipo_ident,
            MUNICIPIO_id_municipio
        } = req.body;

        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .input('nombres', sql.NVarChar, nombres)
            .input('apellidos', sql.NVarChar, apellidos)
            .input('numero_identificacion', sql.NVarChar, numero_identificacion)
            .input('telefono', sql.NVarChar, telefono)
            .input('correo', sql.NVarChar, correo)
            .input('direccion', sql.NVarChar, direccion)
            .input('TIPO_IDENT_id_tipo_ident', sql.Int, TIPO_IDENT_id_tipo_ident)
            .input('MUNICIPIO_id_municipio', sql.Int, MUNICIPIO_id_municipio)
            .query(`
                UPDATE dbo.CLIENTE 
                SET nombres = @nombres,
                    apellidos = @apellidos,
                    numero_identificacion = @numero_identificacion,
                    telefono = @telefono,
                    correo = @correo,
                    direccion = @direccion,
                    TIPO_IDENT_id_tipo_ident = @TIPO_IDENT_id_tipo_ident,
                    MUNICIPIO_id_municipio = @MUNICIPIO_id_municipio
                WHERE id_cliente = @id
            `);

        // `rowsAffected[0]` es cuántas filas tocó el UPDATE
        // Si es 0, significa que el cliente no existía
        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Cliente no encontrado' });
        }

        res.json({ mensaje: 'Cliente actualizado exitosamente' });

    } catch (error) {
        console.error('Error en actualizarCliente:', error);
        res.status(400).json({ error: error.message });
    }
}

// DELETE /api/clientes/:id
export async function eliminarCliente(req, res) {
    try {
        const { id } = req.params;

        const pool = await getConnection();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query('DELETE FROM dbo.CLIENTE WHERE id_cliente = @id');

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ error: 'Cliente no encontrado' });
        }

        res.json({ mensaje: 'Cliente eliminado exitosamente' });

    } catch (error) {
        // Errores típicos: cliente tiene ventas asociadas (FK constraint)
        console.error('Error en eliminarCliente:', error);
        res.status(400).json({ error: error.message });
    }
}