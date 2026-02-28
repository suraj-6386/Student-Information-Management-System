# SIMS v3.0 - Student Information Management System (Academic Hierarchy Refactored)

## Overview

SIMS v3.0 is a fully refactored Student Information Management System implementing a proper academic hierarchy where **Courses and Subjects are distinct entities**. This document explains the new architecture, data model, and workflows.

---

## 🎯 Key Concept - v3.0 Architecture

### The Fundamental Change

**Old Model (v2.0):** Courses = Subjects (mixed together)
- Confusing for academic structures
- Difficult to manage degree programs vs. course modules

**New Model (v3.0):** Courses ≠ Subjects
```
Courses (Degree Programs)          Subjects (Course Modules)
├─ BTech (4 years, 8 sems)        ├─ CS101: Programming
├─ BSc (3 years, 6 sems)          ├─ CS102: Mathematics-I
├─ BCA (3 years, 6 sems)          ├─ CS201: Data Structures
└─ MCA (2 years, 4 sems)          └─ CS301: OOP...
```

---

## 📊 Database Architecture

### Entity Relationship Diagram

```
┌──────────────────────────────────────────────────────────┐
│              Database Structure (3NF)                    │
└──────────────────────────────────────────────────────────┘

┌─────────────┐
│   COURSES   │ (Degree Programs: BTech, BSc, BCA, MCA)
├─────────────┤
│ course_id   │ (PK)
│ course_code │ (BTECH, BSC, etc.)
│ course_name │
│ duration    │
└─────────────┘
       │ 1
       │
       ├──────────────────────┐
       │  (One-to-Many)       │
       ▼ Many                 │
┌──────────────┐             │
│   SUBJECTS   │ (CS101, CS102, etc.)
├──────────────┤             │
│ subject_id   │ (PK)        │
│ subject_code │             │
│ subject_name │             │
│ course_id    │ (FK) ───────┘
│ semester     │
│ credits      │
└──────────────┘
       │ 1
       │
       ├───────────────────────────────────┐
       │                                   │
       ▼ Many                              ▼ Many
┌──────────────────┐          ┌─────────────────────┐
│ SUBJECT_TEACHER  │          │ STUDENT_SUBJECT_    │
│  (Assignment)    │          │   ENROLLMENT        │
├──────────────────┤          ├─────────────────────┤
│ assignment_id    │          │ enrollment_id       │
│ subject_id   (FK)│          │ student_id      (FK)│
│ teacher_id   (FK)│          │ subject_id      (FK)│
└──────────────────┘          └─────────────────────┘

┌──────────────┐          Other Tables:
│    USERS     │          - ATTENDANCE (by subject)
├──────────────┤          - MARKS (by subject)
│ user_id (PK) │          - ANNOUNCEMENTS
│ email        │
│ user_type    │
│ course_id(FK)│ ─────────> For students only
│ role-specific│           (their degree program)
│ fields...    │
└──────────────┘
```

### Table Relationships

#### 1. **COURSES** (Degree Programs)
- **Purpose**: Represent degree programs offered
- **Key Fields**: 
  - `course_code`: BTECH, BSC, BCA, MCA
  - `course_name`: Full name of program
  - `duration_years`: 2-4 years
  - `total_semesters`: 2-8 semesters

#### 2. **SUBJECTS** (Course Modules)
- **Purpose**: Individual courses within a degree program
- **Key Fields**:
  - `subject_code`: CS101, CS102, etc.
  - `subject_name`: Programming Fundamentals, etc.
  - `course_id` (FK): Which degree program
  - `semester`: Which semester (1-8)
  - `credits`: Credit hours for subject
- **Relationship**: Many subjects belong to one course

#### 3. **USERS** (Unified Table)
- **Admin**: Can manage courses, subjects, teachers, students
- **Teacher**:
  - `course_id = NULL` (not assigned to course/degree directly)
  - Assigned to specific SUBJECTS via subject_teacher table
  - Can only see students in their assigned subjects
- **Student**:
  - `course_id`: Points to degree program (BTech, BSc, etc.)
  - `semester`: Current semester
  - Enroll in SUBJECTS based on degree program and semester

#### 4. **SUBJECT_TEACHER** (NEW - Replaces course_teacher)
- **Purpose**: Map teachers to subjects they teach
- **Key Change**: Teachers assigned to SUBJECTS, NOT COURSES
- **Features**:
  - One subject can have multiple teachers (rare)
  - One teacher can teach multiple subjects (common)
  - Unique constraint: (subject_id, teacher_id)

