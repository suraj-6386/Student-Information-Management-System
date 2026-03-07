<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || 
        session.getAttribute("userId") == null || 
        session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int teacherId = (Integer) session.getAttribute("userId");
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            int subjectId = Integer.parseInt(request.getParameter("subject_id"));
            String attendanceDate = request.getParameter("attendance_date");
            
            String getStudentsSQL = "SELECT DISTINCT st.student_id FROM student st " +
                                   "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                                   "WHERE se.subject_id = ? AND se.status = 'active' AND st.status = 'approved'";
            PreparedStatement getStudentsStmt = conn.prepareStatement(getStudentsSQL);
            getStudentsStmt.setInt(1, subjectId);
            ResultSet studentRS = getStudentsStmt.executeQuery();
            
            int recordsInserted = 0;
            String insertSQL = "INSERT INTO attendance (student_id, subject_id, teacher_id, class_date, status) " +
                              "VALUES (?, ?, ?, ?, ?) " +
                              "ON DUPLICATE KEY UPDATE status = VALUES(status), teacher_id = VALUES(teacher_id)";
            
            while (studentRS.next()) {
                int studentId = studentRS.getInt("student_id");
                String checkboxName = "present_" + studentId;
                String status = request.getParameter(checkboxName) != null ? "present" : "absent";
                
                PreparedStatement insertStmt = conn.prepareStatement(insertSQL);
                insertStmt.setInt(1, studentId);
                insertStmt.setInt(2, subjectId);
                insertStmt.setInt(3, teacherId);
                insertStmt.setString(4, attendanceDate);
                insertStmt.setString(5, status);
                insertStmt.executeUpdate();
                insertStmt.close();
                recordsInserted++;
            }
            
            studentRS.close();
            getStudentsStmt.close();
            conn.close();
            
            message = "✓ Attendance recorded for " + recordsInserted + " students!";
            messageType = "success";
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
    <title>Mark Attendance - SIMS</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:ital,wght@0,400;0,700;1,400&family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">>
    <style>
        .attendance-form-section {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .student-list-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        
        .student-list-table thead {
            background: #2c3e50;
            color: white;
        }
        
        .student-list-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }
        
        .student-list-table td {
            padding: 1rem;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .student-list-table .checkbox-col {
            text-align: center;
            width: 100px;
        }
        
        .student-list-table input[type="checkbox"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
        }
        
        .attendance-controls {
            display: flex;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .attendance-controls .form-group {
            flex: 1;
        }
        
        .attendance-controls input,
        .attendance-controls select {
            width: 100%;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS - Teacher Portal</h1>
                <p>Mark Attendance</p>
            </div>
            <div class="nav-links">
                <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="teacher-attendance.jsp" class="nav-link active">Attendance</a>
                <a href="teacher-marks.jsp" class="nav-link">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header">
            <h2>📋 Mark Attendance</h2>
            <p>Select subject and date, then mark attendance for students</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <div class="attendance-form-section">
            <h3>Select Subject and Date</h3>
            <form id="attendanceForm" method="POST">
                <div class="attendance-controls">
                    <div class="form-group">
                        <label for="subject_id">Select Subject *</label>
                        <select id="subject_id" name="subject_id" required onchange="loadStudents()">
                            <option value="">-- Select Subject --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection(
                                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    
                                    String sql = "SELECT s.subject_id, s.subject_code, s.subject_name, c.course_name, s.semester " +
                                                "FROM subjects s " +
                                                "JOIN courses c ON s.course_id = c.course_id " +
                                                "WHERE s.teacher_id = ? " +
                                                "ORDER BY c.course_name, s.semester, s.subject_code";
                                    PreparedStatement stmt = conn.prepareStatement(sql);
                                    stmt.setInt(1, teacherId);
                                    ResultSet rs = stmt.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                            <option value="<%= rs.getInt("subject_id") %>">
                                <%= rs.getString("subject_code") %> - <%= rs.getString("subject_name") %> (<%= rs.getString("course_name") %>, Sem <%= rs.getInt("semester") %>)
                            </option>
                            <%
                                    }
                                    conn.close();
                                } catch (Exception e) {
                                    out.println("<option>Error loading subjects</option>");
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="attendance_date">Select Date *</label>
                        <input type="date" id="attendance_date" name="attendance_date" required>
                    </div>
                </div>

                <!-- Student Listing Section -->
                <div id="studentListContainer" style="display:none; margin-top: 2rem;">
                    <h3>👥 Mark Attendance for Students</h3>
                    <table class="student-list-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Roll Number</th>
                                <th>Student Name</th>
                                <th class="checkbox-col">Present</th>
                            </tr>
                        </thead>
                        <tbody id="studentTableBody">
                            <tr><td colspan="4" style="text-align:center;">Select a subject to load students</td></tr>
                        </tbody>
                    </table>
                </div>

                <div style="margin-top: 1.5rem;">
                    <button type="submit" class="btn btn-primary" id="submitBtn" disabled>Submit Attendance</button>
                </div>
            </form>
        </div>

        <div style="margin-top: 2rem;">
            <a href="teacher-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
       <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
            <p>&copy; SURAJ GUPTA | MCA</p>
        </div>
    </footer>

    <script>
        document.getElementById('attendance_date').valueAsDate = new Date();
        
        function loadStudents() {
            const subjectId = document.getElementById('subject_id').value;
            const studentListContainer = document.getElementById('studentListContainer');
            const submitBtn = document.getElementById('submitBtn');
            
            if (!subjectId) {
                studentListContainer.style.display = 'none';
                submitBtn.disabled = true;
                return;
            }
            
            // Fetch students for the selected subject
            fetch('get-subject-students.jsp?subject_id=' + encodeURIComponent(subjectId))
                .then(response => response.text())
                .then(html => {
                    document.getElementById('studentTableBody').innerHTML = html;
                    studentListContainer.style.display = 'block';
                    submitBtn.disabled = false;
                })
                .catch(error => {
                    console.error('Error loading students:', error);
                    document.getElementById('studentTableBody').innerHTML = '<tr><td colspan="4" style="text-align:center;color:red;">Error loading students</td></tr>';
                    submitBtn.disabled = true;
                });
        }
    </script>
</body>
</html>


