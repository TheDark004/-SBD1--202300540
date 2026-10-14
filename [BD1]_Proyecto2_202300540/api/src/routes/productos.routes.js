import { Router } from "express";
import {
    listarProductos, obtenerProducto, crearProducto, actualizarProducto, eliminarProducto
} from '../controllers/productos.controller.js';

const router = Router();

router.get('/', listarProductos);          // GET    /api/productos
router.get('/:id', obtenerProducto);       // GET    /api/productos/5
router.post('/', crearProducto);           // POST   /api/productos
router.put('/:id', actualizarProducto);    // PUT    /api/productos/5
router.delete('/:id', eliminarProducto);   // DELETE /api/productos/5

export default router;