<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || 
        session.getAttribute("userId") == null || 
        session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    if (!"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp"); return;
    }
    
    int totalUsers = 0, totalStudents = 0, totalTeachers = 0;
    int pendingApprovals = 0, approvedUsers = 0;
    int totalCourses = 0, assignedCourses = 0, totalEnrollments = 0;
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system?useSSL=false&serverTimezone=UTC", "root", "15056324");
        Statement stmt = conn.createStatement();
        
        ResultSet rs = stmt.executeQuery("SELECT (SELECT COUNT(*) FROM student) + (SELECT COUNT(*) FROM teacher) as count");
        if (rs.next()) totalUsers = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM student WHERE status = 'approved'");
        if (rs.next()) totalStudents = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM teacher WHERE status = 'approved'");
        if (rs.next()) totalTeachers = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT (SELECT COUNT(*) FROM student WHERE status = 'pending') + (SELECT COUNT(*) FROM teacher WHERE status = 'pending') as count");
        if (rs.next()) pendingApprovals = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT (SELECT COUNT(*) FROM student WHERE status = 'approved') + (SELECT COUNT(*) FROM teacher WHERE status = 'approved') as count");
        if (rs.next()) approvedUsers = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM courses");
        if (rs.next()) totalCourses = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM subjects");
        if (rs.next()) assignedCourses = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT student_id) as count FROM subject_enrollment");
        if (rs.next()) totalEnrollments = rs.getInt("count");
        
        conn.close();
    } catch (Exception e) { }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — SIMS</title>
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
                <p>Administration Panel</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link active">Dashboard</a>
                <a href="admin-pending.jsp" class="nav-link">Approvals</a>
                <a href="admin-users.jsp" class="nav-link">Users</a>
                <a href="courses.jsp" class="nav-link">Courses</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="reports.jsp" class="nav-link">Reports</a>
                <a href="logout.jsp" class="nav-link">Sign Out</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">

        <div class="page-header">
            <h2>Admin Dashboard</h2>
            <p>Welcome back, <strong><%= session.getAttribute("userName") %></strong> &nbsp;·&nbsp; Administrator</p>
        </div>

        <div class="dashboard-grid">
            <div class="dashboard-card card-danger red">
                <h3>Pending Approvals</h3>
                <div class="stat-number"><%= pendingApprovals %></div>
                <div class="stat-label">Awaiting review</div>
                <a href="admin-pending.jsp" class="btn btn-primary btn-full mt-2">Review Now →</a>
            </div>

            <div class="dashboard-card card-charcoal blue">
                <h3>Total Users</h3>
                <div class="stat-number"><%= totalUsers %></div>
                <div class="stat-label">Registered in system</div>
                <a href="admin-users.jsp" class="btn btn-primary btn-full mt-2">View All →</a>
            </div>

            <div class="dashboard-card card-sage green">
                <h3>Total Courses</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label"><%= assignedCourses %> subjects created</div>
                <a href="courses.jsp" class="btn btn-primary btn-full mt-2">Manage →</a>
            </div>

            <div class="dashboard-card purple">
                <h3>Enrollments</h3>
                <div class="stat-number"><%= totalEnrollments %></div>
                <div class="stat-label">Course registrations</div>
                <a href="reports.jsp" class="btn btn-primary btn-full mt-2">View →</a>
            </div>
        </div>

        <h3 class="section-title">User Breakdown</h3>
        <div class="dashboard-grid">
            <div class="dashboard-card card-sage">
                <h3>Approved Users</h3>
                <div class="stat-number"><%= approvedUsers %></div>
                <div class="stat-label">Active accounts</div>
            </div>
            <div class="dashboard-card card-charcoal">
                <h3>Students</h3>
                <div class="stat-number"><%= totalStudents %></div>
                <div class="stat-label">Enrolled &amp; approved</div>
            </div>
            <div class="dashboard-card card-warm">
                <h3>Teachers</h3>
                <div class="stat-number"><%= totalTeachers %></div>
                <div class="stat-label">Active faculty</div>
            </div>
            <div class="dashboard-card">
                <h3>Subjects</h3>
                <div class="stat-number"><%= assignedCourses %></div>
                <div class="stat-label">Total subjects created</div>
            </div>
        </div>

        <div class="quick-actions-section">
            <h3>Quick Actions</h3>
            <div class="quick-actions-grid">
                <a href="admin-pending.jsp" class="action-btn action-pending">Review Registrations</a>
                <a href="admin-users.jsp" class="action-btn action-users">Edit User Profiles</a>
                <a href="courses.jsp" class="action-btn action-courses">Manage Courses</a>
                <a href="reports.jsp" class="action-btn action-reports">View Reports</a>
            </div>
        </div>

        <div class="system-info-box">
            <h3>System Information</h3>
            <div class="system-info-grid">
                <div><strong>Email:</strong> <%= session.getAttribute("userEmail") %></div>
                <div><strong>Role:</strong> Administrator</div>
                <div><strong>Database:</strong> student_info_system</div>
                <div><strong>Server:</strong> Apache Tomcat</div>
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
