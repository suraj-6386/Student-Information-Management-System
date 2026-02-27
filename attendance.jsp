<%@ include file="DBConnection.jsp" %>

<%
    // SESSION SECURITY CHECK - Teacher only
    String role = (String) session.getAttribute("role");
    if(role == null || !role.equals("teacher")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Attendance - Student Management System</title>
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
        <h1>Update Student Attendance</h1>
    </header>

    <nav>
        <a href="teacherDashboard.jsp">Dashboard</a>
        <a href="marksEntry.jsp">Enter Marks</a>
        <a href="attendance.jsp">Update Attendance</a>
        <a href="logout.jsp">Logout</a>
    </nav>

    <div class="container">
        <div class="form-title">Record Attendance</div>

        <%
            String message = "";
            String messageType = "";

            if(request.getMethod().equals("POST")) {
                try {
                    String sid = request.getParameter("sid");
                    String subject = request.getParameter("subject");
                    String date = request.getParameter("date");
                    String status = request.getParameter("status");

                    if(sid == null || sid.trim().isEmpty() || subject == null || subject.trim().isEmpty() || 
                       date == null || date.trim().isEmpty() || status == null || status.trim().isEmpty()) {
                        message = "All fields are required!";
                        messageType = "error";
                    } else {
                        int studentId = Integer.parseInt(sid);

                        // Check if student exists
                        PreparedStatement check = con.prepareStatement("SELECT * FROM students WHERE student_id=?");
                        check.setInt(1, studentId);
                        ResultSet checkRs = check.executeQuery();

                        if(!checkRs.next()) {
                            message = "Student ID does not exist!";
                            messageType = "error";
                        } else {
                            PreparedStatement ps = con.prepareStatement(
                                "INSERT INTO attendance(student_id, subject, date, status) VALUES(?, ?, ?, ?)"
                            );
                            ps.setInt(1, studentId);
                            ps.setString(2, subject);
                            ps.setString(3, date);
                            ps.setString(4, status);
                            ps.executeUpdate();
                            ps.close();
                            message = "✓ Attendance recorded successfully!";
                            messageType = "success";
                        }
                        checkRs.close();
                        check.close();
                    }
                } catch(NumberFormatException e) {
                    message = "Invalid Student ID!";
                    messageType = "error";
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
                <label for="sid">Student ID *</label>
                <input type="number" id="sid" name="sid" required placeholder="Enter student ID">
            </div>

            <div class="form-group">
                <label for="subject">Subject *</label>
                <select id="subject" name="subject" required>
                    <option value="">-- Select Subject --</option>
                    <option value="Advanced Java">Advanced Java</option>
                    <option value="DBMS">DBMS</option>
                    <option value="AI">AI</option>
                    <option value="ReactJS">ReactJS</option>
                    <option value="Research Methodology">Research Methodology</option>
                    <option value="German Language">German Language</option>
                </select>
            </div>

            <div class="form-group">
                <label for="date">Date *</label>
                <input type="date" id="date" name="date" required>
            </div>

            <div class="form-group">
                <label for="status">Attendance Status *</label>
                <select id="status" name="status" required>
                    <option value="">-- Select Status --</option>
                    <option value="Present">Present</option>
                    <option value="Absent">Absent</option>
                </select>
            </div>

            <div class="form-buttons">
                <button type="submit" class="btn-submit">Record Attendance</button>
                <a href="teacherDashboard.jsp" class="btn-cancel">Cancel</a>
            </div>
        </form>
    </div>

    <footer>
        <p>&copy; 2026 Student Information Management System. All rights reserved.</p>
    </footer>

</body>
</html>