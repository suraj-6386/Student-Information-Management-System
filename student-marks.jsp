<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null || !"student".equals(session.getAttribute("userType"))) {
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
    <title>My Marks - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Student Portal</p>
            </div>
            <div class="nav-links">
                <a href="student-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="student-marks.jsp" class="nav-link active">Marks</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Results & Marks</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Subject ID</th>
                        <th>Subject Code</th>
                        <th>Subject Name</th>
                        <th>Theory</th>
                        <th>Practical</th>
                        <th>Assignment</th>
                        <th>Total Marks</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT m.subject_id, s.subject_code, s.subject_name, m.theory_marks, m.practical_marks, m.assignment_marks, " +
                                        "(m.theory_marks + m.practical_marks + m.assignment_marks) as total_marks, m.grade " +
                                        "FROM marks m " +
                                        "JOIN subjects s ON m.subject_id = s.subject_id " +
                                        "WHERE m.student_id = ? " +
                                        "ORDER BY m.evaluated_at DESC";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='8' style='text-align: center; padding: 2rem;'>No marks recorded yet</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("subject_id") %></td>
                        <td><%= rs.getString("subject_code") %></td>
                        <td><%= rs.getString("subject_name") %></td>
                        <td><%= rs.getInt("theory_marks") %></td>
                        <td><%= rs.getInt("practical_marks") %></td>
                        <td><%= rs.getInt("assignment_marks") %></td>
                        <td><strong><%= rs.getInt("total_marks") %>/300</strong></td>
                        <td><strong><%= rs.getString("grade") %></strong></td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='8' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>

        <div style="margin-top: 2rem;">
            <a href="student-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
