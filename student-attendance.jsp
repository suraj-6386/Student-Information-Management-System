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
    <title>My Attendance - SIMS</title>
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
                <a href="student-attendance.jsp" class="nav-link active">Attendance</a>
                <a href="student-marks.jsp" class="nav-link">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Attendance Record</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Course ID</th>
                        <th>Course Name</th>
                        <th>Classes Attended</th>
                        <th>Total Classes</th>
                        <th>Attendance %</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT a.course_id, c.course_name, COUNT(CASE WHEN a.is_present = 1 THEN 1 END) as attended, COUNT(*) as total FROM attendance a JOIN courses c ON a.course_id = c.course_id WHERE a.student_id = ? GROUP BY a.course_id";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='6' style='text-align: center; padding: 2rem;'>No attendance records</td></tr>");
                            }
                            
                            while (rs.next()) {
                                int attended = rs.getInt("attended");
                                int total = rs.getInt("total");
                                int percentage = total > 0 ? (attended * 100) / total : 0;
                    %>
                    <tr>
                        <td><%= rs.getInt("course_id") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= attended %></td>
                        <td><%= total %></td>
                        <td><strong><%= percentage %>%</strong></td>
                        <td>
                            <% if (percentage >= 75) { %>
                                <span style="background: #d1fae5; color: #065f46; padding: 0.25rem 0.75rem; border-radius: 4px;">Good</span>
                            <% } else if (percentage >= 60) { %>
                                <span style="background: #fef3c7; color: #78350f; padding: 0.25rem 0.75rem; border-radius: 4px;">Average</span>
                            <% } else { %>
                                <span style="background: #fee2e2; color: #7f1d1d; padding: 0.25rem 0.75rem; border-radius: 4px;">Low</span>
                            <% } %>
                        </td>
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
