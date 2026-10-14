import { Router } from "express";

import{
    listarClientes,obtenerCliente,crearCliente,actualizarCliente,eliminarCliente
} from '../controllers/clientes.controller.js';

const router = Router();

router.get('/', listarClientes);         // GET    /api/clientes
router.get('/:id', obtenerCliente);      // GET    /api/clientes/5
router.post('/', crearCliente);          // POST   /api/clientes
router.put('/:id', actualizarCliente);   // PUT    /api/clientes/5
router.delete('/:id', eliminarCliente);  // DELETE /api/clientes/5

export default router;