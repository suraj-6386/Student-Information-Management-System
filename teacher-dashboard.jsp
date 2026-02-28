<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Session Check - *** IMPORTANT ***
    // Only redirect if session doesn't exist, not on every page load
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Additional check for teacher role
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    int totalCourses = 0;
    int totalStudents = 0;
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        Statement stmt = conn.createStatement();
        
        // Total assigned courses
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM course_teacher WHERE teacher_id = " + userId);
        if (rs.next()) totalCourses = rs.getInt("count");
        
        // Total students (from enrollments in assigned courses)
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT e.student_id) as count FROM enrollments e " +
                               "JOIN course_teacher ct ON e.course_id = ct.course_id WHERE ct.teacher_id = " + userId);
        if (rs.next()) totalStudents = rs.getInt("count");
        
        conn.close();
    } catch (Exception e) {
        // Error handling - log but continue
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - SIMS</title>
    <link rel="stylesheet" href="style.css">
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
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="dashboard-header">
            <div class="dashboard-title">
                <h2>Teacher Dashboard</h2>
                <p>Welcome, <%= session.getAttribute("userName") %></p>
            </div>
            <div class="user-info">
                <p><strong>Role:</strong> Teacher</p>
                <p><strong>Email:</strong> <%= session.getAttribute("userEmail") %></p>
                <p><a href="logout.jsp" class="btn btn-secondary">Logout</a></p>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>Assigned Courses</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label">Courses Teaching</div>
                <a href="teacher-courses.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%; text-align: center;">View Courses</a>
            </div>

            <div class="dashboard-card">
                <h3>Total Students</h3>
                <div class="stat-number"><%= totalStudents %></div>
                <div class="stat-label">Students Enrolled</div>
                <a href="teacher-students.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%; text-align: center;">View Students</a>
            </div>

            <div class="dashboard-card">
                <h3>Mark Attendance</h3>
                <div class="stat-number">→</div>
                <div class="stat-label">Record Attendance</div>
                <a href="teacher-attendance.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%; text-align: center;">Mark Attendance</a>
            </div>
        </div>

        <!-- Quick Actions -->
        <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-top: 2rem;">
            <h3>Quick Actions</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 1rem;">
                <a href="teacher-profile.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">👤 My Profile</a>
                <a href="teacher-courses.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">📚 My Courses</a>
                <a href="teacher-attendance.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">✓ Mark Attendance</a>
                <a href="teacher-marks.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">📊 Enter Marks</a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
