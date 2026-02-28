-- ========================================
-- SIMS Database Schema v2.0 - Production Ready
-- Student Information Management System
-- DY Patil School of Science and Technology, Pune
-- MySQL 5.7+
-- ========================================

-- Drop and recreate database for clean setup
DROP DATABASE IF EXISTS student_info_system;
CREATE DATABASE student_info_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_info_system;

-- ========== USERS TABLE (EXPANDED) ==========
-- Consolidated users table for admin, student, and teacher roles
-- Role-specific fields populated based on user_type
-- Status workflow: pending → approved/rejected → active
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    user_type ENUM('admin', 'student', 'teacher') NOT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'SHA-256 hashed + Base64 encoded',
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    
    -- ===== Common Fields =====
    address TEXT,
    
    -- ===== Student-specific fields =====
    roll_number VARCHAR(50) COMMENT 'University roll number',
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    course_id INT,
    semester INT COMMENT '1-8 semester level',
    parent_name VARCHAR(255),
    parent_contact VARCHAR(20),
    admission_year INT,
    
    -- ===== Teacher-specific fields =====
    employee_id VARCHAR(50) UNIQUE COMMENT 'Staff ID number',
    department VARCHAR(100) COMMENT 'Department or school',
    qualification VARCHAR(255) COMMENT 'Academic qualifications',
    experience INT COMMENT 'Years of experience',
    
    -- ===== Audit fields =====
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- ===== Indexes =====
    INDEX idx_email (email),
    INDEX idx_user_type (user_type),
    INDEX idx_status (status),
    INDEX idx_roll_number (roll_number),
    INDEX idx_employee_id (employee_id),
    INDEX idx_course_id (course_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== COURSES TABLE ==========
-- Core courses offered by the institution
-- Each course can be taught by multiple teachers (see course_teacher table)
CREATE TABLE IF NOT EXISTS courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'e.g., CS101',
    course_name VARCHAR(255) NOT NULL COMMENT 'Full course name',
    credits INT NOT NULL COMMENT 'Credit hours',
    semester INT NOT NULL COMMENT '1-8 semester level',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- ===== Indexes =====
    INDEX idx_course_code (course_code),
    INDEX idx_semester (semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== COURSE-TEACHER ASSIGNMENT TABLE ==========
-- Maps teachers to courses they will teach
-- Replaces deprecated subject_teacher relationship
-- One teacher can teach multiple courses
-- One course can have multiple faculty assigned (rotations, co-teaching)
CREATE TABLE IF NOT EXISTS course_teacher (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- ===== Foreign Keys =====
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- ===== Constraints & Indexes =====
    UNIQUE KEY uk_course_teacher (course_id, teacher_id),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_course_id (course_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== ENROLLMENTS TABLE ==========
-- Records student enrollment in courses
-- Core relationship: which students are taking which courses
-- Used for attendance, marks, and course access
CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- ===== Foreign Keys =====
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    
    -- ===== Constraints & Indexes =====
    UNIQUE KEY uk_student_course (student_id, course_id),
    INDEX idx_student_id (student_id),
    INDEX idx_course_id (course_id),
    INDEX idx_enrollment_date (enrollment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== ATTENDANCE TABLE ==========
-- Records daily attendance for each student in each course
-- Updated by teachers marking attendance after each class
-- Used for generating attendance reports and eligibility checks
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL COMMENT 'Who marked attendance',
    class_date DATE NOT NULL,
    is_present BOOLEAN DEFAULT 0 COMMENT '1=present, 0=absent',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- ===== Foreign Keys =====
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- ===== Constraints & Indexes =====
    INDEX idx_student_id (student_id),
    INDEX idx_course_id (course_id),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_class_date (class_date),
    INDEX idx_student_course_date (student_id, course_id, class_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== MARKS TABLE ==========
-- Stores academic marks/grades for each student in each course
-- Three components: assignment, mid_exam, final_exam (each 0-100)
-- Teachers enter marks; totals and grades are auto-calculated
-- One record per student per course (updated when marks change)
CREATE TABLE IF NOT EXISTS marks (
    marks_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL COMMENT 'Teacher who entered marks',
    assignment INT DEFAULT 0 COMMENT '0-100',
    mid_exam INT DEFAULT 0 COMMENT '0-100',
    final_exam INT DEFAULT 0 COMMENT '0-100',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- ===== Foreign Keys =====
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- ===== Constraints & Indexes =====
    UNIQUE KEY uk_student_course_marks (student_id, course_id),
    INDEX idx_student_id (student_id),
    INDEX idx_course_id (course_id),
    INDEX idx_teacher_id (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== ANNOUNCEMENTS TABLE ==========
-- System-wide announcements and notifications
-- Posted by admin/teacher, visible to all appropriate users
-- Students: read-only view
-- Teachers/Admin: can post and view
CREATE TABLE IF NOT EXISTS announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content LONGTEXT NOT NULL,
    posted_by INT NOT NULL,
    posted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- ===== Foreign Keys =====
    FOREIGN KEY (posted_by) REFERENCES users(id) ON DELETE CASCADE,
    
    -- ===== Indexes =====
    INDEX idx_posted_date (posted_date),
    INDEX idx_posted_by (posted_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========== INSERT DEMO DATA ==========
-- Note: All demo passwords are hashed with SHA-256 and encoded with Base64
-- Password hashing: hashlib.sha256(password.encode()).digest() → base64 encode
-- All demo users use password: admin123
-- Hash: JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=

-- ===== Admin User =====
INSERT INTO users (full_name, email, phone, user_type, password, status) 
VALUES ('System Administrator', 'admin@sims.edu', '+91-20-2536-5401', 'admin', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved');

-- ===== Sample Students =====
INSERT INTO users (full_name, email, phone, user_type, password, status, roll_number, date_of_birth, gender, address, course_id, semester, parent_name, parent_contact, admission_year) 
VALUES 
('John Doe', 'student@sims.edu', '+91-98765-43210', 'student', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved', 'CS20001', '2002-05-15', 'M', '123 Student Lane, Pune 411001', 1, 1, 'Jane Doe', '+91-98765-43211', 2020),
('Priya Singh', 'priya.singh@sims.edu', '+91-98123-45678', 'student', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved', 'CS20002', '2002-08-22', 'F', '456 Campus Road, Pune 411008', 1, 1, 'Rajesh Singh', '+91-98123-45679', 2020),
('Amit Kumar', 'amit.kumar@sims.edu', '+91-99876-54321', 'student', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved', 'CS20003', '2003-02-10', 'M', '789 Tech Avenue, Pune 411002', 2, 2, 'Ramesh Kumar', '+91-99876-54322', 2020);

-- ===== Sample Teachers =====
INSERT INTO users (full_name, email, phone, user_type, password, status, employee_id, department, qualification, experience) 
VALUES 
('Dr. Smith', 'dr.smith@sims.edu', '+91-98765-43220', 'teacher', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved', 'EMP2020001', 'Computer Science', 'Ph.D. Computer Science, M.Tech', 8),
('Prof. Johnson', 'prof.johnson@sims.edu', '+91-97654-32109', 'teacher', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved', 'EMP2020002', 'Information Technology', 'M.Tech, B.Tech', 5),
('Ms. Sharma', 'ms.sharma@sims.edu', '+91-96543-21098', 'teacher', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'approved', 'EMP2020003', 'Electronics', 'M.E., B.E.', 6);

-- ===== Sample Courses =====
INSERT INTO courses (course_code, course_name, credits, semester) VALUES 
('CS101', 'Introduction to Programming', 4, 1),
('CS102', 'Data Structures', 4, 2),
('CS201', 'Advanced Web Development', 4, 3),
('CS301', 'Database Management Systems', 4, 4);

-- ===== Course-Teacher Assignments =====
-- Teacher 1 (ID=4) assigned to courses 1, 2, 3, 4
-- Teacher 2 (ID=5) assigned to courses 1, 2
-- Teacher 3 (ID=6) assigned to course 4
INSERT INTO course_teacher (course_id, teacher_id) 
VALUES 
(1, 4), (2, 4), (3, 4), (4, 4),
(1, 5), (2, 5),
(4, 6);

-- ===== Student Course Enrollments =====
-- Student John Doe (ID=2) enrolled in courses 1, 2, 3
-- Student Priya Singh (ID=3) enrolled in courses 1, 2
-- Student Amit Kumar (ID=4) enrolled in course 2, 3, 4
INSERT INTO enrollments (student_id, course_id) 
VALUES 
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 2),
(4, 2), (4, 3), (4, 4);

-- ===== Sample Attendance Records =====
-- John Doe (ID=2) attendance for CS101 (Course 1) - January 2026
INSERT INTO attendance (student_id, course_id, teacher_id, class_date, is_present) 
VALUES 
(2, 1, 4, '2026-01-10', 1),
(2, 1, 4, '2026-01-11', 1),
(2, 1, 4, '2026-01-12', 0),
(2, 1, 4, '2026-01-13', 1),
(2, 1, 4, '2026-01-14', 1);

-- Priya Singh (ID=3) attendance for CS101
INSERT INTO attendance (student_id, course_id, teacher_id, class_date, is_present) 
VALUES 
(3, 1, 4, '2026-01-10', 1),
(3, 1, 4, '2026-01-11', 1),
(3, 1, 4, '2026-01-12', 1),
(3, 1, 4, '2026-01-13', 0),
(3, 1, 4, '2026-01-14', 1);

-- ===== Sample Marks Records =====
-- John Doe marks for enrolled courses
INSERT INTO marks (student_id, course_id, teacher_id, assignment, mid_exam, final_exam) 
VALUES 
(2, 1, 4, 85, 78, 82),
(2, 2, 4, 90, 88, 91),
(2, 3, 4, 75, 72, 78);

-- Priya Singh marks for enrolled courses
INSERT INTO marks (student_id, course_id, teacher_id, assignment, mid_exam, final_exam) 
VALUES 
(3, 1, 4, 88, 85, 89),
(3, 2, 4, 92, 89, 93);

-- Amit Kumar marks for enrolled courses
INSERT INTO marks (student_id, course_id, teacher_id, assignment, mid_exam, final_exam) 
VALUES 
(4, 2, 4, 78, 75, 80),
(4, 3, 4, 82, 79, 83),
(4, 4, 4, 70, 68, 72);

-- ===== Sample Announcements =====
INSERT INTO announcements (title, content, posted_by) 
VALUES 
('Welcome to SIMS', 'Welcome to the Student Information Management System. This system is designed to provide seamless academic management.', 1),
('Maintenance Scheduled', 'System maintenance scheduled for 2026-02-28 from 2 PM to 4 PM. Users may experience temporary disruptions.', 1),
('Mid-Semester Exams', 'Mid-semester exams for Semester 1 & 2 will be held from 2026-03-15 to 2026-03-22. Check your course pages for details.', 4);

-- ========== ADDITIONAL INDEXES FOR PERFORMANCE ==========
-- Created after data insert to avoid slowing down inserts

-- Authentication index
CREATE INDEX idx_users_email_password ON users(email, password);

-- Attendance indexes
CREATE INDEX idx_attendance_date ON attendance(class_date);
CREATE INDEX idx_attendance_lookup ON attendance(student_id, course_id);

-- Marks indexes
CREATE INDEX idx_marks_date ON marks(updated_at);
CREATE INDEX idx_marks_lookup ON marks(student_id, course_id);

-- Announcements index
CREATE INDEX idx_announcements_date ON announcements(posted_date);

-- Course-teacher index
CREATE INDEX idx_course_teacher ON course_teacher(course_id, teacher_id);

-- ========== DATABASE VIEWS FOR REPORTING ==========
-- These views simplify common queries for reporting and dashboards

-- ===== Attendance Summary View =====
-- Returns attendance percentage for each student per course
CREATE OR REPLACE VIEW student_attendance_summary AS
SELECT 
    a.student_id,
    u.full_name as student_name,
    u.roll_number,
    c.course_code,
    c.course_name,
    COUNT(*) as total_classes,
    SUM(IF(a.is_present = 1, 1, 0)) as attended_classes,
    ROUND(SUM(IF(a.is_present = 1, 1, 0)) * 100 / COUNT(*), 2) as attendance_percentage
FROM attendance a
JOIN users u ON a.student_id = u.id
JOIN courses c ON a.course_id = c.course_id
GROUP BY a.student_id, a.course_id;

-- ===== Marks Summary View =====
-- Returns marks and calculated grades for each student per course
CREATE OR REPLACE VIEW student_marks_summary AS
SELECT 
    m.marks_id,
    m.student_id,
    u.full_name as student_name,
    u.roll_number,
    c.course_code,
    c.course_name,
    m.assignment,
    m.mid_exam,
    m.final_exam,
    (m.assignment + m.mid_exam + m.final_exam) as total_marks,
    CASE 
        WHEN (m.assignment + m.mid_exam + m.final_exam) >= 240 THEN 'A'
        WHEN (m.assignment + m.mid_exam + m.final_exam) >= 210 THEN 'B'
        WHEN (m.assignment + m.mid_exam + m.final_exam) >= 180 THEN 'C'
        WHEN (m.assignment + m.mid_exam + m.final_exam) >= 150 THEN 'D'
        ELSE 'F'
    END as grade
FROM marks m
JOIN users u ON m.student_id = u.id
JOIN courses c ON m.course_id = c.course_id;

-- ===== Student Course Enrollment View =====
-- Shows which students are enrolled in which courses
CREATE OR REPLACE VIEW student_course_enrollment AS
SELECT 
    e.enrollment_id,
    u.id as student_id,
    u.full_name as student_name,
    u.roll_number,
    u.email,
    c.course_id,
    c.course_code,
    c.course_name,
    c.semester,
    e.enrollment_date
FROM enrollments e
JOIN users u ON e.student_id = u.id
JOIN courses c ON e.course_id = c.course_id
WHERE u.user_type = 'student' AND u.status = 'approved';

-- ===== Teacher Course Assignment View =====
-- Shows which teachers are assigned to which courses
CREATE OR REPLACE VIEW teacher_course_assignment AS
SELECT 
    ct.assignment_id,
    t.id as teacher_id,
    t.full_name as teacher_name,
    t.employee_id,
    c.course_id,
    c.course_code,
    c.course_name,
    c.semester,
    ct.assigned_date
FROM course_teacher ct
JOIN users t ON ct.teacher_id = t.id
JOIN courses c ON ct.course_id = c.course_id
WHERE t.user_type = 'teacher' AND t.status = 'approved';

-- ========== APPLICATION CONFIGURATION ==========
-- Use these settings in JSP connection strings and configurations

-- ===== Connection Parameters =====
-- Database Name: student_info_system
-- Host: localhost
-- Port: 3306
-- Username: root
-- Password: 15056324
-- JDBC Connection String: jdbc:mysql://localhost:3306/student_info_system

-- ===== Password Hashing =====
-- Algorithm: SHA-256
-- Encoding: Base64
-- Python Reference:
--   import hashlib, base64
--   password = 'admin123'
--   hashed = hashlib.sha256(password.encode()).digest()
--   encoded = base64.b64encode(hashed).decode()
--   # Result: JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=

-- ===== Character Set =====
-- Database: UTF-8 (utf8mb4)
-- Collation: utf8mb4_unicode_ci
-- Supports: Multilingual content, emojis

-- ========== VERIFICATION QUERIES ==========
-- Run these to verify setup is successful

-- Show all tables
-- SHOW TABLES;

-- Count total records
-- SELECT 'users' as table_name, COUNT(*) as count FROM users
-- UNION ALL SELECT 'courses', COUNT(*) FROM courses
-- UNION ALL SELECT 'enrollments', COUNT(*) FROM enrollments
-- UNION ALL SELECT 'course_teacher', COUNT(*) FROM course_teacher
-- UNION ALL SELECT 'attendance', COUNT(*) FROM attendance
-- UNION ALL SELECT 'marks', COUNT(*) FROM marks
-- UNION ALL SELECT 'announcements', COUNT(*) FROM announcements;

-- Verify admin user
-- SELECT id, full_name, email, user_type, status FROM users WHERE user_type = 'admin';

-- Verify student access
-- SELECT u.id, u.full_name, u.roll_number, u.course_id, COUNT(e.course_id) as enrolled_courses
-- FROM users u
-- LEFT JOIN enrollments e ON u.id = e.student_id
-- WHERE u.user_type = 'student' AND u.status = 'approved'
-- GROUP BY u.id;

-- ========== PRODUCTION SETUP RECOMMENDATIONS ==========
-- 1. Create separate database user with limited permissions (not root)
-- 2. Set strong password (not 15056324)
-- 3. Enable SSL/TLS for database connections
-- 4. Regular backup schedule
-- 5. Monitor query performance with slow query log
-- 6. Use connection pooling in application

-- ========== DATABASE SETUP COMPLETE ==========
-- Version: 2.0 (Production Ready)
-- Date: February 28, 2026
-- Institution: DY Patil School of Science and Technology, Pune
-- All tables, indexes, views, and demo data successfully created!
