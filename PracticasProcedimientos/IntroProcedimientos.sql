CREATE OR REPLACE PROCEDURE pAplicarAumento(
 pId IN number,
 pPorc IN number,
 pNuevo OUT number)
IS
 vSalario number;
BEGIN
 SELECT salario INTO vSalario
 FROM empleado
 WHERE idEmpleado = pId;
 IF pPorc > 20 THEN
 RAISE_APPLICATION_ERROR(-20001,
 'el aumento no puede pasar del 20%');
 END IF;
 pNuevo := vSalario * (1 + pPorc/100);
 UPDATE empleado
 SET salario = pNuevo
 WHERE idEmpleado = pId;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
create or replace procedure imprimir(p_tipoempleado varchar) is
    cursor c_empleados is
        select idempleado, nombre
        from empleado
        where tipoempleado = p_tipoempleado;
begin
    dbms_output.put_line('Empleados de tipo '||P_TIPOEMPLEADO);
    for i in c_empleados loop
        dbms_output.put_line('ID: '||i.idempleado||' - Nombre: '||i.nombre);
    end loop;
end;

begin
    imprimir('Destajo');
end;
--------------------------------------------------------------------------------
set serveroutput on;
--------------------------------------------------------------------------------
select * from empleado;
--------------------------------------------------------------------------------
drop table planilla cascade constraint;
drop table bitacora cascade constraint;

create table bitacora (
    id_bitacora number(8),
    fecha date,
    mensaje varchar2(200),
    constraint pk_bitacora
        primary key(id_bitacora)
);

create table planilla (
    id_empleado number(4),
    periodo varchar2(7),
    salario_bruto number(12, 2),
    deducciones number(12, 2),
    bonificacion number(12, 2) default 0,
    salario_neto number(12, 2),
    constraint pk_planilla
        primary key(id_empleado, periodo)
);