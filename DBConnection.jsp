<%@ page import="java.sql.*" %>

<%!
    Connection con = null;
%>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "15056324"
        );
    } catch(Exception e) {
        out.println("<!-- Database Connection Error: " + e.getMessage() + " -->");
    }
%>