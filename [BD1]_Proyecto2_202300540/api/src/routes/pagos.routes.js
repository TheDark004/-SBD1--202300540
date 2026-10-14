import { Router } from "express";
import {
    listarPagos, obtenerPago, crearPago, eliminarPago
} from '../controllers/pagos.controller.js';

const router = Router();

router.get('/', listarPagos);          // GET    /api/pagos  (?venta=5 para filtrar)
router.get('/:id', obtenerPago);       // GET    /api/pagos/5
router.post('/', crearPago);           // POST   /api/pagos  (dispara trigger de estado PAGADA)
router.delete('/:id', eliminarPago);   // DELETE /api/pagos/5

export default router;