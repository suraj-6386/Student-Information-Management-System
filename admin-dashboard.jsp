<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Session Check - Fixed
    if (session == null || session.isNew() || 
        session.getAttribute("userId") == null || 
        session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int totalUsers = 0;
    int totalStudents = 0;
    int totalTeachers = 0;
    int pendingApprovals = 0;
    int approvedUsers = 0;
    int totalCourses = 0;
    int assignedCourses = 0;
    int totalEnrollments = 0;
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        Statement stmt = conn.createStatement();
        
        // Total users by type
        ResultSet rs = stmt.executeQuery("SELECT (SELECT COUNT(*) FROM student) + (SELECT COUNT(*) FROM teacher) as count");
        if (rs.next()) totalUsers = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM student WHERE status = 'active'");
        if (rs.next()) totalStudents = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM teacher WHERE status = 'active'");
        if (rs.next()) totalTeachers = rs.getInt("count");
        
        // Pending approvals
        rs = stmt.executeQuery("SELECT (SELECT COUNT(*) FROM student WHERE status = 'pending') + (SELECT COUNT(*) FROM teacher WHERE status = 'pending') as count");
        if (rs.next()) pendingApprovals = rs.getInt("count");
        
        // Approved users
        rs = stmt.executeQuery("SELECT (SELECT COUNT(*) FROM student WHERE status = 'active') + (SELECT COUNT(*) FROM teacher WHERE status = 'active') as count");
        if (rs.next()) approvedUsers = rs.getInt("count");
        
        // Course statistics
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM courses");
        if (rs.next()) totalCourses = rs.getInt("count");
        
        rs = stmt.executeQuery("SELECT COUNT(*) as count FROM subjects");
        if (rs.next()) assignedCourses = rs.getInt("count");
        
        // Enrollment statistics
        rs = stmt.executeQuery("SELECT COUNT(DISTINCT student_id) as count FROM subject_enrollment");
        if (rs.next()) totalEnrollments = rs.getInt("count");
        
        conn.close();
    } catch (Exception e) {
        // Error handling
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
            margin-bottom: 2rem;
        }
        
        .dashboard-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-left: 5px solid #3498db;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .dashboard-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .dashboard-card h3 {
            margin: 0 0 1rem 0;
            color: #2c3e50;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #3498db;
            margin: 0.5rem 0;
        }
        
        .stat-label {
            color: #7f8c8d;
            font-size: 0.85rem;
            margin-bottom: 1rem;
        }
        
        .dashboard-card.blue {
            border-left-color: #3498db;
        }
        
        .dashboard-card.green {
            border-left-color: #27ae60;
        }
        
        .dashboard-card.green .stat-number {
            color: #27ae60;
        }
        
        .dashboard-card.orange {
            border-left-color: #f39c12;
        }
        
        .dashboard-card.orange .stat-number {
            color: #f39c12;
        }
        
        .dashboard-card.purple {
            border-left-color: #9b59b6;
        }
        
        .dashboard-card.purple .stat-number {
            color: #9b59b6;
        }
        
        .dashboard-card.red {
            border-left-color: #e74c3c;
        }
        
        .dashboard-card.red .stat-number {
            color: #e74c3c;
        }
        
        .quick-actions-section {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-top: 2rem;
        }
        
        .quick-actions-section h3 {
            margin-top: 0;
            margin-bottom: 1.5rem;
        }
        
        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        
        .action-btn {
            padding: 1rem;
            border-radius: 6px;
            text-align: center;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.2s;
            display: block;
            color: white;
            font-size: 0.95rem;
        }
        
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        
        .action-pending {
            background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
        }
        
        .action-users {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
        }
        
        .action-courses {
            background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
        }
        
        .action-reports {
            background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%);
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS - Admin Panel</h1>
                <p>Dashboard</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link active">Dashboard</a>
                <a href="admin-pending.jsp" class="nav-link">Approvals</a>
                <a href="admin-users.jsp" class="nav-link">Users</a>
                <a href="courses.jsp" class="nav-link">Courses</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="reports.jsp" class="nav-link">Reports</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header" style="margin-bottom: 2rem;">
            <h2>👨‍💼 Admin Dashboard</h2>
            <p>Welcome back, <strong><%= session.getAttribute("userName") %></strong></p>
        </div>

        <!-- Primary Statistics -->
        <div class="dashboard-grid">
            <div class="dashboard-card red">
                <h3>⏳ Pending Approvals</h3>
                <div class="stat-number"><%= pendingApprovals %></div>
                <div class="stat-label">Awaiting review</div>
                <a href="admin-pending.jsp" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Review Now →</a>
            </div>

            <div class="dashboard-card blue">
                <h3>👥 Total Users</h3>
                <div class="stat-number"><%= totalUsers %></div>
                <div class="stat-label">Active in system</div>
                <a href="admin-users.jsp" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">View All →</a>
            </div>

            <div class="dashboard-card green">
                <h3>📚 Total Courses</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label"><%= assignedCourses %> with teachers assigned</div>
                <a href="courses.jsp" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Manage →</a>
            </div>

            <div class="dashboard-card purple">
                <h3>📝 Total Enrollments</h3>
                <div class="stat-number"><%= totalEnrollments %></div>
                <div class="stat-label">Course registrations</div>
                <a href="reports.jsp" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">View →</a>
            </div>
        </div>

        <!-- Secondary Statistics -->
        <div style="margin-top: 2rem; margin-bottom: 2rem;">
            <h3 style="margin-bottom: 1rem;">User Breakdown</h3>
            <div class="dashboard-grid">
                <div class="dashboard-card" style="border-left-color: #3498db;">
                    <h3>✓ Approved Users</h3>
                    <div class="stat-number" style="color: #27ae60;"><%= approvedUsers %></div>
                    <div class="stat-label">Active accounts</div>
                </div>

                <div class="dashboard-card" style="border-left-color: #2c3e50;">
                    <h3>👨‍🎓 Total Students</h3>
                    <div class="stat-number" style="color: #3498db;"><%= totalStudents %></div>
                    <div class="stat-label">Enrolled in courses</div>
                </div>

                <div class="dashboard-card" style="border-left-color: #f39c12;">
                    <h3>👨‍🏫 Total Teachers</h3>
                    <div class="stat-number" style="color: #f39c12;"><%= totalTeachers %></div>
                    <div class="stat-label">Teaching courses</div>
                </div>

                <div class="dashboard-card" style="border-left-color: #9b59b6;">
                    <h3>🎓 Assigned Teachers</h3>
                    <div class="stat-number" style="color: #9b59b6;"><%= assignedCourses %> courses</div>
                    <div class="stat-label">Course-Teacher links</div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions-section">
            <h3>⚡ Quick Actions</h3>
            <div class="quick-actions-grid">
                <a href="admin-pending.jsp" class="action-btn action-pending">
                    📋 Review Registrations
                </a>
                <a href="admin-users.jsp" class="action-btn action-users">
                    👥 Edit User Profiles
                </a>
                <a href="courses.jsp" class="action-btn action-courses">
                    📚 Assign Teachers
                </a>
                <a href="reports.jsp" class="action-btn action-reports">
                    📊 View Reports
                </a>
            </div>
        </div>

        <!-- System Information -->
        <div style="background: #f8f9fa; padding: 1.5rem; border-radius: 8px; margin-top: 2rem;">
            <h3 style="margin-top: 0;">System Information</h3>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; color: #7f8c8d; font-size: 0.9rem;">
                <div>
                    <strong>Email:</strong> <%= session.getAttribute("userEmail") %>
                </div>
                <div>
                    <strong>Role:</strong> Administrator
                </div>
                <div>
                    <strong>Database:</strong> student_info_system
                </div>
                <div>
                    <strong>Server:</strong> Apache Tomcat
                </div>
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
