<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.school.exam.model.Subject, com.school.exam.dao.*" %>
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
    
    // Get search parameter if any
    String searchTerm = request.getParameter("search");
    List<Subject> subjects = new ArrayList<>();
    
    if (searchTerm != null && !searchTerm.isEmpty()) {
        subjects = SubjectDAO.searchSubjects(schoolId, searchTerm);
    } else {
        subjects = SubjectDAO.getSubjectsBySchool(schoolId);
    }
    
    // Handle delete action
    if ("POST".equals(request.getMethod()) && "delete".equals(request.getParameter("action"))) {
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        if (SubjectDAO.deleteSubject(subjectId, schoolId)) {
            response.sendRedirect("subjectList.jsp?deleted=1");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subject List - School Exam System</title>
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
        
        .search-section {
            margin-bottom: 25px;
            display: flex;
            gap: 10px;
        }
        
        .search-section input {
            flex: 1;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            font-size: 14px;
        }
        
        .search-section input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .search-section button {
            padding: 12px 25px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
        }
        
        .search-section button:hover {
            background: #764ba2;
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
        
        .no-subjects {
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
        
        .subject-count {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }
        
        .description-preview {
            color: #888;
            font-size: 12px;
            max-width: 300px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>Subject Management</h1>
                <p class="subject-count">Total Subjects: <%= subjects.size() %></p>
            </div>
            <div class="header-actions">
                <a href="addSubject.jsp"><button class="btn btn-primary">+ Add New Subject</button></a>
                <a href="dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
        </div>
        
        <div class="content">
            <a href="dashboard.jsp" class="back-link">← Back to Dashboard</a>
            
            <% if (request.getParameter("deleted") != null) { %>
                <div class="message success">
                    Subject deleted successfully!
                </div>
            <% } %>
            
            <!-- Search Section -->
            <div class="search-section">
                <form method="GET" action="subjectList.jsp" style="display: flex; gap: 10px; width: 100%;">
                    <input type="text" name="search" placeholder="Search by subject name or description..." 
                           value="<%= (searchTerm != null ? searchTerm : "") %>">
                    <button type="submit">Search</button>
                    <% if (searchTerm != null && !searchTerm.isEmpty()) { %>
                        <a href="subjectList.jsp"><button type="button" class="btn" style="background: #999; color: white;">Clear</button></a>
                    <% } %>
                </form>
            </div>
            
            <!-- Subject Table -->
            <div class="table-wrapper">
                <% if (subjects.isEmpty()) { %>
                    <div class="no-subjects">
                        <p>No subjects found. <a href="addSubject.jsp" style="color: #667eea;">Add a new subject</a></p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Subject Name</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Subject subject : subjects) { %>
                                <tr>
                                    <td><strong><%= subject.getSubjectName() %></strong></td>
                                    <td>
                                        <% if (subject.getDescription() != null && !subject.getDescription().isEmpty()) { %>
                                            <div class="description-preview"><%= subject.getDescription() %></div>
                                        <% } else { %>
                                            <span style="color: #ccc;">-</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="status <%= subject.getStatus().toLowerCase() %>">
                                            <%= subject.getStatus() %>
                                        </span>
                                    </td>
                                    <td style="font-size: 12px; color: #999;">
                                        <%= (subject.getCreatedAt() != null ? subject.getCreatedAt().toLocalDate() : "-") %>
                                    </td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="editSubject.jsp?id=<%= subject.getSubjectId() %>">
                                                <button class="action-btn edit-btn">Edit</button>
                                            </a>
                                            <form method="POST" action="subjectList.jsp" style="display: inline;" 
                                                  onsubmit="return confirm('Are you sure you want to delete this subject?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="subjectId" value="<%= subject.getSubjectId() %>">
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
