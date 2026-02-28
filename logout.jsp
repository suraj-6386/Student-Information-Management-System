<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    session.setAttribute("userId", null);
    session.setAttribute("userName", null);
    session.setAttribute("userType", null);
    session.setAttribute("userEmail", null);
    session.invalidate();
    response.sendRedirect("index.html");
%>
