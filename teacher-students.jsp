<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null || !"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    int teacherId = (Integer) session.getAttribute("userId");
    
    // Get subject filter if provided
    String subjectFilter = request.getParameter("subject_id");
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
                            
                            String sql;
                            PreparedStatement stmt;
                            
                            if (subjectFilter != null && !subjectFilter.isEmpty()) {
                                sql = "SELECT st.student_id, st.full_name, st.email, st.phone, c.course_name, st.status " +
                                      "FROM student st " +
                                      "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                                      "JOIN subjects s ON se.subject_id = s.subject_id " +
                                      "JOIN courses c ON st.course_id = c.course_id " +
                                      "WHERE s.teacher_id = ? AND s.subject_id = ? AND st.status = 'approved' " +
                                      "ORDER BY st.full_name";
                                stmt = conn.prepareStatement(sql);
                                stmt.setInt(1, teacherId);
                                stmt.setInt(2, Integer.parseInt(subjectFilter));
                            } else {
                                sql = "SELECT DISTINCT st.student_id, st.full_name, st.email, st.phone, c.course_name, st.status " +
                                      "FROM student st " +
                                      "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                                      "JOIN subjects s ON se.subject_id = s.subject_id " +
                                      "JOIN courses c ON st.course_id = c.course_id " +
                                      "WHERE s.teacher_id = ? AND st.status = 'approved' " +
                                      "ORDER BY st.full_name";
                                stmt = conn.prepareStatement(sql);
                                stmt.setInt(1, teacherId);
                            }
                            ResultSet rs = stmt.executeQuery();
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='6' style='text-align: center; padding: 2rem;'>No students found</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("student_id") %></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
                        <td><%= rs.getString("course_name") != null ? rs.getString("course_name") : "N/A" %></td>
                        <td><span style="background: #d1fae5; color: #065f46; padding: 0.25rem 0.75rem; border-radius: 4px;">Active</span></td>
                    </tr>
                    <%
                            }
                            rs.close();
                            stmt.close();
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
