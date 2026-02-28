<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Session Check - *** IMPORTANT ***
    // Only redirect if session doesn't exist, not on every page load
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Additional check for student role
    if (!"student".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    int totalCourses = 0;
    int marksReceived = 0;
    int attendancePercentage = 0;
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        Statement stmt = conn.createStatement();
        
        // Total enrolled courses
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM enrollments WHERE student_id = " + userId);
        if (rs.next()) totalCourses = rs.getInt("count");
        
        // Marks received
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM marks WHERE student_id = " + userId);
        if (rs.next()) marksReceived = rs.getInt("count");
        
        // Attendance percentage
        rs = stmt.executeQuery("SELECT ROUND(SUM(IF(is_present = 1, 1, 0)) * 100 / COUNT(*), 2) as percentage FROM attendance WHERE student_id = " + userId);
        if (rs.next()) {
            Object percObj = rs.getObject("percentage");
            if (percObj != null) {
                attendancePercentage = ((Number) percObj).intValue();
            }
        }
        
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
    <title>Student Dashboard - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Student Portal</p>
            </div>
            <div class="nav-links">
                <a href="student-dashboard.jsp" class="nav-link active">Dashboard</a>
                <a href="student-profile.jsp" class="nav-link">Profile</a>
                <a href="student-courses.jsp" class="nav-link">Courses</a>
                <a href="student-attendance.jsp" class="nav-link">Attendance</a>
                <a href="student-marks.jsp" class="nav-link">Marks</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="dashboard-header">
            <div class="dashboard-title">
                <h2>Student Dashboard</h2>
                <p>Welcome, <%= session.getAttribute("userName") %></p>
            </div>
            <div class="user-info">
                <p><strong>Role:</strong> Student</p>
                <p><strong>Email:</strong> <%= session.getAttribute("userEmail") %></p>
                <p><a href="logout.jsp" class="btn btn-secondary">Logout</a></p>
            </div>
        </div>

        <!-- Statistics Cards -->
        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>Enrolled Courses</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label">Current Courses</div>
                <a href="student-courses.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%; text-align: center;">View Courses</a>
            </div>

            <div class="dashboard-card">
                <h3>Attendance</h3>
                <div class="stat-number"><%= attendancePercentage %>%</div>
                <div class="stat-label">Overall Attendance</div>
                <a href="student-attendance.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%; text-align: center;">View Details</a>
            </div>

            <div class="dashboard-card">
                <h3>Marks</h3>
                <div class="stat-number"><%= marksReceived %></div>
                <div class="stat-label">Assessments Graded</div>
                <a href="student-marks.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%; text-align: center;">View Results</a>
            </div>
        </div>

        <!-- Quick Actions -->
        <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-top: 2rem;">
            <h3>Quick Links</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-top: 1rem;">
                <a href="student-profile.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">👤 My Profile</a>
                <a href="student-courses.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">📚 My Courses</a>
                <a href="student-attendance.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">✓ Attendance</a>
                <a href="student-marks.jsp" class="btn btn-primary" style="padding: 1rem; text-align: center;">📊 My Marks</a>
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
