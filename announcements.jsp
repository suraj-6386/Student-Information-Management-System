<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = (Integer) session.getAttribute("userId");
    String userType = (String) session.getAttribute("userType");
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            String visibility = request.getParameter("visibility");
            
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                // Get teacher_id from session
                int posterId = userId;
                
                PreparedStatement ps = conn.prepareStatement("INSERT INTO announcements (posted_by, title, content, visibility_level) VALUES (?, ?, ?, ?)");
                ps.setInt(1, posterId);
                ps.setString(2, title);
                ps.setString(3, content);
                ps.setString(4, visibility);
                ps.executeUpdate();
                ps.close();
                
                message = "Announcement posted successfully!";
                messageType = "success";
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
            <div class="nav-brand"><h1>SIMS</h1><p>Announcements</p></div>
            <div class="nav-links">
                <% if ("admin".equals(userType)) { %>
                    <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <% } else if ("teacher".equals(userType)) { %>
                    <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <% } else { %>
                    <a href="student-dashboard.jsp" class="nav-link">Dashboard</a>
                <% } %>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>📢 Announcements</h2>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>"><%= message %></div>
        <% } %>
        
        <% if ("admin".equals(userType) || "teacher".equals(userType)) { %>
        <div class="form-section">
            <h3>Post New Announcement</h3>
            <form method="POST">
                <input type="hidden" name="action" value="create">
                <div class="form-group">
                    <label>Title</label>
                    <input type="text" name="title" required>
                </div>
                <div class="form-group">
                    <label>Content</label>
                    <textarea name="content" rows="4" required></textarea>
                </div>
                <div class="form-group">
                    <label>Visibility</label>
                    <select name="visibility">
                        <option value="all">All</option>
                        <option value="students">Students Only</option>
                        <option value="teachers">Teachers Only</option>
                        <option value="admin">Admin Only</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary">Post Announcement</button>
            </form>
        </div>
        <% } %>
        
        <h3>Recent Announcements</h3>
        <div class="announcements-list">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                    
                    String sql = "SELECT a.*, t.full_name as poster_name FROM announcements a " +
                                "JOIN teacher t ON a.posted_by = t.teacher_id " +
                                "WHERE a.visibility_level = 'all' OR a.visibility_level = ? " +
                                "ORDER BY a.posted_at DESC";
                    
                    if ("admin".equals(userType)) {
                        sql = "SELECT a.*, t.full_name as poster_name FROM announcements a " +
                              "JOIN teacher t ON a.posted_by = t.teacher_id " +
                              "ORDER BY a.posted_at DESC";
                    }
                    
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    if (!"admin".equals(userType)) {
                        stmt.setString(1, userType + "s");
                    }
                    ResultSet rs = stmt.executeQuery();
                    
                    boolean hasAnnouncements = false;
                    while (rs.next()) {
                        hasAnnouncements = true;
            %>
            <div class="announcement-card">
                <h4><%= rs.getString("title") %></h4>
                <p><%= rs.getString("content") %></p>
                <div class="announcement-meta">
                    Posted by <strong><%= rs.getString("poster_name") %></strong> on <%= rs.getTimestamp("posted_at") %>
                </div>
            </div>
            <% }
                    if (!hasAnnouncements) {
                        out.println("<p>No announcements yet.</p>");
                    }
                    conn.close();
                } catch (Exception e) {
                    out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                }
            %>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>
</body>
</html>
