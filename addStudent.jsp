<%@ include file="DBConnection.jsp" %>

<%
    // SESSION SECURITY CHECK - Admin only
    String role = (String) session.getAttribute("role");
    if(role == null || !role.equals("admin")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Add Student</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f6f8;
        }

        header {
            background: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        header h1 {
            font-size: 24px;
            font-weight: 600;
        }

        nav {
            background: #34495e;
            padding: 15px 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        nav a {
            color: white;
            text-decoration: none;
            padding: 10px 15px;
            display: inline-block;
            font-size: 14px;
            transition: background 0.3s;
        }

        nav a:hover {
            background: #2c3e50;
        }

        .container {
            width: 85%;
            max-width: 600px;
            margin: 40px auto;
            background: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .form-title {
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 20px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 6px;
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

        .form-buttons {
            display: flex;
            gap: 10px;
            margin-top: 25px;
        }

        button {
            flex: 1;
            padding: 10px;
            border: none;
            border-radius: 3px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.3s;
        }

        .btn-submit {
            background: #27ae60;
            color: white;
        }

        .btn-submit:hover {
            background: #229954;
        }

        .btn-cancel {
            background: #95a5a6;
            color: white;
            text-decoration: none;
            text-align: center;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-cancel:hover {
            background: #7f8c8d;
        }

        .message {
            padding: 12px;
            border-radius: 3px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid;
        }

        .success-msg {
            background: #d5f4e6;
            color: #27ae60;
            border-left-color: #27ae60;
        }

        .error-msg {
            background: #fadbd8;
            color: #e74c3c;
            border-left-color: #e74c3c;
        }

        footer {
            text-align: center;
            padding: 20px;
            color: #7f8c8d;
            font-size: 12px;
            border-top: 1px solid #ecf0f1;
            margin-top: 30px;
        }
    </style>
</head>

<body>
    <header>
        <h1>Add New Student</h1>
    </header>

    <nav>
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="addStudent.jsp">Add Student</a>
        <a href="viewStudents.jsp">View Students</a>
        <a href="logout.jsp">Logout</a>
    </nav>

    <div class="container">
        <div class="form-title">Student Registration Form</div>

        <%
            String message = "";
            String messageType = "";

            if(request.getMethod().equals("POST")) {
                try {
                    String name = request.getParameter("name");
                    String course = request.getParameter("course");
                    String semester = request.getParameter("semester");
                    String email = request.getParameter("email");
                    String phone = request.getParameter("phone");

                    // Validate input
                    if(name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty() || 
                       phone == null || phone.trim().isEmpty()) {
                        message = "All fields are required!";
                        messageType = "error";
                    } else {
                        PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO students(name, course, semester, email, phone) VALUES(?, ?, ?, ?, ?)"
                        );
                        ps.setString(1, name);
                        ps.setString(2, course);
                        ps.setString(3, semester);
                        ps.setString(4, email);
                        ps.setString(5, phone);

                        ps.executeUpdate();
                        ps.close();
                        message = "✓ Student added successfully!";
                        messageType = "success";
                    }
                } catch(Exception e) {
                    message = "Error: " + e.getMessage();
                    messageType = "error";
                }
            }
        %>

        <% if(!message.isEmpty()) { %>
            <div class="message <%= messageType %>-msg"><%= message %></div>
        <% } %>

        <form method="post">
            <div class="form-group">
                <label for="name">Full Name *</label>
                <input type="text" id="name" name="name" required placeholder="Enter student's full name">
            </div>

            <div class="form-group">
                <label for="course">Course *</label>
                <select id="course" name="course" required>
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
                <label for="semester">Semester *</label>
                <select id="semester" name="semester" required>
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
                <label for="email">Email *</label>
                <input type="email" id="email" name="email" required placeholder="Enter student's email">
            </div>

            <div class="form-group">
                <label for="phone">Phone Number *</label>
                <input type="text" id="phone" name="phone" required placeholder="Enter 10-digit phone number" maxlength="10">
            </div>

            <div class="form-buttons">
                <button type="submit" class="btn-submit">Add Student</button>
                <a href="adminDashboard.jsp" class="btn-cancel">Cancel</a>
            </div>
        </form>
    </div>

    <footer>
        <p>&copy; 2026 Student Information Management System. All rights reserved.</p>
    </footer>

</body>
</html>