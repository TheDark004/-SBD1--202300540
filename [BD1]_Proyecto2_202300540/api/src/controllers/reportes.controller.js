import { getConnection } from "../config/db.js";

// Función auxiliar: las 3 vistas se consultan igual, solo cambia el nombre
async function consultarVista(nombreVista, res) {
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`SELECT * FROM dbo.${nombreVista}`);
        res.json(result.recordset);
    } catch (error) {
        console.error(`Error consultando ${nombreVista}:`, error);
        res.status(500).json({ error: error.message });
    }
}

// GET /api/reportes/ventas-ubicacion
export function ventasPorUbicacion(req, res) {
    return consultarVista('Vista_Ventas_Ubicacion', res);
}

// GET /api/reportes/top-productos
export function topProductos(req, res) {
    return consultarVista('Vista_Top_Productos', res);
}

// GET /api/reportes/saldos-pendientes
export function saldosPendientes(req, res) {
    return consultarVista('Vista_Saldos_Pendientes', res);
}