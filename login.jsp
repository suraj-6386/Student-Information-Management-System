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
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                // Hash password
                MessageDigest md = MessageDigest.getInstance("SHA-256");
                byte[] hashedPassword = md.digest(password.getBytes());
                String hashedPasswordStr = Base64.getEncoder().encodeToString(hashedPassword);
                
                // Query user
                String sql = "SELECT id, full_name, user_type, status FROM users WHERE email = ? AND password = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                stmt.setString(2, hashedPasswordStr);
                
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    String status = rs.getString("status");
                    
                    if ("rejected".equals(status)) {
                        message = "Your registration has been rejected. Please contact admin.";
                        messageType = "danger";
                    } else if ("pending".equals(status)) {
                        message = "Your registration is still pending. Please wait for admin approval.";
                        messageType = "warning";
                    } else if ("approved".equals(status)) {
                        // Set session
                        session.setAttribute("userId", rs.getInt("id"));
                        session.setAttribute("userName", rs.getString("full_name"));
                        session.setAttribute("userType", rs.getString("user_type"));
                        session.setAttribute("userEmail", email);
                        
                        String userType = rs.getString("user_type");
                        
                        // Redirect based on user type
                        if ("admin".equals(userType)) {
                            response.sendRedirect("admin-dashboard.jsp");
                        } else if ("student".equals(userType)) {
                            response.sendRedirect("student-dashboard.jsp");
                        } else if ("teacher".equals(userType)) {
                            response.sendRedirect("teacher-dashboard.jsp");
                        }
                        return;
                    }
                } else {
                    message = "Invalid email or password!";
                    messageType = "danger";
                }
                
                rs.close();
                stmt.close();
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
                    <span class="alert-icon">
                        <% if("success".equals(messageType)) { %>✓<% } else if("danger".equals(messageType)) { %>✕<% } else { %>⚠<% } %>
                    </span>
                    <%= message %>
                </div>
            <% } %>

            <form method="POST" action="login.jsp" class="login-form">
                <div class="form-group">
                    <label for="email">
                        <span class="label-icon">📧</span>
                        <span>Email Address</span>
                    </label>
                    <input type="email" id="email" name="email" placeholder="Enter your registered email" required>
                </div>

                <div class="form-group">
                    <label for="password">
                        <span class="label-icon">🔑</span>
                        <span>Password</span>
                    </label>
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
