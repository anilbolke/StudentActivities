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
    
    String message = "";
    String messageType = "";
    
    // Handle form submission
    if ("POST".equals(request.getMethod())) {
        String newTeacherFirstName = request.getParameter("firstName");
        String newTeacherLastName = request.getParameter("lastName");
        String newTeacherEmail = request.getParameter("email");
        String newTeacherUsername = request.getParameter("username");
        String newTeacherPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate
        if (newTeacherFirstName == null || newTeacherFirstName.isEmpty() ||
            newTeacherLastName == null || newTeacherLastName.isEmpty() ||
            newTeacherEmail == null || newTeacherEmail.isEmpty() ||
            newTeacherUsername == null || newTeacherUsername.isEmpty() ||
            newTeacherPassword == null || newTeacherPassword.isEmpty()) {
            message = "All fields are required!";
            messageType = "error";
        } else if (!newTeacherPassword.equals(confirmPassword)) {
            message = "Passwords do not match!";
            messageType = "error";
        } else if (newTeacherPassword.length() < 6) {
            message = "Password must be at least 6 characters!";
            messageType = "error";
        } else if (!newTeacherEmail.contains("@")) {
            message = "Invalid email format!";
            messageType = "error";
        } else if (UserDAO.emailExists(newTeacherEmail)) {
            message = "Email already exists! Use a different email.";
            messageType = "error";
        } else {
            // Create new teacher
            User teacher = new User();
            teacher.setFirstName(newTeacherFirstName);
            teacher.setLastName(newTeacherLastName);
            teacher.setEmail(newTeacherEmail);
            teacher.setUsername(newTeacherUsername);
            teacher.setPassword(newTeacherPassword);
            teacher.setRole("TEACHER");
            teacher.setSchoolId(schoolId);
            teacher.setStatus("ACTIVE");
            
            int teacherId = UserDAO.addUser(teacher);
            if (teacherId > 0) {
                message = "Teacher '" + newTeacherFirstName + " " + newTeacherLastName + "' created successfully!";
                messageType = "success";
                // Redirect after 2 seconds
%>
<script>
    setTimeout(function() {
        window.location.href = "schoolAdminDashboard.jsp?message=Teacher created successfully";
    }, 2000);
</script>
<%
            } else {
                message = "Failed to create teacher. Please try again.";
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
    <title>Add Teacher - School Admin</title>
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

        .form-group input {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #ecf0f1;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.3s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #1a73e8;
            box-shadow: 0 0 5px rgba(26, 115, 232, 0.3);
        }

        .form-group input::placeholder {
            color: #bdc3c7;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-row .form-group {
            margin-bottom: 1.5rem;
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
                <h1>Add New Teacher</h1>
                <p>Create a new teacher account for your school</p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="alert show alert-<%= messageType %>">
                    <%= "success".equals(messageType) ? "✅ " : "❌ " %><%= message %>
                </div>
            <% } %>

            <form method="POST" action="addTeacher.jsp">
                <div class="form-row">
                    <div class="form-group">
                        <label for="firstName">First Name</label>
                        <input type="text" id="firstName" name="firstName" placeholder="e.g., John" required>
                    </div>
                    <div class="form-group">
                        <label for="lastName">Last Name</label>
                        <input type="text" id="lastName" name="lastName" placeholder="e.g., Doe" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" placeholder="teacher@school.com" required>
                </div>

                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="e.g., teacher_john" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" placeholder="Min 6 characters" required>
                        <div class="password-hint">🔒 Min 6 characters recommended</div>
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter password" required>
                    </div>
                </div>

                <div class="btn-container">
                    <a href="schoolAdminDashboard.jsp" class="btn btn-cancel">Cancel</a>
                    <button type="submit" class="btn btn-submit">+ Create Teacher</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