#### 5. **STUDENT_SUBJECT_ENROLLMENT** (Replaces enrollments)
- **Purpose**: Track which students enroll in which subjects
- **Key Change**: Enrollment now by SUBJECT, not COURSE
- **Status**: active, completed, dropped
- **Unique**: One enrollment per student per subject

#### 6. **ATTENDANCE** (Updated)
- **Now uses**: `subject_id` (not course_id)
- **Tracks**: Which student attended which subject on which date
- **Marked by**: Teacher
- **Status**: present, absent, leave

#### 7. **MARKS** (Updated)
- **Now uses**: `subject_id` (not course_id)
- **Tracks**: Student scores in each subject
- **Components**: 
  - Theory marks (0-100)
  - Practical marks (0-100)
  - Assignment marks (0-100)
  - Total marks (0-300, auto-calculated)
  - Grade (A/B/C/D/F, auto-calculated)

#### 8. **ANNOUNCEMENTS**
- Unchanged from v2.0
- Posted by admin/teacher
- Visible based on role

---

## 🔄 Updated Workflows

### 1. **Registration Workflow**

```
Student Registration:
  ├─ Select Full Name, Email, Roll No., DOB
  ├─ Select COURSE (Degree Program):
  │  └─ Options: BTech, BSc, BCA, MCA
  ├─ System auto-assigns Semester = 1
  ├─ Admin reviews & approves
  └─ Student account created

Admin assigns subjects based on:
  - Course selected (e.g., BTech)
  - Current semester (e.g., Semester 1)
  - Auto-enroll in all Semester 1 subjects for that course
```

### 2. **Student Dashboard**

```
After Login:
  ├─ View Profile
  │   └─ Course: BTech
  │   └─ Semester: 1
  ├─ View Enrolled Subjects
  │   ├─ CS101: Programming Fundamentals
  │   ├─ CS102: Mathematics-I
  │   ├─ CS103: Physics-I
  │   └─ View Attendance/Marks for each
  ├─ View Attendance by Subject
  ├─ View Marks by Subject
  ├─ View Announcements
  └─ Update Profile
```

### 3. **Teacher Dashboard**

```
After Login:
  ├─ View Assigned Subjects (NOT courses)
  │   ├─ CS101: Programming Fundamentals
  │   │    └─ 45 enrolled students
  │   ├─ CS201: Data Structures
  │   │    └─ 42 enrolled students
  │   └─ CS301: OOP
  │        └─ 40 enrolled students
  ├─ Mark Attendance by Subject
  │   ├─ Select Subject
  │   ├─ Select Date
  │   ├─ Mark students present/absent/leave
  │   └─ Save
  ├─ Enter Marks by Subject
  │   ├─ Select Subject
  │   ├─ Enter theory, practical, assignment marks
  │   ├─ Grades auto-calculated
  │   └─ Save
  └─ View Announcements
```

### 4. **Admin Dashboard**

```
Admin Menu:
  ├─ Manage Courses (Degree Programs)
  │   ├─ View all courses (BTech, BSc, etc.)
  │   ├─ View subjects under each course
  │   └─ View students per course
  ├─ Manage Subjects
  │   ├─ Add/Edit/Delete subjects
  │   ├─ Filter by course and semester
  │   └─ View enrollment count
  ├─ Assign Subjects to Teachers
  │   ├─ Select Subject
  │   ├─ Multi-select Teachers (assign multiple)
  │   └─ View current assignments
  ├─ Manage Users
  │   ├─ Approve pending students/teachers
  │   ├─ Edit student profiles (course change, semester update)
  │   ├─ Edit teacher profiles
  │   └─ Manage approvals
  ├─ View Reports
  │   ├─ Subject Enrollment Summary
  │   ├─ Attendance Report by Subject
  │   ├─ Marks Report by Subject
  │   └─ Teacher Assignment Overview
  └─ System Settings
```

### 5. **Attendance Workflow (Teacher)**

```
Step 1: Login as Teacher
  └─ Dashboard shows assigned subjects

Step 2: Select Subject to Mark Attendance
  ├─ Click "Mark Attendance" on subject
  ├─ Choose date (HTML5 date picker)
  └─ System loads all enrolled students

Step 3: Mark Status
  ├─ Display list of enrolled students
  ├─ Mark as:
  │  ├─ ✓ Present
  │  ├─ ✗ Absent
  │  └─ ~ Leave
  ├─ Option: Select All / Deselect All
  └─ Submit

Result:
  └─ Attendance recorded in database
     (student_id, subject_id, teacher_id, date, status)
```

### 6. **Marks Entry Workflow (Teacher)**

