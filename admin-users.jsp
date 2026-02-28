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
    
    if (!"admin".equals(session.getAttribute("userType"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    
    // Handle user update
    if ("POST".equalsIgnoreCase(request.getMethod()) && "update".equals(request.getParameter("action"))) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
            
            int userId = Integer.parseInt(request.getParameter("user_id"));
            String fullName = request.getParameter("full_name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String userType = request.getParameter("user_type");
            
            // Check if email already exists for another user
            String emailCheckSQL = "SELECT id FROM users WHERE email = ? AND id != ?";
            PreparedStatement emailStmt = conn.prepareStatement(emailCheckSQL);
            emailStmt.setString(1, email);
            emailStmt.setInt(2, userId);
            ResultSet emailRS = emailStmt.executeQuery();
            
            if (emailRS.next()) {
                message = "Error: Email already exists for another user";
                messageType = "danger";
            } else {
                // Build base update query
                StringBuilder updateSQL = new StringBuilder(
                    "UPDATE users SET full_name = ?, email = ?, phone = ?, address = ?");
                
                // Add role-specific fields
                if ("student".equals(userType)) {
                    String courseId = request.getParameter("course_id");
                    String semester = request.getParameter("semester");
                    String parentName = request.getParameter("parent_name");
                    String parentContact = request.getParameter("parent_contact");
                    
                    updateSQL.append(", course_id = ?, semester = ?, parent_name = ?, parent_contact = ?");
                } else if ("teacher".equals(userType)) {
                    String department = request.getParameter("department");
                    String qualification = request.getParameter("qualification");
                    String experience = request.getParameter("experience");
                    
                    updateSQL.append(", department = ?, qualification = ?, experience = ?");
                }
                
                // Handle password reset if provided
                if (request.getParameter("password") != null && !request.getParameter("password").isEmpty()) {
                    String newPassword = request.getParameter("password");
                    String hashedPassword = new String(
                        java.util.Base64.getEncoder().encode(
                            java.security.MessageDigest.getInstance("SHA-256").digest(newPassword.getBytes())));
                    updateSQL.append(", password = ?");
                }
                
                updateSQL.append(" WHERE id = ?");
                
                PreparedStatement updateStmt = conn.prepareStatement(updateSQL.toString());
                int paramIndex = 1;
                updateStmt.setString(paramIndex++, fullName);
                updateStmt.setString(paramIndex++, email);
                updateStmt.setString(paramIndex++, phone);
                updateStmt.setString(paramIndex++, address);
                
                if ("student".equals(userType)) {
                    String courseId = request.getParameter("course_id");
                    String semester = request.getParameter("semester");
                    String parentName = request.getParameter("parent_name");
                    String parentContact = request.getParameter("parent_contact");
                    
                    updateStmt.setInt(paramIndex++, courseId != null && !courseId.isEmpty() ? Integer.parseInt(courseId) : 0);
                    updateStmt.setInt(paramIndex++, semester != null && !semester.isEmpty() ? Integer.parseInt(semester) : 0);
                    updateStmt.setString(paramIndex++, parentName);
                    updateStmt.setString(paramIndex++, parentContact);
                } else if ("teacher".equals(userType)) {
                    String department = request.getParameter("department");
                    String qualification = request.getParameter("qualification");
                    String experience = request.getParameter("experience");
                    
                    updateStmt.setString(paramIndex++, department);
                    updateStmt.setString(paramIndex++, qualification);
                    updateStmt.setInt(paramIndex++, experience != null && !experience.isEmpty() ? Integer.parseInt(experience) : 0);
                }
                
                if (request.getParameter("password") != null && !request.getParameter("password").isEmpty()) {
                    String newPassword = request.getParameter("password");
                    String hashedPassword = new String(
                        java.util.Base64.getEncoder().encode(
                            java.security.MessageDigest.getInstance("SHA-256").digest(newPassword.getBytes())));
                    updateStmt.setString(paramIndex++, hashedPassword);
                }
                
                updateStmt.setInt(paramIndex, userId);
                
                updateStmt.executeUpdate();
                message = "✓ User profile updated successfully!";
                messageType = "success";
                
                updateStmt.close();
            }
            
            emailRS.close();
            emailStmt.close();
            conn.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "danger";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management - SIMS</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .edit-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .edit-modal.active {
            display: flex;
        }
        
        .edit-modal-content {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            max-width: 600px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        
        .edit-modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 1rem;
        }
        
        .edit-modal-header h3 {
            margin: 0;
        }
        
        .close-modal {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #7f8c8d;
        }
        
        .form-section {
            margin-bottom: 1.5rem;
            padding-bottom: 1.5rem;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .form-section-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: #7f8c8d;
            text-transform: uppercase;
            margin-bottom: 1rem;
        }
        
        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }
        
        .users-table-wrapper {
            overflow-x: auto;
        }
        
        .users-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }
        
        .users-table thead {
            background: #2c3e50;
            color: white;
        }
        
        .users-table th,
        .users-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        
        .users-table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .edit-btn {
            padding: 0.5rem 1rem;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.2s;
        }
        
        .edit-btn:hover {
            background: #2980b9;
        }
        
        .badge {
            padding: 0.25rem 0.75rem;
            border-radius: 4px;
            font-size: 0.85rem;
            text-transform: capitalize;
        }
        
        .badge-student {
            background: #dbeafe;
            color: #0c2340;
        }
        
        .badge-teacher {
            background: #d1d5db;
            color: #1f2937;
        }
        
        .badge-admin {
            background: #fecaca;
            color: #7f1d1d;
        }
        
        .badge-approved {
            background: #d1fae5;
            color: #065f46;
        }
        
        .badge-pending {
            background: #fef3c7;
            color: #78350f;
        }
        
        .badge-rejected {
            background: #fee2e2;
            color: #7f1d1d;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <div class="nav-brand">
                <h1>SIMS - Admin Panel</h1>
                <p>User Management</p>
            </div>
            <div class="nav-links">
                <a href="admin-dashboard.jsp" class="nav-link">Dashboard</a>
                <a href="admin-pending.jsp" class="nav-link">Approvals</a>
                <a href="admin-users.jsp" class="nav-link active">Users</a>
                <a href="courses.jsp" class="nav-link">Courses</a>
                <a href="logout.jsp" class="nav-link">Logout</a>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <div class="page-header">
            <h2>👥 User Management</h2>
            <p>View and edit registered users</p>
        </div>

        <% if (!message.isEmpty()) { %>
            <div class="alert alert-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <!-- Users Table -->
        <div class="users-table-wrapper">
            <table class="users-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Class.forName("com.mysql.jdbc.Driver");
                            Connection conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                            
                            String sql = "SELECT id, full_name, email, phone, user_type, status FROM users WHERE status = 'approved' ORDER BY user_type, id";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            boolean hasUsers = false;
                            while (rs.next()) {
                                hasUsers = true;
                                int userId = rs.getInt("id");
                                String fullName = rs.getString("full_name");
                                String emailAddr = rs.getString("email");
                                String phone = rs.getString("phone");
                                String userType = rs.getString("user_type");
                                String status = rs.getString("status");
                    %>
                    <tr>
                        <td><%= userId %></td>
                        <td><strong><%= fullName %></strong></td>
                        <td><%= emailAddr %></td>
                        <td><%= phone %></td>
                        <td><span class="badge badge-<%= userType %>"><%= userType %></span></td>
                        <td><span class="badge badge-<%= status %>"><%= status %></span></td>
                        <td>
                            <button class="edit-btn" onclick="openEditModal(<%= userId %>, '<%= userType %>')">
                                Edit
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                            
                            if (!hasUsers) {
                                out.println("<tr><td colspan='7' style='text-align: center; padding: 2rem; color: #7f8c8d;'>No approved users found</td></tr>");
                            }
                            
                            rs.close();
                            stmt.close();
                            conn.close();
                        } catch (Exception e) {
                            out.println("<tr><td colspan='7' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>

        <div style="margin-top: 2rem;">
            <a href="admin-dashboard.jsp" class="btn btn-secondary">← Back to Dashboard</a>
        </div>
    </div>

    <!-- Edit User Modal -->
    <div class="edit-modal" id="editModal">
        <div class="edit-modal-content">
            <div class="edit-modal-header">
                <h3>Edit User Profile</h3>
                <button class="close-modal" onclick="closeEditModal()">✕</button>
            </div>

            <form id="editForm" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="user_id" id="editUserId">
                <input type="hidden" name="user_type" id="editUserType">

                <!-- Common Fields -->
                <div class="form-section">
                    <div class="form-section-title">Basic Information</div>
                    
                    <div class="form-group">
                        <label for="editFullName">Full Name</label>
                        <input type="text" id="editFullName" name="full_name" required>
                    </div>
                    
                    <div class="two-column">
                        <div class="form-group">
                            <label for="editEmail">Email</label>
                            <input type="email" id="editEmail" name="email" required>
                        </div>
                        <div class="form-group">
                            <label for="editPhone">Phone</label>
                            <input type="tel" id="editPhone" name="phone">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editAddress">Address</label>
                        <textarea id="editAddress" name="address" rows="2"></textarea>
                    </div>
                </div>

                <!-- Student-Specific Fields -->
                <div id="studentFields" class="form-section" style="display: none;">
                    <div class="form-section-title">Student Information</div>
                    
                    <div class="two-column">
                        <div class="form-group">
                            <label for="editCourseId">Course</label>
                            <select id="editCourseId" name="course_id">
                                <option value="">-- Select Course --</option>
                                <%
                                    try {
                                        Class.forName("com.mysql.jdbc.Driver");
                                        Connection conn = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/student_info_system", "root", "15056324");
                                        
                                        String sql = "SELECT course_id, course_name FROM courses ORDER BY course_name";
                                        Statement stmt = conn.createStatement();
                                        ResultSet rs = stmt.executeQuery(sql);
                                        
                                        while (rs.next()) {
                                            out.println("<option value='" + rs.getInt("course_id") + "'>" + rs.getString("course_name") + "</option>");
                                        }
                                        
                                        rs.close();
                                        stmt.close();
                                        conn.close();
                                    } catch (Exception e) {}
                                %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="editSemester">Semester</label>
                            <input type="number" id="editSemester" name="semester" min="1" max="8">
                        </div>
                    </div>
                    
                    <div class="two-column">
                        <div class="form-group">
                            <label for="editParentName">Parent Name</label>
                            <input type="text" id="editParentName" name="parent_name">
                        </div>
                        <div class="form-group">
                            <label for="editParentContact">Parent Contact</label>
                            <input type="tel" id="editParentContact" name="parent_contact">
                        </div>
                    </div>
                </div>

                <!-- Teacher-Specific Fields -->
                <div id="teacherFields" class="form-section" style="display: none;">
                    <div class="form-section-title">Teacher Information</div>
                    
                    <div class="two-column">
                        <div class="form-group">
                            <label for="editDepartment">Department</label>
                            <input type="text" id="editDepartment" name="department">
                        </div>
                        <div class="form-group">
                            <label for="editExperience">Experience (Years)</label>
                            <input type="number" id="editExperience" name="experience" min="0">
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editQualification">Qualification</label>
                        <input type="text" id="editQualification" name="qualification">
                    </div>
                </div>

                <!-- Password Reset -->
                <div class="form-section">
                    <div class="form-section-title">Change Password (Optional)</div>
                    
                    <div class="form-group">
                        <label for="editPassword">New Password</label>
                        <input type="password" id="editPassword" name="password" placeholder="Leave blank to keep current password">
                        <small style="color: #7f8c8d;">Minimum 6 characters</small>
                    </div>
                </div>

                <!-- Form Actions -->
                <div style="display: flex; gap: 1rem; margin-top: 2rem;">
                    <button type="submit" class="btn btn-primary" style="flex: 1;">Save Changes</button>
                    <button type="button" class="btn btn-secondary" onclick="closeEditModal()" style="flex: 1;">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <footer class="footer">
        <div class="footer-bottom">
            <p>&copy; 2026 SIMS - Student Information Management System. All rights reserved.</p>
        </div>
    </footer>

    <script>
        function openEditModal(userId, userType) {
            const modal = document.getElementById('editModal');
            document.getElementById('editUserId').value = userId;
            document.getElementById('editUserType').value = userType;
            
            // Show/hide role-specific fields
            document.getElementById('studentFields').style.display = userType === 'student' ? 'block' : 'none';
            document.getElementById('teacherFields').style.display = userType === 'teacher' ? 'block' : 'none';
            
            // Load user data via AJAX
            fetch('get-user-details.jsp?user_id=' + userId)
                .then(response => response.json())
                .then(data => {
                    document.getElementById('editFullName').value = data.full_name || '';
                    document.getElementById('editEmail').value = data.email || '';
                    document.getElementById('editPhone').value = data.phone || '';
                    document.getElementById('editAddress').value = data.address || '';
                    
                    if (userType === 'student') {
                        document.getElementById('editCourseId').value = data.course_id || '';
                        document.getElementById('editSemester').value = data.semester || '';
                        document.getElementById('editParentName').value = data.parent_name || '';
                        document.getElementById('editParentContact').value = data.parent_contact || '';
                    } else if (userType === 'teacher') {
                        document.getElementById('editDepartment').value = data.department || '';
                        document.getElementById('editQualification').value = data.qualification || '';
                        document.getElementById('editExperience').value = data.experience || '';
                    }
                    
                    modal.classList.add('active');
                })
                .catch(error => {
                    alert('Error loading user details: ' + error);
                });
        }
        
        function closeEditModal() {
            document.getElementById('editModal').classList.remove('active');
            document.getElementById('editForm').reset();
        }
        
        // Close modal when clicking outside
        document.getElementById('editModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeEditModal();
            }
        });
    </script>
</body>
</html>
