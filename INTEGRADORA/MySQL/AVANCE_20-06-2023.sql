CREATE DATABASE integradora;
USE integradora;

CREATE TABLE users(
	id_user integer AUTO_INCREMENT,
    email VARCHAR(45) NOT NULL,
    password_user VARCHAR (10) NOT NULL,
    name_user VARCHAR (40) NOT NULL, 
    first_last_name VARCHAR(40) NOT NULL,
    second_last_name VARCHAR(40) NOT NULL,
    telephone_number VARCHAR(10) NOT NULL,
    role_user VARCHAR(40) NOT NULL, 
    PRIMARY KEY (id_user)
);

SELECT role_user, COUNT(*) as count_users
FROM users
GROUP BY role_user;


CREATE INDEX idx_name_user ON users (name_user);
CREATE INDEX idx_last_names ON users (first_last_name, second_last_name);
CREATE UNIQUE INDEX idx_unique_email ON users (email);

#Corregido

CREATE TABLE consultants(
	id_consultant INTEGER AUTO_INCREMENT,
    professional_license VARCHAR(45) NOT NULL,
    experience_years INT NOT NULL, 
    speciality VARCHAR(100) NOT NULL,
    fk_user INTEGER NOT NULL,
    PRIMARY KEY (id_consultant),
    FOREIGN KEY(fk_user) REFERENCES users (id_user)
);

SELECT speciality, COUNT(*) as count_consultants
FROM consultants
GROUP BY speciality;


CREATE INDEX idx_speciality ON consultants (speciality);
CREATE UNIQUE INDEX idx_unique_professional_license ON consultants (professional_license);

CREATE TABLE tutors(
	id_tutor INTEGER AUTO_INCREMENT,
    division_academic VARCHAR(45) NOT NULL,
    fk_user INTEGER NOT NULL,
    PRIMARY KEY (id_tutor),
    FOREIGN KEY(fk_user) REFERENCES users (id_user)
);

SELECT division_academic, COUNT(*) as count_tutors
FROM tutors
GROUP BY division_academic;


CREATE INDEX idx_division_academic ON tutors (division_academic);

CREATE TABLE degrees_students(
	id_degree INTEGER AUTO_INCREMENT,
    name_degree VARCHAR(60) NOT NULL,
    division_academic VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_degree)
);

SELECT division_academic, COUNT(*) as count_degrees
FROM degrees_students
GROUP BY division_academic;

CREATE INDEX idx_name ON degrees_students (name_degree);

CREATE TABLE periods(
	id_period INTEGER AUTO_INCREMENT,
    name_period VARCHAR(50) NOT NULL,
    date_begin DATE NOT NULL,
    date_end DATE NOT NULL,
    PRIMARY KEY (id_period)
);

SELECT name_period, COUNT(*) as count_periods
FROM periods
GROUP BY name_period;


CREATE INDEX idx_period_name ON periods (name_period);
CREATE INDEX idx_date_begin_end ON periods (date_begin, date_end);

CREATE TABLE groups_students(
	id_group INTEGER AUTO_INCREMENT,
    grade INT NOT NULL,
    group_ VARCHAR(1),
    fk_tutor INTEGER NOT NULL,
    fk_degree INTEGER NOT NULL,
    fk_period INTEGER NOT NULL,
    PRIMARY KEY (id_group),
    FOREIGN KEY (fk_tutor) REFERENCES tutors(id_tutor),
    FOREIGN KEY (fk_degree) REFERENCES degrees_students (id_degree),
    FOREIGN KEY (fk_period) REFERENCES periods (id_period)
);

SELECT fk_period, COUNT(*) as count_groups
FROM groups_students
GROUP BY fk_period;

CREATE INDEX idx_grade_group ON groups_students (grade, group_);

CREATE TABLE students(
	id_student INTEGER AUTO_INCREMENT,
    enrollment VARCHAR(10) NOT NULL,
    status_student INTEGER NOT NULL,
    fk_user INTEGER NOT NULL,
    fk_group INTEGER NOT NULL,
    PRIMARY KEY (id_student),
    FOREIGN KEY (fk_user) REFERENCES users(id_user),
    FOREIGN KEY (fk_group) REFERENCES groups_students(id_group)
);

SELECT fk_group, COUNT(*) as count_students
FROM students
GROUP BY fk_group;


CREATE UNIQUE INDEX idx_unique_enrollment ON students (enrollment);

