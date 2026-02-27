<%@ include file="DBConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Register - Student Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f6f8;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .register-container {
            background: white;
            padding: 40px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 450px;
        }

        .register-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .register-header h1 {
            color: #2c3e50;
            font-size: 24px;
            margin-bottom: 5px;
        }

        .register-header p {
            color: #7f8c8d;
            font-size: 13px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #2c3e50;
            font-size: 13px;
            font-weight: 600;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #bdc3c7;
            border-radius: 3px;
            font-size: 13px;
            transition: border-color 0.3s;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 5px rgba(52,152,219,0.2);
        }

        .form-group button {
            width: 100%;
            padding: 10px;
            background: #27ae60;
            color: white;
            border: none;
            border-radius: 3px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
            margin-top: 10px;
        }

        .form-group button:hover {
            background: #229954;
        }

        .error-message {
            color: #e74c3c;
            background: #fadbd8;
            padding: 10px;
            border-radius: 3px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid #e74c3c;
        }

        .success-message {
            color: #27ae60;
            background: #d5f4e6;
            padding: 10px;
            border-radius: 3px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid #27ae60;
        }

        .bottom-link {
            text-align: center;
            margin-top: 15px;
        }

        .bottom-link a {
            color: #3498db;
            text-decoration: none;
            font-size: 12px;
        }

        .bottom-link a:hover {
            text-decoration: underline;
        }

        .role-info {
            background: #ecf0f1;
            padding: 10px;
            border-radius: 3px;
            font-size: 12px;
            color: #2c3e50;
            margin-top: 20px;
        }
    </style>
</head>

