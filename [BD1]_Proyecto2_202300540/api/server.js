import express from  'express';
import cors from 'cors';
import dotenv from 'dotenv';
import morgan from 'morgan';
import { getConnection } from './src/config/db.js';
dotenv.config()


//ROUTES imports
import clientesRoutes from './src/routes/clientes.routes.js';
import productosRoutes from './src/routes/productos.routes.js';
import tiendasRoutes from './src/routes/tiendas.routes.js';
import empleadosRoutes from './src/routes/empleados.routes.js';
import ventasRoutes from './src/routes/ventas.routes.js';
import pagosRoutes from './src/routes/pagos.routes.js';
import detallesRoutes from './src/routes/detalles.routes.js';
import reportesRoutes from './src/routes/reportes.routes.js';



const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

//clientes
app.use('/api/clientes', clientesRoutes);


app.get('/', (req,res) =>{
    res.json({
        mensaje: 'API REST fuciona',
        version : '1.0.0'
    });

});

app.listen(PORT,async() => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
    try{
        await getConnection();
    }catch(err){
        console.log('El servidor arranco pero no hay conexion con la BD');
    }
});