CREATE TABLE appointments(
	id_appointment INTEGER AUTO_INCREMENT,
    fk_student INTEGER NOT NULL,
    place VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_appointment),
    FOREIGN KEY (fk_student) REFERENCES students (id_student)
);

SELECT fk_student, COUNT(*) as count_appointments
FROM appointments
GROUP BY fk_student;

CREATE INDEX idx_place ON appointments (place);

DROP TABLE appointments;
CREATE TABLE sessions(
	id_session INTEGER AUTO_INCREMENT,
    fk_consultant INTEGER NOT NULL,
    date_begin DATETIME NOT NULL,
    date_end DATETIME NOT NULL,
    attendance VARCHAR(2),
    fk_appointment INTEGER NOT NULL,
    PRIMARY KEY(id_session),
    FOREIGN KEY (fk_consultant) REFERENCES consultants (id_consultant),
    FOREIGN KEY (fk_appointment) REFERENCES appointments (id_appointment)
);

DELIMITER $$
CREATE TRIGGER before_delete_session
BEFORE DELETE ON sessions
FOR EACH ROW
BEGIN
    DECLARE appointment_count INT;
    SELECT COUNT(*) INTO appointment_count FROM appointments WHERE id_appointment = OLD.fk_appointment;

    IF appointment_count > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar la sesión si tiene una cita asociada.';
    END IF;
END;$$

SELECT fk_consultant, COUNT(*) as count_sessions
FROM sessions
GROUP BY fk_consultant;


CREATE INDEX idx_date_begin_end_sessions ON sessions (date_begin, date_end);

DROP TABLE sessions;
CREATE TABLE request_consultants(
	id_request_consultant INTEGER AUTO_INCREMENT,
    fk_session INTEGER NOT NULL,
    reason VARCHAR(200),
    status_consultans INTEGER NOT NULL,
    PRIMARY KEY(id_request_consultant),
	FOREIGN KEY (fk_session) REFERENCES sessions (id_session)
);

DELIMITER $$
CREATE TRIGGER before_insert_request_consultants
BEFORE INSERT ON request_consultants
FOR EACH ROW
BEGIN
    DECLARE existing_request_consultants INT;
    SELECT COUNT(*) INTO existing_request_consultants FROM request_consultants WHERE fk_session = NEW.fk_session;

    IF existing_request_consultants > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede enviar una solicitud duplicada para la misma sesión.';
    END IF;
END;$$

DELIMITER $$
CREATE TRIGGER before_delete_request_consultants
BEFORE DELETE ON request_consultants
FOR EACH ROW
BEGIN
    IF OLD.status_consultans = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar la solicitud';
    END IF;
END;$$

DROP TABLE request_consultants;

CREATE TABLE justifications(
	id_justification INTEGER AUTO_INCREMENT,
    fk_session INTEGER NOT NULL,
    reason VARCHAR(200) NOT NULL,
    status_consultans INTEGER NOT NULL,
    date_justification DATE NOT NULL,
    PRIMARY KEY (id_justification),
    FOREIGN KEY (fk_session) REFERENCES sessions(id_session)
);

DELIMITER $$
CREATE TRIGGER before_delete_justifications
BEFORE DELETE ON justifications
FOR EACH ROW
BEGIN
    IF OLD.status_consultans = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar la justificacion';
    END IF;
END;$$

SELECT date_justification, COUNT(*) as count_justifications
FROM justifications
GROUP BY date_justification;


SELECT fk_session, COUNT(*) as count_requests_consultants
FROM request_consultants
GROUP BY fk_session;

CREATE INDEX idx_date_justification ON justifications (date_justification);

DROP TABLE justifications;
CREATE TABLE request_students(
	id_request_student INTEGER AUTO_INCREMENT,
    reason VARCHAR(200),
	status_consultans INTEGER NOT NULL,
    fk_session INTEGER NOT NULL,
    PRIMARY KEY (id_request_student),
    FOREIGN KEY (fk_session) REFERENCES sessions (id_session)
);

DELIMITER $$
CREATE TRIGGER before_insert_request_students
BEFORE INSERT ON request_students
FOR EACH ROW
BEGIN
    DECLARE existing_requests INT;
    SELECT COUNT(*) INTO existing_requests FROM request_students WHERE fk_session = NEW.fk_session;

    IF existing_requests > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede enviar una solicitud duplicada para la misma sesión.';
    END IF;
END;$$

DELIMITER $$
CREATE TRIGGER before_delete_request_students
BEFORE DELETE ON request_students
FOR EACH ROW
BEGIN
    IF OLD.status_students = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar la solicitud';
    END IF;
