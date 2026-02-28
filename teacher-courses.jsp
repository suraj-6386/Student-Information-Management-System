<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // Session Check - Fixed
    if (session == null || session.isNew() || 
        session.getAttribute("userId") == null || 
        session.getAttribute("userType") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (!"teacher".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int teacherId = (Integer) session.getAttribute("userId");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Courses - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .courses-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .course-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: transform 0.2s, box-shadow 0.2s;
            border-left: 5px solid #3498db;
        }
        
        .course-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .course-code {
            font-size: 0.85rem;
            color: #7f8c8d;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }
        
        .course-name {
            font-size: 1.3rem;
            font-weight: bold;
            color: #2c3e50;
            margin: 0.5rem 0;
        }
        
        .course-meta {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin: 1rem 0;
            padding: 1rem 0;
            border-top: 1px solid #ecf0f1;
            border-bottom: 1px solid #ecf0f1;
            font-size: 0.9rem;
        }
        
        .meta-item {
            display: flex;
            justify-content: space-between;
        }
        
        .meta-label {
            color: #7f8c8d;
            font-weight: 600;
        }
        
        .meta-value {
            color: #2c3e50;
            font-weight: bold;
        }
        
        .course-actions {
            display: flex;
            gap: 0.75rem;
            margin-top: 1rem;
        }
        
        .course-actions a {
            flex: 1;
            padding: 0.6rem;
            border-radius: 4px;
            text-align: center;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        
        .action-attendance {
            background: #3498db;
            color: white;
        }
        
        .action-attendance:hover {
            background: #2980b9;
        }
        
        .action-marks {
            background: #27ae60;
            color: white;
        }
        
        .action-marks:hover {
            background: #229954;
        }
        
        .action-students {
            background: #f39c12;
            color: white;
        }
        
        .action-students:hover {
            background: #d68910;
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }
        
        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1.5rem;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-card h3 {
            margin: 0;
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            margin: 0.5rem 0;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS - Teacher Portal</h1>
                <p>My Assigned Courses</p>
            </div>
            <div class="nav-links">
                <a href="teacher-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="teacher-courses.jsp" class="nav-link active">My Courses</a>
                <a href="teacher-students.jsp" class="nav-link">Students</a>
                <a href="teacher-attendance.jsp" class="nav-link">Attendance</a>
                <a href="teacher-marks.jsp" class="nav-link">Marks</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header">
            <h2>📚 My Assigned Courses</h2>
            <p>View and manage your courses</p>
        </div>

        <%
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                
                // Get total courses
                String countSQL = "SELECT COUNT(*) as total FROM subject_teacher WHERE teacher_id = ?";
                PreparedStatement countStmt = conn.prepareStatement(countSQL);
                countStmt.setInt(1, teacherId);
                ResultSet countRS = countStmt.executeQuery();
                int totalCourses = 0;
                if (countRS.next()) {
                    totalCourses = countRS.getInt("total");
                }
                countRS.close();
                countStmt.close();
                
                // Get total students
                String studentCountSQL = "SELECT COUNT(DISTINCT e.student_id) as total " +
                                        "FROM student_subject_enrollment e " +
                                        "JOIN subject_teacher st ON e.subject_id = st.subject_id " +
                                        "WHERE st.teacher_id = ?";
                PreparedStatement studentStmt = conn.prepareStatement(studentCountSQL);
                studentStmt.setInt(1, teacherId);
                ResultSet studentRS = studentStmt.executeQuery();
                int totalStudents = 0;
                if (studentRS.next()) {
                    totalStudents = studentRS.getInt("total");
                }
                studentRS.close();
                studentStmt.close();
        %>
        
        <!-- Statistics -->
        <div class="stats-container">
            <div class="stat-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                <h3>Total Subjects Assigned</h3>
                <div class="stat-value"><%= totalCourses %></div>
            </div>
            <div class="stat-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                <h3>Total Students</h3>
                <div class="stat-value"><%= totalStudents %></div>
            </div>
        </div>

        <%
                if (totalCourses == 0) {
        %>
        <div class="empty-state">
            <div class="empty-state-icon">📭</div>
            <h3>No Subjects Assigned Yet</h3>
            <p>Contact your administrator to assign subjects to your account.</p>
        </div>
        <%
                } else {
        %>
        
        <!-- Subjects List -->
        <div class="courses-grid">
        <%
                    // Get all subjects assigned to teacher
                    String sql = "SELECT s.subject_id, s.subject_code, s.subject_name, s.credits, s.semester, " +
                                "c.course_name, st.assigned_date, COUNT(DISTINCT e.student_id) as student_count " +
                                "FROM subjects s " +
                                "JOIN subject_teacher st ON s.subject_id = st.subject_id " +
                                "JOIN courses c ON s.course_id = c.course_id " +
                                "LEFT JOIN student_subject_enrollment e ON s.subject_id = e.subject_id AND e.status = 'active' " +
                                "WHERE st.teacher_id = ? " +
                                "GROUP BY s.subject_id " +
                                "ORDER BY c.course_name, s.semester, s.subject_code";
                    
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setInt(1, teacherId);
                    ResultSet rs = stmt.executeQuery();
                    
                    while (rs.next()) {
                        int subjectId = rs.getInt("subject_id");
                        String subjectCode = rs.getString("subject_code");
                        String subjectName = rs.getString("subject_name");
                        int credits = rs.getInt("credits");
                        int semester = rs.getInt("semester");
                        String courseName = rs.getString("course_name");
                        int studentCount = rs.getInt("student_count");
                        Timestamp assignedDate = rs.getTimestamp("assigned_date");
        %>
        
        <div class="course-card">
            <div class="course-code"><%= subjectCode %></div>
            <div class="course-name"><%= subjectName %></div>
            
            <div class="course-meta">
                <div class="meta-item">
                    <span class="meta-label">Degree Program:</span>
                    <span class="meta-value"><%= courseName %></span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Semester:</span>
                    <span class="meta-value"><%= semester %></span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Credits:</span>
                    <span class="meta-value"><%= credits %></span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Students:</span>
                    <span class="meta-value"><%= studentCount %></span>
                </div>
                <div class="meta-item">
                    <span class="meta-label">Assigned:</span>
                    <span class="meta-value">
                        <%
                            if (assignedDate != null) {
                                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                out.print(sdf.format(new java.util.Date(assignedDate.getTime())));
                            } else {
                                out.print("N/A");
                            }
                        %>
                    </span>
                </div>
            </div>
            
            <div class="course-actions">
                <a href="teacher-attendance.jsp" class="action-attendance" title="Mark Attendance">
                    ✓ Attendance
                </a>
                <a href="teacher-marks.jsp" class="action-marks" title="Enter Marks">
                    📊 Marks
                </a>
                <a href="teacher-students.jsp?subject_id=<%= subjectId %>" class="action-students" title="View Students">
                    👥 Students
                </a>
            </div>
        </div>
        
        <%
                    }
                    rs.close();
                    stmt.close();
        %>
        </div>
        
        <%
                }
                conn.close();
            } catch (Exception e) {
        %>
        <div class="alert alert-danger">
            Error loading courses: <%= e.getMessage() %>
        </div>
        <%
            }
        %>

        <div style="margin-top: 2rem;">
            <a href="teacher-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
