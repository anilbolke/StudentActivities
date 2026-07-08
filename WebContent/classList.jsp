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
    
    // Get all classes for this school
    List<Class> classes = ClassDAO.getClassesBySchool(schoolId);
    
    // Handle delete action
    if ("POST".equals(request.getMethod()) && "delete".equals(request.getParameter("action"))) {
        int classId = Integer.parseInt(request.getParameter("classId"));
        if (ClassDAO.deleteClass(classId, schoolId)) {
            response.sendRedirect("classList.jsp?deleted=1");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Class List - School Exam System</title>
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
            max-width: 1200px;
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 28px;
        }
        
        .header-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: white;
            color: #667eea;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        
        .btn-secondary {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
        }
        
        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.3);
        }
        
        .content {
            padding: 30px;
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
        
        .table-wrapper {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        table thead {
            background: #f5f5f5;
            border-bottom: 2px solid #e0e0e0;
        }
        
        table th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        
        table td {
            padding: 12px 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 14px;
            color: #555;
        }
        
        table tr:hover {
            background: #f9f9f9;
        }
        
        .status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
        }
        
        .status.active {
            background: #d4edda;
            color: #155724;
        }
        
        .status.inactive {
            background: #f8d7da;
            color: #721c24;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .action-btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .edit-btn {
            background: #667eea;
            color: white;
        }
        
        .edit-btn:hover {
            background: #5568d3;
        }
        
        .delete-btn {
            background: #e74c3c;
            color: white;
        }
        
        .delete-btn:hover {
            background: #c0392b;
        }
        
        .no-classes {
            text-align: center;
            padding: 40px;
            color: #999;
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
        
        .class-count {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }
        
        .class-badge {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>Class Management</h1>
                <p class="class-count">Total Classes: <%= classes.size() %></p>
            </div>
            <div class="header-actions">
                <a href="addClass.jsp"><button class="btn btn-primary">+ Add New Class</button></a>
                <a href="dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
        </div>
        
        <div class="content">
            <a href="dashboard.jsp" class="back-link">← Back to Dashboard</a>
            
            <% if (request.getParameter("deleted") != null) { %>
                <div class="message success">
                    Class deleted successfully!
                </div>
            <% } %>
            
            <!-- Class Table -->
            <div class="table-wrapper">
                <% if (classes.isEmpty()) { %>
                    <div class="no-classes">
                        <p>No classes found. <a href="addClass.jsp" style="color: #667eea;">Add a new class</a></p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Class Name</th>
                                <th>Grade</th>
                                <th>Section</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Class cls : classes) { %>
                                <tr>
                                    <td><strong><%= cls.getClassName() %></strong></td>
                                    <td>
                                        <% if (cls.getGrade() > 0) { %>
                                            <span class="class-badge">Grade <%= cls.getGrade() %></span>
                                        <% } else { %>
                                            <span style="color: #ccc;">-</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (cls.getSection() != null && !cls.getSection().isEmpty()) { %>
                                            <strong><%= cls.getSection() %></strong>
                                        <% } else { %>
                                            <span style="color: #ccc;">-</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="status <%= cls.getStatus().toLowerCase() %>">
                                            <%= cls.getStatus() %>
                                        </span>
                                    </td>
                                    <td style="font-size: 12px; color: #999;">
                                        <%= (cls.getCreatedAt() != null ? cls.getCreatedAt().toLocalDate() : "-") %>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="editClass.jsp?id=<%= cls.getClassId() %>">
                                                <button class="action-btn edit-btn">Edit</button>
                                            </a>
                                            <form method="POST" action="classList.jsp" style="display: inline;" 
                                                  onsubmit="return confirm('Are you sure you want to delete this class?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="classId" value="<%= cls.getClassId() %>">
                                                <button type="submit" class="action-btn delete-btn">Delete</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
