<%
    // Invalidate the session to logout
    session.invalidate();
    response.sendRedirect("index.html");
%>