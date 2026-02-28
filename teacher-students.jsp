<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null || !"teacher".equals(session.getAttribute("userType"))) {
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
    <title>My Students - SIMS</title>
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
                <a href="teacher-students.jsp" class="nav-link active">Students</a>
                <a href="teacher-attendance.jsp" class="nav-link">Attendance</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Students</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Student ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Course</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT DISTINCT u.id, u.full_name, u.email, u.phone, c.course_name, u.status FROM class_teacher ct JOIN users u ON ct.student_id = u.id LEFT JOIN courses c ON ct.course_id = c.course_id WHERE ct.teacher_id = ? AND u.status = 'approved' ORDER BY u.full_name";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='6' style='text-align: center; padding: 2rem;'>No students assigned</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") %></td>
                        <td><%= rs.getString("course_name") != null ? rs.getString("course_name") : "N/A" %></td>
                        <td><span style="background: #d1fae5; color: #065f46; padding: 0.25rem 0.75rem; border-radius: 4px;">Active</span></td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
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
