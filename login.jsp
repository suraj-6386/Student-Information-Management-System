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
                
                // Hash password using SHA-256
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));
                String hashedPasswordStr = Base64.getEncoder().encodeToString(hashedPassword);
                
                // Check admin first (by email)
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
                    adminRS.close();
                    adminStmt.close();
                    conn.close();
                    return;
                }
                adminRS.close();
                adminStmt.close();
                
                // Check student
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
                        studentRS.close();
                        studentStmt.close();
                        conn.close();
                        return;
                    }
                }
                studentRS.close();
                studentStmt.close();
                
                // Check teacher
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
                        teacherRS.close();
                        teacherStmt.close();
                        conn.close();
                        return;
                    }
                }
                teacherRS.close();
                teacherStmt.close();
                
                // If we get here, login failed
                message = "Invalid email/username or password!";
                messageType = "danger";
                
                conn.close();
            } catch (Exception e) {
                message = "Error during login: " + e.getMessage();
                messageType = "danger";
            }
        } else {
            message = "Please enter email and password!";
            messageType = "danger";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>DY Patil School of Science and Technology, Pune</p>
            </div>
            <div class="nav-links">
                <a href="index.html" class="nav-link">Home</a>
                <a href="registration.jsp" class="nav-link">Register</a>
            </div>
        </div>
    </nav>

    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <h2>User Login</h2>
                <p>Access your SIMS account</p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>

            <form method="POST" action="login.jsp" class="login-form">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="Enter your email address" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="Enter your password" required>
                </div>

                <button type="submit" class="btn btn-primary btn-login">Sign In</button>
            </form>

            <div class="login-divider">
                <span>New to SIMS?</span>
            </div>

            <p class="login-footer">
                <a href="registration.jsp" class="link-register">Create an account to get started</a>
            </p>
        </div>

        <div class="login-info">
            <div class="info-card">
                <h3>Students</h3>
                <p>Track your attendance, view grades, and monitor your academic progress in real-time.</p>
            </div>
            <div class="info-card">
                <h3>Faculty</h3>
                <p>Manage classes, record attendance, and enter student grades efficiently through the dashboard.</p>
            </div>
            <div class="info-card">
                <h3>Administration</h3>
                <p>Oversee all system operations, manage users, and generate comprehensive academic reports.</p>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-content">
            <div class="footer-section">
                <h4>DY Patil School of Science and Technology</h4>
                <p>Dedicated to excellence in science and technology education.</p>
            </div>
            <div class="footer-section">
                <h4>Support</h4>
                <p>Email: support@dypatil-sims.edu</p>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2026 DY Patil School of Science and Technology, Pune. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
