-- =============================================================================
-- Student Information Management System (SIMS) - RESTRUCTURED Database
-- Clean normalized structure with proper foreign key relationships
-- =============================================================================

DROP DATABASE IF EXISTS student_info_system;
CREATE DATABASE student_info_system
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE student_info_system;

-- =============================================================================
-- ADMIN TABLE (Single admin user, NOT part of users table)
-- Default login: admin / admin123
-- =============================================================================
CREATE TABLE admin (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- STUDENT TABLE (Stores student-specific data)
-- =============================================================================
CREATE TABLE student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(20) UNIQUE NOT NULL,
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
    status ENUM('pending','active','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================================================
-- TEACHER TABLE (Stores teacher-specific data)
-- =============================================================================
CREATE TABLE teacher (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(20) UNIQUE NOT NULL,
    employee_id VARCHAR(20) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(255),
    department VARCHAR(100),
    qualification VARCHAR(100),
    experience INT DEFAULT 0,
    status ENUM('pending','active','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =============================================================================
-- COURSES TABLE (Degree programs)
-- =============================================================================
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    duration_years INT DEFAULT 3,
    total_semesters INT DEFAULT 6,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- SUBJECTS TABLE (With teacher_id foreign key - teacher assigned to teach subject)
-- =============================================================================
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) UNIQUE NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    course_id INT NOT NULL,
    semester INT NOT NULL,
    credits INT DEFAULT 4,
    max_capacity INT DEFAULT 60,
    teacher_id INT,  -- Foreign key to teacher teaching this subject
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id) ON DELETE SET NULL
);

-- =============================================================================
-- SUBJECT_ENROLLMENT TABLE (Student enrolls in subjects)
-- =============================================================================
CREATE TABLE subject_enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active','completed','dropped') DEFAULT 'active',

    UNIQUE KEY uk_student_subject (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);

-- =============================================================================
-- ATTENDANCE TABLE
-- =============================================================================
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

-- =============================================================================
-- MARKS TABLE
-- =============================================================================
CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,

    -- Internal assessment marks
    internal1_marks INT DEFAULT 0,    -- First Internal (out of 20)
    internal2_marks INT DEFAULT 0,    -- Second Internal (out of 20)
    
    -- External exam marks
    external_marks INT DEFAULT 0,     -- End Semester (out of 60)
    
    total_marks INT DEFAULT 0,         -- Auto-calculated (out of 100)
    grade VARCHAR(2),

    evaluated_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_student_subject_marks (student_id, subject_id),

    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teacher(teacher_id) ON DELETE CASCADE
);

-- =============================================================================
-- ANNOUNCEMENTS TABLE
-- =============================================================================
CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    posted_by INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    visibility_level ENUM('all','students','teachers','admin') DEFAULT 'all',
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (posted_by) REFERENCES teacher(teacher_id) ON DELETE CASCADE
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================
-- Login performance
CREATE INDEX idx_student_login ON student(email, password_hash);
CREATE INDEX idx_teacher_login ON teacher(email, password_hash);

-- Attendance lookups
CREATE INDEX idx_attendance_lookup ON attendance(student_id, subject_id);
CREATE INDEX idx_attendance_date ON attendance(class_date);

-- Marks lookups
CREATE INDEX idx_marks_lookup ON marks(student_id, subject_id);

-- Subject lookups
CREATE INDEX idx_subject_lookup ON subjects(course_id, semester);
CREATE INDEX idx_subject_teacher ON subjects(teacher_id);

-- Enrollment lookups
CREATE INDEX idx_student_enrollment ON subject_enrollment(student_id, status);
CREATE INDEX idx_subject_enrollment ON subject_enrollment(subject_id, status);

-- =============================================================================
-- DEFAULT ADMIN USER
-- Password: admin123 (SHA-256 hashed)
-- =============================================================================
INSERT INTO admin (username, password_hash, full_name, email) VALUES 
('admin', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'System Administrator', 'admin@sims.edu');

