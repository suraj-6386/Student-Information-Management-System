<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    Integer subjectId = null;
    try {
        subjectId = Integer.parseInt(request.getParameter("subject_id"));
    } catch (Exception e) {
        out.print("<tr><td colspan='4' style='text-align:center;color:red;'>Invalid subject ID</td></tr>");
        return;
    }
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
        
        String query = "SELECT st.student_id, st.full_name, st.roll_number " +
                       "FROM student st " +
                       "JOIN subject_enrollment se ON st.student_id = se.student_id " +
                       "WHERE se.subject_id = ? AND se.status = 'active' AND st.status = 'approved' " +
                       "ORDER BY st.roll_number";
        
        PreparedStatement pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, subjectId);
        
        ResultSet rs = pstmt.executeQuery();
        
        boolean hasStudents = false;
        int counter = 1;
        while (rs.next()) {
            hasStudents = true;
            int studentId = rs.getInt("student_id");
            String fullName = rs.getString("full_name");
            String rollNumber = rs.getString("roll_number") != null ? rs.getString("roll_number") : "N/A";
%>
            <tr>
                <td><%= counter %></td>
                <td><%= rollNumber %></td>
                <td><%= fullName %></td>
                <td class="checkbox-col">
                    <input type="checkbox" name="present_<%= studentId %>" value="Present">
                </td>
            </tr>
<%
            counter++;
        }
        
        if (!hasStudents) {
            out.print("<tr><td colspan='4' style='text-align:center;'>No students enrolled in this subject</td></tr>");
        }
        
        rs.close();
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        out.print("<tr><td colspan='4' style='text-align:center;color:red;'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
