declare
    cursor cEstudiante is
        select e.idEstudiante, e.nombre, e.idCarrera, c.creditos as creditosCarrera
        from estudiante e
        join carreras c on c.idCarrera = e.idCarrera;
    cursor cCursosEstudiante(pEstudiante number) is
        select m.idEstudiante, m.idCurso, c.nombre, m.nota, c.notaAprobacion, c.creditos
        from matricula m
        join curso c on c.idCurso = m.idCurso
        where m.idEstudiante = pEStudiante;
    pCredAprobados number := 0;
    pCursosFaltantes varchar2(300):= 'Cursos faltantes:';
begin
    for e in cEstudiante loop
        pCredAprobados := 0;
        pCursosFaltantes := 'Cursos faltantes:';
        for ces in cCursosEstudiante(e.idEstudiante) loop
            if ces.nota >= ces.notaAprobacion then 
                pCredAprobados := pCredAprobados + ces.creditos;
            else
                pCursosFaltantes := pCursosFaltantes||chr(10)||' - ' || ces.nombre;
            end if;
        end loop;
        if pCredAprobados = e.creditosCarrera then
            dbms_output.put_line('El estudiante '||e.nombre||' ha cumplido con toda la malla de cursos de su carrera');
            dbms_output.put_line('');
        else
            dbms_output.put_line('El estudiante "'||e.nombre||'" no  ha cumplido con toda la malla de cursos de su carrera');
            dbms_output.put_line('Créditos totales de la carrera: '||e.creditosCarrera);
            dbms_output.put_line('Créditos aprobados: '||pCredAprobados);
            dbms_output.put_line('Créditos faltantes: '||(e.creditosCarrera-pCredAprobados));
            dbms_output.put_line(pCursosFaltantes);
            dbms_output.put_line('');
        end if;
    end loop;
end;
--------------------------------------------------------------------------------
set serveroutput on;
--------------------------------------------------------------------------------
select * from estudiante;
select * from carreras;
select * from curso;
select * from matricula;
select * from malla;