END;$$


SELECT fk_session, COUNT(*) as count_requests
FROM request_students
GROUP BY fk_session;

DROP TABLE request_students;
# CREACION DE INDICES --------------------
#TABLA USERS
DELIMITER $$
CREATE TRIGGER validar_historial  BEFORE DELETE ON users
FOR EACH ROW
BEGIN
	DECLARE his_st INTEGER;
    DECLARE his_con INTEGER;
    DECLARE his_tu INTEGER;
    
    SELECT COUNT(*) INTO his_st FROM students WHERE fk_user = old.id_user;
    SELECT COUNT(*) INTO his_con FROM consultants WHERE fk_user = old.id_user;
	SELECT COUNT(*) INTO his_tu FROM tutors WHERE fk_user = old.id_user;
    
	IF his_con = 1 OR his_st = 1 OR his_tu = 1 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NO PUDE ELIMINAR UN USUARIO QUE TIENE HISTORIAL ...';
    END IF;

END;
$$

SELECT COUNT(*) FROM students WHERE fk_user = 2;
DROP TRIGGER validar_historial;
#Comprobar TRIGGER
INSERT INTO users VALUES (0, 'solis@utez.edu.mx', '20223TN112', 'Leticia', 'Solis', 'Nepomuceno', '7771429494', 'estudiante');
INSERT INTO users VALUES (0,'aidazevada@utez.edu.mx','12345','Aida Violeta','Zevada','Carrillo','7776843017','tutor');
INSERT INTO tutors VALUES (0, 'DATID', 2);
INSERT INTO degrees_students VALUES (0, 'DSM', 'DATID');
INSERT INTO periods VALUES (0, 'ENE-ABR', '04-01-23', '28-04-23');
INSERT INTO groups_students VALUES (0, 3, 'D', 14, 1, 1);

DELETE FROM tutors WHERE id_tutor = 14;
INSERT INTO students VALUES (0, '20223TN112',1, 3, 6);

SELECT * FROM groups_students;
SELECT * FROM users;

#TABLA GROUPS_STUDENTS
DELIMITER $$
CREATE TRIGGER validar_grupos_tutores BEFORE DELETE ON groups_students
FOR EACH ROW 
BEGIN
	    DECLARE asig_gr INTEGER;
		SELECT COUNT(*) INTO asig_gr FROM tutors WHERE id_tutor = old.fk_tutor;
        
        IF asig_gr = 1 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NO PUDE ELIMINAR UN GRUPO QUE CONTENGA UN TUTOR ...';
        END IF;
END;
$$

DROP TRIGGER validar_grupos_tutores;
SELECT COUNT(*)  FROM tutors WHERE id_tutor = 14;

DELETE FROM students WHERE id_student = 13;
DELETE FROM appointments WHERE id_appointment = 2;
INSERT INTO students VALUES (0, '20223TN112',1, 3, 7);
SELECT * FROM students;
SELECT * FROM users;
SELECT * FROM appointments;
INSERT INTO appointments VALUES (0, 13, 'DOCENCIA 1');

#TABLE APPOINTMENTS
DELIMITER $$
CREATE TRIGGER validar_cita_estudiante BEFORE DELETE ON appointments
FOR EACH ROW
BEGIN
		DECLARE cita_curso INTEGER;
		SELECT COUNT(*) INTO cita_curso FROM students WHERE id_student = old.fk_student;
        
        IF cita_curso != 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NO PUDE ELIMINAR UNA CITA SI YA ESTA AGENDADA ...';
        END IF;
END;
$$

#TABLE STUDENT
DELIMITER $$
CREATE TRIGGER validar_estudiante_grupo BEFORE DELETE ON students
FOR EACH ROW
BEGIN
		DECLARE gupo_es INTEGER;
		SELECT COUNT(*) INTO grupo_es FROM groups_students WHERE id_group = old.fk_tutor;
        
        IF asig_gr = 1 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NO PUDE ELIMINAR UN GRUPO QUE CONTENGA UN TUTOR ...';
        END IF;
END;
$$

#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER before_tutor_insert
BEFORE INSERT ON tutors
FOR EACH ROW
BEGIN
    DECLARE existing_tutors INT;
    
    SELECT COUNT(*) INTO existing_tutors
    FROM tutors
    WHERE id_tutor = NEW.id_tutor;
    
    IF existing_tutors > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El ID del tutor ya existe.';
    END IF;
END $$
INSERT INTO tutors VALUES (1, 'DATID',1);
select * from users;

