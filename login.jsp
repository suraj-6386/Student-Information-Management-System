<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.Base64" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        if (email != null && password != null && !email.isEmpty() && !password.isEmpty()) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system?useSSL=false&serverTimezone=UTC",
                    "root",
                    "15056324"
                );
                
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));
                String hashedPasswordStr = Base64.getEncoder().encodeToString(hashedPassword);
                
                PreparedStatement adminStmt = conn.prepareStatement(
                    "SELECT admin_id, full_name FROM admin WHERE email = ? AND password_hash = ?");
                adminStmt.setString(1, email);
                adminStmt.setString(2, hashedPasswordStr);
                ResultSet adminRS = adminStmt.executeQuery();
                
                if (adminRS.next()) {
                    session.setAttribute("userId", adminRS.getInt("admin_id"));
                    session.setAttribute("userName", adminRS.getString("full_name"));
                    session.setAttribute("userType", "admin");
                    session.setAttribute("userEmail", email);
                    response.sendRedirect("admin-dashboard.jsp");
                    adminRS.close(); adminStmt.close(); conn.close();
                    return;
                }
                adminRS.close(); adminStmt.close();
                
                PreparedStatement studentStmt = conn.prepareStatement(
                    "SELECT student_id, user_id, full_name, status FROM student WHERE email = ? AND password_hash = ?");
                studentStmt.setString(1, email);
                studentStmt.setString(2, hashedPasswordStr);
                ResultSet studentRS = studentStmt.executeQuery();
                
                if (studentRS.next()) {
                    String status = studentRS.getString("status");
                    if ("rejected".equals(status)) {
                        message = "Your registration has been rejected. Please contact admin.";
                        messageType = "danger";
                    } else if ("active".equals(status) || "pending".equals(status) || "approved".equals(status)) {
                        session.setAttribute("userId", studentRS.getInt("student_id"));
                        session.setAttribute("userIdCode", studentRS.getString("user_id"));
                        session.setAttribute("userName", studentRS.getString("full_name"));
                        session.setAttribute("userType", "student");
                        session.setAttribute("userEmail", email);
                        response.sendRedirect("student-dashboard.jsp");
                        studentRS.close(); studentStmt.close(); conn.close();
                        return;
                    }
                }
                studentRS.close(); studentStmt.close();
                
                PreparedStatement teacherStmt = conn.prepareStatement(
                    "SELECT teacher_id, user_id, full_name, status FROM teacher WHERE email = ? AND password_hash = ?");
                teacherStmt.setString(1, email);
                teacherStmt.setString(2, hashedPasswordStr);
                ResultSet teacherRS = teacherStmt.executeQuery();
                
                if (teacherRS.next()) {
                    String status = teacherRS.getString("status");
                    if ("rejected".equals(status)) {
                        message = "Your registration has been rejected. Please contact admin.";
                        messageType = "danger";
                    } else if ("active".equals(status) || "pending".equals(status) || "approved".equals(status)) {
                        session.setAttribute("userId", teacherRS.getInt("teacher_id"));
                        session.setAttribute("userIdCode", teacherRS.getString("user_id"));
                        session.setAttribute("userName", teacherRS.getString("full_name"));
                        session.setAttribute("userType", "teacher");
                        session.setAttribute("userEmail", email);
                        response.sendRedirect("teacher-dashboard.jsp");
                        teacherRS.close(); teacherStmt.close(); conn.close();
                        return;
                    }
                }
                teacherRS.close(); teacherStmt.close();
                
                message = "Invalid email or password. Please try again.";
                messageType = "danger";
                conn.close();
            } catch (Exception e) {
                message = "Sign-in error: " + e.getMessage();
                messageType = "danger";
            }
        } else {
            message = "Please enter your email and password.";
            messageType = "danger";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — SIMS</title>
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
                <p>DY Patil School of Science &amp; Technology</p>
            </div>
            <div class="nav-links">
                <a href="index.html" class="nav-link">Home</a>
                <a href="registration.jsp" class="nav-link">Register</a>
            </div>
        </div>
    </nav>

    <div class="login-page-wrap">
        <div class="login-container">

            <div class="login-card">
                <div class="login-header">
                    <h2>Welcome back.</h2>
                    <p>Sign in to access your SIMS account</p>
                </div>

                <% if (!message.isEmpty()) { %>
                    <div class="alert alert-<%= messageType %>">
                        <span class="alert-icon">!</span><%= message %>
                    </div>
                <% } %>

                <form method="POST" action="login.jsp" class="login-form">
                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" placeholder="you@institution.edu" required>
                    </div>
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required>
                    </div>
                    <button type="submit" class="btn-login">Sign In →</button>
                </form>

                <div class="login-divider"><span>New to SIMS?</span></div>

                <p class="login-footer">
                    <a href="registration.jsp" class="link-register">Create an account to get started</a>
                </p>
            </div>

            <div class="login-info">
                <p class="login-info-heading">Three portals. One platform.</p>
                <p class="login-info-sub">Use the same sign-in form — SIMS automatically routes you to the correct dashboard based on your credentials.</p>

                <div class="info-card">
                    <h3>👨‍🎓 Students</h3>
                    <p>Track attendance, view grades, monitor academic progress, and stay updated with course announcements.</p>
                </div>
                <div class="info-card">
                    <h3>👨‍🏫 Faculty</h3>
                    <p>Manage classes, mark attendance, enter grades, and communicate with enrolled students.</p>
                </div>
                <div class="info-card">
                    <h3>👨‍💼 Administration</h3>
                    <p>Oversee all system operations, manage user approvals, and generate institutional reports.</p>
                </div>
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
