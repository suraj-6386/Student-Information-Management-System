<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Session Check - Fixed
    if (session == null || session.isNew() || 
        session.getAttribute("userId") == null || 
        session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    
    // Handle course creation with teacher assignment
    if ("POST".equalsIgnoreCase(request.getMethod()) && "create".equals(request.getParameter("action"))) {
        try {
            String courseCode = request.getParameter("course_code");
            String courseName = request.getParameter("course_name");
            String credits = request.getParameter("credits");
            String semester = request.getParameter("semester");
            String teacherId = request.getParameter("teacher_id");
            
            if (courseCode != null && courseName != null && credits != null && semester != null) {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                // Check for duplicate course code
                String checkSQL = "SELECT course_id FROM courses WHERE course_code = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkSQL);
                checkStmt.setString(1, courseCode);
                ResultSet checkRS = checkStmt.executeQuery();
                
                if (checkRS.next()) {
                    message = "Error: Course code already exists";
                    messageType = "danger";
                } else {
                    // Insert course
                    String sql = "INSERT INTO courses (course_code, course_name, credits, semester) VALUES (?, ?, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                    stmt.setString(1, courseCode);
                    stmt.setString(2, courseName);
                    stmt.setInt(3, Integer.parseInt(credits));
                    stmt.setInt(4, Integer.parseInt(semester));
                    
                    stmt.executeUpdate();
                    
                    // Get the generated course ID
                    ResultSet generatedKeys = stmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        int courseId = generatedKeys.getInt(1);
                        
                        // Assign teacher if selected
                        if (teacherId != null && !teacherId.isEmpty()) {
                            String assignSQL = "INSERT INTO course_teacher (course_id, teacher_id) VALUES (?, ?)";
                            PreparedStatement assignStmt = conn.prepareStatement(assignSQL);
                            assignStmt.setInt(1, courseId);
                            assignStmt.setInt(2, Integer.parseInt(teacherId));
                            assignStmt.executeUpdate();
                            assignStmt.close();
                        }
                    }
                    
                    message = "✓ Course created successfully!";
                    messageType = "success";
                    stmt.close();
                }
                
                checkRS.close();
                checkStmt.close();
                conn.close();
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "danger";
        }
    }
    
    // Handle teacher assignment change
    if ("POST".equalsIgnoreCase(request.getMethod()) && "assign".equals(request.getParameter("action"))) {
        try {
            int courseId = Integer.parseInt(request.getParameter("course_id"));
            String newTeacherId = request.getParameter("teacher_id");
            
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            if (newTeacherId != null && !newTeacherId.isEmpty()) {
                // Remove existing assignment
                String deleteSQL = "DELETE FROM course_teacher WHERE course_id = ?";
                PreparedStatement deleteStmt = conn.prepareStatement(deleteSQL);
                deleteStmt.setInt(1, courseId);
                deleteStmt.executeUpdate();
                deleteStmt.close();
                
                // Add new assignment
                String insertSQL = "INSERT INTO course_teacher (course_id, teacher_id) VALUES (?, ?)";
                PreparedStatement insertStmt = conn.prepareStatement(insertSQL);
                insertStmt.setInt(1, courseId);
                insertStmt.setInt(2, Integer.parseInt(newTeacherId));
                insertStmt.executeUpdate();
                insertStmt.close();
                
                message = "✓ Teacher assigned to course successfully!";
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
    <title>Manage Courses - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .course-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 5px solid #3498db;
        }
        
        .course-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .course-code {
            font-size: 0.85rem;
            color: #7f8c8d;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 1px;
        }
        
        .course-name {
            font-size: 1.2rem;
            font-weight: bold;
            color: #2c3e50;
            margin: 0.5rem 0;
        }
        
        .course-meta {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin: 1rem 0;
            font-size: 0.9rem;
        }
        
        .meta-item {
            display: flex;
            justify-content: space-between;
        }
        
        .meta-item strong {
            color: #2c3e50;
        }
        
        .teacher-assignment {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 6px;
            margin-top: 1rem;
        }
        
        .teacher-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .teacher-name {
            font-weight: 600;
            color: #2c3e50;
        }
        
        .change-teacher-btn {
            padding: 0.5rem 1rem;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
        }
        
        .change-teacher-btn:hover {
            background: #2980b9;
        }
        
        .teacher-select-form {
            display: none;
            margin-top: 1rem;
            padding: 1rem;
            background: white;
            border-radius: 6px;
        }
        
        .teacher-select-form.active {
            display: block;
        }
        
        .form-row {
            display: flex;
            gap: 1rem;
            align-items: flex-end;
        }
        
        .form-row .form-group {
            flex: 1;
            margin-bottom: 0;
        }
        
        .form-row button {
            padding: 0.5rem 1.5rem;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS - Admin Panel</h1>
                <p>Course Management</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="admin-users.jsp" class="nav-link">Users</a>
                <a href="courses.jsp" class="nav-link active">Courses</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header">
            <h2>📚 Manage Courses & Assign Teachers</h2>
            <p>Create courses and assign teachers</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Create Course Form -->
        <div class="form-container" style="margin-bottom: 2rem;">
            <h3>Create New Course</h3>
            <form method="POST" action="courses.jsp">
                <input type="hidden" name="action" value="create">
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                    <div class="form-group">
                        <label for="course_code">Course Code *</label>
                        <input type="text" id="course_code" name="course_code" placeholder="e.g., CS101" required>
                    </div>

                    <div class="form-group">
                        <label for="semester">Semester *</label>
                        <select id="semester" name="semester" required>
                            <option value="">-- Select Semester --</option>
                            <option value="1">Semester 1</option>
                            <option value="2">Semester 2</option>
                            <option value="3">Semester 3</option>
                            <option value="4">Semester 4</option>
                            <option value="5">Semester 5</option>
                            <option value="6">Semester 6</option>
                            <option value="7">Semester 7</option>
                            <option value="8">Semester 8</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label for="course_name">Course Name *</label>
                    <input type="text" id="course_name" name="course_name" placeholder="e.g., Data Structures" required>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                    <div class="form-group">
                        <label for="credits">Credits *</label>
                        <input type="number" id="credits" name="credits" min="1" max="10" value="3" required>
                    </div>

                    <div class="form-group">
                        <label for="teacher_id">Assign Teacher (Optional)</label>
                        <select id="teacher_id" name="teacher_id">
                            <option value="">-- Select Teacher --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection(
                                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    
                                    String sql = "SELECT id, full_name FROM users WHERE user_type = 'teacher' AND status = 'approved' ORDER BY full_name";
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                        out.println("<option value='" + rs.getInt("id") + "'>" + rs.getString("full_name") + "</option>");
                                    }
                                    
                                    rs.close();
                                    stmt.close();
                                    conn.close();
                                } catch (Exception e) {}
                            %>
                        </select>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">✓ Create Course</button>
            </form>
        </div>

        <!-- All Courses Section -->
        <h3 style="margin-bottom: 1.5rem;">📋 All Courses</h3>
        
        <div id="coursesContainer">
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection conn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                    
                    String sql = "SELECT c.course_id, c.course_code, c.course_name, c.credits, c.semester, " +
                                "u.full_name as teacher_name, u.id as teacher_id, " +
                                "COUNT(DISTINCT e.student_id) as student_count " +
                                "FROM courses c " +
                                "LEFT JOIN course_teacher ct ON c.course_id = ct.course_id " +
                                "LEFT JOIN users u ON ct.teacher_id = u.id " +
                                "LEFT JOIN enrollments e ON c.course_id = e.course_id " +
                                "GROUP BY c.course_id " +
                                "ORDER BY c.semester ASC, c.course_code ASC";
                    
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery(sql);
                    
                    boolean hasCourses = false;
                    while (rs.next()) {
                        hasCourses = true;
                        int courseId = rs.getInt("course_id");
                        String courseCode = rs.getString("course_code");
                        String courseName = rs.getString("course_name");
                        int credits = rs.getInt("credits");
                        int semester = rs.getInt("semester");
                        String teacherName = rs.getString("teacher_name");
                        Integer teacherId = rs.getObject("teacher_id") != null ? rs.getInt("teacher_id") : null;
                        int studentCount = rs.getInt("student_count");
            %>
            
            <div class="course-card">
                <div class="course-card-header">
                    <div>
                        <div class="course-code"><%= courseCode %></div>
                        <div class="course-name"><%= courseName %></div>
                    </div>
                    <div style="text-align: right; color: #7f8c8d; font-size: 0.9rem;">
                        Sem <%= semester %>
                    </div>
                </div>
                
                <div class="course-meta">
                    <div class="meta-item">
                        <span>Credits:</span>
                        <strong><%= credits %></strong>
                    </div>
                    <div class="meta-item">
                        <span>Students:</span>
                        <strong><%= studentCount %></strong>
                    </div>
                    <div class="meta-item">
                        <span>Course ID:</span>
                        <strong><%= courseId %></strong>
                    </div>
                </div>
                
                <!-- Teacher Assignment -->
                <div class="teacher-assignment">
                    <div class="teacher-info">
                        <%
                            if (teacherName != null && !teacherName.isEmpty()) {
                        %>
                            <div>
                                <span style="color: #7f8c8d; font-size: 0.85rem;">Assigned Teacher:</span>
                                <div class="teacher-name">👨‍🏫 <%= teacherName %></div>
                            </div>
                        <%
                            } else {
                        %>
                            <div>
                                <span style="color: #7f8c8d; font-size: 0.85rem;">Assigned Teacher:</span>
                                <div class="teacher-name" style="color: #e74c3c;">⚠ Unassigned</div>
                            </div>
                        <%
                            }
                        %>
                        <button type="button" class="change-teacher-btn" onclick="toggleTeacherForm(<%= courseId %>)">
                            Change Teacher
                        </button>
                    </div>
                    
                    <!-- Change Teacher Form -->
                    <div id="teacherForm_<%= courseId %>" class="teacher-select-form">
                        <form method="POST" action="courses.jsp" style="margin: 0;">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="course_id" value="<%= courseId %>">
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="newTeacher_<%= courseId %>">Select Teacher</label>
                                    <select id="newTeacher_<%= courseId %>" name="teacher_id" required>
                                        <option value="">-- Select Teacher --</option>
                                        <%
                                            try {
                                                String teacherSQL = "SELECT id, full_name FROM users WHERE user_type = 'teacher' AND status = 'approved' ORDER BY full_name";
                                                Statement teacherStmt = conn.createStatement();
                                                ResultSet teacherRS = teacherStmt.executeQuery(teacherSQL);
                                                
                                                while (teacherRS.next()) {
                                                    int tid = teacherRS.getInt("id");
                                                    String tname = teacherRS.getString("full_name");
                                                    String selected = (teacherId != null && teacherId == tid) ? "selected" : "";
                                                    out.println("<option value='" + tid + "' " + selected + ">" + tname + "</option>");
                                                }
                                                
                                                teacherRS.close();
                                                teacherStmt.close();
                                            } catch (Exception e) {}
                                        %>
                                    </select>
                                </div>
                                <button type="submit" class="btn btn-success" style="margin-bottom: 0;">Assign</button>
                                <button type="button" class="btn btn-secondary" onclick="toggleTeacherForm(<%= courseId %>" style="margin-bottom: 0;">Cancel</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <%
                    }
                    
                    if (!hasCourses) {
            %>
            <div style="text-align: center; padding: 3rem; color: #7f8c8d;">
                <p style="font-size: 1.1rem;">📭 No courses created yet</p>
                <p>Create your first course using the form above</p>
            </div>
            <%
                    }
                    
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='alert alert-danger'>Error loading courses: " + e.getMessage() + "</div>");
                }
            %>
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

    <script>
        function toggleTeacherForm(courseId) {
            const form = document.getElementById('teacherForm_' + courseId);
            form.classList.toggle('active');
        }
    </script>
</body>
</html>
