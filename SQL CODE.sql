CREATE DATABASE IF NOT EXISTS student_management;

USE student_management;

CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO subjects (subject_name) VALUES
('Advanced Java'),
('DBMS'),
('AI'),
('ReactJS'),
('Research Methodology'),
('German Language');

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    course VARCHAR(50) NOT NULL,
    semester VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teacher_subjects (
    teacher_subject_id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    UNIQUE(teacher_id, subject_id)
);

CREATE TABLE login (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL,
    student_id INT NULL,
    teacher_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE SET NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

CREATE TABLE marks (
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    marks INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    status VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);

INSERT INTO login (username, password, role, student_id, teacher_id)
VALUES ('admin', 'admin123', 'admin', NULL, NULL);

CREATE UNIQUE INDEX idx_login_username ON login(username);

CREATE INDEX idx_login_role ON login(role);

CREATE INDEX idx_login_student_id ON login(student_id);

CREATE INDEX idx_login_teacher_id ON login(teacher_id);

CREATE INDEX idx_students_email ON students(email);

CREATE INDEX idx_teachers_email ON teachers(email);

CREATE INDEX idx_marks_student ON marks(student_id);

CREATE INDEX idx_marks_subject ON marks(subject_id);

CREATE INDEX idx_attendance_student ON attendance(student_id);

CREATE INDEX idx_attendance_subject ON attendance(subject_id);

CREATE INDEX idx_attendance_date ON attendance(date);

CREATE INDEX idx_teacher_subjects_teacher ON teacher_subjects(teacher_id);

CREATE INDEX idx_teacher_subjects_subject ON teacher_subjects(subject_id);

CREATE VIEW student_login_view AS
SELECT 
    l.id,
    l.username,
    l.role,
    l.student_id,
    s.name,
    s.email,
    s.course,
    s.semester
FROM login l
LEFT JOIN students s ON l.student_id = s.student_id
WHERE l.role = 'student';

CREATE VIEW teacher_login_view AS
SELECT 
    l.id,
    l.username,
    l.role,
    l.teacher_id,
    t.name,
    t.email,
    t.subject,
    t.phone
FROM login l
LEFT JOIN teachers t ON l.teacher_id = t.teacher_id
WHERE l.role = 'teacher';

CREATE VIEW teacher_subject_view AS
SELECT 
    t.teacher_id,
    t.name AS teacher_name,
    s.subject_id,
    s.subject_name
FROM teachers t
INNER JOIN teacher_subjects ts ON t.teacher_id = ts.teacher_id
INNER JOIN subjects s ON ts.subject_id = s.subject_id
ORDER BY t.teacher_id, s.subject_name;


SHOW TABLES;


SELECT * FROM subjects;


SELECT id, username, role, student_id, teacher_id FROM login;




SELECT * FROM students;


SELECT * FROM teachers;


SELECT t.name AS teacher, s.subject_name AS subject
FROM teacher_subjects ts
INNER JOIN teachers t ON ts.teacher_id = t.teacher_id
INNER JOIN subjects s ON ts.subject_id = s.subject_id;


SELECT * FROM marks;


SELECT * FROM attendance;


SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_NAME IN ('login', 'marks', 'attendance', 'teacher_subjects')
AND REFERENCED_TABLE_NAME IS NOT NULL;