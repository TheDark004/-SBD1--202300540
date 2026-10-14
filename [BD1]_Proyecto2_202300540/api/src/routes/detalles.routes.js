import { Router } from "express";
import {
    listarDetalles, obtenerDetalle, crearDetalle, eliminarDetalle
} from '../controllers/detalles.controller.js';

const router = Router();

router.get('/', listarDetalles);          // GET    /api/detalles  (?venta=5 para filtrar)
router.get('/:id', obtenerDetalle);       // GET    /api/detalles/5
router.post('/', crearDetalle);           // POST   /api/detalles  (dispara trigger de inventario)
router.delete('/:id', eliminarDetalle);   // DELETE /api/detalles/5

export default router;