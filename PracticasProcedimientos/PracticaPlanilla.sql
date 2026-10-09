--------------------------------------------------------------------------------
-- Procedimiento para insertar valores a la planilla de un periodo en específico
create or replace procedure proc_planilla(p_fecha_inicio date, p_fecha_fin date)
    is
    -- Cursores
    cursor c_empleados_destajo(pc_fecha_inicio date, pc_fecha_fin date) is 
        select e.idempleado, e.salario, m.fecha
    cursor c_empleados_produccion is 
begin
    for e in empleados loop
    
    end loop;
end;
--------------------------------------------------------------------------------
-- Función para saber pago por hora
create or replace function f_pago_horas(p_idempleado number, p_fecha date)
    return number is
    -- Variables
    v_pago number := 0;
    v_pago_total number := 0;
    -- Cursores
    cursor c_marcas_empleado(pc_idempleado number, pc_fecha date) is
        select e.salario, m.salida-m.entrada as horas
        from empleado e
        join marcas m on e.idempleado = m.idempleado
        where m.idempleado = pc_idempleado and m.fecha = pc_fecha;
begin
    for i in c_marcas_empleado(p_idempleado, p_fecha) loop
        v_pago := i.horas * i.salario;
        v_pago_total := v_pago_total + v_pago;
        -- Reinicia variable pago para el siguiente ciclo
        v_pago := 0;
    end loop;
    
    return v_pago_total;
    
    exception when NO_DATA_FOUND OR TOO_MANY_ROWS then
        return 0;
end;
--------------------------------------------------------------------------------
-- Funcion para saber horas diurnas trabajadas
create or replace function f_horas_diurnas(p_idempleado number, p_fecha date) 
    return int is
    
    v_horas number;
begin
    select (salida-entrada)
        into v_horas
        from marcas
        where idempleado = p_idempleado and
              fecha = p_fecha and
              tipoMarca = 'Diurnas';
    return v_horas;
    exception when NO_DATA_FOUND OR TOO_MANY_ROWS THEN  
        RETURN 0;
end;
--------------------------------------------------------------------------------
-- Funcion para saber horas nocturnas trabajadas
create or replace function f_horas_nocturnas(p_idempleado number, p_fecha date) 
    return int is
    
    v_horas number;
begin
    select (salida-entrada)
        into v_horas
        from marcas
        where idempleado = p_idempleado and
              fecha = p_fecha and
              tipoMarca = 'Nocturnas';
    return v_horas;
    exception when NO_DATA_FOUND OR TOO_MANY_ROWS THEN  
        RETURN 0;
end;
--------------------------------------------------------------------------------
-- Función para ver si es feriado
create or replace function f_es_feriado(p_fecha date) return int is
    v_es_feriado int;
begin
    select count(fecha)
        into v_es_feriado
        from diasferiados
        where fecha = p_fecha;
    return v_es_feriado;
end;
-- Ver si funciona
BEGIN DBMS_OUTPUT.PUT_LINE(f_es_feriado('15/01/22')); END;
--------------------------------------------------------------------------------
-- Retorna el monto a pagar para ese día
create or replace function f_pago_kg_prod(p_idempleado in number, 
    p_fecha in date) return number is 
    
    v_pago number := 0;
begin
    select (p1.kilosProducidos*p2.costoKiloProducido)
        into v_pago
        from produccion p1
        join producto p2 on p1.idProducto = p2.idProducto
        where p1.idEmpleado = p_idEmpleado and p1.fecha = p_fecha;
        
    return v_pago;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN TOO_MANY_ROWS THEN
        RETURN 0;
end;
-- Ver si funciona
begin
    DBMS_OUTPUT.PUT_LINE(f_pago_kg_prod(1, '07/01/22'));
end;
--------------------------------------------------------------------------------
select * from empleado;
select * from marcas;
select * from produccion;
select * from producto;
select * from planilla;
select * from diasferiados;
--------------------------------------------------------------------------------
drop table empleado cascade constraint;
drop table marcas cascade constraint;
drop table produccion cascade constraint;
drop table producto cascade constraint;
drop table planilla cascade constraint;
drop table diasferiados cascade constraint;
--------------------------------------------------------------------------------
create table empleado(
idEmpleado number,
nombre varchar(20),
tipoEmpleado varchar(15),
salario number,
primary key(idEmpleado));
insert into empleado values (1,'Juan', 'Destajo', 0);
insert into empleado values (2,'Ana', 'Por hora', 200);
insert into empleado values (3,'Carlos', 'Destajo', 0);
insert into empleado values (4,'Pedro', 'Por Hora', 100);
--------------------------------------------------------------------------------
create table marcas(
idMarca number,
idEmpleado number,
fecha date,
entrada number,
salida number,
tipoMarca varchar(10),
primary key(idMarca));
insert into marcas values (1,2,'07-01-2022', 8, 11, 'Diurnas');
insert into marcas values (2,4,'14-01-2022', 18, 23, 'Nocturnas');
insert into marcas values (3,4,'10-01-2022', 8, 10, 'Diurnas');
insert into marcas values (4,4,'10-01-2022', 12, 14, 'Diurnas');
insert into marcas values (5,2,'11-01-2022', 18, 22, 'Nocturnas');
--------------------------------------------------------------------------------
create table produccion(
idProduccion number,
fecha date,
idProducto number,
idEmpleado number,
kilosProducidos number,
primary key(idProduccion));
insert into produccion values(1, '07-01-2022', 1, 1, 10);
insert into produccion values(2, '14-01-2022', 2, 1, 15);
insert into produccion values(3, '14-01-2022', 5, 3, 5);
insert into produccion values(4, '14-01-2022', 6, 1, 10);
insert into produccion values(5, '15-01-2022', 7, 3, 15); 
--------------------------------------------------------------------------------
create table producto(
idProducto number,
nombre varchar(10),
costoKiloProducido number,
primary key(idProducto));
insert into producto values (1, 'Helado', 750),
insert into producto values (2, 'Chocolate', 500);
insert into producto values (3, 'Coca Cola', 50);
insert into producto values (4, 'Agua', 100);
insert into producto values (5, 'Frutas', 200);
insert into producto values (6, 'Yogurt', 100);
insert into producto values (7, 'Leche', 100);
--------------------------------------------------------------------------------
create table planilla(
idEmpleado number,
fecha date,
montoAPagar number,
primary key(idEmpleado,Fecha));
--------------------------------------------------------------------------------
create table diasFeriados(
idFeriado number,
fecha date,
descripcion varchar(20),
primary key(idFeriado));
insert into diasFeriados values (1, '15-01-2022', 'un feriado');
commit; 
--------------------------------------------------------------------------------
set serveroutput on;