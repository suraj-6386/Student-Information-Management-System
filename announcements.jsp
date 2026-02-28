<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod()) && "admin".equals(session.getAttribute("userType"))) {
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        
        if (title != null && content != null) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                String sql = "INSERT INTO announcements (title, content, posted_by, posted_date) VALUES (?, ?, ?, NOW())";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, title);
                stmt.setString(2, content);
                stmt.setInt(3, userId);
                
                stmt.executeUpdate();
                message = "Announcement posted successfully!";
                messageType = "success";
                
                stmt.close();
                conn.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "danger";
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Announcements - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Announcements</p>
            </div>
            <div class="nav-links">
                <a href="announcements.jsp" class="nav-link active">Announcements</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>System Announcements</h2>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <% if ("admin".equals(session.getAttribute("userType"))) { %>
            <div class="form-container">
                <h3>Post New Announcement</h3>
                <form method="POST" action="announcements.jsp">
                    <div class="form-group">
                        <label for="title">Title *</label>
                        <input type="text" id="title" name="title" required>
                    </div>

                    <div class="form-group">
                        <label for="content">Content *</label>
                        <textarea id="content" name="content" required></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Post Announcement</button>
                </form>
            </div>
        <% } %>

        <h3 style="margin-top: 2rem;">Recent Announcements</h3>
        <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                    
                    String sql = "SELECT id, title, content, posted_by, posted_date FROM announcements ORDER BY posted_date DESC LIMIT 10";
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(sql);
                    
                    if (!rs.isBeforeFirst()) {
                        out.println("<p style='text-align: center;'>No announcements yet</p>");
                    }
                    
                    while (rs.next()) {
            %>
            <div style="border-bottom: 1px solid #ddd; padding: 1.5rem 0;">
                <h4><%= rs.getString("title") %></h4>
                <p><%= rs.getString("content") %></p>
                <small style="color: #999;">Posted on <%= rs.getString("posted_date") %></small>
            </div>
            <%
                    }
                    conn.close();
                } catch (Exception e) {
                    out.println("<p style='color: red;'>Error loading announcements: " + e.getMessage() + "</p>");
                }
            %>
        </div>

        <div style="margin-top: 2rem;">
            <% if ("admin".equals(session.getAttribute("userType"))) { %>
                <a href="admin-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
            <% } else if ("student".equals(session.getAttribute("userType"))) { %>
                <a href="student-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
            <% } else if ("teacher".equals(session.getAttribute("userType"))) { %>
                <a href="teacher-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
            <% } %>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
