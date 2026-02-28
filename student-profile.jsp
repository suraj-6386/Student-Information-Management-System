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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand"><h1>SIMS</h1><p>Student Portal</p></div>
            <div class="nav-links">
                <a href="student-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="student-profile.jsp" class="nav-link active">Profile</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Profile</h2>
        
        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                PreparedStatement stmt = conn.prepareStatement("SELECT s.*, c.course_name FROM student s LEFT JOIN courses c ON s.course_id = c.course_id WHERE s.student_id = ?");
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
        %>
        <div class="form-section">
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
                <div><strong>User ID:</strong> <%= rs.getString("user_id") %></div>
                <div><strong>Full Name:</strong> <%= rs.getString("full_name") %></div>
                <div><strong>Email:</strong> <%= rs.getString("email") %></div>
                <div><strong>Phone:</strong> <%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></div>
                <div><strong>Roll Number:</strong> <%= rs.getString("roll_number") != null ? rs.getString("roll_number") : "N/A" %></div>
                <div><strong>Course:</strong> <%= rs.getString("course_name") != null ? rs.getString("course_name") : "N/A" %></div>
                <div><strong>Semester:</strong> <%= rs.getInt("semester") %></div>
                <div><strong>Parent Name:</strong> <%= rs.getString("parent_name") != null ? rs.getString("parent_name") : "N/A" %></div>
                <div><strong>Parent Contact:</strong> <%= rs.getString("parent_contact") != null ? rs.getString("parent_contact") : "N/A" %></div>
                <div><strong>Status:</strong> <%= rs.getString("status") %></div>
            </div>
        </div>
        <%
                }
                conn.close();
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            }
        %>
        
        <div style="margin-top:2rem;">
            <a href="student-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>
</body>
</html>
