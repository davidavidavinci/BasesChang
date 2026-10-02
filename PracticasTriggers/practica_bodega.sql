create table empleado(
    id_empleado number,
    nombre varchar2(30),
    id_departamento number,
    id_jefe number,
    salario number,
    primary key(id_empleado)
);

create table articulo(
    id_articulo number,
    nombre varchar2(30),
    existencia number,
    primary key(id_articulo)
);

create table movimiento(
    id_movimiento number,
    fecha date,
    tipo_mov varchar2(30),
    id_bodega number,
    id_empleado number,
    referencia varchar2(100),
    primary key(id_movimiento)
);

create table movimiento_detalle(
    id_movimiento number,
    id_producto number,
    cantidad number,
    primary key(id_movimiento, id_producto)
);

create table bodega(
    id_bodega number,
    existencia_total_bodega number,
    primary key(id_bodega)
);

create table bodega_producto(
    id_bodega number,
    id_producto number,
    existencia number,
    primary key(id_bodega, id_producto)
);

create table permiso(
    id_bodega number,
    id_empleado number,
    primary key(id_bodega, id_empleado)
);

create table tope(
    id_empleado number,
    id_producto number,
    cant_maxima_mes number,
    primary key(id_empleado, id_producto)
);

-- Genera el campo referencia de forma automática
create or replace trigger referencia_automatica
    before insert on movimiento
    for each row
declare
    v_consecutivo number;
begin
    select count(*) + 1 
        into v_consecutivo
        from movimiento
        where id_bodega = :new.id_bodega and tipo_mov = :new.tipo_mov;
    
    :new.referencia := :new.id_bodega||':'||
                       :new.tipo_mov||':'||
                       v_consecutivo;
end;

-- Empleado solo puede realizar movimientos para los que tiene permiso,
-- Jefe no necesita permiso
