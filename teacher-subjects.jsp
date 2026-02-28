<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int teacherId = (Integer) session.getAttribute("userId");
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
            <div class="nav-brand"><h1>SIMS</h1><p>Teacher Portal</p></div>
            <div class="nav-links">
                <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="teacher-subjects.jsp" class="nav-link active">My Subjects</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>My Subjects</h2>
        
        <div class="form-section">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Subject Code</th>
                        <th>Subject Name</th>
                        <th>Course</th>
                        <th>Semester</th>
                        <th>Credits</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            PreparedStatement stmt = conn.prepareStatement(
                                "SELECT s.*, c.course_name FROM subjects s " +
                                "JOIN courses c ON s.course_id = c.course_id " +
                                "WHERE s.teacher_id = ? ORDER BY s.semester, s.subject_name"
                            );
                            stmt.setInt(1, teacherId);
                            ResultSet rs = stmt.executeQuery();
                            
                            boolean hasSubjects = false;
                            while (rs.next()) {
                                hasSubjects = true;
                    %>
                    <tr>
                        <td><%= rs.getString("subject_code") %></td>
                        <td><%= rs.getString("subject_name") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= rs.getInt("semester") %></td>
                        <td><%= rs.getInt("credits") %></td>
                    </tr>
                    <%
                            }
                            
                            if (!hasSubjects) {
                    %>
                    <tr>
                        <td colspan="5" style="text-align:center;">No subjects assigned yet.</td>
                    </tr>
                    <%
                            }
                            
                            conn.close();
                        } catch (Exception e) {
                    %>
                    <tr>
                        <td colspan="5" style="text-align:center; color:red;">Error: <%= e.getMessage() %></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <div style="margin-top:2rem;">
            <a href="teacher-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>
</body>
</html>
