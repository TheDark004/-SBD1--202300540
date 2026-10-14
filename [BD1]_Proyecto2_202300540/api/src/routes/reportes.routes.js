import { Router } from "express";
import {
    ventasPorUbicacion, topProductos, saldosPendientes
} from '../controllers/reportes.controller.js';

const router = Router();

router.get('/ventas-ubicacion', ventasPorUbicacion);   // GET /api/reportes/ventas-ubicacion
router.get('/top-productos', topProductos);            // GET /api/reportes/top-productos
router.get('/saldos-pendientes', saldosPendientes);    // GET /api/reportes/saldos-pendientes

export default router;