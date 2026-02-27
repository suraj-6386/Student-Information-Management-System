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
    <title>Teacher Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f6f8;
            color: #333;
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

        .user-info {
            text-align: right;
            font-size: 12px;
            margin-top: -25px;
            padding: 0 20px;
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
            border-radius: 3px;
        }

        nav a:hover {
            background: #2c3e50;
        }

        .container {
            width: 85%;
            max-width: 1200px;
            margin: 40px auto;
            background: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .dashboard-title {
            color: #2c3e50;
            margin-bottom: 30px;
            font-size: 22px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .menu-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 25px;
            border-radius: 5px;
            color: white;
            text-decoration: none;
            transition: transform 0.3s, box-shadow 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-left: 5px solid white;
        }

        .menu-card:nth-child(2) {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }

        .menu-card:nth-child(3) {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }

        .menu-card:nth-child(4) {
            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
        }

        .menu-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .menu-card h3 {
            font-size: 16px;
            margin-bottom: 10px;
            font-weight: 600;
        }

        .menu-card p {
            font-size: 13px;
            opacity: 0.9;
        }

        footer {
            text-align: center;
            padding: 20px;
            color: #7f8c8d;
            font-size: 12px;
            border-top: 1px solid #ecf0f1;
        }
    </style>
</head>

<body>
    <header>
        <h1>Teacher Dashboard</h1>
        <div class="user-info">
            Logged in as: <strong><%= session.getAttribute("username") %></strong> | <a href="logout.jsp" style="color: #3498db; text-decoration: none;">Logout</a>
        </div>
    </header>

    <nav>
        <a href="teacherDashboard.jsp">Dashboard</a>
        <a href="viewStudents.jsp">View Students</a>
        <a href="marksEntry.jsp">Enter Marks</a>
        <a href="attendance.jsp">Update Attendance</a>
        <a href="logout.jsp">Logout</a>
    </nav>

    <div class="container">
        <div class="dashboard-title">Welcome, Teacher!</div>

        <div class="menu-grid">
            <a href="viewStudents.jsp" class="menu-card">
                <h3>👥 View Students</h3>
                <p>View all registered students</p>
            </a>

            <a href="marksEntry.jsp" class="menu-card">
                <h3>📝 Enter Marks</h3>
                <p>Record and manage student marks</p>
            </a>

            <a href="attendance.jsp" class="menu-card">
                <h3>📋 Update Attendance</h3>
                <p>Mark and track attendance</p>
            </a>

            <a href="logout.jsp" class="menu-card">
                <h3>🚪 Logout</h3>
                <p>Exit from the system securely</p>
            </a>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Student Information Management System. All rights reserved.</p>
    </footer>

</body>
</html>