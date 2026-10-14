import { Router } from "express";
import {
    listarEmpleados, obtenerEmpleado, crearEmpleado, actualizarEmpleado, eliminarEmpleado
} from '../controllers/empleados.controller.js';

const router = Router();

router.get('/', listarEmpleados);          // GET    /api/empleados
router.get('/:id', obtenerEmpleado);       // GET    /api/empleados/5
router.post('/', crearEmpleado);           // POST   /api/empleados
router.put('/:id', actualizarEmpleado);    // PUT    /api/empleados/5
router.delete('/:id', eliminarEmpleado);   // DELETE /api/empleados/5

export default router;