```
Step 1: Select Subject
  ├─ Dropdown of assigned subjects
  └─ Shows enrolled count

Step 2: View Enrolled Students
  ├─ Auto-populated student list
  ├─ Shows: Student ID, Name, Roll No.
  └─ Can search/filter

Step 3: Enter Marks
  ├─ For each student:
  │   ├─ Theory Marks (0-100)
  │   ├─ Practical Marks (0-100)
  │   ├─ Assignment Marks (0-100)
  │   └─ Auto-calculate:
  │      ├─ Total = Theory + Practical + Assignment
  │      └─ Grade = Auto-calculated
  └─ Submit

Grade Calculation:
  - 270-300 = A
  - 240-269 = B
  - 180-239 = C
  - 150-179 = D
  - Below 150 = F
```

---

## 🗄️ Sample Data Architecture

### Degree Programs (Courses)
```
1. BTech - 4 years, 8 semesters, 160 credits
   ├─ Semester 1: CS101, CS102, CS103 (3 subjects)
   ├─ Semester 2: CS201, CS202, CS203 (3 subjects)
   ├─ Semester 3: CS301, CS302 (2 subjects)
   └─ Semester 4: CS401, CS402 (2 subjects)

2. BSc - 3 years, 6 semesters, 120 credits
   ├─ Semester 1: SCI101, SCI102, SCI103 (3 subjects)
   └─ Semester 2: SCI201, SCI202 (2 subjects)

3. BCA - 3 years, 6 semesters, 120 credits
   ├─ Semester 1: BCA101, BCA102, BCA103 (3 subjects)
   └─ Semester 2: BCA201, BCA202 (2 subjects)

4. MCA - 2 years, 4 semesters, 80 credits
   (Demo: Subjects can be added)
```

### Teacher Assignments (subject_teacher)
```
Dr. Smith (teacher_id=2) teaches:
  - CS101: Programming Fundamentals
  - CS201: Data Structures
  - CS301: Object-Oriented Programming

Prof. Johnson (teacher_id=3) teaches:
  - CS102: Mathematics-I
  - CS203: Database Basics
  - CS302: Web Development-I

Ms. Sharma (teacher_id=4) teaches:
  - CS202: Mathematics-II
  - CS401: Database Management Systems
  - CS402: Web Development-II
```

### Student Enrollments (student_subject_enrollment)
```
John Doe (BTech, Semester 1):
  - Enrolled in: CS101, CS102, CS103

Priya Singh (BTech, Semester 1):
  - Enrolled in: CS101, CS102, CS103

Amit Kumar (BTech, Semester 2):
  - Enrolled in: CS201, CS202, CS203

Alice Wilson (BSc, Semester 1):
  - Enrolled in: SCI101, SCI102, SCI103

Rahul Patel (BCA, Semester 1):
  - Enrolled in: BCA101, BCA102, BCA103
```

---

## 🎓 Demo User Credentials

### All Demo Passwords: `admin123`
Hash: `JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=`

### Admin
- **Email**: admin@sims.edu
- **Password**: admin123
- **Access**: Full system access

### Teachers
1. **Dr. Smith**
   - Email: dr.smith@sims.edu
   - Employee ID: EMP2020001
   - Teaches: Programming, Data Structures, OOP

2. **Prof. Johnson**
   - Email: prof.johnson@sims.edu
   - Employee ID: EMP2020002
   - Teaches: Math-I, Database Basics, Web Dev-I

3. **Ms. Sharma**
   - Email: ms.sharma@sims.edu
   - Employee ID: EMP2020003
   - Teaches: Math-II, DBMS, Web Dev-II

### Students
1. **John Doe** (BTech, Sem 1)
   - Email: john.doe@sims.edu
   - Roll No: BTECH20001

2. **Priya Singh** (BTech, Sem 1)
   - Email: priya.singh@sims.edu
   - Roll No: BTECH20002

3. **Amit Kumar** (BTech, Sem 2)
   - Email: amit.kumar@sims.edu
   - Roll No: BTECH20003

4. **Alice Wilson** (BSc, Sem 1)
   - Email: alice.wilson@sims.edu
   - Roll No: BSC20001

5. **Rahul Patel** (BCA, Sem 1)
   - Email: rahul.patel@sims.edu
   - Roll No: BCA20001

---

## 💾 Database Setup

### Prerequisites
- MySQL 5.7 or higher
- Database: `student_info_system`
- Character Set: UTF-8mb4
- Engine: InnoDB

### Setup Steps

1. **Drop existing database** (if upgrading from v2.0):
   ```bash
   mysql -u root -p -e "DROP DATABASE IF EXISTS student_info_system;"
   ```

