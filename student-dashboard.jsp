<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    if (!"student".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp"); return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    int totalCourses = 0, marksReceived = 0;
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
    <title>Student Dashboard — SIMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
                <a href="student-profile.jsp" class="nav-link">Profile</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Sign Out</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">

        <div class="dashboard-header">
            <div class="dashboard-title">
                <h2>Student Dashboard</h2>
                <p>Welcome, <strong><%= session.getAttribute("userName") %></strong>
                   &nbsp;·&nbsp; ID: <%= session.getAttribute("userIdCode") %></p>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="dashboard-card card-sage">
                <h3>Enrolled Subjects</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label">Active subjects this semester</div>
                <a href="student-courses.jsp" class="btn btn-sage btn-full mt-2">View Details →</a>
            </div>

            <div class="dashboard-card card-charcoal">
                <h3>Marks Received</h3>
                <div class="stat-number"><%= marksReceived %></div>
                <div class="stat-label">Subjects graded</div>
                <a href="student-marks.jsp" class="btn btn-primary btn-full mt-2">View Details →</a>
            </div>

            <div class="dashboard-card card-warm">
                <h3>Attendance</h3>
                <div class="stat-number"><%= String.format("%.1f", attendancePercent) %>%</div>
                <div class="stat-label">Overall attendance rate</div>
                <a href="student-attendance.jsp" class="btn btn-primary btn-full mt-2">View Details →</a>
            </div>
        </div>

        <div class="quick-actions-section">
            <h3>Quick Access</h3>
            <div class="quick-actions-grid">
                <a href="student-courses.jsp"    class="action-btn action-courses">My Courses</a>
                <a href="student-attendance.jsp" class="action-btn action-users">Attendance Log</a>
                <a href="student-marks.jsp"      class="action-btn action-reports">My Marks</a>
                <a href="announcements.jsp"      class="action-btn action-pending" style="background:var(--warm-gray);">Announcements</a>
            </div>
        </div>

    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
            <p>&copy; SURAJ GUPTA | MCA</p>
        </div>
    </footer>

</body>
</html>
