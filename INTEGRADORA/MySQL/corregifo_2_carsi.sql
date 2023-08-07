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

CREATE TABLE tutors(
	id_tutor INTEGER AUTO_INCREMENT,
    division_academic VARCHAR(45) NOT NULL,
    fk_user INTEGER NOT NULL,
    PRIMARY KEY (id_tutor),
    FOREIGN KEY(fk_user) REFERENCES users (id_user)
);

CREATE TABLE degrees_students(
	id_degree INTEGER AUTO_INCREMENT,
    name_degree VARCHAR(60) NOT NULL,
    division_academic VARCHAR(60) NOT NULL,
    PRIMARY KEY (id_degree)
);

CREATE TABLE periods(
	id_period INTEGER AUTO_INCREMENT,
    name_period VARCHAR(50) NOT NULL,
    date_begin DATE NOT NULL,
    date_end DATE NOT NULL,
    PRIMARY KEY (id_period)
);

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

CREATE TABLE appointments(
	id_appointment INTEGER AUTO_INCREMENT,
    fk_student INTEGER NOT NULL,
    place VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_appointment),
    FOREIGN KEY (fk_student) REFERENCES students (id_student)
);
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
DROP TABLE sessions;
CREATE TABLE request_consultants(
	id_request_consultant INTEGER AUTO_INCREMENT,
    fk_session INTEGER NOT NULL,
    reason VARCHAR(200),
    status_consultans INTEGER NOT NULL,
    PRIMARY KEY(id_request_consultant),
	FOREIGN KEY (fk_session) REFERENCES sessions (id_session)
);
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
DROP TABLE justifications;
CREATE TABLE request_students(
	id_request_student INTEGER AUTO_INCREMENT,
    reason VARCHAR(200),
	status_consultans INTEGER NOT NULL,
    fk_session INTEGER NOT NULL,
    PRIMARY KEY (id_request_student),
    FOREIGN KEY (fk_session) REFERENCES sessions (id_session)
);
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