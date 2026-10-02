create table estudiante(
    id_estudiante number,
    nombre varchar2(30),
    telefono number,
    max_creditos number,
    total_creditos_mat number,
    primary key(id_estudiante)
);

create table curso(
    id_curso number,
    nombre varchar2(30),
    creditos number,
    primary key(id_curso)
);

create table matricula(
    id_matricula number,
    id_estudiante number,
    periodo varchar2(30),
    creditos_mat number,
    primary key(id_matricula, id_estudiante)
);

create table matricula_detalle(
    id_matricula number,
    id_curso number,
    primary key(id_matricula, id_curso)
);

-- Inserts estudiante
insert into estudiante values(1, 'Fulano', 1111, 12, 11);
insert into estudiante values(2, 'Mengano', 2222, 12, 10);
insert into estudiante values(3, 'Sutano', 3333, 12, 9);
    
-- Inserts curso
insert into curso values(1, 'Programación I', 4);
insert into curso values(2, 'Cálculo I', 3);
insert into curso values(3, 'Seminario II', 2);

-- Triggers
create or replace trigger validacion_matricula
    before insert on matricula_detalle
    for each row
declare
    v_estudiante number;
    v_cred_mat number;
    v_cred_max number;
    v_cred_curso number;
    v_cursos_previos number;
begin
    select id_estudiante, total_creditos_mat
        into v_estudiante, v_cred_mat
        from matricula
        where id_matricula =:new.id_matricula;
    
    select max_creditos 
        into v_cred_max
        from estudiante
        where id_estudiante = v_estudiante;
    
    select creditos 
        into v_cred_curso
        from curso
        where id_curso = :new.id_curso;
        
    SELECT COUNT(*)
        INTO v_cursos_previos
        FROM matricula_detalle md
        JOIN matricula m ON md.id_matricula = m.id_matricula
        WHERE m.id_estudiante = v_estudiante
        AND md.id_Curso = :NEW.id_Curso;
    
    -- Validaciones
    IF v_cursos_previos > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: El estudiante ya matriculó este curso.');
    END IF;
    
    UPDATE Matricula
    SET creditos_mat = creditos_mat + v_cred_curso
    WHERE id_matricula = :NEW.id_matricula;
    
    UPDATE Estudiante
    SET total_creditos_mat = total_creditos_mat + v_cred_curso
    WHERE id_estudiante = v_Estudiante;
end;