<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.Base64" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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
        String dob = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String courseId = request.getParameter("courseId");
        String semester = request.getParameter("semester");
        String  parentName = request.getParameter("parentName");
        String parentContact = request.getParameter("parentContact");
        String admissionYear = request.getParameter("admissionYear");
        
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
        } else if ("teacher".equals(userType) && (employeeId == null || employeeId.trim().isEmpty())) {
            message = "Employee ID is required for teachers!";
            messageType = "danger";
        } else {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                // Check if email already exists
                String checkSql = "SELECT user_id FROM users WHERE email = ?";
                PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setString(1, email);
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    message = "Email already registered!";
                    messageType = "danger";
                } else {
                    // Hash password
                    MessageDigest md = MessageDigest.getInstance("SHA-256");
                    byte[] hashedPassword = md.digest(password.getBytes());
                    String hashedPasswordStr = Base64.getEncoder().encodeToString(hashedPassword);
                    
                    // Insert new user with all fields
                    String insertSql = "INSERT INTO users (full_name, email, phone, user_type, password_hash, status, ";
                    String values = "VALUES (?, ?, ?, ?, ?, 'pending', ";
                    
                    if ("student".equals(userType)) {
                        insertSql += "roll_number, course_id, semester) ";
                        insertSql += values + params + ")";
                    } else if ("teacher".equals(userType)) {
                        params = "?, ?, ?, ?"; // 4 additional params for teacher
                        insertSql += "employee_id, department) ";
                        insertSql += values + params + ")";
                    }
                    
                    PreparedStatement insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setString(1, fullName);
                    insertStmt.setString(2, email);
                    insertStmt.setString(3, phone);
                    insertStmt.setString(4, userType);
                    insertStmt.setString(5, hashedPasswordStr);
                    insertStmt.setString(6, phone);
                    
                    if ("student".equals(userType)) {
                        insertStmt.setString(7, rollNumber);
                        insertStmt.setString(8, null); // date_of_birth removed
                        insertStmt.setString(9, null); // gender removed
                        insertStmt.setString(10, courseId != null && !courseId.isEmpty() ? courseId : null);
                        insertStmt.setString(11, semester);
                    } else if ("teacher".equals(userType)) {
                        insertStmt.setString(7, employeeId);
                        insertStmt.setString(8, department);
                    }
                    
                    insertStmt.executeUpdate();
                    message = "✓ Registration successful! Your account is pending admin approval. Please check your email for updates.";
                    messageType = "success";
                    
                    insertStmt.close();
                }
                
                rs.close();
                checkStmt.close();
                conn.close();
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
                <p>DY Patil School of Science and Technology, Pune</p>
            </div>
            <div class="nav-links">
                <a href="index.html" class="nav-link">Home</a>
                <a href="login.jsp" class="nav-link">Login</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="form-container" style="max-width: 800px;">
            <h2>Create Your Account</h2>
            <p>Register as a Student or Teacher with complete information</p>

            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>

            <form method="POST" action="registration.jsp">
                <!-- Common Fields -->
                <fieldset style="border: 1px solid #ccc; padding: 1.5rem; border-radius: 6px; margin-bottom: 1.5rem;">
                    <legend style="padding: 0 1rem;">Common Information</legend>
                    
                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="fullName">Full Name *</label>
                            <input type="text" id="fullName" name="fullName" required>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="userType">Register As *</label>
                            <select id="userType" name="userType" required onchange="toggleFields()">
                                <option value="">-- Select Type --</option>
                                <option value="student">Student</option>
                                <option value="teacher">Teacher</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="email">Email Address *</label>
                            <input type="email" id="email" name="email" required>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="phone">Phone Number *</label>
                            <input type="text" id="phone" name="phone" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="address">Address</label>
                        <textarea id="address" name="address" rows="2" placeholder="Street address, city, state"></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="password">Password *</label>
                            <input type="password" id="password" name="password" required>
                            <small>Minimum 6 characters</small>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="confirmPassword">Confirm Password *</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required>
                        </div>
                    </div>
                </fieldset>

                <!-- Student Fields -->
                <fieldset id="studentFields" style="border: 1px solid #ccc; padding: 1.5rem; border-radius: 6px; margin-bottom: 1.5rem; display: none;">
                    <legend style="padding: 0 1rem;">Student Information</legend>
                    
                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="rollNumber">Roll Number *</label>
                            <input type="text" id="rollNumber" name="rollNumber" placeholder="e.g., CS20001">
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="admissionYear">Admission Year *</label>
                            <input type="number" id="admissionYear" name="admissionYear" placeholder="2020">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="dob">Date of Birth</label>
                            <input type="date" id="dob" name="dob">
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="gender">Gender</label>
                            <select id="gender" name="gender">
                               <option value="">-- Select --</option>
                                <option value="M">Male</option>
                                <option value="F">Female</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="courseId">Degree Program (Course) *</label>
                            <select id="courseId" name="courseId" required>
                                <option value="">-- Select Degree Program --</option>
                                <option value="1">BTech - Bachelor of Technology (4 years)</option>
                                <option value="2">BSc - Bachelor of Science (3 years)</option>
                                <option value="3">BCA - Bachelor of Computer Applications (3 years)</option>
                                <option value="4">MCA - Master of Computer Applications (2 years)</option>
                            </select>
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="semester">Current Semester</label>
                            <select id="semester" name="semester">
                                <option value="">-- Select --</option>                                <option value="1" selected>Semester 1</option>
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

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="parentName">Parent/Guardian Name</label>
                            <input type="text" id="parentName" name="parentName" placeholder="Full name">
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="parentContact">Parent Contact</label>
                            <input type="text" id="parentContact" name="parentContact" placeholder="+91-XXX-XXX-XXXX">
                        </div>
                    </div>
                </fieldset>

                <!-- Teacher Fields -->
                <fieldset id="teacherFields" style="border: 1px solid #ccc; padding: 1.5rem; border-radius: 6px; margin-bottom: 1.5rem; display: none;">
                    <legend style="padding: 0 1rem;">Faculty Information</legend>
                    
                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="employeeId">Employee ID *</label>
                            <input type="text" id="employeeId" name="employeeId" placeholder="e.g., EMP2020001">
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="department">Department *</label>
                            <input type="text" id="department" name="department" placeholder="e.g., Computer Science">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group" style="flex: 1;">
                            <label for="qualification">Qualification *</label>
                            <input type="text" id="qualification" name="qualification" placeholder="e.g., M.Tech, B.Tech">
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label for="experience">Experience (Years) *</label>
                            <input type="number" id="experience" name="experience" min="0" placeholder="0">
                        </div>
                    </div>
                </fieldset>

                <button type="submit" class="btn btn-primary" style="width: 100%; padding: 1rem; font-size: 1.1rem;">Register Now</button>
            </form>

            <p style="text-align: center; margin-top: 1.5rem;">
                Already have an account? <a href="login.jsp" style="font-weight: 600;">Login here</a>
            </p>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - DY Patil School of Science and Technology, Pune. All rights reserved.</p>
        </div>
    </footer>

    <style>
        .form-row {
            display: flex;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        fieldset {
            border-radius: 8px;
        }
        
        legend {
            font-weight: 600;
            color: var(--primary-color);
        }
    </style>
</body>
</html>
