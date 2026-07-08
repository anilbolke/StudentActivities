<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.school.exam.model.User, com.school.exam.dao.UserDAO" %>
<%
    // Check if user is already logged in
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username != null) {
        // Redirect based on role
        if ("ADMIN".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
        } else if ("SCHOOL_ADMIN".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/schoolAdminDashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        }
        return;
    }
    
    String message = "";
    String messageType = "";
    
    // Handle login form submission
    if ("POST".equals(request.getMethod())) {
        String loginUsername = request.getParameter("username");
        String loginPassword = request.getParameter("password");
        
        if (loginUsername == null || loginUsername.isEmpty() || 
            loginPassword == null || loginPassword.isEmpty()) {
            message = "Username and password are required!";
            messageType = "error";
        } else {
            // Authenticate user
            User user = UserDAO.authenticate(loginUsername, loginPassword);
            
            if (user != null) {
                // Check if user is TEACHER, SCHOOL_ADMIN or ADMIN
                if ("TEACHER".equals(user.getRole()) || "ADMIN".equals(user.getRole()) || "SCHOOL_ADMIN".equals(user.getRole())) {
                    // Set session attributes
                    session.setAttribute("userId", user.getUserId());
                    session.setAttribute("username", user.getUsername());
                    session.setAttribute("userRole", user.getRole());
                    session.setAttribute("firstName", user.getFirstName());
                    session.setAttribute("lastName", user.getLastName());
                    session.setAttribute("schoolId", user.getSchoolId());
                    session.setAttribute("email", user.getEmail());
                    
                    // Route to appropriate dashboard based on role
                    if ("ADMIN".equals(user.getRole())) {
                        response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                    } else if ("SCHOOL_ADMIN".equals(user.getRole())) {
                        response.sendRedirect(request.getContextPath() + "/schoolAdminDashboard.jsp");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
                    }
                    return;
                } else {
                    message = "Access denied! Only teachers, school admins, and system admins can log in.";
                    messageType = "error";
                }
            } else {
                message = "Invalid username or password!";
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
    <title>Login - School Exam Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .login-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 420px;
            width: 100%;
            overflow: hidden;
        }
        
        .login-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        
        .login-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .login-header p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .login-body {
            padding: 40px 30px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 5px rgba(102, 126, 234, 0.3);
        }
        
        .form-group input::placeholder {
            color: #999;
        }
        
        .message {
            padding: 12px 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
            display: none;
        }
        
        .message.show {
            display: block;
        }
        
        .message.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .message.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .remember-me {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .remember-me input {
            margin-right: 8px;
            width: 16px;
            height: 16px;
            cursor: pointer;
        }
        
        .remember-me label {
            margin: 0;
            cursor: pointer;
            color: #666;
            font-weight: 500;
        }
        
        .login-button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            margin-bottom: 15px;
        }
        
        .login-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .login-button:active {
            transform: translateY(0);
        }
        
        .footer-text {
            text-align: center;
            color: #666;
            font-size: 13px;
            margin-top: 20px;
        }
        
        .footer-text a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
        
        .footer-text a:hover {
            text-decoration: underline;
        }
        
        .demo-credentials {
            background: #f0f4ff;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-top: 20px;
            border-radius: 5px;
            font-size: 12px;
            color: #555;
        }
        
        .demo-credentials strong {
            display: block;
            margin-bottom: 8px;
            color: #333;
        }
        
        .demo-credentials p {
            margin: 3px 0;
        }
        
        .input-icon {
            position: relative;
        }
        
        .input-icon::before {
            content: "";
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            width: 20px;
            height: 20px;
            background-size: 100%;
            opacity: 0.5;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>📚 School Exam System</h1>
            <p>Teacher & Admin Login</p>
        </div>
        
        <div class="login-body">
            <% if (!message.isEmpty()) { %>
                <div class="message show <%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form method="POST" action="login.jsp">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" 
                           placeholder="Enter your username" 
                           required autofocus>
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" 
                           placeholder="Enter your password" 
                           required>
                </div>
                
                <div class="remember-me">
                    <input type="checkbox" id="rememberMe" name="rememberMe">
                    <label for="rememberMe">Remember me</label>
                </div>
                
                <button type="submit" class="login-button">Login</button>
            </form>
            
            <div class="demo-credentials">
                <strong>Demo Credentials:</strong>
                <p style="margin-top: 8px;"><strong style="color: #1a73e8;">👨‍🏫 Teacher:</strong></p>
                <p><strong>Username:</strong> teacher1</p>
                <p><strong>Password:</strong> password123</p>
                
                <p style="margin-top: 12px;"><strong style="color: #1a73e8;">🏫 School Admin:</strong></p>
                <p><strong>Username:</strong> schooladmin1</p>
                <p><strong>Password:</strong> school123</p>
                
                <p style="margin-top: 8px; color: #999; font-size: 11px;">
                    (Contact your administrator for account creation)
                </p>
            </div>
            
            <div class="footer-text">
                Don't have an account? <a href="#" title="Contact school administrator">Contact Administrator</a>
            </div>
        </div>
    </div>
    
    <script>
        // Optional: Add visual feedback to input fields
        document.getElementById('username').addEventListener('focus', function() {
            this.parentElement.style.borderColor = '#667eea';
        });
        
        document.getElementById('password').addEventListener('focus', function() {
            this.parentElement.style.borderColor = '#667eea';
        });
    </script>
</body>
</html>
