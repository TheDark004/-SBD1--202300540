-- Creamos (o reemplazamos) un trigger llamado TR_Insert_Detalle
-- que vive en la tabla DETALLE_VENTA y se ejecuta DESPUÉS de un INSERT
CREATE OR ALTER TRIGGER TR_Insert_detalle     
ON DETALLE_VENTA
AFTER INSERT                         
AS
BEGIN
    -- SET NOCOUNT ON es una buena práctica:
    -- evita que SQL Server envíe mensajes de "N filas afectadas" que confunden al cliente
    SET NOCOUNT ON;
    
   
    -- PASO 1: Verificar si algún producto insertado no tiene stock suficiente
    -- INSERTED contiene las filas que se acaban de insertar
    -- Hacemos JOIN con PRODUCTO para poder ver la existencia actual
    -- Preguntamos: ¿existe AL MENOS UNA fila donde lo pedido supere lo disponible?
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PRODUCTO p ON p.id_producto = i.PRODUCTO_id_producto
        WHERE i.cantidad > p.existencia
    )
    BEGIN
        -- Si encontramos un problema, lanzamos un error personalizado
        -- Severidad 16 = error de usuario (que el cliente/API puede capturar)
        RAISERROR('Stock insuficiente para completar la venta.', 16, 1);

        -- Cancelamos toda la transacción. Esto deshace el INSERT original
        -- y cualquier otro cambio hecho en la misma transacción
        ROLLBACK TRANSACTION;

        -- Salimos del trigger sin seguir ejecutando
        RETURN;
    END

    
    -- PASO 2: Si llegamos aquí, todos los productos tienen stock suficiente
    -- Descontamos la cantidad vendida de la existencia de cada producto
    -- UPDATE con JOIN a INSERTED: descuenta en una sola operación
    -- para TODOS los productos afectados (no uno por uno)
    UPDATE p
    SET p.existencia = p.existencia - i.cantidad
    FROM PRODUCTO p
    JOIN inserted i ON p.id_producto = i.PRODUCTO_id_producto;
END;