DROP DATABASE IF EXISTS student_info_system;

CREATE DATABASE student_info_system
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE student_info_system;

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    duration_years INT DEFAULT 3,
    total_semesters INT DEFAULT 6,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) UNIQUE NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    course_id INT NOT NULL,
    semester INT NOT NULL,
    credits INT DEFAULT 4,
    max_capacity INT DEFAULT 60,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type ENUM('admin','teacher','student') NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    status ENUM('pending','approved','rejected') DEFAULT 'pending',

    -- Student Fields
    roll_number VARCHAR(20),
    course_id INT,
    semester INT DEFAULT 1,

    -- Teacher Fields
    employee_id VARCHAR(20),
    department VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE SET NULL
);

CREATE TABLE subject_teacher (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_subject_teacher (subject_id, teacher_id),

    FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    FOREIGN KEY (teacher_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE student_subject_enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active','completed','dropped') DEFAULT 'active',

    UNIQUE KEY uk_student_subject (student_id, subject_id),

    FOREIGN KEY (student_id)
        REFERENCES users(user_id)
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

    FOREIGN KEY (student_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    FOREIGN KEY (teacher_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,

    theory_marks INT DEFAULT 0,
    practical_marks INT DEFAULT 0,
    assignment_marks INT DEFAULT 0,
    total_marks INT DEFAULT 0,
    grade VARCHAR(2),

    evaluated_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_student_subject_marks (student_id, subject_id),

    FOREIGN KEY (student_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id)
        ON DELETE CASCADE,

    FOREIGN KEY (teacher_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    posted_by INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    visibility_level ENUM('all','students','teachers','admin') DEFAULT 'all',
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (posted_by)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_users_login ON users(email, password_hash);

CREATE INDEX idx_attendance_lookup ON attendance(student_id, subject_id);

CREATE INDEX idx_marks_lookup ON marks(student_id, subject_id);

CREATE INDEX idx_subject_lookup ON subjects(course_id, semester);

INSERT INTO users (
    email,
    password_hash,
    user_type,
    full_name,
    phone,
    status
) VALUES (
    'admin@sims.edu',
    'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=',
    'admin',
    'System Administrator',
    '9876543210',
    'approved'
);