<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    int adminId = (Integer) session.getAttribute("userId");
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            if ("addCourse".equals(action)) {
                String courseCode = request.getParameter("courseCode");
                String courseName = request.getParameter("courseName");
                String duration = request.getParameter("duration");
                String semesters = request.getParameter("semesters");
                
                PreparedStatement checkStmt = conn.prepareStatement("SELECT course_id FROM courses WHERE course_code = ?");
                checkStmt.setString(1, courseCode);
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    message = "Course code already exists!";
                    messageType = "danger";
                } else {
                    rs.close();
                    checkStmt.close();
                    
                    PreparedStatement ps = conn.prepareStatement("INSERT INTO courses (course_code, course_name, duration_years, total_semesters) VALUES (?, ?, ?, ?)");
                    ps.setString(1, courseCode);
                    ps.setString(2, courseName);
                    ps.setInt(3, Integer.parseInt(duration));
                    ps.setInt(4, Integer.parseInt(semesters));
                    ps.executeUpdate();
                    ps.close();
                    
                    message = "Course added successfully!";
                    messageType = "success";
                }
            } else if ("addSubject".equals(action)) {
                String subjectCode = request.getParameter("subjectCode");
                String subjectName = request.getParameter("subjectName");
                String courseId = request.getParameter("courseId");
                String semester = request.getParameter("semester");
                String credits = request.getParameter("credits");
                String teacherId = request.getParameter("teacherId");
                
                PreparedStatement ps = conn.prepareStatement("INSERT INTO subjects (subject_code, subject_name, course_id, semester, credits, teacher_id) VALUES (?, ?, ?, ?, ?, ?)");
                ps.setString(1, subjectCode);
                ps.setString(2, subjectName);
                ps.setInt(3, Integer.parseInt(courseId));
                ps.setInt(4, Integer.parseInt(semester));
                ps.setInt(5, Integer.parseInt(credits));
                if (teacherId != null && !teacherId.isEmpty() && !teacherId.equals("")) {
                    ps.setInt(6, Integer.parseInt(teacherId));
                } else {
                    ps.setNull(6, java.sql.Types.INTEGER);
                }
                ps.executeUpdate();
                ps.close();
                
                message = "Subject added successfully!";
                messageType = "success";
            }
            
            conn.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "danger";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Courses & Subjects - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand"><h1>SIMS</h1><p>Admin Portal</p></div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="courses.jsp" class="nav-link active">Courses</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <h2>Manage Courses & Subjects</h2>
        
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>"><%= message %></div>
        <% } %>
        
        <!-- Add Course Form -->
        <div class="form-section">
            <h3>Add New Course</h3>
            <form method="POST">
                <input type="hidden" name="action" value="addCourse">
                <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                    <div class="form-group">
                        <label>Course Code *</label>
                        <input type="text" name="courseCode" required placeholder="e.g., BTech-CS">
                    </div>
                    <div class="form-group">
                        <label>Course Name *</label>
                        <input type="text" name="courseName" required placeholder="e.g., B.Tech in Computer Science">
                    </div>
                    <div class="form-group">
                        <label>Duration (Years)</label>
                        <input type="number" name="duration" value="4" min="1" max="6">
                    </div>
                    <div class="form-group">
                        <label>Total Semesters</label>
                        <input type="number" name="semesters" value="8" min="2" max="12">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Add Course</button>
            </form>
        </div>
        
        <!-- Add Subject Form -->
        <div class="form-section">
            <h3>Add New Subject</h3>
            <form method="POST">
                <input type="hidden" name="action" value="addSubject">
                <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                    <div class="form-group">
                        <label>Subject Code *</label>
                        <input type="text" name="subjectCode" required>
                    </div>
                    <div class="form-group">
                        <label>Subject Name *</label>
                        <input type="text" name="subjectName" required>
                    </div>
                    <div class="form-group">
                        <label>Course *</label>
                        <select name="courseId" required>
                            <option value="">-- Select Course --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery("SELECT course_id, course_name FROM courses ORDER BY course_name");
                                    while (rs.next()) {
                            %>
                            <option value="<%= rs.getInt("course_id") %>"><%= rs.getString("course_name") %></option>
                            <% }
                                    conn.close();
                                } catch (Exception e) {}
                            %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Semester *</label>
                        <input type="number" name="semester" required min="1" max="8" value="1">
                    </div>
                    <div class="form-group">
                        <label>Credits</label>
                        <input type="number" name="credits" value="4" min="1" max="10">
                    </div>
                    <div class="form-group">
                        <label>Assign Teacher (Optional)</label>
                        <select name="teacherId">
                            <option value="">-- No Teacher --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    PreparedStatement ps = conn.prepareStatement("SELECT teacher_id, full_name FROM teacher WHERE status = 'active' ORDER BY full_name");
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                            %>
                            <option value="<%= rs.getInt("teacher_id") %>"><%= rs.getString("full_name") %></option>
                            <% }
                                    conn.close();
                                } catch (Exception e) {}
                            %>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary">Add Subject</button>
            </form>
        </div>
        
        <!-- List Courses -->
        <h3>All Courses</h3>
        <div class="table-container">
            <table>
                <thead>
                    <tr><th>Code</th><th>Name</th><th>Duration</th><th>Semesters</th></tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT * FROM courses ORDER BY course_name");
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("course_code") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td><%= rs.getInt("duration_years") %> years</td>
                        <td><%= rs.getInt("total_semesters") %></td>
                    </tr>
                    <% }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='4' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>
</body>
</html>
