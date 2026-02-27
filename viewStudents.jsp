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
    <title>View Students</title>
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
            width: 95%;
            max-width: 1200px;
            margin: 30px auto;
            background: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .page-title {
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 22px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
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

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table thead {
            background: #2c3e50;
            color: white;
        }

        table th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            border-bottom: 2px solid #ecf0f1;
        }

        table td {
            padding: 12px;
            border-bottom: 1px solid #ecf0f1;
            font-size: 13px;
        }

        table tbody tr:hover {
            background: #f9f9f9;
        }

        .action-buttons {
            display: flex;
            gap: 5px;
        }

        .btn-edit, .btn-delete {
            padding: 6px 12px;
            border: none;
            border-radius: 3px;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: transform 0.2s;
        }

        .btn-edit {
            background: #3498db;
            color: white;
        }

        .btn-edit:hover {
            background: #2980b9;
            transform: scale(1.05);
        }

        .btn-delete {
            background: #e74c3c;
            color: white;
        }

        .btn-delete:hover {
            background: #c0392b;
            transform: scale(1.05);
        }

        .add-btn {
            background: #27ae60;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin-bottom: 20px;
            font-size: 13px;
            font-weight: 600;
        }

        .add-btn:hover {
            background: #229954;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
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
        <h1>View All Students</h1>
    </header>

    <nav>
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="addStudent.jsp">Add Student</a>
        <a href="viewStudents.jsp">View Students</a>
        <a href="logout.jsp">Logout</a>
    </nav>

    <div class="container">
        <div class="page-title">Student Records</div>

        <%
            String message = "";
            String messageType = "";
            String action = request.getParameter("action");
            String id = request.getParameter("id");

            // Handle delete
            if("delete".equals(action) && id != null) {
                try {
                    PreparedStatement ps = con.prepareStatement("DELETE FROM students WHERE student_id=?");
                    ps.setInt(1, Integer.parseInt(id));
                    ps.executeUpdate();
                    ps.close();
                    message = "✓ Student deleted successfully!";
                    messageType = "success";
                } catch(Exception e) {
                    message = "Error deleting student: " + e.getMessage();
                    messageType = "error";
                }
            }
        %>

        <% if(!message.isEmpty()) { %>
            <div class="message <%= messageType %>-msg"><%= message %></div>
        <% } %>

        <a href="addStudent.jsp" class="add-btn">+ Add New Student</a>

        <%
            try {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM students ORDER BY student_id DESC");
                ResultSet rs = ps.executeQuery();

                if(!rs.isBeforeFirst()) {
        %>
                    <div class="no-data">No students found in the system.</div>
        <%
                } else {
        %>
                    <table>
                        <thead>
                            <tr>
                                <th>Student ID</th>
                                <th>Name</th>
                                <th>Course</th>
                                <th>Semester</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
        <%
                    while(rs.next()) {
        %>
                            <tr>
                                <td><%= rs.getInt("student_id") %></td>
                                <td><%= rs.getString("name") %></td>
                                <td><%= rs.getString("course") %></td>
                                <td><%= rs.getString("semester") %></td>
                                <td><%= rs.getString("email") %></td>
                                <td><%= rs.getString("phone") %></td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="editStudent.jsp?id=<%= rs.getInt("student_id") %>" class="btn-edit">Edit</a>
                                        <a href="viewStudents.jsp?action=delete&id=<%= rs.getInt("student_id") %>" class="btn-delete" onclick="return confirm('Are you sure?');">Delete</a>
                                    </div>
                                </td>
                            </tr>
        <%
                    }
        %>
                        </tbody>
                    </table>
        <%
                }
                rs.close();
                ps.close();
            } catch(Exception e) {
                out.println("<div class='message error-msg'>Error: " + e.getMessage() + "</div>");
            }
        %>
    </div>

    <footer>
        <p>&copy; 2026 Student Information Management System. All rights reserved.</p>
    </footer>

</body>
</html>