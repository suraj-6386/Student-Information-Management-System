<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session == null || session.isNew() || session.getAttribute("userId") == null || session.getAttribute("userType") == null) {
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
            
            int studentId = Integer.parseInt(request.getParameter("student_id"));
            int subjectId = Integer.parseInt(request.getParameter("subject_id"));
            
            int internal1 = Integer.parseInt(request.getParameter("internal1"));
            int internal2 = Integer.parseInt(request.getParameter("internal2"));
            int external = Integer.parseInt(request.getParameter("external"));
            
            if (internal1 < 0 || internal1 > 20) {
                throw new Exception("First Internal must be between 0-20");
            }
            if (internal2 < 0 || internal2 > 20) {
                throw new Exception("Second Internal must be between 0-20");
            }
            if (external < 0 || external > 60) {
                throw new Exception("End Semester must be between 0-60");
            }
            
            int totalMarks = internal1 + internal2 + external;
            String grade;
            if (totalMarks >= 90) grade = "A+";
            else if (totalMarks >= 80) grade = "A";
            else if (totalMarks >= 70) grade = "B+";
            else if (totalMarks >= 60) grade = "B";
            else if (totalMarks >= 50) grade = "C";
            else if (totalMarks >= 40) grade = "D";
            else grade = "F";
            
            String sql = "INSERT INTO marks (student_id, subject_id, teacher_id, internal1_marks, internal2_marks, external_marks, total_marks, grade, evaluated_at) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW()) " +
                        "ON DUPLICATE KEY UPDATE internal1_marks = ?, internal2_marks = ?, external_marks = ?, total_marks = ?, grade = ?, updated_at = NOW(), teacher_id = ?";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, studentId);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, teacherId);
            stmt.setInt(4, internal1);
            stmt.setInt(5, internal2);
            stmt.setInt(6, external);
            stmt.setInt(7, totalMarks);
            stmt.setString(8, grade);
            stmt.setInt(9, internal1);
            stmt.setInt(10, internal2);
            stmt.setInt(11, external);
            stmt.setInt(12, totalMarks);
            stmt.setString(13, grade);
            stmt.setInt(14, teacherId);
            
            stmt.executeUpdate();
            message = "Marks saved! Total: " + totalMarks + "/100 | Grade: " + grade;
            messageType = "success";
            
            stmt.close();
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
    <title>Enter Marks - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .marks-container { max-width: 800px; margin: 0 auto; padding: 2rem; }
        .form-section { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 2rem; }
        .form-group { margin-bottom: 1.5rem; }
        .form-group label { display: block; font-weight: 600; margin-bottom: 0.5rem; }
        .form-group select, .form-group input { width: 100%; padding: 0.75rem; border: 2px solid #ecf0f1; border-radius: 4px; font-size: 1rem; }
        .marks-input-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin: 1.5rem 0; }
        .mark-input { background: #f8f9fa; padding: 1.5rem; border-radius: 8px; text-align: center; }
        .mark-input input { width: 80px; padding: 0.75rem; border: 2px solid #ddd; border-radius: 4px; font-size: 1.25rem; text-align: center; }
        .mark-input .max-marks { font-size: 0.85rem; color: #7f8c8d; margin-top: 0.5rem; }
        .total-display { background: #3498db; color: white; padding: 1.5rem; border-radius: 8px; text-align: center; margin-top: 1.5rem; }
        .total-display .total-value { font-size: 2.5rem; font-weight: bold; }
        .student-info { background: #e8f5e9; padding: 1rem; border-radius: 4px; margin-bottom: 1rem; display: none; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand"><h1>SIMS</h1><p>Teacher Portal</p></div>
            <div class="nav-links">
                <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="teacher-marks.jsp" class="nav-link active">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="marks-container">
            <h2>📊 Enter Marks</h2>
            <p>Select subject and student, then enter marks</p>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>" style="margin-bottom: 1.5rem;"><%= message %></div>
            <% } %>
            
            <div class="form-section">
                <h3>Step 1: Select Subject</h3>
                <div class="form-group">
                    <label for="subject_id">Subject *</label>
                    <select id="subject_id" onchange="loadStudents()">
                        <option value="">-- Select Subject --</option>
                        <%
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                String sql = "SELECT s.subject_id, s.subject_code, s.subject_name, c.course_name, s.semester " +
                                            "FROM subjects s JOIN courses c ON s.course_id = c.course_id " +
                                            "WHERE s.teacher_id = ? ORDER BY c.course_name, s.semester";
                                PreparedStatement stmt = conn.prepareStatement(sql);
                                stmt.setInt(1, teacherId);
                                ResultSet rs = stmt.executeQuery();
                                while (rs.next()) {
                        %>
                        <option value="<%= rs.getInt("subject_id") %>">
                            <%= rs.getString("subject_code") %> - <%= rs.getString("subject_name") %> (<%= rs.getString("course_name") %>, Sem <%= rs.getInt("semester") %>)
                        </option>
                        <% }
                                conn.close();
                            } catch (Exception e) { out.println("<option>Error</option>"); }
                        %>
                    </select>
                </div>
            </div>
            
            <div id="studentSection" class="form-section" style="display:none;">
                <h3>Step 2: Select Student</h3>
                <div class="form-group">
                    <label for="student_id">Student *</label>
                    <select id="student_id" onchange="showMarksForm()">
                        <option value="">-- Select Student --</option>
                    </select>
                </div>
            </div>
            
            <div id="marksSection" class="form-section" style="display:none;">
                <h3>Step 3: Enter Marks</h3>
                <form method="POST">
                    <input type="hidden" name="subject_id" id="form_subject_id">
                    <input type="hidden" name="student_id" id="form_student_id">
                    
                    <div class="marks-input-grid">
                        <div class="mark-input">
                            <label>First Internal</label>
                            <input type="number" name="internal1" id="internal1" min="0" max="20" value="0" oninput="calculateTotal()">
                            <div class="max-marks">Out of 20</div>
                        </div>
                        <div class="mark-input">
                            <label>Second Internal</label>
                            <input type="number" name="internal2" id="internal2" min="0" max="20" value="0" oninput="calculateTotal()">
                            <div class="max-marks">Out of 20</div>
                        </div>
                        <div class="mark-input">
                            <label>End Semester</label>
                            <input type="number" name="external" id="external" min="0" max="60" value="0" oninput="calculateTotal()">
                            <div class="max-marks">Out of 60</div>
                        </div>
                    </div>
                    
                    <div class="total-display">
                        <div class="total-label">Total Marks</div>
                        <div class="total-value"><span id="totalMarks">0</span>/100</div>
                    </div>
                    
                    <button type="submit" class="btn btn-primary" style="width:100%; margin-top:1rem;">Save Marks</button>
                </form>
            </div>
            
            <div style="margin-top: 2rem;">
                <a href="teacher-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom"><p>&copy; 2026 SIMS. All rights reserved.</p></div>
    </footer>

    <script>
        function loadStudents() {
            const subjectId = document.getElementById('subject_id').value;
            const studentSelect = document.getElementById('student_id');
            document.getElementById('studentSection').style.display = 'none';
            document.getElementById('marksSection').style.display = 'none';
            if (!subjectId) return;
            
            fetch('get-subject-students.jsp?subject_id=' + subjectId)
                .then(response => response.json())
                .then(data => {
                    studentSelect.innerHTML = '<option value="">-- Select Student --</option>';
                    data.forEach(student => {
                        const option = document.createElement('option');
                        option.value = student.student_id;
                        option.textContent = (student.roll_number || 'N/A') + ' - ' + student.full_name;
                        studentSelect.appendChild(option);
                    });
                    document.getElementById('studentSection').style.display = 'block';
                });
        }
        
        function showMarksForm() {
            const studentId = document.getElementById('student_id').value;
            if (!studentId) { document.getElementById('marksSection').style.display = 'none'; return; }
            document.getElementById('form_subject_id').value = document.getElementById('subject_id').value;
            document.getElementById('form_student_id').value = studentId;
            document.getElementById('marksSection').style.display = 'block';
        }
        
        function calculateTotal() {
            const internal1 = parseInt(document.getElementById('internal1').value) || 0;
            const internal2 = parseInt(document.getElementById('internal2').value) || 0;
            const external = parseInt(document.getElementById('external').value) || 0;
            document.getElementById('totalMarks').textContent = internal1 + internal2 + external;
        }
    </script>
</body>
</html>
