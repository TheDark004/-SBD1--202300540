import { Router } from "express";
import {
    listarTiendas, obtenerTienda, crearTienda, actualizarTienda, eliminarTienda
} from '../controllers/tiendas.controller.js';

const router = Router();

router.get('/', listarTiendas);          // GET    /api/tiendas
router.get('/:id', obtenerTienda);       // GET    /api/tiendas/5
router.post('/', crearTienda);           // POST   /api/tiendas
router.put('/:id', actualizarTienda);    // PUT    /api/tiendas/5
router.delete('/:id', eliminarTienda);   // DELETE /api/tiendas/5

export default router;