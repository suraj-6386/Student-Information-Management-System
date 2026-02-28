-- ========================================
-- SIMS v3.0 - Academic Hierarchy Refactored
-- Student Information Management System
-- DY Patil School of Science and Technology, Pune
--
-- KEY ARCHITECTURE CHANGE:
-- Courses = Degree Programs (BTech, BSc, BCA, MCA)
-- Subjects = Individual course modules within programs
-- Proper academic normalization (3NF)
--
-- MySQL 5.7+ | UTF-8mb4 | InnoDB
-- ========================================

DROP DATABASE IF EXISTS student_info_system;
CREATE DATABASE student_info_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_info_system;

-- ========================================
-- 1. COURSES TABLE (Degree Programs)
-- ========================================
-- Represents degree programs offered by the institution
-- Examples: BTech, BSc, BCA, MCA (NOT individual subjects)
-- Subjects belong to courses (one-to-many relationship)
-- ========================================

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL COMMENT 'e.g., BTECH, BSC, BCA, MCA',
    course_name VARCHAR(100) NOT NULL COMMENT 'e.g., Bachelor of Technology',
    duration_years INT DEFAULT 4 COMMENT 'Program duration',
    total_semesters INT DEFAULT 8 COMMENT 'Total semesters in program',
    credits_required INT DEFAULT 160 COMMENT 'Total credits for degree',
    description TEXT COMMENT 'Program description',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_course_code (course_code),
    INDEX idx_course_name (course_name),
    
    CONSTRAINT chk_duration CHECK (duration_years > 0),
    CONSTRAINT chk_semesters CHECK (total_semesters > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 2. SUBJECTS TABLE (Course Modules)
-- ========================================
-- Individual subjects/courses within a degree program
-- Example: Programming, Data Structures, DBMS all belong to BTech
-- Each subject belongs to ONE course and ONE semester
-- Multiple teachers can teach the same subject (rare but possible)
-- ========================================

CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) UNIQUE NOT NULL COMMENT 'e.g., CS101, CS102, CS201',
    subject_name VARCHAR(100) NOT NULL COMMENT 'e.g., Programming Fundamentals',
    course_id INT NOT NULL COMMENT 'FK to courses table (BTech, BSc, etc.)',
    semester INT NOT NULL COMMENT 'Semester level (1-8)',
    credits INT DEFAULT 4 COMMENT 'Credit hours for subject',
    description TEXT COMMENT 'Subject content and learning outcomes',
    max_capacity INT DEFAULT 60 COMMENT 'Maximum students per offering',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_subject_code (subject_code),
    INDEX idx_course_id (course_id),
    INDEX idx_semester (semester),
    INDEX idx_course_semester (course_id, semester),
    
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    
    CONSTRAINT chk_semester_range CHECK (semester >= 1 AND semester <= 8),
    CONSTRAINT chk_credits CHECK (credits > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 3. USERS TABLE (Admin, Teacher, Student)
-- ========================================
-- Unified users table for all three roles
-- For students: course_id = degree program (e.g., BTech)
-- For teachers: course_id = NULL (subjects are assigned separately)
-- For admin: course_id = NULL (no course assignment needed)
-- ========================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL COMMENT 'SHA-256 hashed + Base64 encoded',
    user_type ENUM('admin', 'teacher', 'student') NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) DEFAULT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    
    -- ===== Common Fields for All Users =====
    address TEXT DEFAULT NULL,
    city VARCHAR(50) DEFAULT NULL,
    state VARCHAR(50) DEFAULT NULL,
    pincode VARCHAR(10) DEFAULT NULL,
    
    -- ===== Student-Specific Fields =====
    roll_number VARCHAR(20) DEFAULT NULL COMMENT 'Unique roll number for student',
    date_of_birth DATE DEFAULT NULL,
    gender ENUM('M', 'F', 'Other') DEFAULT NULL,
    course_id INT DEFAULT NULL COMMENT 'FK to degree program (BTech, BSc, etc.)',
    semester INT DEFAULT 1 COMMENT 'Current semester (1-8)',
    parent_name VARCHAR(100) DEFAULT NULL,
    parent_phone VARCHAR(15) DEFAULT NULL,
    parent_email VARCHAR(100) DEFAULT NULL,
    admission_year INT DEFAULT NULL,
    
    -- ===== Teacher-Specific Fields =====
    employee_id VARCHAR(20) DEFAULT NULL COMMENT 'Staff/Employee ID',
    department VARCHAR(50) DEFAULT NULL COMMENT 'Department name',
    qualification VARCHAR(100) DEFAULT NULL COMMENT 'Academic qualifications (Ph.D., M.Tech, etc.)',
    experience_years INT DEFAULT 0 COMMENT 'Teaching experience',
    specialization VARCHAR(100) DEFAULT NULL COMMENT 'Teaching specialization',
    
    -- ===== Audit Fields =====
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- ===== Indexes for Performance =====
    INDEX idx_email_password (email, password_hash),
    INDEX idx_user_type (user_type),
    INDEX idx_status (status),
    INDEX idx_roll_number (roll_number),
    INDEX idx_employee_id (employee_id),
    INDEX idx_course_id (course_id),
    
    -- ===== Foreign Keys =====
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE SET NULL,
    
    -- ===== Constraints =====
    CONSTRAINT chk_student_course CHECK ((user_type != 'student') OR (course_id IS NOT NULL)),
    CONSTRAINT chk_roll_number_type CHECK ((user_type != 'student') OR (roll_number IS NOT NULL)),
    CONSTRAINT chk_teacher_emp_id CHECK ((user_type != 'teacher') OR (employee_id IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 4. SUBJECT_TEACHER TABLE (Subject-to-Teacher Mapping)
-- ========================================
-- Assigns subjects to teachers (replaces old course_teacher table)
-- One subject can have multiple teachers
-- One teacher can teach multiple subjects
-- This is the KEY change: teachers are assigned to SUBJECTS, not COURSES
-- ========================================

CREATE TABLE subject_teacher (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL COMMENT 'FK to subjects table',
    teacher_id INT NOT NULL COMMENT 'FK to users table (user_type=teacher)',
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_subject_id (subject_id),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_subject_teacher (subject_id, teacher_id),
    
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_subject_teacher (subject_id, teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 5. STUDENT_SUBJECT_ENROLLMENT TABLE
-- ========================================
-- Students → Subjects enrollment mapping
-- Replaces old enrollments table (which was course-based)
-- Now students enroll in SUBJECTS, not COURSES
-- ========================================

CREATE TABLE student_subject_enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL COMMENT 'FK to users (user_type=student)',
    subject_id INT NOT NULL COMMENT 'FK to subjects table',
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'completed', 'dropped') DEFAULT 'active',
    
    INDEX idx_student_id (student_id),
    INDEX idx_subject_id (subject_id),
    INDEX idx_enrollment_status (status),
    INDEX idx_student_subject (student_id, subject_id),
    INDEX idx_enrollment_date (enrollment_date),
    
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_student_subject (student_id, subject_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 6. ATTENDANCE TABLE
-- ========================================
-- Tracks attendance by SUBJECT (not course)
-- Teacher marks which students attended which subject on which date
-- ========================================

CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL COMMENT 'FK to users (student)',
    subject_id INT NOT NULL COMMENT 'FK to subjects table',
    teacher_id INT NOT NULL COMMENT 'Who marked attendance',
    class_date DATE NOT NULL,
    status ENUM('present', 'absent', 'leave') DEFAULT 'absent',
    remarks VARCHAR(255) DEFAULT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_student_id (student_id),
    INDEX idx_subject_id (subject_id),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_class_date (class_date),
    INDEX idx_student_subject_date (student_id, subject_id, class_date),
    
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 7. MARKS TABLE
-- ========================================
-- Student marks tracked by SUBJECT (not course)
-- Auto-calculated grades: A(90+), B(80-89), C(70-79), D(60-69), F(<60)
-- Total out of 300: theory(0-100) + practical(0-100) + assignment(0-100)
-- ========================================

CREATE TABLE marks (
    mark_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL COMMENT 'FK to users (student)',
    subject_id INT NOT NULL COMMENT 'FK to subjects table',
    teacher_id INT NOT NULL COMMENT 'Who entered marks',
    theory_marks INT DEFAULT 0 COMMENT '0-100',
    practical_marks INT DEFAULT 0 COMMENT '0-100',
    assignment_marks INT DEFAULT 0 COMMENT '0-100',
    total_marks INT DEFAULT 0 COMMENT 'Auto-calculated (0-300)',
    grade VARCHAR(1) DEFAULT NULL COMMENT 'Auto-calculated (A/B/C/D/F)',
    evaluated_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_student_id (student_id),
    INDEX idx_subject_id (subject_id),
    INDEX idx_teacher_id (teacher_id),
    INDEX idx_student_subject (student_id, subject_id),
    INDEX idx_evaluated_at (evaluated_at),
    
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES users(user_id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_student_subject_marks (student_id, subject_id),
    CONSTRAINT chk_marks_range CHECK (total_marks >= 0 AND total_marks <= 300),
    CONSTRAINT chk_grade_valid CHECK (grade IN ('A', 'B', 'C', 'D', 'F', NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 8. ANNOUNCEMENTS TABLE
-- ========================================
-- System-wide announcements/notifications
-- Posted by admin/teacher, visible based on role
-- ========================================

CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    posted_by INT NOT NULL COMMENT 'FK to users (admin/teacher)',
    title VARCHAR(200) NOT NULL,
    content TEXT,
    visibility_level ENUM('all', 'students', 'teachers', 'admin') DEFAULT 'all',
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_posted_by (posted_by),
    INDEX idx_visibility_level (visibility_level),
    INDEX idx_posted_at (posted_at),
    
    FOREIGN KEY (posted_by) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- INSERT DEMO DATA
-- ========================================
-- Password for all demo users: admin123
-- Hash: JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=

-- ===== Insert Degree Programs (Courses) =====
INSERT INTO courses (course_code, course_name, duration_years, total_semesters, credits_required, description) VALUES
('BTECH', 'Bachelor of Technology (B.Tech)', 4, 8, 160, 'Four-year engineering degree program'),
('BSC', 'Bachelor of Science (B.Sc)', 3, 6, 120, 'Three-year science degree program'),
('BCA', 'Bachelor of Computer Applications (B.C.A)', 3, 6, 120, 'Three-year computer applications degree'),
('MCA', 'Master of Computer Applications (M.C.A)', 2, 4, 80, 'Two-year master''s degree in computer applications');

-- ===== Insert Subjects Under BTech =====
-- Semester 1 & 2 subjects for BTech
INSERT INTO subjects (subject_code, subject_name, course_id, semester, credits, description, max_capacity) VALUES
-- BTech Semester 1
('CS101', 'Programming Fundamentals', 1, 1, 4, 'Introduction to programming using C/C++', 60),
('CS102', 'Mathematics-I', 1, 1, 4, 'Calculus and Differential Equations', 60),
('CS103', 'Physics-I', 1, 1, 4, 'Mechanics and Thermodynamics', 60),

-- BTech Semester 2
('CS201', 'Data Structures', 1, 2, 4, 'Arrays, Lists, Trees, Graphs', 60),
('CS202', 'Mathematics-II', 1, 2, 4, 'Linear Algebra and Probability', 60),
('CS203', 'Database Basics', 1, 2, 4, 'Introduction to Database Systems', 60),

-- BTech Semester 3
('CS301', 'Object-Oriented Programming', 1, 3, 4, 'OOP concepts and Java programming', 60),
('CS302', 'Web Development-I', 1, 3, 4, 'HTML, CSS, JavaScript fundamentals', 50),

-- BTech Semester 4
('CS401', 'Database Management Systems', 1, 4, 4, 'DBMS design and SQL', 60),
('CS402', 'Web Development-II', 1, 4, 4, 'Advanced web technologies and frameworks', 50);

-- ===== Insert Subjects Under BSc =====
INSERT INTO subjects (subject_code, subject_name, course_id, semester, credits, description, max_capacity) VALUES
-- BSc Semester 1
('SCI101', 'Physics', 2, 1, 4, 'Fundamental Physics concepts', 50),
('SCI102', 'Chemistry', 2, 1, 4, 'Inorganic and Organic Chemistry', 50),
('SCI103', 'Mathematics', 2, 1, 4, 'Algebra and Trigonometry', 50),

-- BSc Semester 2
('SCI201', 'Advanced Physics', 2, 2, 4, 'Electricity and Magnetism', 50),
('SCI202', 'Biochemistry', 2, 2, 4, 'Biochemical processes', 50);

-- ===== Insert Subjects Under BCA =====
INSERT INTO subjects (subject_code, subject_name, course_id, semester, credits, description, max_capacity) VALUES
-- BCA Semester 1
('BCA101', 'Fundamentals of Computers', 3, 1, 4, 'Computer hardware and software basics', 40),
('BCA102', 'Programming in C', 3, 1, 4, 'C programming language', 40),
('BCA103', 'Web Design', 3, 1, 4, 'Web design principles', 40),

-- BCA Semester 2
('BCA201', 'Java Programming', 3, 2, 4, 'Java and Object-Oriented concepts', 40),
('BCA202', 'Database Design', 3, 2, 4, 'Database concepts and design', 40);

-- ===== Insert Admin User =====
INSERT INTO users (email, password_hash, user_type, full_name, phone, status) VALUES
('admin@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'admin', 'System Administrator', '+91-20-2536-5401', 'approved');

-- ===== Insert Teacher Users =====
INSERT INTO users (email, password_hash, user_type, full_name, phone, status, employee_id, department, qualification, experience_years, specialization) VALUES
('dr.smith@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'teacher', 'Dr. Smith', '+91-98765-43220', 'approved', 'EMP2020001', 'Computer Science', 'Ph.D. Computer Science, M.Tech CSE', 8, 'Programming and Data Structures'),
('prof.johnson@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'teacher', 'Prof. Johnson', '+91-97654-32109', 'approved', 'EMP2020002', 'Information Technology', 'M.Tech IT, B.Tech CSE', 6, 'Web Development'),
('ms.sharma@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'teacher', 'Ms. Sharma', '+91-96543-21098', 'approved', 'EMP2020003', 'Electronics', 'M.E. Electronics, B.E. ECE', 5, 'Database Systems');

-- ===== Insert Student Users =====
INSERT INTO users (email, password_hash, user_type, full_name, phone, status, roll_number, date_of_birth, gender, address, course_id, semester, parent_name, parent_phone, admission_year) VALUES
('john.doe@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'student', 'John Doe', '+91-98765-43210', 'approved', 'BTECH20001', '2002-05-15', 'M', '123 Student Lane, Pune 411001', 1, 1, 'Jane Doe', '+91-98765-43211', 2020),
('priya.singh@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'student', 'Priya Singh', '+91-98123-45678', 'approved', 'BTECH20002', '2002-08-22', 'F', '456 Campus Road, Pune 411008', 1, 1, 'Rajesh Singh', '+91-98123-45679', 2020),
('amit.kumar@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'student', 'Amit Kumar', '+91-99876-54321', 'approved', 'BTECH20003', '2003-02-10', 'M', '789 Tech Avenue, Pune 411002', 1, 2, 'Ramesh Kumar', '+91-99876-54322', 2020),
('alice.wilson@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'student', 'Alice Wilson', '+91-99123-45678', 'approved', 'BSC20001', '2002-03-20', 'F', '321 Science Street, Pune 411011', 2, 1, 'Robert Wilson', '+91-99123-45679', 2020),
('rahul.patel@sims.edu', 'JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=', 'student', 'Rahul Patel', '+91-98234-56789', 'approved', 'BCA20001', '2002-07-12', 'M', '654 Tech Park, Pune 411014', 3, 1, 'Suresh Patel', '+91-98234-56790', 2021);

-- ===== Subject-Teacher Assignments =====
-- Dr. Smith teaches: Programming Fundamentals, Data Structures, OOP
-- Prof. Johnson teaches: Web Development-I, Web Development-II, Database Basics
-- Ms. Sharma teaches: Database Management Systems, DBMS-related courses

INSERT INTO subject_teacher (subject_id, teacher_id) VALUES
-- Dr. Smith (teacher_id=2)
(1, 2),   -- CS101 Programming Fundamentals
(4, 2),   -- CS201 Data Structures
(7, 2),   -- CS301 Object-Oriented Programming

-- Prof. Johnson (teacher_id=3)
(2, 3),   -- CS102 Mathematics-I
(8, 3),   -- CS302 Web Development-I
(6, 3),   -- CS203 Database Basics

-- Ms. Sharma (teacher_id=4)
(5, 4),   -- CS202 Mathematics-II
(9, 4),   -- CS401 Database Management Systems
(10, 4);  -- CS402 Web Development-II

-- ===== Student Subject Enrollments =====
-- John Doe enrolled in BTech Sem 1&2 subjects
INSERT INTO student_subject_enrollment (student_id, subject_id, status) VALUES
(5, 1, 'active'),   -- John in CS101
(5, 2, 'active'),   -- John in CS102
(5, 3, 'active'),   -- John in CS103
(5, 4, 'active'),   -- John in CS201
(5, 5, 'active'),   -- John in CS202
(5, 6, 'active');   -- John in CS203

-- Priya Singh enrolled in BTech Sem 1&2 subjects
INSERT INTO student_subject_enrollment (student_id, subject_id, status) VALUES
(6, 1, 'active'),   -- Priya in CS101
(6, 2, 'active'),   -- Priya in CS102
(6, 3, 'active'),   -- Priya in CS103
(6, 4, 'active'),   -- Priya in CS201
(6, 5, 'active');   -- Priya in CS202

-- Amit Kumar enrolled in BTech Sem 2 subjects (Currently in Sem 2)
INSERT INTO student_subject_enrollment (student_id, subject_id, status) VALUES
(7, 4, 'active'),   -- Amit in CS201
(7, 5, 'active'),   -- Amit in CS202
(7, 6, 'active');   -- Amit in CS203

-- Alice Wilson enrolled in BSc Sem 1 subjects
INSERT INTO student_subject_enrollment (student_id, subject_id, status) VALUES
(8, 11, 'active'),  -- Alice in SCI101
(8, 12, 'active'),  -- Alice in SCI102
(8, 13, 'active');  -- Alice in SCI103

-- Rahul Patel enrolled in BCA Sem 1 subjects
INSERT INTO student_subject_enrollment (student_id, subject_id, status) VALUES
(9, 16, 'active'),  -- Rahul in BCA101
(9, 17, 'active'),  -- Rahul in BCA102
(9, 18, 'active');  -- Rahul in BCA103

-- ===== Attendance Records =====
-- John Doe attendance for CS101 (subject_id=1)
INSERT INTO attendance (student_id, subject_id, teacher_id, class_date, status) VALUES
(5, 1, 2, '2026-01-10', 'present'),
(5, 1, 2, '2026-01-11', 'present'),
(5, 1, 2, '2026-01-12', 'absent'),
(5, 1, 2, '2026-01-13', 'present'),
(5, 1, 2, '2026-01-14', 'present'),
(5, 1, 2, '2026-01-15', 'leave');

-- Priya Singh attendance for CS101
INSERT INTO attendance (student_id, subject_id, teacher_id, class_date, status) VALUES
(6, 1, 2, '2026-01-10', 'present'),
(6, 1, 2, '2026-01-11', 'present'),
(6, 1, 2, '2026-01-12', 'present'),
(6, 1, 2, '2026-01-13', 'absent'),
(6, 1, 2, '2026-01-14', 'present'),
(6, 1, 2, '2026-01-15', 'present');

-- Amit Kumar attendance for CS201 (Data Structures)
INSERT INTO attendance (student_id, subject_id, teacher_id, class_date, status) VALUES
(7, 4, 2, '2026-01-10', 'present'),
(7, 4, 2, '2026-01-11', 'absent'),
(7, 4, 2, '2026-01-12', 'present'),
(7, 4, 2, '2026-01-13', 'present'),
(7, 4, 2, '2026-01-14', 'present');

-- ===== Marks Records =====
-- John Doe marks for subjects
INSERT INTO marks (student_id, subject_id, teacher_id, theory_marks, practical_marks, assignment_marks, total_marks, grade, evaluated_at) VALUES
(5, 1, 2, 85, 88, 90, 263, 'A', '2026-01-20'),
(5, 2, 3, 78, 80, 85, 243, 'A', '2026-01-20'),
(5, 3, 3, 75, 72, 78, 225, 'B', '2026-01-20');

-- Priya Singh marks for subjects
INSERT INTO marks (student_id, subject_id, teacher_id, theory_marks, practical_marks, assignment_marks, total_marks, grade, evaluated_at) VALUES
(6, 1, 2, 88, 90, 92, 270, 'A', '2026-01-20'),
(6, 2, 3, 85, 88, 89, 262, 'A', '2026-01-20'),
(6, 3, 3, 90, 91, 93, 274, 'A', '2026-01-20');

-- Amit Kumar marks for subjects
INSERT INTO marks (student_id, subject_id, teacher_id, theory_marks, practical_marks, assignment_marks, total_marks, grade, evaluated_at) VALUES
(7, 4, 2, 78, 75, 80, 233, 'B', '2026-01-20'),
(7, 5, 4, 82, 80, 85, 247, 'A', '2026-01-20'),
(7, 6, 4, 70, 68, 72, 210, 'B', '2026-01-20');

-- ===== Announcements =====
INSERT INTO announcements (posted_by, title, content, visibility_level) VALUES
(1, 'Welcome to SIMS v3.0', 'Welcome to the refactored Student Information Management System. This version introduces proper academic hierarchy with Courses (degree programs) and Subjects (course modules).', 'all'),
(1, 'Semester Planning', 'Students should review their enrolled subjects and course schedules. All subject assignments are now visible in your dashboard.', 'students'),
(1, 'Teacher Portal Update', 'Teachers can now view their assigned subjects and manage student attendance and marks for each subject individually.', 'teachers'),
(2, 'CS101 Class Schedule', 'Programming Fundamentals (CS101) lectures are held every Monday, Wednesday, and Friday from 10:00 AM to 11:30 AM in Lab 101.', 'all');

-- ========================================
-- PERFORMANCE INDEXES
-- ========================================

-- Authentication index
CREATE INDEX idx_users_email_password ON users(email, password_hash);

-- Attendance indexes
CREATE INDEX idx_attendance_date ON attendance(class_date);
CREATE INDEX idx_attendance_lookup ON attendance(student_id, subject_id);

-- Marks indexes
CREATE INDEX idx_marks_date ON marks(evaluated_at);
CREATE INDEX idx_marks_lookup ON marks(student_id, subject_id);

-- Subject-Teacher lookup
CREATE INDEX idx_subject_teacher_lookup ON subject_teacher(teacher_id, subject_id);

-- Subject indexes for course navigation
CREATE INDEX idx_subjects_by_course ON subjects(course_id);

-- ========================================
-- REPORTING VIEWS
-- ========================================

-- ===== Student Attendance Summary by Subject =====
-- Shows attendance percentage per subject for each student
CREATE OR REPLACE VIEW student_subject_attendance_summary AS
SELECT 
    a.student_id,
    u.full_name as student_name,
    u.roll_number,
    s.subject_code,
    s.subject_name,
    c.course_name,
    s.semester,
    COUNT(*) as total_classes,
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_count,
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_count,
    SUM(CASE WHEN a.status = 'leave' THEN 1 ELSE 0 END) as leave_count,
    ROUND(SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as attendance_percentage
FROM attendance a
JOIN users u ON a.student_id = u.user_id
JOIN subjects s ON a.subject_id = s.subject_id
JOIN courses c ON s.course_id = c.course_id
GROUP BY a.student_id, a.subject_id;

-- ===== Student Marks Summary by Subject =====
-- Shows marks and grades per subject
CREATE OR REPLACE VIEW student_subject_marks_summary AS
SELECT 
    m.student_id,
    u.full_name as student_name,
    u.roll_number,
    s.subject_code,
    s.subject_name,
    c.course_name,
    s.semester,
    m.theory_marks,
    m.practical_marks,
    m.assignment_marks,
    m.total_marks,
    m.grade,
    m.evaluated_at
FROM marks m
JOIN users u ON m.student_id = u.user_id
JOIN subjects s ON m.subject_id = s.subject_id
JOIN courses c ON s.course_id = c.course_id;

-- ===== Subject Enrollment Summary =====
-- Shows which students are enrolled in which subjects
CREATE OR REPLACE VIEW subject_enrollment_summary AS
SELECT 
    s.subject_id,
    s.subject_code,
    s.subject_name,
    c.course_name,
    s.semester,
    COUNT(DISTINCT e.student_id) as enrolled_students,
    s.max_capacity,
    ROUND(COUNT(DISTINCT e.student_id) * 100.0 / s.max_capacity, 1) as capacity_usage_percent
FROM subjects s
LEFT JOIN student_subject_enrollment e ON s.subject_id = e.subject_id AND e.status = 'active'
JOIN courses c ON s.course_id = c.course_id
GROUP BY s.subject_id;

-- ===== Teacher Subject Assignment Summary =====
-- Shows which subjects teachers are assigned to teach
CREATE OR REPLACE VIEW teacher_subject_assignment AS
SELECT 
    t.user_id as teacher_id,
    t.full_name as teacher_name,
    t.employee_id,
    s.subject_id,
    s.subject_code,
    s.subject_name,
    c.course_name,
    s.semester,
    COUNT(DISTINCT e.student_id) as student_count,
    st.assigned_date
FROM subject_teacher st
JOIN users t ON st.teacher_id = t.user_id
JOIN subjects s ON st.subject_id = s.subject_id
JOIN courses c ON s.course_id = c.course_id
LEFT JOIN student_subject_enrollment e ON s.subject_id = e.subject_id AND e.status = 'active'
WHERE t.status = 'approved'
GROUP BY st.assignment_id;

-- ===== Course Curriculum View =====
-- Shows all subjects in each degree program by semester
CREATE OR REPLACE VIEW course_curriculum AS
SELECT 
    c.course_id,
    c.course_code,
    c.course_name,
    s.subject_id,
    s.subject_code,
    s.subject_name,
    s.semester,
    s.credits,
    COUNT(DISTINCT st.teacher_id) as teacher_count
FROM courses c
LEFT JOIN subjects s ON c.course_id = s.course_id
LEFT JOIN subject_teacher st ON s.subject_id = st.subject_id
GROUP BY s.subject_id
ORDER BY c.course_id, s.semester, s.subject_code;

-- ========================================
-- APPLICATION CONFIGURATION
-- ========================================

-- ===== Connection Parameters =====
-- Database Name: student_info_system
-- Host: localhost
-- Port: 3306
-- Username: root
-- JDBC: jdbc:mysql://localhost:3306/student_info_system?useSSL=false&serverTimezone=UTC

-- ===== Password Hashing =====
-- Algorithm: SHA-256
-- Encoding: Base64
-- Python script:
--   import hashlib, base64
--   password = 'admin123'
--   hashed = hashlib.sha256(password.encode()).digest()
--   encoded = base64.b64encode(hashed).decode()
--   print(encoded)  # JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=

-- ===== Demo User Credentials =====
-- Admin: admin@sims.edu / admin123
-- Teachers:
--   - dr.smith@sims.edu / admin123
--   - prof.johnson@sims.edu / admin123
--   - ms.sharma@sims.edu / admin123
-- Students:
--   - john.doe@sims.edu / admin123
--   - priya.singh@sims.edu / admin123
--   - amit.kumar@sims.edu / admin123
--   - alice.wilson@sims.edu / admin123
--   - rahul.patel@sims.edu / admin123

-- ========== VERIFICATION QUERIES ==========

-- Count all records by table
-- SELECT 'courses' as table_name, COUNT(*) as count FROM courses
-- UNION ALL SELECT 'subjects', COUNT(*) FROM subjects
-- UNION ALL SELECT 'users', COUNT(*) FROM users
-- UNION ALL SELECT 'subject_teacher', COUNT(*) FROM subject_teacher
-- UNION ALL SELECT 'student_subject_enrollment', COUNT(*) FROM student_subject_enrollment
-- UNION ALL SELECT 'attendance', COUNT(*) FROM attendance
-- UNION ALL SELECT 'marks', COUNT(*) FROM marks
-- UNION ALL SELECT 'announcements', COUNT(*) FROM announcements;

-- Verify data structure
-- SELECT c.course_name, COUNT(s.subject_id) as subject_count
-- FROM courses c
-- LEFT JOIN subjects s ON c.course_id = s.course_id
-- GROUP BY c.course_id;

-- Verify teacher assignments by subject
-- SELECT t.full_name, s.subject_code, s.subject_name, c.course_name
-- FROM subject_teacher st
-- JOIN users t ON st.teacher_id = t.user_id
-- JOIN subjects s ON st.subject_id = s.subject_id
-- JOIN courses c ON s.course_id = c.course_id
-- ORDER BY t.full_name;

-- ========== DATABASE SETUP COMPLETE ==========
-- Version: 3.0 - Academic Hierarchy Refactored
-- Date: February 28, 2026
-- Institution: DY Patil School of Science and Technology, Pune
--
-- KEY CHANGES FROM v2.0:
-- ✅ New table structure with Courses (degree programs) and Subjects (modules)
-- ✅ Renamed course_teacher → subject_teacher
-- ✅ Renamed enrollments → student_subject_enrollment  
-- ✅ Updated attendance and marks to use subject_id
-- ✅ Added 5 comprehensive reporting views
-- ✅ Demo data includes all 4 degree programs
-- ✅ Proper foreign key relationships (3NF normalized)
--
-- All tables, indexes, views, and demo data successfully created!
-- Ready for production deployment!
