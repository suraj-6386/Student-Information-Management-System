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
    <title>My Attendance - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand"><h1>SIMS</h1><p>Student Portal</p></div>
            <div class="nav-links">
                <a href="student-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="student-courses.jsp" class="nav-link">Courses</a>
                <a href="student-attendance.jsp" class="nav-link active">Attendance</a>
                <a href="student-marks.jsp" class="nav-link">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>✓ My Attendance</h2>
        
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Subject</th>
                        <th>Total</th>
                        <th>Present</th>
                        <th>Absent</th>
                        <th>Percentage</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT s.subject_name, " +
                                        "COUNT(*) as total, " +
                                        "SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_count, " +
                                        "SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_count, " +
                                        "ROUND(SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as percentage " +
                                        "FROM attendance a " +
                                        "JOIN subjects s ON a.subject_id = s.subject_id " +
                                        "WHERE a.student_id = ? " +
                                        "GROUP BY s.subject_id, s.subject_name";
                            PreparedStatement stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, userId);
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='5' style='text-align:center;'>No attendance records</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("subject_name") %></td>
                        <td><%= rs.getInt("total") %></td>
                        <td><%= rs.getInt("present_count") %></td>
                        <td><%= rs.getInt("absent_count") %></td>
                        <td><%= rs.getDouble("percentage") %>%</td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
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
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>
</body>
</html>