2. **Run DB_SETUP.sql**:
   ```bash
   mysql -u root -p < DB_SETUP.sql
   ```

3. **Verify installation**:
   ```bash
   mysql -u root -p student_info_system -e "SHOW TABLES;"
   ```

4. **Check demo data**:
   ```bash
   mysql -u root -p student_info_system -e "SELECT COUNT(*) FROM users; SELECT COUNT(*) FROM courses; SELECT COUNT(*) FROM subjects;"
   ```

---

## 🔍 Reporting Views

### 1. `student_subject_attendance_summary`
Shows attendance percentage per subject for each student.
```sql
SELECT * FROM student_subject_attendance_summary 
WHERE student_id = 5;
-- Result: Attendance % for John's each subject
```

### 2. `student_subject_marks_summary`
Shows marks and grades per subject.
```sql
SELECT * FROM student_subject_marks_summary 
WHERE student_id = 6;
-- Result: Theory, Practical, Assignment, Grade per subject
```

### 3. `subject_enrollment_summary`
Shows enrollment count and capacity usage per subject.
```sql
SELECT * FROM subject_enrollment_summary 
WHERE course_id = 1;
-- Result: All BTech subjects with enrollment %
```

### 4. `teacher_subject_assignment`
Shows which subjects teachers teach.
```sql
SELECT * FROM teacher_subject_assignment 
WHERE teacher_id = 2;
-- Result: All subjects taught by Dr. Smith
```

### 5. `course_curriculum`
Complete curriculum of each degree program.
```sql
SELECT * FROM course_curriculum 
WHERE course_code = 'BTECH' AND semester = 1;
-- Result: All Semester 1 subjects in BTech
```

---

## 🔄 Migration from v2.0 to v3.0

### Old Structure (v2.0)
- `courses` table: CS101, CS102, etc. (mixed concept)
- `enrollments`: student → course
- `course_teacher`: teacher → course
- `attendance`, `marks`: by course_id

### New Structure (v3.0)
- `courses` table: BTech, BSc, BCA, MCA (degree programs)
- `subjects` table: CS101, CS102, etc. (under courses)
- `student_subject_enrollment`: student → subject
- `subject_teacher`: teacher → subject (renamed from course_teacher)
- `attendance`, `marks`: by subject_id

### Data Migration Steps
1. Backup v2.0 database
2. Create v3.0 database with DB_SETUP.sql
3. Map old courses to subjects under appropriate degree program
4. Update student enrollments to subject-based
5. Transfer teacher assignments to subject_teacher
6. Migrate attendance and marks records (course_id → subject_id)
7. Verify data integrity

---

## 📁 Project Structure

```
StudentInfoManageSystem/
├─ DB_SETUP.sql                 # Database schema (v3.0 refactored)
├─ README.md                    # This documentation
├─ style.css                    # Global CSS
├─ index.html                   # Public landing page

├─ login.jsp                    # Login page
├─ registration.jsp             # Student/Teacher registration
├─ logout.jsp                   # Logout handler

├─ student-dashboard.jsp        # Student home page
├─ student-profile.jsp          # Student profile view/update
├─ student-subjects.jsp         # View enrolled SUBJECTS (updated)
├─ student-marks.jsp            # View subject marks
├─ student-attendance.jsp       # View subject attendance

├─ teacher-dashboard.jsp        # Teacher home page
├─ teacher-profile.jsp          # Teacher profile
├─ teacher-subjects.jsp         # View assigned SUBJECTS (NEW)
├─ teacher-attendance.jsp       # Mark subject attendance
├─ teacher-marks.jsp            # Enter subject marks

├─ admin-dashboard.jsp          # Admin home page
├─ admin-users.jsp              # Manage users
├─ admin-pending.jsp            # Approve pending accounts
├─ subjects.jsp                 # Manage SUBJECTS (NEW)
├─ courses.jsp                  # Manage COURSES (degree programs)
├─ reports.jsp                  # View reports

├─ announcements.jsp            # View/post announcements
├─ error.jsp                    # Error page

└─ AJAX Endpoints:
   ├─ get-user-details.jsp      # Load user data for editing
   ├─ get-subject-students.jsp  # Load students in subject (NEW)
   └─ get-teacher-subjects.jsp  # Load teacher's assigned subjects
```

---

## 🐛 Troubleshooting

### Issue: Foreign key constraint error on database setup
**Solution**: Ensure InnoDB engine is used. Check MySQL version ≥ 5.7.

### Issue: Students not seeing enrolled subjects
**Solution**: Verify student_subject_enrollment table has entries for student and subject IDs match system data.

