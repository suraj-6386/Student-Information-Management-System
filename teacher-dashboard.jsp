<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int teacherId = (Integer) session.getAttribute("userId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }
        
        .dashboard-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .dashboard-card h3 {
            margin: 0 0 0.5rem 0;
            color: #2c3e50;
            font-size: 1.1rem;
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #3498db;
            margin: 0.5rem 0;
        }
        
        .stat-label {
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }
        
        .section-title {
            font-size: 1.3rem;
            font-weight: bold;
            color: #2c3e50;
            margin: 2rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #3498db;
        }
        
        .courses-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        
        .course-card {
            background: white;
            border-radius: 8px;
            padding: 1.25rem;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            border-left: 4px solid #3498db;
        }
        
        .course-code {
            font-size: 0.8rem;
            color: #7f8c8d;
            text-transform: uppercase;
            font-weight: 600;
        }
        
        .course-name {
            font-size: 1.1rem;
            font-weight: bold;
            color: #2c3e50;
            margin: 0.5rem 0;
        }
        
        .course-meta {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.5rem;
        }
        
        .students-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 2rem;
        }
        
        .students-table thead {
            background: #2c3e50;
            color: white;
        }
        
        .students-table th {
            padding: 0.75rem;
            text-align: left;
            font-weight: 600;
            font-size: 0.9rem;
        }
        
        .students-table td {
            padding: 0.75rem;
            border-bottom: 1px solid #ecf0f1;
            font-size: 0.9rem;
        }
        
        .students-table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #7f8c8d;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Teacher Portal</p>
            </div>
            <div class="nav-links">
                <a href="teacher-dashboard.jsp" class="nav-link active">Dashboard</a>
                <a href="teacher-profile.jsp" class="nav-link">Profile</a>
                <a href="teacher-courses.jsp" class="nav-link">My Courses</a>
                <a href="teacher-students.jsp" class="nav-link">Students</a>
                <a href="teacher-attendance.jsp" class="nav-link">Attendance</a>
                <a href="teacher-marks.jsp" class="nav-link">Marks</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="dashboard-header">
            <div class="dashboard-title">
                <h2>Teacher Dashboard</h2>
                <p>Welcome, <%= session.getAttribute("userName") %> <span style="font-size: 0.85rem; color: #7f8c8d;"> | ID: <%= session.getAttribute("userIdCode") %></span></p>
            </div>
            <div class="user-info">
                <p><strong>Role:</strong> Teacher</p>
                <p><strong>Email:</strong> <%= session.getAttribute("userEmail") %></p>
            </div>
        </div>

        <!-- Quick Stats -->
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>📚 Assigned Subjects</h3>
                <div class="stat-number">
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) as cnt FROM subjects WHERE teacher_id = ?");
                            ps.setInt(1, teacherId);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                out.print(rs.getInt("cnt"));
                            }
                            rs.close();
                            ps.close();
                            conn.close();
                        } catch (Exception e) {
                            out.print("0");
                        }
                    %>
                </div>
                <div class="stat-label">Subjects Teaching</div>
            </div>

            <div class="dashboard-card">
                <h3>👥 Total Students</h3>
                <div class="stat-number">
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            PreparedStatement ps = conn.prepareStatement(
                                "SELECT COUNT(DISTINCT se.student_id) as cnt FROM subject_enrollment se " +
                                "JOIN subjects s ON se.subject_id = s.subject_id WHERE s.teacher_id = ? AND se.status = 'active'");
                            ps.setInt(1, teacherId);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                out.print(rs.getInt("cnt"));
                            }
                            rs.close();
                            ps.close();
                            conn.close();
                        } catch (Exception e) {
                            out.print("0");
                        }
                    %>
                </div>
                <div class="stat-label">Students Enrolled</div>
            </div>

            <div class="dashboard-card">
                <h3>✓ Quick Attendance</h3>
                <div class="stat-number" style="font-size: 2rem;">→</div>
                <div class="stat-label">Mark Attendance</div>
                <a href="teacher-attendance.jsp" class="btn btn-primary" style="width: 100%;">Mark Now →</a>
            </div>
        </div>

        <!-- Assigned Subjects Section -->
        <h3 class="section-title">📚 My Assigned Subjects</h3>
        
        <%
            int courseCount = 0;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                String courseSQL = "SELECT s.subject_id, s.subject_code, s.subject_name, s.credits, s.semester, " +
                                   "c.course_name, COUNT(DISTINCT se.student_id) as student_count " +
                                   "FROM subjects s " +
                                   "JOIN courses c ON s.course_id = c.course_id " +
                                   "LEFT JOIN subject_enrollment se ON s.subject_id = se.subject_id AND se.status = 'active' " +
                                   "WHERE s.teacher_id = ? " +
                                   "GROUP BY s.subject_id " +
                                   "ORDER BY c.course_name, s.semester";
                
                PreparedStatement courseStmt = conn.prepareStatement(courseSQL);
                courseStmt.setInt(1, teacherId);
                ResultSet courseRS = courseStmt.executeQuery();
                
                boolean hasCourses = false;
                while (courseRS.next()) {
                    hasCourses = true;
                    courseCount++;
        %>
        <div class="course-card">
            <div class="course-code"><%= courseRS.getString("subject_code") %></div>
            <div class="course-name"><%= courseRS.getString("subject_name") %></div>
            <div class="course-meta">
                <strong>Course:</strong> <%= courseRS.getString("course_name") %> | 
                <strong>Semester:</strong> <%= courseRS.getInt("semester") %> | 
                <strong>Credits:</strong> <%= courseRS.getInt("credits") %> |
                <strong>Students:</strong> <%= courseRS.getInt("student_count") %>
            </div>
        </div>
        <%
                }
                
                if (!hasCourses) {
        %>
        <div class="empty-state">
            <p>No subjects assigned yet. Contact your administrator to assign subjects.</p>
        </div>
        <%
                }
                
                courseRS.close();
                courseStmt.close();
                conn.close();
            } catch (Exception e) {
        %>
        <div class="empty-state" style="color: red;">
            Error loading subjects: <%= e.getMessage() %>
        </div>
        <% } %>

        <!-- Students Section -->
        <h3 class="section-title">👥 My Students</h3>
        
        <%
            int studentCount = 0;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                String studentSQL = "SELECT DISTINCT st.student_id, st.full_name, st.email, st.roll_number, c.course_name " +
                                   "FROM student st " +
                                   "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                                   "JOIN subjects s ON se.subject_id = s.subject_id " +
                                   "JOIN courses c ON s.course_id = c.course_id " +
                                   "WHERE s.teacher_id = ? AND st.status = 'active' AND se.status = 'active' " +
                                   "ORDER BY st.full_name";
                
                PreparedStatement studentStmt = conn.prepareStatement(studentSQL);
                studentStmt.setInt(1, teacherId);
                ResultSet studentRS = studentStmt.executeQuery();
                
                boolean hasStudents = false;
        %>
        
        <table class="students-table">
            <thead>
                <tr>
                    <th>Roll No.</th>
                    <th>Student Name</th>
                    <th>Email</th>
                    <th>Course</th>
                </tr>
            </thead>
            <tbody>
        <%
                while (studentRS.next()) {
                    hasStudents = true;
                    studentCount++;
        %>
                <tr>
                    <td><%= studentRS.getString("roll_number") != null ? studentRS.getString("roll_number") : "N/A" %></td>
                    <td><%= studentRS.getString("full_name") %></td>
                    <td><%= studentRS.getString("email") %></td>
                    <td><%= studentRS.getString("course_name") %></td>
                </tr>
        <%
                }
                
                if (!hasStudents) {
        %>
                <tr>
                    <td colspan="4" style="text-align: center; padding: 2rem;">No students enrolled in your subjects</td>
                </tr>
        <%
                }
        %>
            </tbody>
        </table>
        <%
                studentRS.close();
                studentStmt.close();
                conn.close();
            } catch (Exception e) {
        %>
        <div class="empty-state" style="color: red;">
            Error loading students: <%= e.getMessage() %>
        </div>
        <% } %>

        <div style="margin-top: 2rem; text-align: center;">
            <a href="teacher-dashboard.jsp" class="btn btn-secondary">↑ Back to Top</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
