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
    <meta charset="UTF-8">
    <title>Edit Student - Student Management System</title>
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
        <h1>Edit Student</h1>
    </header>

    <nav>
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="addStudent.jsp">Add Student</a>
        <a href="viewStudents.jsp">View Students</a>
        <a href="logout.jsp">Logout</a>
    </nav>

    <div class="container">
        <div class="form-title">Update Student Information</div>

        <%
            String id = request.getParameter("id");
            String message = "";
            String messageType = "";
            String name = "", course = "", semester = "", email = "", phone = "";

            if(id == null || id.trim().isEmpty()) {
                message = "Invalid student ID!";
                messageType = "error";
            } else {
                // Handle update
                if(request.getMethod().equals("POST")) {
                    try {
                        name = request.getParameter("name");
                        course = request.getParameter("course");
                        semester = request.getParameter("semester");
                        email = request.getParameter("email");
                        phone = request.getParameter("phone");

                        if(name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty() ||
                           phone == null || phone.trim().isEmpty()) {
                            message = "All fields are required!";
                            messageType = "error";
                        } else {
                            PreparedStatement ps = con.prepareStatement(
                                "UPDATE students SET name=?, course=?, semester=?, email=?, phone=? WHERE student_id=?"
                            );
                            ps.setString(1, name);
                            ps.setString(2, course);
                            ps.setString(3, semester);
                            ps.setString(4, email);
                            ps.setString(5, phone);
                            ps.setInt(6, Integer.parseInt(id));

                            ps.executeUpdate();
                            ps.close();
                            message = "✓ Student updated successfully!";
                            messageType = "success";
                        }
                    } catch(Exception e) {
                        message = "Error: " + e.getMessage();
                        messageType = "error";
                    }
                } else {
                    // Fetch student data
                    try {
                        PreparedStatement ps = con.prepareStatement("SELECT * FROM students WHERE student_id=?");
                        ps.setInt(1, Integer.parseInt(id));
                        ResultSet rs = ps.executeQuery();

                        if(rs.next()) {
                            name = rs.getString("name");
                            course = rs.getString("course");
                            semester = rs.getString("semester");
                            email = rs.getString("email");
                            phone = rs.getString("phone");
                        } else {
                            message = "Student not found!";
                            messageType = "error";
                        }
                        rs.close();
                        ps.close();
                    } catch(Exception e) {
                        message = "Error: " + e.getMessage();
                        messageType = "error";
                    }
                }
            }
        %>

        <% if(!message.isEmpty()) { %>
            <div class="message <%= messageType %>-msg"><%= message %></div>
        <% } %>

        <% if(id != null && !id.trim().isEmpty() && message.isEmpty()) { %>
            <form method="post">
                <div class="form-group">
                    <label for="name">Full Name *</label>
                    <input type="text" id="name" name="name" required placeholder="Enter student's full name" value="<%= name %>">
                </div>

                <div class="form-group">
                    <label for="course">Course *</label>
                    <select id="course" name="course" required>
                        <option value="">-- Select Course --</option>
                        <option value="B.Tech" <%= "B.Tech".equals(course) ? "selected" : "" %>>B.Tech</option>
                        <option value="B.Sc" <%= "B.Sc".equals(course) ? "selected" : "" %>>B.Sc</option>
                        <option value="M.Tech" <%= "M.Tech".equals(course) ? "selected" : "" %>>M.Tech</option>
                        <option value="MBA" <%= "MBA".equals(course) ? "selected" : "" %>>MBA</option>
                        <option value="BCA" <%= "BCA".equals(course) ? "selected" : "" %>>BCA</option>
                        <option value="MCA" <%= "MCA".equals(course) ? "selected" : "" %>>MCA</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="semester">Semester *</label>
                    <select id="semester" name="semester" required>
                        <option value="">-- Select Semester --</option>
                        <option value="1" <%= "1".equals(semester) ? "selected" : "" %>>1st Semester</option>
                        <option value="2" <%= "2".equals(semester) ? "selected" : "" %>>2nd Semester</option>
                        <option value="3" <%= "3".equals(semester) ? "selected" : "" %>>3rd Semester</option>
                        <option value="4" <%= "4".equals(semester) ? "selected" : "" %>>4th Semester</option>
                        <option value="5" <%= "5".equals(semester) ? "selected" : "" %>>5th Semester</option>
                        <option value="6" <%= "6".equals(semester) ? "selected" : "" %>>6th Semester</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email" required placeholder="Enter student's email" value="<%= email %>">
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="text" id="phone" name="phone" required placeholder="Enter 10-digit phone number" maxlength="10" value="<%= phone %>">
                </div>

                <div class="form-buttons">
                    <button type="submit" class="btn-submit">Update Student</button>
                    <a href="viewStudents.jsp" class="btn-cancel">Cancel</a>
                </div>
            </form>
        <% } else { %>
            <div style="text-align: center; padding: 20px;">
                <a href="viewStudents.jsp" class="btn-cancel" style="max-width: 200px; display: inline-flex;">Back to Students</a>
            </div>
        <% } %>
    </div>

    <footer>
        <p>&copy; 2026 Student Information Management System. All rights reserved.</p>
    </footer>

</body>
</html>
