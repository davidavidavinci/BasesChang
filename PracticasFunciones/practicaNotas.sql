--------------------------------------------------------------------------------
-- Consulta 1: Consulta de curso aprobado 
create or replace function aprobado(pEstudiante in number, pCurso in number)
    return varchar is
            
    vResultado varchar(20);
begin
    begin
        select resultado
            into vResultado
            from matricula
            where pEstudiante = idEstudiante and pCurso = idCurso;
        
        exception
            when no_data_found then
            vResultado := 'No ha aprobado';
    end;
    return vResultado;
end;
--------------------------------------------------------------------------------
-- Consulta 2: Consulta de créditos ganados 
create or replace function totalCreditos(pEstudiante in number) 
    return number is
    
    vCarrera number;
    vTotal number := 0;
    
    cursor cCreditosEstudiante(pcEstudiante number, pCarrera number) is
        select c.creditos
        from curso c
        join matricula mat on mat.idCurso = c.idCurso
        join malla m on m.idCurso = c.idCurso
        where mat.resultado = 'Aprobado' 
            and mat.idEstudiante = pcEstudiante
            and m.idCarrera = pCarrera;
begin
    select idCarrera
        into vCarrera
        from estudiante
        where idEstudiante = pEstudiante;
        
    for c in cCreditosEstudiante(pEstudiante, vCarrera) loop
        vTotal := vTotal + c.creditos; 
    end loop;
    return vTotal;
end;    
--------------------------------------------------------------------------------
-- Consulta 3: Consulta de graduación 
create or replace function puedeGaduarse(pEstudiante in number)
    return boolean is
    
    vPuedeGraduarse boolean := false;
    vCreditosCarrera number;
    
begin
    select c.creditos
        into vCreditosCarrera
        from carrera c
        join estudiante e on e.idCarrera = c.idCarrera;
        
    if totalCreditos(pEstudiante) >= vCreditosCarrera then
        vPuedeGraduarse := true;
    end if;
    return vPuedeGraduarse;
end;
--------------------------------------------------------------------------------
-- Consulta 4: Con base en el modelo de tablas anterior, programar una función 
-- que devuelva si los créditos totales de una carrera están correctos con los 
-- créditos de sus cursos. 
create or replace function creditosCorrectos(pCarrera in number)
    return boolean is

    vSumaCreditos number := 0;
    vCreditos number;
    vEstanIgual boolean := false;
    
    cursor cCreditosCursos(pcCarrera number) is
        select c.creditos
        from curso c
        join malla m on m.idCarrera = pcCarrera;
begin
    select creditos
        into vCreditos
        from carrera
        where idCarrera = pCarrera;
    
    select sum(creditos)
        into vSumaCreditos
        from cCreditosCarrera(pCarrera);
        
    if vCreditos = vSumaCreditos then 
        vEstanIgual := true; 
    end if;
    return vEstanIgual;
end;
--------------------------------------------------------------------------------
-- Consulta 5: Consulta de cursos restantes 
create or replace function cantCursosRestantes(pEstudiante in number)
    return number is
    
    vCursosAprobados number;
    vCursosCarrera number;
    vCarrera number;
    
    cursor cCursosCarrera(pCarrera number) is 
        select idCurso
        from malla
        where idCarrera = pCarrera;
        
    cursor cCursosAprobados(pcEstudiante number) is
        select mat.idCurso
        from matricula mat
        join estudiante e on e.idEstudiante = mat.idEstudiante
        where mat.idEstudiante = pcEstudiante and mat.resultado = 'Aprobado' and mat.idCurso in (select idCurso from malla where idCarrera = e.idCarrera);
BEGIN
    select idCarrera
        into vCarrera
        from estudiante
        where idEstudiante = pEstudiante;
        
    select count(idCurso)
        into vCursosCarrera
        from cCursosCarrera(vCarrera);    
    
    select count(idCurso)
        into vCursosAprobados
        from cCursosAprobados(pEstudiante);
        
    return (vCursosCarrera-vCursosAprobados);
end;        