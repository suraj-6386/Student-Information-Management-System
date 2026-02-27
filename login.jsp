<%@ include file="DBConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Student Management System</title>
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

        .login-container {
            background: white;
            padding: 40px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 380px;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-header h1 {
            color: #2c3e50;
            font-size: 24px;
            margin-bottom: 5px;
        }

        .login-header p {
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

        .form-group input {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #bdc3c7;
            border-radius: 3px;
            font-size: 13px;
            transition: border-color 0.3s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 5px rgba(52,152,219,0.2);
        }

        .form-group button {
            width: 100%;
            padding: 10px;
            background: #2c3e50;
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
            background: #1a252f;
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

        .home-link {
            text-align: center;
            margin-top: 15px;
        }

        .home-link a {
            color: #3498db;
            text-decoration: none;
            font-size: 12px;
        }

        .home-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>

<body>
    <div class="login-container">
        <div class="login-header">
            <h1>Login</h1>
            <p>Student Management System</p>
        </div>

        <%
            String errorMsg = "";
            if(request.getMethod().equals("POST")) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");

                try {
                    // Using PreparedStatement for security - check login credentials
                    PreparedStatement ps = con.prepareStatement(
                        "SELECT id, role, student_id, teacher_id FROM login WHERE username=? AND password=?"
                    );
                    ps.setString(1, username);
                    ps.setString(2, password);

                    ResultSet rs = ps.executeQuery();

                    if(rs.next()) {
                        String role = rs.getString("role");
                        int userId = rs.getInt("id");

                        // Store common session attributes
                        session.setAttribute("username", username);
                        session.setAttribute("role", role);
                        session.setAttribute("user_id", userId);

                        // Store role-specific ID and redirect accordingly
                        if(role.equals("student")) {
                            int studentId = rs.getInt("student_id");
                            session.setAttribute("student_id", studentId);
                            response.sendRedirect("studentDashboard.jsp");
                        }
                        else if(role.equals("teacher")) {
                            int teacherId = rs.getInt("teacher_id");
                            session.setAttribute("teacher_id", teacherId);
                            response.sendRedirect("teacherDashboard.jsp");
                        }
                        else if(role.equals("admin")) {
                            response.sendRedirect("adminDashboard.jsp");
                        }
                    } else {
                        errorMsg = "Invalid username or password!";
                    }
                    ps.close();
                } catch(Exception e) {
                    errorMsg = "Login error: " + e.getMessage();
                }
            }
        %>

        <% if(!errorMsg.isEmpty()) { %>
            <div class="error-message">⚠ <%= errorMsg %></div>
        <% } %>

        <form method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required placeholder="Enter your username">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required placeholder="Enter your password">
            </div>

            <div class="form-group">
                <button type="submit">Login</button>
            </div>
        </form>

        <div class="home-link">
            <a href="index.html">← Back to Home</a> | 
            <a href="registration.jsp">Create Account →</a>
        </div>
    </div>

</body>
</html>