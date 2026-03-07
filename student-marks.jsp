<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"student".equals(session.getAttribute("userType"))) {
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
        <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand"><h1>SIMS</h1><p>Student Portal</p></div>
            <div class="nav-links">
                <a href="student-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="student-courses.jsp" class="nav-link">Courses</a>
                <a href="student-attendance.jsp" class="nav-link">Attendance</a>
                <a href="student-marks.jsp" class="nav-link active">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>📊 My Marks</h2>
        
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Internal 1</th>
                        <th>Internal 2</th>
                        <th>External</th>
                        <th>Total</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT s.subject_name, m.internal1_marks, m.internal2_marks, m.external_marks, m.total_marks, m.grade " +
                                        "FROM marks m " +
                                        "JOIN subjects s ON m.subject_id = s.subject_id " +
                                        "WHERE m.student_id = ?";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='6' style='text-align:center;'>No marks yet</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("subject_name") %></td>
                        <td><%= rs.getInt("internal1_marks") %>/20</td>
                        <td><%= rs.getInt("internal2_marks") %>/20</td>
                        <td><%= rs.getInt("external_marks") %>/60</td>
                        <td><%= rs.getInt("total_marks") %>/100</td>
                        <td><strong><%= rs.getString("grade") %></strong></td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='6' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <div style="margin-top:2rem;">
            <a href="student-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
            <p>&copy; SURAJ GUPTA | MCA</p></div>
    </footer>
</body>
</html>


