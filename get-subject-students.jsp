<%@ page import="java.sql.*" %>
<%@ page contentType="application/json" %>
<%@ page import="java.util.*" %>

<%
    Integer subjectId = null;
    try {
        subjectId = Integer.parseInt(request.getParameter("subject_id"));
    } catch (Exception e) {
        out.print("{\"error\": \"Invalid subject_id\"}");
        return;
    }
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        String query = "SELECT st.student_id, st.full_name, st.roll_number, st.email " +
                       "FROM student st " +
                       "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                       "WHERE se.subject_id = ? AND se.status = 'active' AND st.status = 'active' " +
                       "ORDER BY st.full_name";
        
        PreparedStatement pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, subjectId);
        
        ResultSet rs = pstmt.executeQuery();
        
        out.print("[");
        boolean first = true;
        while (rs.next()) {
            if (!first) out.print(",");
            out.print("{");
            out.print("\"student_id\": " + rs.getInt("student_id") + ",");
            out.print("\"full_name\": \"" + rs.getString("full_name") + "\",");
            out.print("\"roll_number\": \"" + (rs.getString("roll_number") != null ? rs.getString("roll_number") : "") + "\",");
            out.print("\"email\": \"" + rs.getString("email") + "\"");
            out.print("}");
            first = false;
        }
        out.print("]");
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.print("{\"error\": \"" + e.getMessage() + "\"}");
    }
%>