<body>
    <div class="register-container">
        <div class="register-header">
            <h1>Create Account</h1>
            <p>Student Management System</p>
        </div>

        <%
            String errorMsg = "";
            String successMsg = "";
            
            if(request.getMethod().equals("POST")) {
                String role = request.getParameter("role");
                String name = request.getParameter("name");
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String confirmPassword = request.getParameter("confirmPassword");
                String email = request.getParameter("email");
                String studentCourse = request.getParameter("studentCourse");
                String studentSemester = request.getParameter("studentSemester");
                String studentPhone = request.getParameter("studentPhone");
                String teacherSubject = request.getParameter("teacherSubject");
                String teacherPhone = request.getParameter("teacherPhone");

                try {
                    // Validation
                    if(name == null || name.trim().isEmpty() || 
                       username == null || username.trim().isEmpty() ||
                       password == null || password.trim().isEmpty() ||
                       email == null || email.trim().isEmpty()) {
                        errorMsg = "All fields are required!";
                    }
                    else if(!password.equals(confirmPassword)) {
                        errorMsg = "Passwords do not match!";
                    }
                    else if(role == null || role.trim().isEmpty()) {
                        errorMsg = "Please select a role!";
                    }
                    else if(password.length() < 6) {
                        errorMsg = "Password must be at least 6 characters long!";
                    }
                    else {
                        // Check if username already exists
                        PreparedStatement checkPs = con.prepareStatement(
                            "SELECT username FROM login WHERE username=?"
                        );
                        checkPs.setString(1, username);
                        ResultSet checkRs = checkPs.executeQuery();

                        if(checkRs.next()) {
                            errorMsg = "Username already exists! Please choose another.";
                        } else {
                            // Registration logic based on role
                            if("student".equals(role)) {
                                String course = studentCourse;
                                String semester = studentSemester;
                                String phone = studentPhone;

                                if(course == null || course.trim().isEmpty() || 
                                   semester == null || semester.trim().isEmpty() ||
                                   phone == null || phone.trim().isEmpty()) {
                                    errorMsg = "Please fill all student fields!";
                                } else {
                                    // Insert into students table
                                    PreparedStatement studentPs = con.prepareStatement(
                                        "INSERT INTO students (name, course, semester, email, phone) VALUES (?, ?, ?, ?, ?)",
                                        java.sql.Statement.RETURN_GENERATED_KEYS
                                    );
                                    studentPs.setString(1, name);
                                    studentPs.setString(2, course);
                                    studentPs.setString(3, semester);
                                    studentPs.setString(4, email);
                                    studentPs.setString(5, phone);
                                    studentPs.executeUpdate();

                                    // Get generated student_id
                                    ResultSet geneKeys = studentPs.getGeneratedKeys();
                                    int studentId = 0;
                                    if(geneKeys.next()) {
                                        studentId = geneKeys.getInt(1);
                                    }

                                    // Insert into login table with student_id
                                    PreparedStatement loginPs = con.prepareStatement(
                                        "INSERT INTO login (username, password, role, student_id) VALUES (?, ?, ?, ?)"
                                    );
                                    loginPs.setString(1, username);
                                    loginPs.setString(2, password);
                                    loginPs.setString(3, "student");
                                    loginPs.setInt(4, studentId);
                                    loginPs.executeUpdate();
                                    loginPs.close();

                                    successMsg = "✓ Student registration successful! You can now login.";
                                    studentPs.close();
                                }
                            } 
                            else if("teacher".equals(role)) {
                                String subject = teacherSubject;
                                String phone = teacherPhone;

                                if(subject == null || subject.trim().isEmpty() || 
                                   phone == null || phone.trim().isEmpty()) {
                                    errorMsg = "Please fill all teacher fields!";
                                } else {
                                    // Insert into teachers table
                                    PreparedStatement teacherPs = con.prepareStatement(
                                        "INSERT INTO teachers (name, subject, email, phone) VALUES (?, ?, ?, ?)",
                                        java.sql.Statement.RETURN_GENERATED_KEYS
                                    );
                                    teacherPs.setString(1, name);
                                    teacherPs.setString(2, subject);
                                    teacherPs.setString(3, email);
                                    teacherPs.setString(4, phone);
                                    teacherPs.executeUpdate();

                                    // Get generated teacher_id
                                    ResultSet geneKeys = teacherPs.getGeneratedKeys();
                                    int teacherId = 0;
                                    if(geneKeys.next()) {
                                        teacherId = geneKeys.getInt(1);
                                    }

                                    // Insert into login table with teacher_id
                                    PreparedStatement loginPs = con.prepareStatement(
                                        "INSERT INTO login (username, password, role, teacher_id) VALUES (?, ?, ?, ?)"
                                    );
                                    loginPs.setString(1, username);
                                    loginPs.setString(2, password);
                                    loginPs.setString(3, "teacher");
                                    loginPs.setInt(4, teacherId);
                                    loginPs.executeUpdate();
                                    loginPs.close();

                                    successMsg = "✓ Teacher registration successful! You can now login.";
                                    teacherPs.close();
                                }
                            }
                        }
                        checkPs.close();
                    }
                } catch(Exception e) {
                    errorMsg = "Registration error: " + e.getMessage();
                }
            }
        %>

        <% if(!errorMsg.isEmpty()) { %>
            <div class="error-message">⚠ <%= errorMsg %></div>
        <% } %>

        <% if(!successMsg.isEmpty()) { %>
            <div class="success-message"><%= successMsg %></div>
            <div style="text-align: center; margin-top: 20px;">
                <a href="login.jsp" style="background: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 3px; display: inline-block;">Go to Login</a>
            </div>
        <% } else { %>

        <form method="post">
            <div class="form-group">
                <label for="role">Register as *</label>
                <select id="role" name="role" required onchange="updateFields()">
                    <option value="">-- Select Role --</option>
                    <option value="student">Student</option>
                    <option value="teacher">Teacher</option>
                </select>
            </div>

            <div class="form-group">
                <label for="name">Full Name *</label>
                <input type="text" id="name" name="name" required placeholder="Enter your full name">
            </div>

            <div class="form-group">
                <label for="username">Username *</label>
                <input type="text" id="username" name="username" required placeholder="Choose a username">
            </div>

            <div class="form-group">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email" required placeholder="Enter your email">
            </div>

            <div class="form-group">
                <label for="password">Password *</label>
                <input type="password" id="password" name="password" required placeholder="Minimum 6 characters">
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password *</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Re-enter password">
            </div>

            <div id="studentFields" style="display: none;">
                <div class="form-group">
                    <label for="studentCourse">Course *</label>
                    <select id="studentCourse" name="studentCourse">
                        <option value="">-- Select Course --</option>
                        <option value="B.Tech">B.Tech</option>
                        <option value="B.Sc">B.Sc</option>
                        <option value="M.Tech">M.Tech</option>
                        <option value="MBA">MBA</option>
                        <option value="BCA">BCA</option>
                        <option value="MCA">MCA</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="studentSemester">Semester *</label>
                    <select id="studentSemester" name="studentSemester">
                        <option value="">-- Select Semester --</option>
                        <option value="1">1st Semester</option>
                        <option value="2">2nd Semester</option>
                        <option value="3">3rd Semester</option>
                        <option value="4">4th Semester</option>
                        <option value="5">5th Semester</option>
                        <option value="6">6th Semester</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="studentPhone">Phone Number *</label>
                    <input type="text" id="studentPhone" name="studentPhone" placeholder="10-digit phone number" maxlength="10">
                </div>
            </div>

            <div id="teacherFields" style="display: none;">
                <div class="form-group">
                    <label for="teacherSubject">Subject *</label>
                    <input type="text" id="teacherSubject" name="teacherSubject" placeholder="e.g., Mathematics, English">
                </div>

                <div class="form-group">
                    <label for="teacherPhone">Phone Number *</label>
                    <input type="text" id="teacherPhone" name="teacherPhone" placeholder="10-digit phone number" maxlength="10">
                </div>
            </div>

            <div class="form-group">
                <button type="submit">Create Account</button>
            </div>
        </form>

        <div class="role-info">
            <strong>Note:</strong> Admin accounts are pre-created. Students and Teachers can register here.
        </div>

        <% } %>

        <div class="bottom-link">
            Already have an account? <a href="login.jsp">Login here →</a>
        </div>
    </div>

    <script>
        function updateFields() {
            var role = document.getElementById("role").value;
            var studentFields = document.getElementById("studentFields");
            var teacherFields = document.getElementById("teacherFields");

            if(role === "student") {
                studentFields.style.display = "block";
                teacherFields.style.display = "none";
            } else if(role === "teacher") {
                studentFields.style.display = "none";
                teacherFields.style.display = "block";
            } else {
                studentFields.style.display = "none";
                teacherFields.style.display = "none";
            }
        }
    </script>

</body>
</html>
