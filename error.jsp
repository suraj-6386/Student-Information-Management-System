<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - SIMS</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS</h1>
                <p>Error Page</p>
            </div>
            <div class="nav-links">
                <a href="index.html" class="nav-link">Home</a>
                <a href="login.jsp" class="nav-link">Login</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container" style="text-align: center;">
        <div style="background: white; padding: 3rem; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <div style="font-size: 4rem; margin-bottom: 1rem;">⚠️</div>
            <h2 style="color: #ef4444;">Oops! An Error Occurred</h2>
            
            <p style="font-size: 1.1rem; color: #666; margin: 1.5rem 0;">
                We apologize for the inconvenience. An error occurred while processing your request.
            </p>

            <div style="background: #fee2e2; color: #7f1d1d; padding: 1.5rem; border-radius: 4px; margin: 2rem 0; text-align: left;">
                <strong>Error Details:</strong><br>
                <% 
                    String errorMessage = (String) request.getAttribute("error");
                    if (errorMessage != null) {
                        out.println(errorMessage);
                    } else {
                        out.println("An unexpected error has occurred. Please try again later.");
                    }
                %>
            </div>

            <div style="margin-top: 2rem;">
                <a href="index.html" class="btn btn-primary" style="margin-right: 1rem;">Go to Home</a>
                <a href="login.jsp" class="btn btn-secondary">Go to Login</a>
            </div>

            <p style="color: #999; margin-top: 2rem; font-size: 0.9rem;">
                If this error persists, please contact the administrator at support@sims.edu
            </p>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
