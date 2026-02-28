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
                        <th>Course ID</th>
                        <th>Course Name</th>
                        <th>Subject</th>
                        <th>Assignment</th>
                        <th>Mid Exam</th>
                        <th>Final Exam</th>
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
                            
                            String sql = "SELECT m.course_id, c.course_code, c.course_name, m.assignment, m.mid_exam, m.final_exam, (m.assignment + m.mid_exam + m.final_exam) as total FROM marks m JOIN courses c ON m.course_id = c.course_id WHERE m.student_id = ?";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='8' style='text-align: center; padding: 2rem;'>No marks recorded yet</td></tr>");
                            }
                            
                            while (rs.next()) {
                                int total = rs.getInt("total");
                                String grade = total >= 80 ? "A" : total >= 70 ? "B" : total >= 60 ? "C" : total >= 50 ? "D" : "F";
                    %>
                    <tr>
                        <td><%= rs.getInt("course_id") %></td>
                        <td><%= rs.getString("course_code") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= rs.getInt("assignment") %></td>
                        <td><%= rs.getInt("mid_exam") %></td>
                        <td><%= rs.getInt("final_exam") %></td>
                        <td><strong><%= total %>/300</strong></td>
                        <td><strong><%= grade %></strong></td>
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
