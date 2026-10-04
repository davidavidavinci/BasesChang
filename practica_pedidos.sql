declare
    cursor cCliente(pTipo char) is
        select idCliente
        from cliente
        where tipo = pTipo;
    cursor cPedidoCliente(pCliente number) is
        select idPedido, fecha
        from pedido
        where idCliente = pCliente;
    cursor cPedidoDetalle(pPedido number) is
        select idProducto, cantidad
        from pedidoDetalle
        where idPedido = pPedido;
    cursor cFactura is
        select idFactura
        from factura;
    pTipoCliente char := 'A';
    pIdFacturaActual number := 1;
    pSubtotal number := 0;
    pPrecio number := 0;
    pMontoTotal number := 0;
begin
    -- Verifica que idFacturaSiguiente sea mayor al último agregado
    for i in cFactura loop
        if pIdFacturaActual = i.idFactura then
            pIdFacturaActual := pIdFacturaActual + 1;
        end if;
    end loop;
    -- Recorre los clientes de tipo 'A'
    for c in cCliente(pTipoCliente) loop
        -- Recorre los pedidos del cliente 
        for pc in cPedidoCliente(c.idCliente) loop
            -- Recorre pedidoDetalle del pedido del cliente
            for pd in cPedidoDetalle(pc.idPedido) loop
                -- Averigüar el precio del producto
                select precio
                    into pPrecio
                    from producto
                    where idProducto = pd.idProducto;
                -- Calcular subtotal
                pSubtotal := pd.cantidad * pPrecio;
                -- Actualizar monto total
                pMontoTotal := pMontoTotal + pSubtotal;
                -- Actualizar FacturaDetalle
                insert into FacturaDetalle
                    values(pIdFacturaActual, pd.idProducto, pd.cantidad, pSubtotal, pPrecio);
            end loop;
            -- Actualizar Factura
            insert into Factura
                values(pIdFacturaActual, pc.fecha, pMontoTotal, c.idCliente, pc.idPedido);
            -- Actualizar/reiniciar parámetros
            pIdFacturaActual := pIdFacturaActual + 1;
            pMontoTotal := 0;
            pSubtotal := 0;
            pPrecio := 0;
        end loop;
    end loop;
end;
--------------------------------------------------------------------------------
select * from FacturaDetalle;
select * from Factura;
select * from PedidoDetalle;
select * from Pedido;
select * from Producto;
select * from Cliente;
--------------------------------------------------------------------------------
TRUNCATE TABLE Factura;
TRUNCATE TABLE FacturaDetalle;