### Issue: Teachers can't mark attendance
**Solution**: Verify:
1. Teacher is assigned to subject via subject_teacher table
2. Students are enrolled in subject via student_subject_enrollment
3. Date format is valid (YYYY-MM-DD)

### Issue: Marks not showing correct grades
**Solution**: Verify mark totals are calculated correctly (theory + practical + assignment <= 300).

---

## 📋 Feature Checklist (v3.0)

- ✅ **Courses vs Subjects**: Proper separation with degree programs as courses
- ✅ **Course Management**: Admin can manage degree programs
- ✅ **Subject Management**: Admin can manage subjects under courses
- ✅ **Student Registration**: Students select degree program
- ✅ **Subject Enrollment**: Students enroll in subjects by program/semester
- ✅ **Teacher Assignment**: Teachers assigned to subjects (not courses)
- ✅ **Attendance by Subject**: Teachers mark attendance for specific subjects
- ✅ **Marks by Subject**: Teachers enter marks for subjects only
- ✅ **Student Dashboard**: View enrolled subjects and their marks/attendance
- ✅ **Teacher Dashboard**: View assigned subjects with student lists
- ✅ **Admin Controls**: Full management of courses, subjects, assignments
- ✅ **Reporting Views**: 5 comprehensive SQL views for analytics
- ✅ **Session Management**: One-time login, persistent sessions
- ✅ **Data Security**: SHA-256 password hashing, role-based access
- ✅ **Demo Data**: Complete sample data with all 4 degree programs

---
## 🆔 Auto-Generated User IDs

### Feature Overview

As of the latest update, SIMS now features auto-generated User IDs for both students and teachers:

- **Students**: `STU000001`, `STU000002`, etc.
- **Teachers**: `TEA000001`, `TEA000002`, etc.

### How It Works

1. **During Registration**:
   - Users register with email, full name, and other details
   - System automatically generates a unique User ID
   - User ID is displayed immediately after approval

2. **Visible In**:
   - ✅ Student Profile Page
   - ✅ Teacher Profile Page
   - ✅ Dashboard (next to user name)
   - ✅ Various system reports

3. **Login Method**:
   - All users now login using **Email Address** (not username)
   - Admin users also login with email (not username)
   - Format: User email + password

### Migration for Existing Databases

If you have an existing SIMS database without User IDs:

1. Run the migration script:
   ```bash
   MySQL > source ADD_USER_ID_MIGRATION.sql
   ```

2. Or manually execute:
   ```sql
   ALTER TABLE student ADD COLUMN user_id VARCHAR(20) UNIQUE NOT NULL;
   ALTER TABLE teacher ADD COLUMN user_id VARCHAR(20) UNIQUE NOT NULL;
   ```

3. The system will auto-generate IDs for new registrations immediately.

---

## 🔐 Login Authentication

### Email-Based Login

The system now uses **email addresses** for authentication across all user types:

| User Type | Login Field | Example |
|-----------|------------|---------|
| Student | Email | student@example.com |
| Teacher | Email | teacher@school.edu |
| Admin | Email | admin@sims.edu |

### Key Benefits

- ✅ Easier to remember (use actual email)
- ✅ Consistent across all roles
- ✅ Better security (emails are unique)
- ✅ Supports password reset functionality

---
## 🗓️ Version History

### v3.0 (February 28, 2026) - Current
- **Major Refactoring**: Implemented proper academic hierarchy
- **Key Changes**:
  - Courses now represent degree programs only
  - Subjects table added for course modules
  - subject_teacher table replaces course_teacher
  - student_subject_enrollment replaces enrollments
  - All attendance and marks now track by subject
- **New Features**:
  - Subject management interface
  - Course curriculum views
  - Enrollment summary reports
  - Teacher assignment optimization

### v2.0 (January 2026)
- Session management fixes
- Teacher dashboard enhancement
- Enhanced admin controls
- Comprehensive reporting views

### v1.0 (December 2025)
- Initial launch
- Basic role-based authentication
- Course and attendance management

---

## 📞 Support & Contact

**Institution**: DY Patil School of Science and Technology, Pune

**System Administrator**: admin@sims.edu

**For Issues**:
1. Check this README first
2. Review database tables structure
3. Verify all foreign keys and constraints
4. Check application error logs

---

## ⚖️ License & Terms

This Student Information Management System is developed exclusively for DY Patil School of Science and Technology, Pune. All rights reserved.

---

**SIMS v3.0 | Production Ready | Fully Normalized Database | Enhanced Academic Hierarchy**
