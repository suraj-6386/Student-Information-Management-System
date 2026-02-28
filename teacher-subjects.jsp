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
    <title>My Subjects - SIMS</title>
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
                <a href="teacher-subjects.jsp" class="nav-link active">Subjects</a>
                <a href="teacher-students.jsp" class="nav-link">Students</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Assigned Subjects</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Subject ID</th>
                        <th>Subject Name</th>
                        <th>Subject Code</th>
                        <th>Credits</th>
                        <th>Semester</th>
                        <th>Students</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT st.subject_id, s.subject_code, s.subject_name, s.credits, s.semester, COUNT(e.student_id) as student_count FROM subject_teacher st JOIN subjects s ON st.subject_id = s.subject_id LEFT JOIN enrollments e ON s.subject_id = e.subject_id WHERE st.teacher_id = ? GROUP BY st.subject_id";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='6' style='text-align: center; padding: 2rem;'>No subjects assigned</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("subject_id") %></td>
                        <td><%= rs.getString("subject_name") %></td>
                        <td><%= rs.getString("subject_code") %></td>
                        <td><%= rs.getInt("credits") %></td>
                        <td><%= rs.getInt("semester") %></td>
                        <td><span style="background: #dbeafe; color: #0c2340; padding: 0.25rem 0.75rem; border-radius: 4px;"><%= rs.getInt("student_count") %> Students</span></td>
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
