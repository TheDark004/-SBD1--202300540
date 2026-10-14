import sql from 'mssql';
import dotenv from 'dotenv';

dotenv.config();


const config = {
    server: process.env.DB_SERVER,
    port: parseInt(process.env.DB_PORT),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
        encrypt: false,
        trustServerCertificate: process.env.DB_TRUST_CERT === 'true',
        enableArithAbort: true
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

let pool = null;

export async function getConnection() {
    try {
        if (pool) {
            return pool;
        }
        pool = await sql.connect(config);
        console.log('Conexión a SQL Server establecida');
        return pool;
    } catch (error) {
        console.error('Error de conexion:', error.message);
        throw error;
    }
}

export {sql};