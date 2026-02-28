<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"student".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    int totalCourses = 0;
    int marksReceived = 0;
    double attendancePercent = 0;
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system?useSSL=false&serverTimezone=UTC", "root", "15056324");
        
        Statement stmt = conn.createStatement();
        
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM subject_enrollment WHERE student_id = " + userId + " AND status = 'active'");
        if (rs.next()) totalCourses = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM marks WHERE student_id = " + userId);
        if (rs.next()) marksReceived = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT ROUND(SUM(IF(status = 'present', 1, 0)) * 100 / NULLIF(COUNT(*), 0), 2) as percentage FROM attendance WHERE student_id = " + userId);
        if (rs.next() && rs.getObject("percentage") != null) {
            attendancePercent = rs.getDouble("percentage");
        }
        
        conn.close();
    } catch (Exception e) { }
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
                <a href="student-courses.jsp" class="nav-link">My Courses</a>
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
                <p>Welcome, <%= session.getAttribute("userName") %> <span style="font-size: 0.85rem; color: #7f8c8d;"> | ID: <%= session.getAttribute("userIdCode") %></span></p>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="dashboard-card">
                <h3>📚 Enrolled Subjects</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label">Active Subjects</div>
                <a href="student-courses.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%;">View Details</a>
            </div>

            <div class="dashboard-card">
                <h3>📊 Marks Received</h3>
                <div class="stat-number"><%= marksReceived %></div>
                <div class="stat-label">Subjects Graded</div>
                <a href="student-marks.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%;">View Details</a>
            </div>

            <div class="dashboard-card">
                <h3>✓ Attendance</h3>
                <div class="stat-number"><%= String.format("%.1f", attendancePercent) %>%</div>
                <div class="stat-label">Overall Attendance</div>
                <a href="student-attendance.jsp" class="btn btn-primary" style="margin-top: 1rem; width: 100%;">View Details</a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
