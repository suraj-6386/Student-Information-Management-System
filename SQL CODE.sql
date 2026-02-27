CREATE DATABASE student_management;

USE student_management;

CREATE TABLE login (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,
    role VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    course VARCHAR(50) NOT NULL,
    semester VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    subject VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE marks (
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject VARCHAR(50) NOT NULL,
    marks INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    status VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

INSERT INTO login (username, password, role) VALUES
('admin', 'admin123', 'admin'),
('teacher', 'teacher123', 'teacher'),
('student', 'student123', 'student');

INSERT INTO students (name, course, semester, email, phone) VALUES
('Suraj Gupta', 'MCA', '2', 'suraj@college.edu', '6394902284'),
('Priya Singh', 'BCA', '2', 'priya@college.edu', '9876543211'),
('Vikram Patel', 'B.Tech', '2', 'vikram@college.edu', '9876543212'),
('Anjali Verma', 'MCA', '2', 'anjali@college.edu', '9876543213'),
('Rohan Gupta', 'B.Sc', '2', 'rohan@college.edu', '9876543214');

INSERT INTO teachers (name, subject, email, phone) VALUES
('Mrs. Minal Pawar', 'Adv JAVA', 'minal@college.edu', '9123456789'),
('Prof. Abhishek Sharma', 'DBMS', 'neha@college.edu', '9123456790'),
('Mr. Arvind Singh', 'AI', 'arvind@college.edu', '9123456791');

INSERT INTO marks (student_id, subject, marks) VALUES
(1, 'Adv JAVA', 85),
(1, 'DBMS', 78),
(1, 'AI', 88),
(2, 'Adv JAVA', 92),
(2, 'DBMS', 86),
(3, 'AI', 76),
(4, 'Adv JAVA', 95),
(5, 'DBMS', 82);

INSERT INTO attendance (student_id, date, status) VALUES
(1, '2026-02-20', 'Present'),
(1, '2026-02-21', 'Present'),
(1, '2026-02-22', 'Absent'),
(1, '2026-02-23', 'Leave'),
(2, '2026-02-20', 'Present'),
(2, '2026-02-21', 'Present'),
(2, '2026-02-22', 'Present'),
(3, '2026-02-20', 'Present'),
(3, '2026-02-21', 'Absent'),
(4, '2026-02-20', 'Present'),
(5, '2026-02-21', 'Present');

-- Verify all tables are created
SHOW TABLES;

SELECT * FROM login;

SELECT * FROM students;

SELECT * FROM marks;

SELECT * FROM attendance;




