<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Session check
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String action = request.getParameter("action");
    String userType = request.getParameter("user_type");
    String userId = request.getParameter("user_id");
    String message = "";
    String messageType = "";
    
    if (action != null && userId != null && userType != null) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            String status = "approve".equals(action) ? "active" : "rejected";
            String sql = "";
            PreparedStatement stmt;
            
            if ("student".equals(userType)) {
                sql = "UPDATE student SET status = ? WHERE student_id = ? AND status = 'pending'";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, status);
                stmt.setInt(2, Integer.parseInt(userId));
            } else if ("teacher".equals(userType)) {
                sql = "UPDATE teacher SET status = ? WHERE teacher_id = ? AND status = 'pending'";
                stmt = conn.prepareStatement(sql);
                stmt.setString(1, status);
                stmt.setInt(2, Integer.parseInt(userId));
            } else {
                stmt = null;
            }
            
            if (stmt != null) {
                int rows = stmt.executeUpdate();
                if (rows > 0) {
                    message = "Registration " + ("approve".equals(action) ? "approved" : "rejected") + " successfully!";
                    messageType = "success";
                } else {
                    message = "User not found or already processed!";
                    messageType = "danger";
                }
                stmt.close();
            }
            
            conn.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "danger";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pending Approvals - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Admin Panel</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="admin-pending.jsp" class="nav-link active">Approvals</a>
                <a href="admin-users.jsp" class="nav-link">Users</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>Pending Registration Approvals</h2>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            // Get pending students
                            String sql = "SELECT student_id as id, full_name, email, phone, 'student' as user_type, status FROM student WHERE status = 'pending'";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            boolean hasPending = false;
                            while (rs.next()) {
                                hasPending = true;
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
                        <td>
                            <span style="background: blue; color: white; padding: 0.25rem 0.75rem; border-radius: 4px; text-transform: capitalize;">
                                Student
                            </span>
                        </td>
                        <td>
                            <span style="background: #fef3c7; color: #78350f; padding: 0.25rem 0.75rem; border-radius: 4px;">
                                <%= rs.getString("status") %>
                            </span>
                        </td>
                        <td>
                            <a href="admin-pending.jsp?action=approve&user_type=student&user_id=<%= rs.getInt("id") %>" class="btn btn-success" style="padding: 0.5rem 1rem; font-size: 0.9rem; margin-right: 0.25rem;">Approve</a>
                            <a href="admin-pending.jsp?action=reject&user_type=student&user_id=<%= rs.getInt("id") %>" class="btn btn-danger" style="padding: 0.5rem 1rem; font-size: 0.9rem;">Reject</a>
                        </td>
                    </tr>
                    <%
                            }
                            
                            // Get pending teachers
                            rs = stmt.executeQuery("SELECT teacher_id as id, full_name, email, phone, 'teacher' as user_type, status FROM teacher WHERE status = 'pending'");
                            while (rs.next()) {
                                hasPending = true;
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
                        <td>
                            <span style="background: green; color: white; padding: 0.25rem 0.75rem; border-radius: 4px; text-transform: capitalize;">
                                Teacher
                            </span>
                        </td>
                        <td>
                            <span style="background: #fef3c7; color: #78350f; padding: 0.25rem 0.75rem; border-radius: 4px;">
                                <%= rs.getString("status") %>
                            </span>
                        </td>
                        <td>
                            <a href="admin-pending.jsp?action=approve&user_type=teacher&user_id=<%= rs.getInt("id") %>" class="btn btn-success" style="padding: 0.5rem 1rem; font-size: 0.9rem; margin-right: 0.25rem;">Approve</a>
                            <a href="admin-pending.jsp?action=reject&user_type=teacher&user_id=<%= rs.getInt("id") %>" class="btn btn-danger" style="padding: 0.5rem 1rem; font-size: 0.9rem;">Reject</a>
                        </td>
                    </tr>
                    <%
                            }
                            
                            if (!hasPending) {
                                out.println("<tr><td colspan='7' style='text-align: center; padding: 2rem;'>No pending registrations</td></tr>");
                            }
                            
                            rs.close();
                            stmt.close();
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>

        <div style="margin-top: 2rem;">
            <a href="admin-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