-- =============================================================================
-- SAMPLE COURSES (Required for student registration)
-- =============================================================================
INSERT INTO courses (course_code, course_name, duration_years, total_semesters) VALUES
('BTech-CS', 'Bachelor of Technology in Computer Science', 4, 8),
('BTech-IT', 'Bachelor of Technology in Information Technology', 4, 8),
('BSc-CS', 'Bachelor of Science in Computer Science', 3, 6),
('BCA', 'Bachelor of Computer Applications', 3, 6),
('MCA', 'Master of Computer Applications', 2, 4);

-- =============================================================================
-- BACKWARD COMPATIBILITY: USERS VIEW (Optional - for legacy code)
-- This view combines student, teacher, and admin for backward compatibility
-- =============================================================================
-- Note: JSP files should be updated to use separate tables
-- This view is provided for reference only
-- CREATE OR REPLACE VIEW users AS
-- SELECT student_id as user_id, email, password_hash, 'student' as user_type, 
--        full_name, phone, address, status, roll_number, course_id, semester,
--        parent_name, parent_contact, NULL as employee_id, NULL as department,
--        NULL as qualification, NULL as experience, created_at
-- FROM student
-- UNION ALL
-- SELECT teacher_id as user_id, email, password_hash, 'teacher' as user_type,
--        full_name, phone, address, status, NULL as roll_number, NULL as course_id, NULL as semester,
--        NULL as parent_name, NULL as parent_contact, employee_id, department,
--        qualification, experience, created_at
-- FROM teacher;
ALTER TABLE student 
ADD COLUMN user_id VARCHAR(20) UNIQUE NULL AFTER student_id;

-- =============================================================================
-- Step 2: Generate user_id for existing students
-- =============================================================================
-- This stored procedure will generate unique student IDs in format STU000001
SET @counter = 1;
UPDATE student 
SET user_id = CONCAT('STU', LPAD(@counter := @counter + 1, 6, '0'))
WHERE user_id IS NULL
ORDER BY student_id;

-- =============================================================================
-- Step 3: Make user_id NOT NULL for students
-- =============================================================================
ALTER TABLE student 
MODIFY COLUMN user_id VARCHAR(20) UNIQUE NOT NULL;

-- =============================================================================
-- Step 4: Add user_id column to teacher table (if not exists)
-- =============================================================================
ALTER TABLE teacher 
ADD COLUMN user_id VARCHAR(20) UNIQUE NULL AFTER teacher_id;

-- =============================================================================
-- Step 5: Generate user_id for existing teachers
-- =============================================================================
-- This will generate unique teacher IDs in format TEA000001
SET @counter = 1;
UPDATE teacher 
SET user_id = CONCAT('TEA', LPAD(@counter := @counter + 1, 6, '0'))
WHERE user_id IS NULL
ORDER BY teacher_id;

-- =============================================================================
-- Step 6: Make user_id NOT NULL for teachers
-- =============================================================================
ALTER TABLE teacher 
MODIFY COLUMN user_id VARCHAR(20) UNIQUE NOT NULL;

-- =============================================================================
-- Step 7: Verify the migration
-- =============================================================================
SELECT 'Student IDs Generated:' as Migration_Status, COUNT(*) as Count 
FROM student WHERE user_id LIKE 'STU%'
UNION ALL
SELECT 'Teacher IDs Generated:', COUNT(*) 
FROM teacher WHERE user_id LIKE 'TEA%';

-- =============================================================================
-- Additional useful queries (run these to view your data)
-- =============================================================================

-- View all students with their new user IDs:
-- SELECT student_id, user_id, full_name, email, status FROM student;

-- View all teachers with their new user IDs:
-- SELECT teacher_id, user_id, full_name, email, status FROM teacher;

-- =============================================================================
-- Done! Your database has been successfully migrated.
-- Users can now see their User IDs in their profile pages and dashboards.
-- =============================================================================
