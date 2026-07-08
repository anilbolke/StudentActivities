<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check authorization
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    
    if (username == null || !userRole.equals("SCHOOL_ADMIN") || schoolId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get teacher ID
    int teacherId = Integer.parseInt(request.getParameter("teacherId") != null ? request.getParameter("teacherId") : "-1");
    User teacher = null;
    
    if (teacherId > 0) {
        teacher = UserDAO.getUserById(teacherId);
        // Verify teacher belongs to this school
        if (teacher == null || !teacher.getSchoolId().equals(schoolId)) {
            response.sendRedirect("schoolAdminDashboard.jsp?error=Teacher not found");
            return;
        }
    }
    
    String message = "";
    String messageType = "";
    
    // Handle form submission
    if ("POST".equals(request.getMethod()) && teacher != null) {
        String updatedFirstName = request.getParameter("firstName");
        String updatedLastName = request.getParameter("lastName");
        String updatedEmail = request.getParameter("email");
        String updatedPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String updatedStatus = request.getParameter("status");
        
        // Validate
        if (updatedFirstName == null || updatedFirstName.isEmpty() ||
            updatedLastName == null || updatedLastName.isEmpty() ||
            updatedEmail == null || updatedEmail.isEmpty()) {
            message = "Name and email are required!";
            messageType = "error";
        } else if (!updatedEmail.contains("@")) {
            message = "Invalid email format!";
            messageType = "error";
        } else if (UserDAO.emailExistsForOtherUser(updatedEmail, teacherId)) {
            message = "Email already exists! Use a different email.";
            messageType = "error";
        } else if (!updatedPassword.isEmpty()) {
            // Password being changed
            if (!updatedPassword.equals(confirmPassword)) {
                message = "Passwords do not match!";
                messageType = "error";
            } else if (updatedPassword.length() < 6) {
                message = "Password must be at least 6 characters!";
                messageType = "error";
            } else {
                // Update with new password
                teacher.setFirstName(updatedFirstName);
                teacher.setLastName(updatedLastName);
                teacher.setEmail(updatedEmail);
                teacher.setPassword(updatedPassword);
                teacher.setStatus(updatedStatus);
                
                if (UserDAO.updateUser(teacher)) {
                    message = "Teacher details updated successfully!";
                    messageType = "success";
%>
<script>
    setTimeout(function() {
        window.location.href = "schoolAdminDashboard.jsp?message=Teacher updated successfully";
    }, 2000);
</script>
<%
                } else {
                    message = "Failed to update teacher. Please try again.";
                    messageType = "error";
                }
            }
        } else {
            // Update without password change
            teacher.setFirstName(updatedFirstName);
            teacher.setLastName(updatedLastName);
            teacher.setEmail(updatedEmail);
            teacher.setStatus(updatedStatus);
            
            if (UserDAO.updateUser(teacher)) {
                message = "Teacher details updated successfully!";
                messageType = "success";
%>
<script>
    setTimeout(function() {
        window.location.href = "schoolAdminDashboard.jsp?message=Teacher updated successfully";
    }, 2000);
</script>
<%
            } else {
                message = "Failed to update teacher. Please try again.";
                messageType = "error";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Teacher - School Admin</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a73e8 0%, #1765cc 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .navbar {
            background: linear-gradient(135deg, #1a73e8 0%, #1765cc 100%);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }

        .navbar-brand {
            font-size: 1.5rem;
            font-weight: bold;
        }

        .btn-back {
            background-color: rgba(255,255,255,0.2);
            color: white;
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .btn-back:hover {
            background-color: rgba(255,255,255,0.3);
        }

        .container {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }

        .form-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 2.5rem;
            width: 100%;
            max-width: 500px;
        }

        .form-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .form-header h1 {
            color: #1a73e8;
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
        }

        .form-header p {
            color: #7f8c8d;
            font-size: 0.95rem;
        }

        .alert {
            padding: 1rem;
            border-radius: 4px;
            margin-bottom: 1.5rem;
            display: none;
        }

        .alert.show {
            display: block;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #2c3e50;
            font-weight: 600;
            font-size: 0.95rem;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #ecf0f1;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #1a73e8;
            box-shadow: 0 0 5px rgba(26, 115, 232, 0.3);
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-row .form-group {
            margin-bottom: 1.5rem;
        }

        .section {
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 1px solid #ecf0f1;
        }

        .section:last-of-type {
            border-bottom: none;
        }

        .section-title {
            font-size: 0.9rem;
            color: #1a73e8;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 1rem;
        }

        .btn-container {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }

        .btn {
            flex: 1;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s;
        }

        .btn-submit {
            background: linear-gradient(135deg, #1a73e8 0%, #1765cc 100%);
            color: white;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(26, 115, 232, 0.4);
        }

        .btn-cancel {
            background-color: #ecf0f1;
            color: #2c3e50;
        }

        .btn-cancel:hover {
            background-color: #bdc3c7;
        }

        .password-hint {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-top: 0.5rem;
        }

        @media (max-width: 768px) {
            .form-container {
                padding: 1.5rem;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 0;
            }

            .form-header h1 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <div class="navbar">
        <div class="navbar-brand">🏫 School Admin Portal</div>
        <a href="schoolAdminDashboard.jsp" class="btn-back">← Back to Dashboard</a>
    </div>

    <!-- Container -->
    <div class="container">
        <div class="form-container">
            <div class="form-header">
                <h1>Edit Teacher</h1>
                <p><% if (teacher != null) { %><%= teacher.getFirstName() + " " + teacher.getLastName() %><% } %></p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="alert show alert-<%= messageType %>">
                    <%= "success".equals(messageType) ? "✅ " : "❌ " %><%= message %>
                </div>
            <% } %>

            <% if (teacher != null) { %>
            <form method="POST" action="editTeacher.jsp?teacherId=<%= teacher.getUserId() %>">
                <!-- Personal Information -->
                <div class="section">
                    <div class="section-title">Personal Information</div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="firstName">First Name</label>
                            <input type="text" id="firstName" name="firstName" value="<%= teacher.getFirstName() %>" required>
                        </div>
                        <div class="form-group">
                            <label for="lastName">Last Name</label>
                            <input type="text" id="lastName" name="lastName" value="<%= teacher.getLastName() %>" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" value="<%= teacher.getEmail() %>" required>
                    </div>

                    <div class="form-group">
                        <label>Username (Cannot be changed)</label>
                        <input type="text" value="<%= teacher.getUsername() %>" disabled style="background-color: #f8f9fa; cursor: not-allowed;">
                    </div>
                </div>

                <!-- Password -->
                <div class="section">
                    <div class="section-title">Password (Leave blank to keep current)</div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="password">New Password</label>
                            <input type="password" id="password" name="password" placeholder="Leave blank to keep current">
                            <div class="password-hint">🔒 Min 6 characters</div>
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword">Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter password">
                        </div>
                    </div>
                </div>

                <!-- Status -->
                <div class="section">
                    <div class="section-title">Account Status</div>
                    
                    <div class="form-group">
                        <label for="status">Status</label>
                        <select id="status" name="status">
                            <option value="ACTIVE" <%= "ACTIVE".equals(teacher.getStatus()) ? "selected" : "" %>>Active</option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(teacher.getStatus()) ? "selected" : "" %>>Inactive</option>
                            <option value="BLOCKED" <%= "BLOCKED".equals(teacher.getStatus()) ? "selected" : "" %>>Blocked</option>
                        </select>
                    </div>
                </div>

                <div class="btn-container">
                    <a href="schoolAdminDashboard.jsp" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-submit">✔️ Update Teacher</button>
                </div>
            </form>
            <% } else { %>
                <div style="text-align: center; padding: 2rem;">
                    <p style="color: #d32f2f; margin-bottom: 1rem;">❌ Teacher not found!</p>
                    <a href="schoolAdminDashboard.jsp" class="btn btn-cancel" style="display: inline-block;">Go Back</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
