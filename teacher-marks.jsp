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
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            int studentId = Integer.parseInt(request.getParameter("student_id"));
            int subjectId = Integer.parseInt(request.getParameter("subject_id"));
            int theoryMarks = Integer.parseInt(request.getParameter("theory_marks"));
            int practicalMarks = Integer.parseInt(request.getParameter("practical_marks"));
            int assignmentMarks = Integer.parseInt(request.getParameter("assignment_marks"));
            
            // Validate marks
            if (theoryMarks < 0 || theoryMarks > 100 || practicalMarks < 0 || practicalMarks > 100 || 
                assignmentMarks < 0 || assignmentMarks > 100) {
                throw new Exception("All marks must be between 0 and 100");
            }
            
            int totalMarks = theoryMarks + practicalMarks + assignmentMarks;
            String grade;
            if (totalMarks >= 270) grade = "A";
            else if (totalMarks >= 240) grade = "B";
            else if (totalMarks >= 180) grade = "C";
            else if (totalMarks >= 150) grade = "D";
            else grade = "F";
            
            String sql = "INSERT INTO marks (student_id, subject_id, teacher_id, theory_marks, practical_marks, assignment_marks, total_marks, grade, evaluated_at) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW()) " +
                        "ON DUPLICATE KEY UPDATE theory_marks = ?, practical_marks = ?, assignment_marks = ?, total_marks = ?, grade = ?, updated_at = NOW(), teacher_id = ?";
            
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, studentId);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, teacherId);
            stmt.setInt(4, theoryMarks);
            stmt.setInt(5, practicalMarks);
            stmt.setInt(6, assignmentMarks);
            stmt.setInt(7, totalMarks);
            stmt.setString(8, grade);
            stmt.setInt(9, theoryMarks);
            stmt.setInt(10, practicalMarks);
            stmt.setInt(11, assignmentMarks);
            stmt.setInt(12, totalMarks);
            stmt.setString(13, grade);
            stmt.setInt(14, teacherId);
            
            stmt.executeUpdate();
            message = "✓ Marks saved successfully! (Grade: " + grade + ", Total: " + totalMarks + "/300)";
            messageType = "success";
            
            stmt.close();
            conn.close();
        } catch (NumberFormatException e) {
            message = "Error: Invalid input. Marks must be numbers between 0-100";
            messageType = "danger";
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
        .marks-form-section {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .marks-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 1.5rem;
            margin: 1.5rem 0;
        }
        
        .mark-input-group {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 6px;
            border-left: 4px solid #3498db;
        }
        
        .mark-input-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #2c3e50;
            font-size: 0.9rem;
        }
        
        .mark-input-group input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #ecf0f1;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }
        
        .mark-input-group input:focus {
            outline: none;
            border-color: #3498db;
            background: white;
        }
        
        .marks-summary {
            background: #ecf0f1;
            padding: 1.5rem;
            border-radius: 6px;
            margin: 1.5rem 0;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }
        
        .summary-item {
            text-align: center;
        }
        
        .summary-label {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-bottom: 0.5rem;
        }
        
        .summary-value {
            font-size: 1.8rem;
            font-weight: bold;
            color: #2c3e50;
        }
        
        .grade-excellent {
            color: #27ae60;
        }
        
        .grade-good {
            color: #2980b9;
        }
        
        .grade-average {
            color: #f39c12;
        }
        
        .grade-poor {
            color: #e74c3c;
        }
        
        .step-indicator {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            justify-content: space-between;
        }
        
        .step {
            flex: 1;
            text-align: center;
            padding: 1rem;
            background: #ecf0f1;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 600;
        }
        
        .step.active {
            background: #3498db;
            color: white;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS - Teacher Portal</h1>
                <p>Enter Marks</p>
            </div>
            <div class="nav-links">
                <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="teacher-courses.jsp" class="nav-link">My Courses</a>
                <a href="teacher-attendance.jsp" class="nav-link">Attendance</a>
                <a href="teacher-marks.jsp" class="nav-link active">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header">
            <h2>📊 Enter Student Marks</h2>
            <p>Select course and student, then enter marks</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Step Indicator -->
        <div class="step-indicator">
            <div class="step active">① Select Course</div>
            <div class="step">② Select Student</div>
            <div class="step">③ Enter Marks</div>
            <div class="step">④ Submit</div>
        </div>

        <!-- Course and Student Selection -->
        <div class="marks-form-section">
            <h3>Step 1-2: Select Course and Student</h3>
            <form id="marksForm" method="POST" action="teacher-marks.jsp">
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                    <div class="form-group">
                        <label for="course_id">Select Your Course *</label>
                        <select id="course_id" name="course_id" required onchange="updateStudentList()">
                            <option value="">-- Select Course --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection(
                                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    
                                    String sql = "SELECT DISTINCT c.course_id, c.course_code, c.course_name " +
                                                "FROM courses c " +
                                                "JOIN course_teacher ct ON c.course_id = ct.course_id " +
                                                "WHERE ct.teacher_id = ? " +
                                                "ORDER BY c.course_name ASC";
                                    
                                    PreparedStatement stmt = conn.prepareStatement(sql);
                                    stmt.setInt(1, teacherId);
                                    ResultSet rs = stmt.executeQuery();
                                    
                                    while (rs.next()) {
                            %>
                            <option value="<%= rs.getInt("course_id") %>">
                                <%= rs.getString("course_code") %> - <%= rs.getString("course_name") %>
                            </option>
                            <%
                                    }
                                    conn.close();
                                } catch (Exception e) {
                                    out.println("<option>Error loading courses</option>");
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="student_id">Select Student *</label>
                        <select id="student_id" name="student_id" required>
                            <option value="">-- Select Course First --</option>
                        </select>
                    </div>
                </div>
            </form>
        </div>

        <!-- Marks Entry Section -->
        <div class="marks-form-section">
            <h3>Step 3-4: Enter Marks and Submit</h3>
            
            <div class="marks-grid">
                <div class="mark-input-group">
                    <label for="assignment">Assignment Marks</label>
                    <input type="number" id="assignment" name="assignment" min="0" max="100" value="0" 
                           form="marksForm" onchange="calculateTotal()" oninput="calculateTotal()">
                    <small style="color: #7f8c8d;">Out of 100</small>
                </div>

                <div class="mark-input-group">
                    <label for="mid_exam">Mid Exam Marks</label>
                    <input type="number" id="mid_exam" name="mid_exam" min="0" max="100" value="0" 
                           form="marksForm" onchange="calculateTotal()" oninput="calculateTotal()">
                    <small style="color: #7f8c8d;">Out of 100</small>
                </div>

                <div class="mark-input-group">
                    <label for="final_exam">Final Exam Marks</label>
                    <input type="number" id="final_exam" name="final_exam" min="0" max="100" value="0" 
                           form="marksForm" onchange="calculateTotal()" oninput="calculateTotal()">
                    <small style="color: #7f8c8d;">Out of 100</small>
                </div>
            </div>

            <!-- Summary and Grade -->
            <div class="marks-summary">
                <div class="summary-item">
                    <div class="summary-label">Total Marks</div>
                    <div class="summary-value" id="totalMarks">0 / 300</div>
                </div>
                <div class="summary-item">
                    <div class="summary-label">Grade</div>
                    <div class="summary-value" id="gradeDisplay">-</div>
                </div>
            </div>

            <!-- Submit Button -->
            <button type="submit" form="marksForm" class="btn btn-primary" style="width: 100%; padding: 0.8rem; font-size: 1rem;">
                ✓ Save Marks
            </button>
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
        function updateStudentList() {
            const courseId = document.getElementById('course_id').value;
            const studentSelect = document.getElementById('student_id');
            
            if (!courseId) {
                studentSelect.innerHTML = '<option value="">-- Select Course First --</option>';
                return;
            }
            
            // Create option to load students
            studentSelect.innerHTML = '<option value="">Loading students...</option>';
            
            fetch('get-course-students.jsp?course_id=' + courseId)
                .then(response => response.json())
                .then(data => {
                    populateStudentSelect(data);
                })
                .catch(error => {
                    studentSelect.innerHTML = '<option value="">Error loading students</option>';
                    console.error('Error:', error);
                });
        }
        
        function populateStudentSelect(students) {
            const select = document.getElementById('student_id');
            select.innerHTML = '<option value="">-- Select Student --</option>';
            
            if (students.length === 0) {
                select.innerHTML = '<option value="">No students in this course</option>';
                return;
            }
            
            students.forEach(student => {
                const option = document.createElement('option');
                option.value = student.id;
                let displayText = student.full_name;
                if (student.roll_number) {
                    displayText += ' (' + student.roll_number + ')';
                }
                option.textContent = displayText;
                select.appendChild(option);
            });
        }
        
        function calculateTotal() {
            const assignment = parseInt(document.getElementById('assignment').value) || 0;
            const midExam = parseInt(document.getElementById('mid_exam').value) || 0;
            const finalExam = parseInt(document.getElementById('final_exam').value) || 0;
            
            const total = assignment + midExam + finalExam;
            document.getElementById('totalMarks').textContent = total + ' / 300';
            
            // Calculate and display grade
            const percentage = (total / 300) * 100;
            let grade = '-';
            let gradeClass = '';
            
            if (percentage >= 80) {
                grade = 'A';
                gradeClass = 'grade-excellent';
            } else if (percentage >= 70) {
                grade = 'B';
                gradeClass = 'grade-good';
            } else if (percentage >= 60) {
                grade = 'C';
                gradeClass = 'grade-average';
            } else if (percentage >= 50) {
                grade = 'D';
                gradeClass = 'grade-poor';
            } else if (total > 0) {
                grade = 'F';
                gradeClass = 'grade-poor';
            }
            
            const gradeDisplay = document.getElementById('gradeDisplay');
            gradeDisplay.textContent = grade;
            gradeDisplay.className = 'summary-value ' + gradeClass;
        }
        
        // Initial calculation on page load
        calculateTotal();
    </script>
</body>
</html>
