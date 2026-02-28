<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null || !"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    String fullName = "", email = "", phone = "";
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        String sql = "SELECT full_name, email, phone FROM users WHERE user_id = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            fullName = rs.getString("full_name");
            email = rs.getString("email");
            phone = rs.getString("phone");
        }
        
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
    <title>My Profile - SIMS</title>
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
                <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="teacher-profile.jsp" class="nav-link active">Profile</a>
                <a href="teacher-subjects.jsp" class="nav-link">Subjects</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Profile</h2>

        <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 2rem;">
                <div>
                    <h4>📋 Personal Information</h4>
                    <table style="width: 100%; border: none;">
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">Full Name:</td>
                            <td style="padding: 0.5rem; border: none;"><%= fullName %></td>
                        </tr>
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">Email:</td>
                            <td style="padding: 0.5rem; border: none;"><%= email %></td>
                        </tr>
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">Phone:</td>
                            <td style="padding: 0.5rem; border: none;"><%= phone %></td>
                        </tr>
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">User ID:</td>
                            <td style="padding: 0.5rem; border: none;"><%= userId %></td>
                        </tr>
                    </table>
                </div>

                <div>
                    <h4>📊 Professional Status</h4>
                    <table style="width: 100%; border: none;">
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">Employment Status:</td>
                            <td style="padding: 0.5rem; border: none;"><span style="background: #d1fae5; color: #065f46; padding: 0.25rem 0.75rem; border-radius: 4px;">Active</span></td>
                        </tr>
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">Department:</td>
                            <td style="padding: 0.5rem; border: none;">Computer Science</td>
                        </tr>
                        <tr>
                            <td style="padding: 0.5rem; text-align: right; font-weight: bold; border: none;">Member Since:</td>
                            <td style="padding: 0.5rem; border: none;">2026</td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>

        <div style="margin-top: 2rem;">
            <a href="teacher-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
