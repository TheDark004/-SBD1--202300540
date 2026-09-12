-- Uso de métodos de pago
-- Método de pago, cantidad de pagos y monto total recibido
SELECT 
    mp.nombre AS METODO_PAGO,
    COUNT(p.id_pago) AS CANTIDAD_PAGOS ,
    SUM(p.monto) AS MONTO_TOTAL_RECIBIDO
FROM METODO_PAGO mp 
JOIN PAGO p ON p.METODO_PAGO_ID_METODO_PAGO = mp.ID_METODO_PAGO
group by mp.NOMBRE
order by MONTO_TOTAL_RECIBIDO DESC;
