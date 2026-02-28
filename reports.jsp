<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Reports - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Reports</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="reports.jsp" class="nav-link active">Reports</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>System Reports</h2>

        <!-- Summary Statistics -->
        <div class="dashboard-grid">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                    
                    // Total Students
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users WHERE user_type = 'student'");
                    int totalStudents = 0;
                    if (rs.next()) totalStudents = rs.getInt("count");
                    
                    // Total Teachers
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM users WHERE user_type = 'teacher'");
                    int totalTeachers = 0;
                    if (rs.next()) totalTeachers = rs.getInt("count");
                    
                    // Total Courses
                    rs = stmt.executeQuery("SELECT COUNT(*) as count FROM courses");
                    int totalCourses = 0;
                    if (rs.next()) totalCourses = rs.getInt("count");
                    
                    // Total Enrollments (subjects)
                    rs = stmt.executeQuery("SELECT COUNT(DISTINCT student_id) as count FROM student_subject_enrollment");
                    int totalEnrollments = 0;
                    if (rs.next()) totalEnrollments = rs.getInt("count");
            %>
            <div class="dashboard-card">
                <h3>Total Students</h3>
                <div class="stat-number"><%= totalStudents %></div>
                <div class="stat-label">Registered Students</div>
            </div>

            <div class="dashboard-card">
                <h3>Total Teachers</h3>
                <div class="stat-number"><%= totalTeachers %></div>
                <div class="stat-label">Active Teachers</div>
            </div>

            <div class="dashboard-card">
                <h3>Total Courses</h3>
                <div class="stat-number"><%= totalCourses %></div>
                <div class="stat-label">Available Courses</div>
            </div>

            <div class="dashboard-card">
                <h3>Total Enrollments</h3>
                <div class="stat-number"><%= totalEnrollments %></div>
                <div class="stat-label">Student Enrollments</div>
            </div>

            <%
                    conn.close();
                } catch (Exception e) {
                    out.println("<div style='color: red;'>Error: " + e.getMessage() + "</div>");
                }
            %>
        </div>

        <!-- Detailed Reports -->
        <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-top: 2rem;">
            <h3>Enrollment by Semester</h3>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Semester</th>
                            <th>Course</th>
                            <th>Enrolled Students</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                
                                String sql = "SELECT s.semester, c.course_name, COUNT(e.student_id) as count " +
                                             "FROM subjects s " +
                                             "JOIN courses c ON s.course_id = c.course_id " +
                                             "LEFT JOIN student_subject_enrollment e ON s.subject_id = e.subject_id " +
                                             "GROUP BY s.subject_id, c.course_name, s.semester " +
                                             "ORDER BY s.semester, c.course_name";
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(sql);
                                
                                while (rs.next()) {
                        %>
                        <tr>
                            <td>Semester <%= rs.getInt("semester") %></td>
                            <td><%= rs.getString("course_name") %></td>
                            <td><%= rs.getInt("count") %> Students</td>
                        </tr>
                        <%
                                }
                                conn.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='3' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
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
