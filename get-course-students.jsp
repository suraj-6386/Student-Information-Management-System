<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>

<%
    response.setHeader("Content-Type", "application/json");
    
    // Get course_id from request parameter
    String courseIdStr = request.getParameter("course_id");
    
    if (courseIdStr == null || courseIdStr.isEmpty()) {
        out.print("[]");
        return;
    }
    
    try {
        int courseId = Integer.parseInt(courseIdStr);
        
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        // Query: Get all students enrolled in the course, sorted by roll number
        String sql = "SELECT u.user_id, u.full_name, u.email, u.roll_number " +
                    "FROM users u " +
                    "JOIN student_subject_enrollment e ON u.user_id = e.student_id " +
                    "JOIN subjects sub ON e.subject_id = sub.subject_id " +
                    "WHERE sub.course_id = ? AND u.status = 'approved' AND u.user_type = 'student' " +
                    "ORDER BY u.roll_number ASC";
        
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, courseId);
        ResultSet rs = stmt.executeQuery();
        
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        
        while (rs.next()) {
            if (!first) json.append(",");
            json.append("{");
            json.append("\"id\":").append(rs.getInt("user_id")).append(",");
            json.append("\"full_name\":\"").append(rs.getString("full_name").replace("\"", "\\\"")).append("\",");
            json.append("\"email\":\"").append(rs.getString("email").replace("\"", "\\\"")).append("\",");
            json.append("\"roll_number\":\"").append((rs.getString("roll_number") != null ? rs.getString("roll_number") : "").replace("\"", "\\\"")).append("\"");
            json.append("}");
            first = false;
        }
        
        json.append("]");
        
        rs.close();
        stmt.close();
        conn.close();
        
        out.print(json.toString());
    } catch (Exception e) {
        out.print("[]");
    }
%>
