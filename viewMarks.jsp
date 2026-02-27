<%@ include file="DBConnection.jsp" %>

<%
    // SESSION SECURITY CHECK - Student only
    String role = (String) session.getAttribute("role");
    if(role == null || !role.equals("student")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Marks - Student Management System</title>
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
            max-width: 900px;
            margin: 30px auto;
            background: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .table-title {
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 22px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
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

        .no-data {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }

        .back-link {
            margin-top: 20px;
            text-align: center;
        }

        .back-link a {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 3px;
            display: inline-block;
            transition: background 0.3s;
        }

        .back-link a:hover {
            background: #2980b9;
        }

        .error-msg {
            background: #fadbd8;
            color: #e74c3c;
            padding: 15px;
            border-radius: 3px;
            border-left: 4px solid #e74c3c;
            margin-bottom: 20px;
        }

        .mark-pending {
            color: #7f8c8d;
            font-style: italic;
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
        <h1>My Marks</h1>
    </header>

    <nav>
        <a href="studentDashboard.jsp">Dashboard</a>
        <a href="profile.jsp">View Profile</a>
        <a href="viewMarks.jsp">View Marks</a>
        <a href="viewAttendance.jsp">View Attendance</a>
        <a href="logout.jsp">Logout</a>
    </nav>

    <div class="container">
        <div class="table-title">Your Marks Records</div>

        <%
            try {
                Integer sid = (Integer) session.getAttribute("student_id");

                if(sid == null || sid == 0) {
                    out.println("<div class='error-msg'>Error: Could not retrieve student ID from session.</div>");
                } else {
                    // Default subjects for all students
                    String[] defaultSubjects = {"Advanced Java", "DBMS", "AI", "ReactJS", "Research Methodology", "German Language"};
                    
                    // Get marks for this student
                    PreparedStatement ps = con.prepareStatement("SELECT subject, marks FROM marks WHERE student_id=?");
                    ps.setInt(1, sid);
                    ResultSet rs = ps.executeQuery();
                    
                    java.util.HashMap<String, Integer> marksMap = new java.util.HashMap<>();
                    while(rs.next()) {
                        marksMap.put(rs.getString("subject"), rs.getInt("marks"));
                    }
                    rs.close();
                    ps.close();
        %>
                    <table>
                        <thead>
                            <tr>
                                <th>Subject</th>
                                <th>Marks</th>
                                <th>Percentage</th>
                            </tr>
                        </thead>
                        <tbody>
        <%
                    for(String subject : defaultSubjects) {
                        if(marksMap.containsKey(subject)) {
                            int marks = marksMap.get(subject);
                            double percentage = marks;
        %>
                            <tr>
                                <td><%= subject %></td>
                                <td><%= marks %>/100</td>
                                <td><%= percentage %>%</td>
                            </tr>
        <%
                        } else {
        %>
                            <tr>
                                <td><%= subject %></td>
                                <td class="mark-pending">Pending</td>
                                <td class="mark-pending">-</td>
                            </tr>
        <%
                        }
                    }
                    }
                }
            } catch(Exception e) {
                out.println("<div class='error-msg'>Error: " + e.getMessage() + "</div>");
            }
        %>

        <div class="back-link">
            <a href="studentDashboard.jsp">← Back to Dashboard</a>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Student Information Management System. All rights reserved.</p>
    </footer>

</body>
</html>