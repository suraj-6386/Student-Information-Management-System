# SIMS - Student Information Management System
## DY Patil School of Science and Technology, Pune

A professional, web-based Student Information Management System built with **pure HTML, CSS, JSP, and MySQL** - No frameworks, no bloatware.

---

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [What's New in v2.0](#whats-new-in-v20)
3. [Technology Stack](#technology-stack)
4. [Quick Start](#quick-start)
5. [Registration Workflow](#registration-workflow)
6. [Module Documentation](#module-documentation)
7. [Session Management](#session-management)
8. [User Roles](#user-roles--permissions)
9. [Attendance Module](#attendance-module)
10. [Marks Module](#marks-module)
11. [Database Schema](#database-schema)
12. [Troubleshooting](#troubleshooting)

---

## System Overview

SIMS is a comprehensive academic management system that streamlines operations for:
- **Students**: Track courses,attendance, marks, announcements
- **Teachers**: Manage assigned courses, mark attendance, enter grades
- **Administrators**: Oversee users, manage courses, assign teachers

### Key Features
✅ **Professional Registration** - Students & teachers register with complete information  
✅ **One-Time Login Session** - Sessions persist across ALL pages until logout  
✅ **Course-Teacher Assignment** - Admins assign courses to teachers efficiently  
✅ **Attendance Tracking** - Date + checkbox-based marking per course  
✅ **Mark Management** - Track assignment, mid-exam, final exam marks  
✅ **Announcement System** - Faculty and admin post updates for all  
✅ **User Edit** - Admin can edit any approved user's profile  
✅ **Responsive Design** - Works on desktop, tablet, mobile  

---

## What's New in v2.0

### 🎓 Registration Improvements
- **Student fields**: Roll number, DOB, gender, address, course, semester, parent info
- **Teacher fields**: Employee ID, department, qualification, experience
- Dynamic form based on user type selection
- Complete data collection at registration time

### 🔄 Session Management (FIXED)
- **One-time login**: Users log in once and stay logged in
- **Session persistence**: Remains active across all pages
- **Proper session checks**: At top of each protected page
- **Logout**: Properly destroys session

### 📚 Course Management
- **Removed subjects module** - Now using courses exclusively
- **Course-Teacher Assignment** - Admin assigns teachers to courses
- **Automatic reflection** - Assigned courses appear in teacher dashboard
- **Teachers see only their courses** in all modules

### 📝 Attendance Workflow
- **Date picker**: Select specific class date
- **Auto-loaded students**: All students of selected course displayed
- **Checkbox marking**: Simple present/absent marking
- **Teacher tracking**: Records teacher ID with attendance

### 📊 Marks Workflow
- **Course selection**: Pick course from assigned courses
- **Student dropdown**: Select student from course enrollment
- **Mark entry**: Assignment, mid exam, final exam  
- **Auto-calculation**: Total and grade automatically calculated

### 👤 User Edit by Admin
- **Edit profile**: Admin can modify any approved user
- **Change email/phone**: Update contact information
- **Reset password**: Change user password manually
- **Course/department update**: Update role-specific fields

### 📢 Announcement System
- **Works for all roles**: Admin, teacher, student
- **Admin posts**: System-wide announcements
- **Teacher posts**: Can post to students
- **Student view**: Read-only access to announcements

---

## Technology Stack

| Component | Technology |
|-----------|-----------|
| Frontend | HTML5, CSS3 |
| Backend | JSP (Java Server Pages) |
| Database | MySQL 5.7+ |
| Server | Apache Tomcat 8.0+ |
| Auth | Session-based, SHA-256 password hashing |

**NO Frameworks**: Pure development without Spring, Hibernate, Bootstrap, React

---

## Quick Start

### 1. Database Setup
```bash
# Open phpMyAdmin or MySQL CLI
mysql -u root -p

# Run setup script
source DB_SETUP.sql

# Verify database created
SHOW DATABASES;  # Should list 'student_info_system'
```

### 2. Verify Application Files
```
StudentInfoManageSystem/
├── index.html
├── registration.jsp
├── login.jsp
├── student-dashboard.jsp ... [19 more JSP files]
├── style.css
├── DB_SETUP.sql
└── README.md  ← You are here
```

### 3. Access Application
```
http://localhost:8080/MyApps/StudentInfoManageSystem/
```

### 4. Login with Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@sims.edu | admin123 |
| Student | student@sims.edu | student123 |
| Teacher | teacher@sims.edu | teacher123 |

---

## Registration Workflow

### Student Registration Collects:
- Full Name, DOB, Gender, Email, Phone
- Roll Number, Course, Semester, Admission Year  
- Address, Parent Name, Parent Contact
- Username, Password (auto-hashed)

### Teacher Registration Collects:
- Full Name, Email, Phone, Address
- Employee ID, Department
- Qualification, Experience (years)
- Username, Password (auto-hashed)

### Registration Flow
```
Registration Page
↓
User enters data (role-specific)
↓
Email duplicate check
↓
Password hashing (SHA-256)
↓
INSERT into database
↓
Status: PENDING (awaiting approval)
↓
Admin reviews & approves
↓
User can now LOGIN
```

---

## Module Documentation

### HOME PAGE (index.html)
Professional introduction with:
- College branding (DY Patil School of Science and Technology)
- Features overview with icons
- Role descriptions (Student, Teacher, Admin)
- Quick action buttons

**URL**: `/index.html`

### REGISTRATION (registration.jsp)
- Dynamic form based on user type
- Separate sections for student/teacher fields
- Real-time field visibility toggle
- Form validation before submission

**Flow**: 
1. Choose user type (Student/Teacher)
2. Fill common fields + role-specific fields
3. Click Register
4. Status set to "pending"
5. Admin must approve

### LOGIN (login.jsp)
- Email + password authentication
- Session creation on success
- Role-based dashboard redirect
- Error messaging

**Outcome**:
- ✅ If approved: Redirected to role dashboard
- ❌ If pending: Error message "awaiting approval"
- ❌ If rejected: Error message "registration rejected"

### STUDENT DASHBOARD
Statistics shown:
- Total courses enrolled
- Marks received
- Attendance percentage

**Quick Links**:
- Profile → View/edit student info
- Courses → List of enrolled courses
- Attendance → Per-course attendance view
- Marks → View marks and grades

**Protected by**: `userType === 'student'`

### STUDEN T MODULES

#### Courses (student-courses.jsp)
Displays:
- Course code & name
- Credits, semester
- Enrollment date
- Teacher assigned

#### Attendance (student-attendance.jsp)
Shows per-course:
- Total classes held
- Classes attended
- Attendance percentage
- Date-wise breakdown

#### Marks (student-marks.jsp)
Displays:
- Course name
- Assignment, Mid exam, Final exam scores
- Total marks
- Grade (auto-calculated)

### TEACHER DASHBOARD
Statistics shown:
- Total assigned courses
- Total students
- Quick action buttons

**Quick Links**:
- Profile → View/edit teacher info
- My Courses → List assigned courses NEW
- Students → Students in courses
- Attendance → Mark attendance
- Marks → Enter marks

**Protected by**: `userType === 'teacher'`

### TEACHER MODULES

#### My Courses (teacher-courses.jsp) - NEW
Lists all courses assigned to teacher:
- Course code & name
- Semester, credits
- Date assigned
- Student enrollment count

#### Students (teacher-students.jsp)
Students in courses assigned to teacher:
- Student name, ID, email
- Contact information
- Enrolled course(s)

#### Attendance (teacher-attendance.jsp) - IMPROVED
**Step 1**: Select course (from assigned courses)
**Step 2**: Select date (HTML5 date picker)
**Step 3**: Auto-load all students of that course
**Step 4**: Mark ☐ Present/Absent for each
**Step 5**: Submit

**Stored**: student_id, course_id, teacher_id, class_date, is_present

#### Marks (teacher-marks.jsp) - IMPROVED
**Step 1**: Select course
**Step 2**: Select student (auto-populated dropdown)
**Step 3**: Enter marks:
- Assignment (0-100)
- Mid Exam (0-100)  
- Final Exam (0-100)
**Step 4**: Submit
**Auto-calculated**: Total, Grade

**Stored**: student_id, course_id, teacher_id, assignment, mid_exam, final_exam

### ADMIN DASHBOARD
Statistics & quick actions:
- Pending registrations
- Approved users
- Course management
- System reports

**Modules**:
- Pending Approvals → Review & approve/reject registrations
- Approved Users → Edit user profiles, reset passwords  
- Courses → Create/manage courses + assign teachers
- Reports → System analytics

**Protected by**: `userType === 'admin'`

### ADMIN MODULES

#### Pending Approvals (admin-pending.jsp)
Table with pending registrations:
- User name, email, phone, type
- Action buttons: [Approve] [Reject]
- Auto-updated course enrollment if student

#### Approved Users (admin-users.jsp) - ENHANCED
All approved users with [Edit] button:

**Edit Form allows changing**:
- Email, phone, address
- Course (for students)
- Department, qualification (for teachers)
- Password reset option

#### Courses (courses.jsp) - ENHANCED
Create/manage courses:
- **Create Course**: Code, name, credits, semester
- **Assign Teacher**: Dropdown to select teacher for each course
- **Update Course**: Edit existing course details
- **View Assignments**: See which teacher assigned

**Note**: Course-teacher relationship stored separately
- Teachers see assigned courses in dashboard

#### Reports (reports.jsp)
System analytics:
- Total users by type
- Student enrollment statistics
- Attendance summary
- Marks distribution

### ANNOUNCEMENTS (announcements.jsp)
- Admin/Teacher can post
- All can view
- Sorted by latest first
- Shows: Title, content, author, date

---

## Session Management

### ✅ Session Fixed in v2.0

**Problem (v1.0)**: Users logged out when navigating pages  
**Solution (v2.0)**: Proper session checking only at login/logout

### Implementation

**At TOP of every protected JSP** (after imports):
```jsp
<%
    // Session Check - FIXED
    if (session == null || session.isNew() || 
        session.getAttribute("userId") == null || 
        session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Optional: Role check
    if (!"student".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    // Page logic continues...
%>
```

### Session Attributes
```
session.setAttribute("userId", userId);             // Integer
session.setAttribute("userName", fullName);         // String  
session.setAttribute("userType", user_type);        // 'student'/'teacher'/'admin'
session.setAttribute("userEmail", email);           // String
```

### Session Lifecycle
1. **Created**: login.jsp after successful authentication
2. **Maintained**: All pages check and use session
3. **Persisted**: Across all navigation until logout
4. **Destroyed**: logout.jsp calls `session.invalidate()`
5. **Timeout**: Default 30 minutes (configurable)

---

## User Roles & Permissions

### 👨‍🎓 STUDENT
✓ View profile  
✓ View enrolled courses  
✓ View attendance per course  
✓ View marks and grades  
✓ Read announcements  
✗ Cannot create/edit anything  

### 👨‍🏫 TEACHER
✓ View assigned courses  
✓ View enrolled students  
✓ Mark attendance (with date picker)  
✓ Enter/edit student marks  
✓ Post announcements  
✓ View/edit own profile  
✗ Cannot manage courses  
✗ Cannot manage other teachers/students  

### 👨‍💼 ADMIN
✓ View all users  
✓ Approve/reject registrations  
✓ Edit any user profile  
✓ Reset user passwords  
✓ Create/manage courses  
✓ Assign teachers to courses  
✓ View system reports  
✓ Post announcements  
✓ Full system access  

---

## Attendance Module

### Workflow

**Teacher Attendance** (`teacher-attendance.jsp`):
1. Select course from dropdown (auto-populated from course_teacher)
2. Select date using HTML5 date picker
3. After date selection:
   - Query: Fetch all students enrolled in selected course
   - Display table with checkbox for each student
4. Mark ☐ Present/☐ Absent for each student
5. Click Submit
6. INSERT into attendance table with teacher_id

**Student Attendance** (`student-attendance.jsp`):
- Shows per-course attendance summary
- Auto-calculated percentage
- Date-wise attendance records

### Database Storage
```sql
INSERT INTO attendance 
(student_id, course_id, teacher_id, class_date, is_present)
VALUES (?, ?, ?, ?, ?);
```

### Query for Report
```sql
SELECT 
    student_id,
    course_name,
    COUNT(*) as total_classes,
    SUM(IF(is_present = 1, 1, 0)) as attended_classes,
    ROUND(attended_classes * 100 / total_classes, 2) as percentage
FROM attendance a
JOIN courses c ON a.course_id = c.course_id
GROUP BY a.student_id, a.course_id;
```

---

## Marks Module

### Workflow

**Teacher Marks Entry** (`teacher-marks.jsp`):
1. Select course from dropdown
2. Select student (auto-populated with students in course)
3. Enter marks:
   - Assignment: 0-100
   - Mid Exam: 0-100
   - Final Exam: 0-100
4. Submit
5. System auto-calculates:
   - Total = assignment + mid_exam + final_exam
   - Grade = A/B/C/D/F based on total
6. INSERT/UPDATE marks table

**Student Marks View** (`student-marks.jsp`):
- Shows all courses with their marks
- Displays assignment, mid-exam, final-exam
- Shows total and grade
- Auto-calculated totals

### Grade Calculation
```
Total Score = Assignment + Mid Exam + Final Exam (out of 300)

240+ = A
210+ = B
180+ = C
150+ = D
<150 = F
```

---

## Database Schema

### users Table
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    user_type ENUM('admin', 'student', 'teacher'),
    password VARCHAR(255),
    status ENUM('pending', 'approved', 'rejected'),
    
    -- Student fields
    roll_number VARCHAR(50),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    address TEXT,
    course_id INT,
    semester INT,
    parent_name VARCHAR(255),
    parent_contact VARCHAR(20),
    admission_year INT,
    
    -- Teacher fields
    employee_id VARCHAR(50),
    department VARCHAR(100),
    qualification VARCHAR(255),
    experience INT,
    
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
```

### course_teacher Table (NEW - Replaces subject_teacher)
```sql
CREATE TABLE course_teacher (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL,
    assigned_date TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    UNIQUE KEY (course_id, teacher_id)
);
```

### courses Table
```sql
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(50) UNIQUE NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    credits INT NOT NULL,
    semester INT NOT NULL,
    created_at TIMESTAMP
);
```

### attendance Table
```sql
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL,  -- NEW
    class_date DATE NOT NULL,
    is_present BOOLEAN DEFAULT 0,
    created_at TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (teacher_id) REFERENCES users(id)
);
```

### marks Table
```sql
CREATE TABLE marks (
    marks_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL,  -- NEW
    assignment INT DEFAULT 0,
    mid_exam INT DEFAULT 0,
    final_exam INT DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    UNIQUE KEY (student_id, course_id)
);
```

### Key Changes from v1.0
- ✅ Removed `subjects` table dependency
- ✅ Replaced `subject_teacher` with `course_teacher`  
- ✅ Updated `attendance` to include `teacher_id`
- ✅ Updated `marks` to include `teacher_id`
- ✅ Added student fields to `users` table
- ✅ Added teacher fields to `users` table

---

## Troubleshooting

### "Session Lost After Navigation"
**Solution**:
1. Verify session check is at TOP of JSP (before any output)
2. Ensure `session.setAttribute()` called in login.jsp
3. Check browser cookies enabled
4. Verify timeout hasn't exceeded (default 30 min)

### "Cannot Mark Attendance - No Students"
**Solution**:
1. Ensure students enrolled in course (`enrollments` table)
2. Verify teacher assigned to course (`course_teacher` table)
3. Check course selection dropdown displays correct course
4. Verify date picker populated

### "Login Fails - Invalid Credentials"
**Solution**:
1. Verify user status is 'approved' (not 'pending'/'rejected')
2. Check password hash matches database
3. Verify database has user record
4. Try demo credentials first

Generate correct hash:
```python
import hashlib, base64
password = "admin123"
hashed = hashlib.sha256(password.encode()).digest()
print(base64.b64encode(hashed).decode())
# JAvlGPq9JyTdtvBO6x2llnRI1+gxwIyPqCKAn3THIKk=
```

### "Database Connection Error"
**Solution**:
1. Start MySQL service
2. Verify database exists: `SHOW DATABASES;`
3. Check credentials: root / 15056324
4. Verify connection string: `jdbc:mysql://localhost:3306/student_info_system`

### "CSS Not Loading"
**Solution**:
1. Verify `style.css` in root folder
2. Check `<link>` tag: `<link rel="stylesheet" href="style.css">`
3. Clear browser cache (Ctrl+Shift+Delete)
4. Check console for 404 errors

---

## File Structure

```
StudentInfoManageSystem/
├── index.html
├── style.css
│
├── login.jsp
├── registration.jsp
├── logout.jsp
│
├── student-dashboard.jsp
├── student-profile.jsp
├── student-courses.jsp
├── student-attendance.jsp
├── student-marks.jsp
├── announcements.jsp
│
├── teacher-dashboard.jsp
├── teacher-profile.jsp
├── teacher-courses.jsp          ← NEW (was teacher-subjects.jsp)
├── teacher-students.jsp
├── teacher-attendance.jsp      ← IMPROVED
├── teacher-marks.jsp           ← IMPROVED
│
├── admin-dashboard.jsp
├── admin-pending.jsp
├── admin-users.jsp             ← ENHANCED
├── courses.jsp                 ← ENHANCED
├── reports.jsp
│
├── DB_SETUP.sql
├── README.md
└── error.jsp
```

---

## Version History

### v2.0 - Major Professional Update (Current)
- ✅ Complete registration with student/teacher details
- ✅ Fixed session persistence for one-time login
- ✅ Course-teacher assignment system
- ✅ Removed subjects module - courses only
- ✅ Enhanced attendance with date picker + checkbox
- ✅ Admin user edit functionality  
- ✅ Improved marks module with auto-calculation
- ✅ Professional college branding
- ✅ Enhanced database schema
- ✅ Comprehensive README documentation

### v1.0 - Initial Release
- Basic registration and login
- Core dashboard modules
- Simple course management
- Basic attendance/marks

---

## Support & Contact

**Email**: support@dypatil-sims.edu  
**Phone**: +91-20-XXXX-XXXX  
**Location**: Pune, Maharashtra, India  

---

**SIMS v2.0 - Production Ready** ✅  
**Last Updated**: February 28, 2026  
**Institution**: DY Patil School of Science and Technology, Pune

---

## 📁 Project Structure

**ALL FILES IN SINGLE FOLDER** (`/StudentInfoManageSystem/`):

```
StudentInfoManageSystem/
├── index.html                    (Landing page - only HTML file)
├── style.css                     (Single unified stylesheet)
│
├── registration.jsp              (User registration form)
├── login.jsp                     (Authentication portal)
├── logout.jsp                    (Session termination)
│
├── admin-dashboard.jsp           (Admin main portal)
├── admin-pending.jsp             (Approve/reject registrations)
├── admin-users.jsp               (User management)
├── courses.jsp                   (Create/manage courses)
├── subjects.jsp                  (Create/manage subjects)
├── reports.jsp                   (System reports & analytics)
│
├── student-dashboard.jsp         (Student main portal)
├── student-profile.jsp           (Student profile view)
├── student-courses.jsp           (Enrolled courses)
├── student-attendance.jsp        (View attendance)
├── student-marks.jsp             (View results)
│
├── teacher-dashboard.jsp         (Teacher main portal)
├── teacher-profile.jsp           (Teacher profile view)
├── teacher-subjects.jsp          (Assigned subjects)
├── teacher-students.jsp          (Class student list)
├── teacher-attendance.jsp        (Mark attendance)
├── teacher-marks.jsp             (Enter marks)
│
├── announcements.jsp             (View/post announcements)
├── error.jsp                     (Error handling page)
│
├── DB_SETUP.sql                  (Database schema - separate)
└── README.md                     (This file - separate)
```

**Key Structure**: 
- ✅ Single folder with ALL 24 JSP files + 1 HTML + 1 CSS
- ✅ No `WEB-INF` folder needed
- ✅ No Java files (.java)
- ✅ No subfolders

---

## 🚀 Quick Start Guide

### 1. Database Setup

1. **Open phpMyAdmin**:
   - Go to `http://localhost/phpmyadmin`
   - Login with default credentials (root/empty password)

2. **Create Database**:
   - Click "New" → Create database `student_info_system`

3. **Import Schema**:
   - Select the `student_info_system` database
   - Go to "Import" tab
   - Choose `DB_SETUP.sql` file and click "Import"
   - ✅ All tables and sample data created

### 2. Verify Tomcat Setup

1. **Check Folder**:
   ```
   C:\xampp\tomcat\webapps\MyApps\StudentInfoManageSystem\
   ```
   - All 24 JSP files present
   - index.html present
   - style.css present
   - DB_SETUP.sql present

2. **Restart Tomcat** (if files were just added)

### 3. Access the Application

1. **Open Browser**:
   ```
   http://localhost:8080/MyApps/StudentInfoManageSystem/
   ```

2. **Landing Page** (`index.html`):
   - Welcome page with navigation
   - Links to Register, Login, About

3. **Register or Login**:
   - Register as Student/Teacher (pending approval)
   - OR login with demo credentials (see below)

---

## 👤 Demo Credentials

| Role | Email | Password | Status |
|------|-------|----------|--------|
| **Admin** | admin@sims.edu | admin123 | Approved |
| **Student** | student@sims.edu | student123 | Approved |
| **Teacher** | teacher@sims.edu | teacher123 | Approved |

### Login Flow:
1. Go to `http://localhost:8080/MyApps/StudentInfoManageSystem/login.jsp`
2. Enter email and password from table above
3. Click "Login"
4. ✅ Redirected to role-specific dashboard

---

## 🔐 Security Features

### Password Management:
- All passwords **SHA-256 hashed** with Base64 encoding
- Hash implementation: `java.security.MessageDigest`
- Stored as Base64 string in database

### Session Management:
- JSP `session` object for user tracking
- Session attributes: `userId`, `userName`, `userType`, `userEmail`
- Automatic redirect to login if session expires
- Logout clears all session data

### SQL Injection Prevention:
- All queries use **PreparedStatement**
- Never concatenates user input directly
- Example:
  ```jsp
  String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
  PreparedStatement pstmt = conn.prepareStatement(sql);
  pstmt.setString(1, email);
  pstmt.setString(2, password);
  ```

---

## 📦 Database Schema

### Core Tables:

1. **users** - All system users
   - Fields: id, full_name, email, phone, user_type, password, status
   - Status: pending → approved → (login enabled)

2. **courses** - Available courses
   - Fields: course_id, course_code, course_name, credits, semester

3. **subjects** - Academic subjects
   - Fields: subject_id, subject_code, subject_name, credits, semester

4. **enrollments** - Student course enrollments
   - Fields: enrollment_id, student_id, course_id, subject_id

5. **attendance** - Class attendance records
   - Fields: attendance_id, student_id, course_id, class_date, is_present

6. **marks** - Student assessment marks
   - Fields: marks_id, student_id, course_id, assignment, mid_exam, final_exam

7. **announcements** - System announcements
   - Fields: announcement_id, title, content, posted_by, posted_date

8. **subject_teacher** - Teacher subject assignments  
9. **class_teacher** - Teacher class assignments

---

## 🎯 User Workflows

### ADMIN WORKFLOW:
1. Login with credentials
2. View dashboard with statistics
3. Review pending registrations (admin-pending.jsp)
4. Approve/reject student and teacher applications
5. Manage courses (courses.jsp)
6. Manage subjects (subjects.jsp)
7. View system reports (reports.jsp)

### STUDENT WORKFLOW:
1. Register on registration.jsp (status = pending)
2. Wait for admin approval
3. Login after approval
4. View personal dashboard
5. View enrolled courses
6. Check attendance percentage
7. View marks and results
8. Read announcements

### TEACHER WORKFLOW:
1. Register on registration.jsp (status = pending)
2. Wait for admin approval  
3. Login after approval
4. View personal dashboard
5. View assigned subjects
6. View class students
7. Mark attendance
8. Enter student marks
9. Post announcements

---

## 🔧 Configuration

### Database Connection (in JSP files):
```jsp
Class.forName("com.mysql.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/student_info_system", "root", "");
```

### MySQL Credentials:
- **Host**: localhost
- **Port**: 3306
- **Database**: student_info_system
- **Username**: root
- **Password**: (empty for default XAMPP)

### JSP Connection Pattern (used in all files):
```jsp
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.Base64" %>
<%
    // Session check
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Database operations
    Class.forName("com.mysql.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/student_info_system", "root", "");
    
    PreparedStatement pstmt = conn.prepareStatement(sql);
    // ... execute query
    conn.close();
%>
```

---

## 🎨 UI/UX Design

### Color Scheme (Professional University Theme):
- **Primary**: Navy Blue (#1e3a8a)
- **Secondary**: Amber/Gold (#f59e0b)
- **Accent**: Light Blue (#3b82f6)
- **Success**: Green (#10b981)
- **Warning**: Orange (#f97316)
- **Danger**: Red (#ef4444)

### Responsive Design:
- ✅ Mobile-friendly (breakpoints: 768px, 480px)
- ✅ CSS3 Grid & Flexbox (NO Bootstrap)
- ✅ Professional dashboard layout
- ✅ Accessible forms and tables

### CSS Features:
- ~1500 lines of professional CSS3
- Smooth transitions and hover effects
- Consistent typography
- Clean card-based interface
- Responsive tables and forms

---

## 🐛 Troubleshooting

### Issue: "Connection Refused"
**Solution**: 
- Ensure MySQL is running (`mysql.exe` in XAMPP Control Panel)
- Check connection string in JSP files
- Verify database name: `student_info_system`

### Issue: "No JSP files showing"
**Solution**:
- Files must be in: `C:\xampp\tomcat\webapps\MyApps\StudentInfoManageSystem\`
- Restart Tomcat after adding files
- Clear browser cache (Ctrl+Shift+Delete)

### Issue: "Login not working"
**Solution**:
- Check MySQL user table for correct password hash
- Ensure user status is 'approved' (not 'pending')
- Try demo credentials first
- Check browser console for JS errors

### Issue: "CSS not loading"
**Solution**:
- Ensure `style.css` is in same folder as JSP files
- Check file path in HTML `<link>` tag: `<link rel="stylesheet" href="style.css">`
- Clear browser cache

---

## 📝 File Descriptions

| File | Purpose | Type |
|------|---------|------|
| index.html | Landing page | HTML |
| style.css | Main stylesheet | CSS |
| registration.jsp | User registration | JSP |
| login.jsp | Authentication | JSP |
| *-dashboard.jsp | Role dashboards | JSP |
| *-profile.jsp | User profiles | JSP |
| *-*.jsp | Feature pages | JSP |
| DB_SETUP.sql | Database schema | SQL |
| README.md | Documentation | Markdown |

---

## 📊 Sample Data Included

- **1 Admin User**
- **1 Sample Student** (enrolled in 3 courses)
- **1 Sample Teacher** (assigned 3 subjects)
- **4 Sample Courses** (CS101-CS301)
- **4 Sample Subjects**
- **Sample Attendance Records** (for student)
- **Sample Marks** (for student)

All accessible with demo credentials provided above.

---

## ✨ Features Summary

### ✅ Implemented:
- User Registration & Approval System
- Role-Based Access Control
- Secure Authentication
- Admin Dashboard & Management
- Student Portal
- Teacher Portal
- Course Management
- Subject Management
- Attendance Tracking
- Mark Entry & Display
- Announcement System
- System Reports
- Responsive UI
- Professional Styling

### 🔒 Security:
- Password Hashing (SHA-256)
- Session Management
- SQL Injection Prevention
- Access Control
- Status Verification

---

## 🤝 Support

### Common Questions:

**Q: Can I add more users?**
A: Yes, via registration.jsp. Admin must approve before they can login.

**Q: How do I backup the database?**
A: Use phpMyAdmin → Export → Choose database → Download SQL file

**Q: Can I modify the CSS?**
A: Yes! Edit `style.css` directly. All styles are in one file.

**Q: How do I add new features?**
A: Create new JSP files in the same folder following the existing pattern.

---

## 📄 License

This project is provided as-is for educational and commercial use.

---

## 🏁 Getting Help

1. Check the database schema in `DB_SETUP.sql`
2. Review existing JSP files for patterns
3. Check browser console for errors (F12)
4. Check phpMyAdmin for data verification
5. Verify all files are in the correct folder

---

## ✅ Setup Verification Checklist

Before using the system:

- [ ] MySQL server running
- [ ] `student_info_system` database created
- [ ] `DB_SETUP.sql` imported successfully
- [ ] All 24 JSP files in StudentInfoManageSystem folder
- [ ] `index.html` in folder
- [ ] `style.css` in folder
- [ ] Tomcat restarted after adding files
- [ ] Can access `http://localhost:8080/MyApps/StudentInfoManageSystem/`
- [ ] Can login with demo credentials
- [ ] Database connection working

---

**SIMS Version**: 1.0  
**Last Updated**: 2026  
**Status**: Production Ready ✅

---

## 📞 Contact

- **Support Email**: support@sims.edu
- **Admin Contact**: admin@sims.edu
- **Phone**: +1-800-SIMS-123

---

**Thank you for using SIMS - Student Information Management System!**
