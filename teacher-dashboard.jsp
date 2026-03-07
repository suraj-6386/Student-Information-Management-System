<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp"); return;
    }
    int teacherId = (Integer) session.getAttribute("userId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard — SIMS</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
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
                <a href="teacher-dashboard.jsp" class="nav-link active">Dashboard</a>
                <a href="teacher-profile.jsp" class="nav-link">Profile</a>
                <a href="teacher-courses.jsp" class="nav-link">My Courses</a>
                <a href="teacher-students.jsp" class="nav-link">Students</a>
                <a href="teacher-attendance.jsp" class="nav-link">Attendance</a>
                <a href="teacher-marks.jsp" class="nav-link">Marks</a>
                <a href="announcements.jsp" class="nav-link">Announcements</a>
                <a href="logout.jsp" class="nav-link">Sign Out</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">

        <div class="dashboard-header">
            <div class="dashboard-title">
                <h2>Teacher Dashboard</h2>
                <p>Welcome, <strong><%= session.getAttribute("userName") %></strong>
                   &nbsp;·&nbsp; ID: <%= session.getAttribute("userIdCode") %></p>
            </div>
            <div class="user-info">
                <p><strong>Role:</strong> Faculty</p>
                <p><%= session.getAttribute("userEmail") %></p>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="dashboard-card card-sage">
                <h3>Assigned Subjects</h3>
                <div class="stat-number">
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) as cnt FROM subjects WHERE teacher_id = ?");
                            ps.setInt(1, teacherId);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) out.print(rs.getInt("cnt"));
                            rs.close(); ps.close(); conn.close();
                        } catch (Exception e) { out.print("0"); }
                    %>
                </div>
                <div class="stat-label">Subjects currently teaching</div>
            </div>

            <div class="dashboard-card card-charcoal">
                <h3>Total Students</h3>
                <div class="stat-number">
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            PreparedStatement ps = conn.prepareStatement(
                                "SELECT COUNT(DISTINCT se.student_id) as cnt FROM subject_enrollment se " +
                                "JOIN subjects s ON se.subject_id = s.subject_id WHERE s.teacher_id = ? AND se.status = 'active'");
                            ps.setInt(1, teacherId);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) out.print(rs.getInt("cnt"));
                            rs.close(); ps.close(); conn.close();
                        } catch (Exception e) { out.print("0"); }
                    %>
                </div>
                <div class="stat-label">Students in your classes</div>
            </div>

            <div class="dashboard-card card-warm">
                <h3>Mark Attendance</h3>
                <div class="stat-number" style="font-size:2rem; line-height:2.4rem;">→</div>
                <div class="stat-label">Record for today</div>
                <a href="teacher-attendance.jsp" class="btn btn-sage btn-full mt-2">Open Attendance →</a>
            </div>
        </div>

        <h3 class="section-title">My Assigned Subjects</h3>
        <div class="courses-grid">
        <%
            boolean hasCourses = false;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                String courseSQL = "SELECT s.subject_id, s.subject_code, s.subject_name, s.credits, s.semester, " +
                                   "c.course_name, COUNT(DISTINCT se.student_id) as student_count " +
                                   "FROM subjects s " +
                                   "JOIN courses c ON s.course_id = c.course_id " +
                                   "LEFT JOIN subject_enrollment se ON s.subject_id = se.subject_id AND se.status = 'active' " +
                                   "WHERE s.teacher_id = ? GROUP BY s.subject_id ORDER BY c.course_name, s.semester";
                PreparedStatement courseStmt = conn.prepareStatement(courseSQL);
                courseStmt.setInt(1, teacherId);
                ResultSet courseRS = courseStmt.executeQuery();
                while (courseRS.next()) {
                    hasCourses = true;
        %>
            <div class="course-card">
                <div class="course-code"><%= courseRS.getString("subject_code") %></div>
                <div class="course-name"><%= courseRS.getString("subject_name") %></div>
                <div class="course-meta">
                    <strong>Course:</strong> <%= courseRS.getString("course_name") %> &nbsp;·&nbsp;
                    <strong>Sem:</strong> <%= courseRS.getInt("semester") %> &nbsp;·&nbsp;
                    <strong>Credits:</strong> <%= courseRS.getInt("credits") %> &nbsp;·&nbsp;
                    <strong>Students:</strong> <%= courseRS.getInt("student_count") %>
                </div>
            </div>
        <%
                }
                if (!hasCourses) {
        %>
            <div class="empty-state"><p>No subjects assigned yet. Contact your administrator.</p></div>
        <%
                }
                courseRS.close(); courseStmt.close(); conn.close();
            } catch (Exception e) {
        %>
            <div class="empty-state" style="color:var(--danger)">Error loading subjects: <%= e.getMessage() %></div>
        <% } %>
        </div>

        <h3 class="section-title">My Students</h3>
        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                String studentSQL = "SELECT DISTINCT st.student_id, st.full_name, st.email, st.roll_number, c.course_name " +
                                   "FROM student st " +
                                   "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                                   "JOIN subjects s ON se.subject_id = s.subject_id " +
                                   "JOIN courses c ON s.course_id = c.course_id " +
                                   "WHERE s.teacher_id = ? AND st.status = 'approved' AND se.status = 'active' ORDER BY st.full_name";
                PreparedStatement studentStmt = conn.prepareStatement(studentSQL);
                studentStmt.setInt(1, teacherId);
                ResultSet studentRS = studentStmt.executeQuery();
                boolean hasStudents = false;
        %>
        <div class="table-container">
        <table class="students-table">
            <thead>
                <tr>
                    <th>Roll No.</th>
                    <th>Student Name</th>
                    <th>Email</th>
                    <th>Course</th>
                </tr>
            </thead>
            <tbody>
        <%
                while (studentRS.next()) {
                    hasStudents = true;
        %>
                <tr>
                    <td><%= studentRS.getString("roll_number") != null ? studentRS.getString("roll_number") : "N/A" %></td>
                    <td><%= studentRS.getString("full_name") %></td>
                    <td><%= studentRS.getString("email") %></td>
                    <td><%= studentRS.getString("course_name") %></td>
                </tr>
        <%
                }
                if (!hasStudents) {
        %>
                <tr><td colspan="4" style="text-align:center; padding:2rem; color:var(--warm-gray-light)">No students enrolled in your subjects yet.</td></tr>
        <%      }
                studentRS.close(); studentStmt.close(); conn.close();
            } catch (Exception e) { %>
                <tr><td colspan="4" style="color:var(--danger)">Error loading students: <%= e.getMessage() %></td></tr>
        <% } %>
            </tbody>
        </table>
        </div>

    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
            <p>&copy; SURAJ GUPTA | MCA</p>
        </div>
    </footer>

</body>
</html>
