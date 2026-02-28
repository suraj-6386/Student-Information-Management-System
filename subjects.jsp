<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String subjectCode = request.getParameter("subject_code");
        String subjectName = request.getParameter("subject_name");
        String credits = request.getParameter("credits");
        String semester = request.getParameter("semester");
        String courseId = request.getParameter("course_id");
        String teacherId = request.getParameter("teacher_id");
        
        if (subjectCode != null && subjectName != null && credits != null && semester != null && courseId != null) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                String sql;
                PreparedStatement stmt;
                
                if (teacherId != null && !teacherId.isEmpty()) {
                    sql = "INSERT INTO subjects (subject_code, subject_name, course_id, credits, semester, teacher_id) VALUES (?, ?, ?, ?, ?, ?)";
                    stmt = conn.prepareStatement(sql);
                    stmt.setInt(6, Integer.parseInt(teacherId));
                } else {
                    sql = "INSERT INTO subjects (subject_code, subject_name, course_id, credits, semester) VALUES (?, ?, ?, ?, ?)";
                    stmt = conn.prepareStatement(sql);
                }
                stmt.setString(1, subjectCode);
                stmt.setString(2, subjectName);
                stmt.setInt(3, Integer.parseInt(courseId));
                stmt.setInt(4, Integer.parseInt(credits));
                stmt.setInt(5, Integer.parseInt(semester));
                
                stmt.executeUpdate();
                message = "Subject created successfully!";
                messageType = "success";
                
                stmt.close();
                conn.close();
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageType = "danger";
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Subjects - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Subject Management</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="subjects.jsp" class="nav-link active">Subjects</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>Manage Subjects</h2>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <div class="form-container">
            <h3>Create New Subject</h3>
            <form method="POST" action="subjects.jsp">
                <div class="form-group">
                    <label for="subject_code">Subject Code *</label>
                    <input type="text" id="subject_code" name="subject_code" required>
                </div>

                <div class="form-group">
                    <label for="subject_name">Subject Name *</label>
                    <input type="text" id="subject_name" name="subject_name" required>
                </div>

                <div class="form-group">
                    <label for="course_id">Course *</label>
                    <select id="course_id" name="course_id" required>
                        <option value="">-- Select Course --</option>
                        <%
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                
                                String sql = "SELECT course_id, course_name FROM courses ORDER BY course_name";
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(sql);
                                
                                while (rs.next()) {
                                    out.println("<option value='" + rs.getInt("course_id") + "'>" + rs.getString("course_name") + "</option>");
                                }
                                
                                rs.close();
                                stmt.close();
                                conn.close();
                            } catch (Exception e) {}
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="teacher_id">Assigned Teacher</label>
                    <select id="teacher_id" name="teacher_id">
                        <option value="">-- Select Teacher (Optional) --</option>
                        <%
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                Connection conn = DriverManager.getConnection(
                                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                
                                String sql = "SELECT teacher_id, full_name FROM teacher WHERE status = 'approved' ORDER BY full_name";
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(sql);
                                
                                while (rs.next()) {
                                    out.println("<option value='" + rs.getInt("teacher_id") + "'>" + rs.getString("full_name") + "</option>");
                                }
                                
                                rs.close();
                                stmt.close();
                                conn.close();
                            } catch (Exception e) {}
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="credits">Credits *</label>
                    <input type="number" id="credits" name="credits" min="1" max="10" required>
                </div>

                <div class="form-group">
                    <label for="semester">Semester *</label>
                    <input type="number" id="semester" name="semester" min="1" max="8" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">Create Subject</button>
            </form>
        </div>

        <h3 style="margin-top: 2rem;">All Subjects</h3>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Subject ID</th>
                        <th>Subject Code</th>
                        <th>Subject Name</th>
                        <th>Course</th>
                        <th>Teacher</th>
                        <th>Credits</th>
                        <th>Semester</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT s.*, c.course_name, t.full_name as teacher_name " +
                                         "FROM subjects s " +
                                         "LEFT JOIN courses c ON s.course_id = c.course_id " +
                                         "LEFT JOIN teacher t ON s.teacher_id = t.teacher_id " +
                                         "ORDER BY s.semester, s.subject_code";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            if (!rs.isBeforeFirst()) {
                                out.println("<tr><td colspan='7' style='text-align: center; padding: 2rem;'>No subjects</td></tr>");
                            }
                            
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getInt("subject_id") %></td>
                        <td><%= rs.getString("subject_code") %></td>
                        <td><%= rs.getString("subject_name") %></td>
                        <td><%= rs.getString("course_name") != null ? rs.getString("course_name") : "N/A" %></td>
                        <td><%= rs.getString("teacher_name") != null ? rs.getString("teacher_name") : "Not Assigned" %></td>
                        <td><%= rs.getInt("credits") %></td>
                        <td>Sem <%= rs.getInt("semester") %></td>
                    </tr>
                    <%
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
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
