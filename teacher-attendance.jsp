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
    
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int teacherId = (Integer) session.getAttribute("userId");
    String message = "";
    String messageType = "";
    
    // Handle attendance submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            int subjectId = Integer.parseInt(request.getParameter("subject_id"));
            String attendanceDate = request.getParameter("attendance_date");
            
            // Get all student IDs for this subject
            String getStudentsSQL = "SELECT DISTINCT u.user_id FROM users u " +
                                   "JOIN student_subject_enrollment sse ON u.user_id = sse.student_id " +
                                   "WHERE sse.subject_id = ? AND sse.status = 'active' AND u.status = 'approved'";
            PreparedStatement getStudentsStmt = conn.prepareStatement(getStudentsSQL);
            getStudentsStmt.setInt(1, subjectId);
            ResultSet studentRS = getStudentsStmt.executeQuery();
            
            int recordsInserted = 0;
            String insertSQL = "INSERT INTO attendance (student_id, subject_id, teacher_id, class_date, status) " +
                              "VALUES (?, ?, ?, ?, ?) " +
                              "ON DUPLICATE KEY UPDATE status = VALUES(status)";
            
            while (studentRS.next()) {
                int studentId = studentRS.getInt("user_id");
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
    <link rel="stylesheet" href="style.css">
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
        
        .student-list-table tbody tr:hover {
            background: #f8f9fa;
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
        
        .hidden {
            display: none;
        }
        
        .student-count {
            background: #ecf0f1;
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1rem;
            font-weight: 600;
        }
        
        .select-all-controls {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .btn-small {
            padding: 0.5rem 1rem;
            font-size: 0.9rem;
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
                <a href="teacher-subjects.jsp" class="nav-link">My Subjects</a>
                <a href="teacher-attendance.jsp" class="nav-link active">Attendance</a>
                <a href="teacher-marks.jsp" class="nav-link">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header">
            <h2>📋 Mark Attendance</h2>
            <p>Select course and date, then mark attendance for students</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Course and Date Selection Form -->
        <div class="attendance-form-section">
            <h3>Step 1: Select Subject and Date</h3>
            <form id="attendanceForm" method="POST">
                <div class="attendance-controls">
                    <div class="form-group">
                        <label for="subject_id">Select Subject (Course) *</label>
                        <select id="subject_id" name="subject_id" required onchange="loadStudents()">
                            <option value="">-- Select Subject --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection(
                                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    
                                    String sql = "SELECT DISTINCT s.subject_id, s.subject_code, s.subject_name, c.course_name, s.semester " +
                                                "FROM subjects s " +
                                                "JOIN courses c ON s.course_id = c.course_id " +
                                                "JOIN subject_teacher st ON s.subject_id = st.subject_id " +
                                                "WHERE st.teacher_id = ? " +
                                                "ORDER BY c.course_name, s.semester, s.subject_code ASC";
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
            </form>
            <p style="color: #7f8c8d; font-size: 0.9rem; margin-top: 1rem;">
                ℹ️ After selecting a subject and date, click "Load Students" to display the student list below.
            </p>
        </div>

        <!-- Student List Section -->
        <div id="studentListSection" class="hidden">
            <div class="attendance-form-section">
                <h3>Step 2: Mark Attendance</h3>
                
                <div class="student-count">
                    <span id="studentCountText">Loading students...</span>
                </div>

                <div class="select-all-controls">
                    <button type="button" class="btn btn-secondary btn-small" onclick="selectAllStudents()">
                        ☑ Mark All Present
                    </button>
                    <button type="button" class="btn btn-secondary btn-small" onclick="deselectAllStudents()">
                        ☐ Mark All Absent
                    </button>
                </div>

                <table class="student-list-table" id="studentListTable">
                    <thead>
                        <tr>
                            <th>Roll Number</th>
                            <th>Student Name</th>
                            <th>Email</th>
                            <th class="checkbox-col">Present</th>
                        </tr>
                    </thead>
                    <tbody id="studentTableBody">
                        <tr><td colspan="4" style="text-align: center; padding: 2rem;">No students loaded</td></tr>
                    </tbody>
                </table>

                <div style="margin-top: 1.5rem;">
                    <button type="submit" form="attendanceForm" class="btn btn-primary" onclick="markAttendance()" style="width: 100%;">
                        ✓ Submit Attendance
                    </button>
                </div>
            </div>
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

    <script>
        function loadStudents() {
            const subjectId = document.getElementById('subject_id').value;
            const attendanceDate = document.getElementById('attendance_date').value;
            
            if (!subjectId) {
                alert('Please select a subject first');
                return;
            }
            
            if (!attendanceDate) {
                alert('Please select a date first');
                return;
            }
            
            // Make AJAX call to get students
            fetch('get-subject-students.jsp?subject_id=' + subjectId)
                .then(response => response.json())
                .then(data => {
                    populateStudentList(data);
                    document.getElementById('studentListSection').classList.remove('hidden');
                })
                .catch(error => {
                    alert('Error loading students: ' + error);
                });
        }
        
        function populateStudentList(students) {
            const tbody = document.getElementById('studentTableBody');
            tbody.innerHTML = '';
            
            if (students.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 2rem;">No students enrolled in this subject</td></tr>';
                document.getElementById('studentCountText').textContent = '0 students in this subject';
                return;
            }
            
            students.forEach(student => {
                const row = document.createElement('tr');
                row.innerHTML = `
                    <td>${student.roll_number || 'N/A'}</td>
                    <td>${student.full_name}</td>
                    <td>${student.email}</td>
                    <td class="checkbox-col">
                        <input type="checkbox" name="present_${student.student_id}" value="1" checked>
                    </td>
                `;
                tbody.appendChild(row);
            });
            
            document.getElementById('studentCountText').textContent = `${students.length} student(s) in this subject`;
        }
        
        function selectAllStudents() {
            const checkboxes = document.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(cb => cb.checked = true);
        }
        
        function deselectAllStudents() {
            const checkboxes = document.querySelectorAll('input[type="checkbox"]');
            checkboxes.forEach(cb => cb.checked = false);
        }
        
        function markAttendance() {
            const subjectId = document.getElementById('subject_id').value;
            const attendanceDate = document.getElementById('attendance_date').value;
            
            if (!subjectId || !attendanceDate) {
                alert('Please select both subject and date');
                return;
            }
            
            const form = document.getElementById('attendanceForm');
            form.submit();
        }
    </script>
</body>
</html>
