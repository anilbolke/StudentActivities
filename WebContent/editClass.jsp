<%@page import="com.school.exam.model.Class"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%
    // Check if user is logged in and is a TEACHER
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (username == null || !("TEACHER".equals(userRole) || "ADMIN".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get class ID from URL
    int classId = 0;
    try {
        classId = Integer.parseInt(request.getParameter("id"));
    } catch (NumberFormatException e) {
        response.sendRedirect("classList.jsp");
        return;
    }
    
    // Get class details
    Class classObj = ClassDAO.getClassById(classId);
    if (classObj == null || classObj.getSchoolId() != schoolId) {
        response.sendRedirect("classList.jsp");
        return;
    }
    
    // Variables for displaying messages
    String message = "";
    String messageType = "";
    
    // Handle form submission
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        
        if ("update".equals(action)) {
            classObj.setClassName(request.getParameter("className"));
            
            String gradeStr = request.getParameter("grade");
            if (gradeStr != null && !gradeStr.isEmpty()) {
                classObj.setGrade(Integer.parseInt(gradeStr));
            }
            
            classObj.setSection(request.getParameter("section"));
            classObj.setStatus(request.getParameter("status"));
            
            if (ClassDAO.updateClass(classObj)) {
                message = "Class updated successfully!";
                messageType = "success";
            } else {
                message = "Failed to update class. Please try again.";
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
    <title>Edit Class - School Exam System</title>
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
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .content {
            padding: 40px;
        }
        
        .message {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-size: 14px;
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
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .form-section h3 {
            color: #667eea;
            font-size: 16px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 15px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group label span {
            color: #e74c3c;
        }
        
        .form-group input,
        .form-group select {
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 5px rgba(102, 126, 234, 0.3);
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #e0e0e0;
            color: #333;
        }
        
        .btn-secondary:hover {
            background: #d0d0d0;
        }
        
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Edit Class</h1>
            <p>Update class information</p>
        </div>
        
        <div class="content">
            <a href="classList.jsp" class="back-link">← Back to Class List</a>
            
            <% if (!message.isEmpty()) { %>
                <div class="message <%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form method="POST" action="editClass.jsp?id=<%= classId %>">
                <input type="hidden" name="action" value="update">
                
                <!-- Class Information -->
                <div class="form-section">
                    <h3>Class Information</h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="className">Class Name <span>*</span></label>
                            <input type="text" id="className" name="className" 
                                   value="<%= classObj.getClassName() %>" required>
                        </div>
                        <div class="form-group">
                            <label for="grade">Grade</label>
                            <select id="grade" name="grade">
                                <option value="">Select Grade</option>
                                <option value="1" <%= (classObj.getGrade() == 1 ? "selected" : "") %>>Grade 1</option>
                                <option value="2" <%= (classObj.getGrade() == 2 ? "selected" : "") %>>Grade 2</option>
                                <option value="3" <%= (classObj.getGrade() == 3 ? "selected" : "") %>>Grade 3</option>
                                <option value="4" <%= (classObj.getGrade() == 4 ? "selected" : "") %>>Grade 4</option>
                                <option value="5" <%= (classObj.getGrade() == 5 ? "selected" : "") %>>Grade 5</option>
                                <option value="6" <%= (classObj.getGrade() == 6 ? "selected" : "") %>>Grade 6</option>
                                <option value="7" <%= (classObj.getGrade() == 7 ? "selected" : "") %>>Grade 7</option>
                                <option value="8" <%= (classObj.getGrade() == 8 ? "selected" : "") %>>Grade 8</option>
                                <option value="9" <%= (classObj.getGrade() == 9 ? "selected" : "") %>>Grade 9</option>
                                <option value="10" <%= (classObj.getGrade() == 10 ? "selected" : "") %>>Grade 10</option>
                                <option value="11" <%= (classObj.getGrade() == 11 ? "selected" : "") %>>Grade 11</option>
                                <option value="12" <%= (classObj.getGrade() == 12 ? "selected" : "") %>>Grade 12</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="section">Section</label>
                            <select id="section" name="section">
                                <option value="">Select Section</option>
                                <option value="A" <%= ("A".equals(classObj.getSection()) ? "selected" : "") %>>A</option>
                                <option value="B" <%= ("B".equals(classObj.getSection()) ? "selected" : "") %>>B</option>
                                <option value="C" <%= ("C".equals(classObj.getSection()) ? "selected" : "") %>>C</option>
                                <option value="D" <%= ("D".equals(classObj.getSection()) ? "selected" : "") %>>D</option>
                                <option value="E" <%= ("E".equals(classObj.getSection()) ? "selected" : "") %>>E</option>
                                <option value="F" <%= ("F".equals(classObj.getSection()) ? "selected" : "") %>>F</option>
                                <option value="G" <%= ("G".equals(classObj.getSection()) ? "selected" : "") %>>G</option>
                                <option value="H" <%= ("H".equals(classObj.getSection()) ? "selected" : "") %>>H</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="status">Status <span>*</span></label>
                            <select id="status" name="status" required>
                                <option value="ACTIVE" <%= ("ACTIVE".equals(classObj.getStatus()) ? "selected" : "") %>>Active</option>
                                <option value="INACTIVE" <%= ("INACTIVE".equals(classObj.getStatus()) ? "selected" : "") %>>Inactive</option>
                            </select>
                        </div>
                    </div>
                </div>
                
                <!-- Buttons -->
                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Update Class</button>
                    <a href="classList.jsp"><button type="button" class="btn btn-secondary">Cancel</button></a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
