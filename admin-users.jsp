<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int adminId = (Integer) session.getAttribute("userId");
    String message = "";
    String messageType = "";
    
    // Handle approve/reject actions
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");
        String userType = request.getParameter("userType");
        
        if (action != null && userIdStr != null && userType != null) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                int userId = Integer.parseInt(userIdStr);
                String newStatus = "approve".equals(action) ? "active" : "rejected";
                
                if ("student".equals(userType)) {
                    PreparedStatement ps = conn.prepareStatement("UPDATE student SET status = ? WHERE student_id = ?");
                    ps.setString(1, newStatus);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                    ps.close();
                } else if ("teacher".equals(userType)) {
                    PreparedStatement ps = conn.prepareStatement("UPDATE teacher SET status = ? WHERE teacher_id = ?");
                    ps.setString(1, newStatus);
                    ps.setInt(2, userId);
                    ps.executeUpdate();
                    ps.close();
                }
                
                message = "User " + newStatus + " successfully!";
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
    <title>Manage Users - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand"><h1>SIMS</h1><p>Admin Portal</p></div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="admin-users.jsp" class="nav-link active">Users</a>
                <a href="courses.jsp" class="nav-link">Courses</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>Manage Users</h2>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>"><%= message %></div>
        <% } %>
        
        <h3>Pending Approvals</h3>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            // Get pending students
                            PreparedStatement ps = conn.prepareStatement("SELECT student_id as id, full_name, email, 'student' as user_type, status FROM student WHERE status = 'pending'");
                            ResultSet rs = ps.executeQuery();
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("user_type") %></td>
                        <td><span class="badge badge-warning">Pending</span></td>
                        <td>
                            <form method="POST" style="display:inline;">
                                <input type="hidden" name="userId" value="<%= rs.getInt("id") %>">
                                <input type="hidden" name="userType" value="student">
                                <button type="submit" name="action" value="approve" class="btn btn-success btn-small">Approve</button>
                                <button type="submit" name="action" value="reject" class="btn btn-danger btn-small">Reject</button>
                            </form>
                        </td>
                    </tr>
                    <% }
                            rs.close();
                            
                            // Get pending teachers
                            ps = conn.prepareStatement("SELECT teacher_id as id, full_name, email, 'teacher' as user_type, status FROM teacher WHERE status = 'pending'");
                            rs = ps.executeQuery();
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("user_type") %></td>
                        <td><span class="badge badge-warning">Pending</span></td>
                        <td>
                            <form method="POST" style="display:inline;">
                                <input type="hidden" name="userId" value="<%= rs.getInt("id") %>">
                                <input type="hidden" name="userType" value="teacher">
                                <button type="submit" name="action" value="approve" class="btn btn-success btn-small">Approve</button>
                                <button type="submit" name="action" value="reject" class="btn btn-danger btn-small">Reject</button>
                            </form>
                        </td>
                    </tr>
                    <% }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <h3 style="margin-top:2rem;">All Approved Users</h3>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Type</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT student_id as id, full_name, email, 'student' as user_type, status FROM student WHERE status = 'active' UNION ALL SELECT teacher_id, full_name, email, 'teacher', status FROM teacher WHERE status = 'active' ORDER BY user_type, id");
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("user_type") %></td>
                        <td><span class="badge badge-success"><%= rs.getString("status") %></span></td>
                    </tr>
                    <% }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>
</body>
</html>
