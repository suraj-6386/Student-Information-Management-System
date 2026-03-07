DROP DATABASE IF EXISTS student_info_system;

CREATE DATABASE student_info_system
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE student_info_system;

CREATE TABLE admin (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    duration_years INT DEFAULT 3,
    total_semesters INT DEFAULT 6,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teacher (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    employee_id VARCHAR(20) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    department VARCHAR(100),
    qualification VARCHAR(100),
    experience INT DEFAULT 0,
    status ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    roll_number VARCHAR(20) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    parent_name VARCHAR(100),
    parent_contact VARCHAR(15),
    course_id INT,
    semester INT DEFAULT 1,
    status ENUM('pending','approved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE SET NULL
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) UNIQUE NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    course_id INT NOT NULL,
    semester INT NOT NULL,
    credits INT DEFAULT 4,
    max_capacity INT DEFAULT 60,
    teacher_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE,

    FOREIGN KEY (teacher_id)
        REFERENCES teacher(teacher_id)
        ON DELETE SET NULL
);

CREATE TABLE subject_enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active','completed','dropped') DEFAULT 'active',

    UNIQUE KEY uk_student_subject (student_id, subject_id),

    FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE CASCADE,

    FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE
);

CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    class_date DATE NOT NULL,
    status ENUM('present','absent','leave') DEFAULT 'absent',
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_attendance (student_id, subject_id, class_date),

    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id) ON DELETE CASCADE
);

CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,

    internal1_marks INT DEFAULT 0,
    internal2_marks INT DEFAULT 0,
    external_marks INT DEFAULT 0,
    total_marks INT DEFAULT 0,
    grade VARCHAR(2),

    evaluated_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_student_subject_marks (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id) ON DELETE CASCADE
);

CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    posted_by INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    visibility_level ENUM('all','students','teachers','admin') DEFAULT 'all',
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (posted_by)
        REFERENCES teacher(teacher_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_student_login ON student(email, password_hash);

CREATE INDEX idx_teacher_login ON teacher(email, password_hash);

CREATE INDEX idx_attendance_lookup ON attendance(student_id, subject_id);

CREATE INDEX idx_attendance_date ON attendance(class_date);

CREATE INDEX idx_marks_lookup ON marks(student_id, subject_id);

CREATE INDEX idx_subject_lookup ON subjects(course_id, semester);

CREATE INDEX idx_subject_teacher ON subjects(teacher_id);

CREATE INDEX idx_student_enrollment ON subject_enrollment(student_id, status);

CREATE INDEX idx_subject_enrollment ON subject_enrollment(subject_id, status);

INSERT INTO admin (username, password_hash, full_name, email)
VALUES (
'admin',
'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=',
'System Administrator',
'admin@sims.edu'
);

INSERT INTO courses (course_code, course_name, duration_years, total_semesters) VALUES
('BTech-CS', 'Bachelor of Technology in Computer Science', 4, 8),
('BTech-IT', 'Bachelor of Technology in Information Technology', 4, 8),
('BSc-CS', 'Bachelor of Science in Computer Science', 3, 6),
('BCA', 'Bachelor of Computer Applications', 3, 6),
('MCA', 'Master of Computer Applications', 2, 4);

SET @counter = 1;
UPDATE student 
SET user_id = CONCAT('STU', LPAD(@counter := @counter + 1, 6, '0'))
WHERE user_id IS NULL
ORDER BY student_id;

ALTER TABLE student 
MODIFY COLUMN user_id VARCHAR(20) UNIQUE NOT NULL;

SET @counter = 1;
UPDATE teacher 
SET user_id = CONCAT('TEA', LPAD(@counter := @counter + 1, 6, '0'))
WHERE user_id IS NULL
ORDER BY teacher_id;

ALTER TABLE teacher 
MODIFY COLUMN user_id VARCHAR(20) UNIQUE NOT NULL;

SELECT 'Student IDs Generated:' as Migration_Status, COUNT(*) as Count 
FROM student WHERE user_id LIKE 'STU%'
UNION ALL
SELECT 'Teacher IDs Generated:', COUNT(*) 
FROM teacher WHERE user_id LIKE 'TEA%';

SELECT * FROM student;

SELECT * FROM teacher;

SELECT * FROM attendance;

ALTER TABLE attendance 
DROP COLUMN status;

ALTER TABLE attendance 
ADD COLUMN status ENUM('Present', 'Absent') DEFAULT 'Absent';

