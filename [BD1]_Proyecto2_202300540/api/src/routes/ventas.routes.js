import { Router } from "express";
import {
    listarVentas, obtenerVenta, crearVenta, actualizarVenta, eliminarVenta
} from '../controllers/ventas.controller.js';

const router = Router();

router.get('/', listarVentas);          // GET    /api/ventas
router.get('/:id', obtenerVenta);       // GET    /api/ventas/5  (con detalles y pagos)
router.post('/', crearVenta);           // POST   /api/ventas    (venta + detalles en transacción)
router.put('/:id', actualizarVenta);    // PUT    /api/ventas/5
router.delete('/:id', eliminarVenta);   // DELETE /api/ventas/5

export default router;