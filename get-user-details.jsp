<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>

<%
    response.setHeader("Content-Type", "application/json");
    
    String userIdStr = request.getParameter("user_id");
    
    if (userIdStr == null || userIdStr.isEmpty()) {
        out.print("{}");
        return;
    }
    
    try {
        int userId = Integer.parseInt(userIdStr);
        
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        String sql = "SELECT full_name, email, phone, address, course_id, semester, " +
                    "parent_name, parent_contact, department, qualification, experience " +
                    "FROM users WHERE id = ?";
        
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        
        StringBuilder json = new StringBuilder("{");
        
        if (rs.next()) {
            json.append("\"full_name\":\"").append(rs.getString("full_name") != null ? rs.getString("full_name").replace("\"", "\\\"") : "").append("\",");
            json.append("\"email\":\"").append(rs.getString("email") != null ? rs.getString("email").replace("\"", "\\\"") : "").append("\",");
            json.append("\"phone\":\"").append(rs.getString("phone") != null ? rs.getString("phone").replace("\"", "\\\"") : "").append("\",");
            json.append("\"address\":\"").append(rs.getString("address") != null ? rs.getString("address").replace("\"", "\\\"") : "").append("\",");
            json.append("\"course_id\":").append(rs.getInt("course_id") > 0 ? rs.getInt("course_id") : "null").append(",");
            json.append("\"semester\":").append(rs.getInt("semester") > 0 ? rs.getInt("semester") : "null").append(",");
            json.append("\"parent_name\":\"").append(rs.getString("parent_name") != null ? rs.getString("parent_name").replace("\"", "\\\"") : "").append("\",");
            json.append("\"parent_contact\":\"").append(rs.getString("parent_contact") != null ? rs.getString("parent_contact").replace("\"", "\\\"") : "").append("\",");
            json.append("\"department\":\"").append(rs.getString("department") != null ? rs.getString("department").replace("\"", "\\\"") : "").append("\",");
            json.append("\"qualification\":\"").append(rs.getString("qualification") != null ? rs.getString("qualification").replace("\"", "\\\"") : "").append("\",");
            json.append("\"experience\":").append(rs.getInt("experience") > 0 ? rs.getInt("experience") : "null");
        }
        
        json.append("}");
        
        rs.close();
        stmt.close();
        conn.close();
        
        out.print(json.toString());
    } catch (Exception e) {
        out.print("{}");
    }
%>
