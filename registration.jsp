<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.Base64" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Function to generate unique user ID
    String generateStudentUserId(Connection conn) throws SQLException {
        String userId = "";
        boolean unique = false;
        while (!unique) {
            int randomNum = (int)(Math.random() * 1000000);
            userId = "STU" + String.format("%06d", randomNum);
            PreparedStatement checkStmt = conn.prepareStatement("SELECT user_id FROM student WHERE user_id = ?");
            checkStmt.setString(1, userId);
            ResultSet rs = checkStmt.executeQuery();
            unique = !rs.next();
            rs.close();
            checkStmt.close();
        }
        return userId;
    }
    
    String generateTeacherUserId(Connection conn) throws SQLException {
        String userId = "";
        boolean unique = false;
        while (!unique) {
            int randomNum = (int)(Math.random() * 1000000);
            userId = "TEA" + String.format("%06d", randomNum);
            PreparedStatement checkStmt = conn.prepareStatement("SELECT user_id FROM teacher WHERE user_id = ?");
            checkStmt.setString(1, userId);
            ResultSet rs = checkStmt.executeQuery();
            unique = !rs.next();
            rs.close();
            checkStmt.close();
        }
        return userId;
    }
%>

<%
    String message = "";
    String messageType = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String userType = request.getParameter("userType");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String address = request.getParameter("address");
        
        // Student-specific fields
        String rollNumber = request.getParameter("rollNumber");
        String courseId = request.getParameter("courseId");
        String semester = request.getParameter("semester");
        String parentName = request.getParameter("parentName");
        String parentContact = request.getParameter("parentContact");
        
        // Teacher-specific fields
        String employeeId = request.getParameter("employeeId");
        String department = request.getParameter("department");
        String qualification = request.getParameter("qualification");
        String experience = request.getParameter("experience");
        
        // Validation
        if (fullName == null || fullName.trim().isEmpty() || email == null || email.trim().isEmpty()) {
            message = "Full name and email are required!";
            messageType = "danger";
        } else if (!password.equals(confirmPassword)) {
            message = "Passwords do not match!";
            messageType = "danger";
        } else if (password.length() < 6) {
            message = "Password must be at least 6 characters long!";
            messageType = "danger";
        } else if ("student".equals(userType) && (rollNumber == null || rollNumber.trim().isEmpty())) {
            message = "Roll number is required for students!";
            messageType = "danger";
        } else if ("student".equals(userType) && (courseId == null || courseId.trim().isEmpty())) {
            message = "Please select a course for student registration!";
            messageType = "danger";
        } else if ("teacher".equals(userType) && (employeeId == null || employeeId.trim().isEmpty())) {
            message = "Employee ID is required for teachers!";
            messageType = "danger";
        } else {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                // Check if email already exists in student or teacher tables
                String checkSql = "SELECT student_id FROM student WHERE email = ? UNION ALL SELECT teacher_id FROM teacher WHERE email = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setString(1, email);
                checkStmt.setString(2, email);
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    message = "Email already registered!";
                    messageType = "danger";
                } else {
                    rs.close();
                    checkStmt.close();
                    
                    // Hash password
                    MessageDigest md = MessageDigest.getInstance("SHA-256");
                    byte[] hashedPassword = md.digest(password.getBytes("UTF-8"));
                    String hashedPasswordStr = Base64.getEncoder().encodeToString(hashedPassword);
                    
                    if ("student".equals(userType)) {
                        // Insert into student table
                        String studentUserId = generateStudentUserId(conn);
                        String insertSql = "INSERT INTO student (user_id, full_name, email, phone, password_hash, status, address, roll_number, course_id, semester, parent_name, parent_contact) VALUES (?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, ?, ?)";
                        PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                        insertStmt.setString(1, studentUserId);
                        insertStmt.setString(2, fullName);
                        insertStmt.setString(3, email);
                        insertStmt.setString(4, phone);
                        insertStmt.setString(5, hashedPasswordStr);
                        insertStmt.setString(6, address);
                        insertStmt.setString(7, rollNumber);
                        
                        if (courseId != null && !courseId.isEmpty()) {
                            insertStmt.setInt(8, Integer.parseInt(courseId));
                        } else {
                            insertStmt.setNull(8, java.sql.Types.INTEGER);
                        }
                        
                        insertStmt.setString(9, semester != null && !semester.isEmpty() ? semester : "1");
                        insertStmt.setString(10, parentName);
                        insertStmt.setString(11, parentContact);
                        
                        insertStmt.executeUpdate();
                        insertStmt.close();
                        
                    } else if ("teacher".equals(userType)) {
                        // Insert into teacher table
                        String teacherUserId = generateTeacherUserId(conn);
                        String insertSql = "INSERT INTO teacher (user_id, full_name, email, phone, password_hash, status, address, employee_id, department, qualification, experience) VALUES (?, ?, ?, ?, ?, 'pending', ?, ?, ?, ?, ?)";
                        PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                        insertStmt.setString(1, teacherUserId);
                        insertStmt.setString(2, fullName);
                        insertStmt.setString(3, email);
                        insertStmt.setString(4, phone);
                        insertStmt.setString(5, hashedPasswordStr);
                        insertStmt.setString(6, address);
                        insertStmt.setString(7, employeeId);
                        insertStmt.setString(8, department);
                        insertStmt.setString(9, qualification);
                        insertStmt.setInt(10, experience != null && !experience.isEmpty() ? Integer.parseInt(experience) : 0);
                        
                        insertStmt.executeUpdate();
                        insertStmt.close();
                    }
                    
                    message = "Registration successful! Your account is pending admin approval.";
                    messageType = "success";
                }
                
                if (rs != null && !rs.isClosed()) rs.close();
                if (checkStmt != null && !checkStmt.isClosed()) checkStmt.close();
                if (conn != null && !conn.isClosed()) conn.close();
                
            } catch (Exception e) {
                message = "Error during registration: " + e.getMessage();
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
    <title>Register - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <script>
        function toggleFields() {
            var userType = document.getElementById("userType").value;
            var studentFields = document.getElementById("studentFields");
            var teacherFields = document.getElementById("teacherFields");
            
            if (userType === "student") {
                studentFields.style.display = "block";
                teacherFields.style.display = "none";
            } else if (userType === "teacher") {
                studentFields.style.display = "none";
                teacherFields.style.display = "block";
            } else {
                studentFields.style.display = "none";
                teacherFields.style.display = "none";
            }
        }
    </script>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>DY Patil School of Science and Technology</p>
            </div>
            <div class="nav-links">
                <a href="index.html" class="nav-link">Home</a>
                <a href="login.jsp" class="nav-link">Login</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="login-card" style="max-width: 600px; margin: 2rem auto;">
            <div class="login-header">
                <h2>Create Account</h2>
                <p>Register as Student or Teacher</p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>

            <form method="POST" class="login-form">
                <div class="form-group">
                    <label for="userType">Register As *</label>
                    <select id="userType" name="userType" required onchange="toggleFields()">
                        <option value="">-- Select Type --</option>
                        <option value="student">Student</option>
                        <option value="teacher">Teacher</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName" required>
                </div>

                <div class="form-group">
                    <label for="email">Email Address *</label>
                    <input type="email" id="email" name="email" required>
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="text" id="phone" name="phone">
                </div>

                <div class="form-group">
                    <label for="address">Address</label>
                    <textarea id="address" name="address" rows="2"></textarea>
                </div>

                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" required minlength="6">
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                </div>

                <!-- Student Fields -->
                <div id="studentFields" style="display: none;">
                    <div class="form-group">
                        <label for="rollNumber">Roll Number *</label>
                        <input type="text" id="rollNumber" name="rollNumber">
                    </div>

                    <div class="form-group">
                        <label for="courseId">Course *</label>
                        <select id="courseId" name="courseId">
                            <option value="">-- Select Course --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.jdbc.Driver");
                                    Connection conn = DriverManager.getConnection(
                                        "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery("SELECT course_id, course_name FROM courses ORDER BY course_name");
                                    while (rs.next()) {
                            %>
                            <option value="<%= rs.getInt("course_id") %>"><%= rs.getString("course_name") %></option>
                            <%
                                    }
                                    rs.close();
                                    stmt.close();
                                    conn.close();
                                } catch (Exception e) {}
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="semester">Semester</label>
                        <select id="semester" name="semester">
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

                    <div class="form-group">
                        <label for="parentName">Parent Name</label>
                        <input type="text" id="parentName" name="parentName">
                    </div>

                    <div class="form-group">
                        <label for="parentContact">Parent Contact</label>
                        <input type="text" id="parentContact" name="parentContact">
                    </div>
                </div>

                <!-- Teacher Fields -->
                <div id="teacherFields" style="display: none;">
                    <div class="form-group">
                        <label for="employeeId">Employee ID *</label>
                        <input type="text" id="employeeId" name="employeeId">
                    </div>

                    <div class="form-group">
                        <label for="department">Department</label>
                        <input type="text" id="department" name="department">
                    </div>

                    <div class="form-group">
                        <label for="qualification">Qualification</label>
                        <input type="text" id="qualification" name="qualification">
                    </div>

                    <div class="form-group">
                        <label for="experience">Years of Experience</label>
                        <input type="number" id="experience" name="experience" min="0" value="0">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%;">Register</button>
            </form>

            <p style="text-align: center; margin-top: 1rem;">
                Already have an account? <a href="login.jsp">Login here</a>
            </p>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
