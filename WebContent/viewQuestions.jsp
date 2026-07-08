<%@page import="com.school.exam.model.Class"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%
    // Check if user is logged in as ADMIN
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !("ADMIN".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get filter parameters
    String filterSubject = request.getParameter("filterSubject");
    String filterClass = request.getParameter("filterClass");
    String filterDifficulty = request.getParameter("filterDifficulty");
    String filterStatus = request.getParameter("filterStatus");
    String pageParam = request.getParameter("page");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
    
    int pageNum = 1;
    int pageSize = 10;
    
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            pageNum = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            pageNum = 1;
        }
    }
    
    // Get all questions
    List<Question> allQuestions = new ArrayList<>();
    List<School> schools = SchoolDAO.getAllSchools();
    List<Subject> allSubjects = new ArrayList<>();
    List<Class> allClasses = new ArrayList<>();
    
    if (schools != null && !schools.isEmpty()) {
        for (School school : schools) {
            // Get all classes for this school
            List<Class> classes = ClassDAO.getClassesBySchool(school.getSchoolId());
            if (classes != null && !classes.isEmpty()) {
                allClasses.addAll(classes);
                for (Class cls : classes) {
                    // Get subjects for this school
                    List<Subject> subjects = SubjectDAO.getAllSubjectsBySchool(school.getSchoolId());
                    if (subjects != null && !subjects.isEmpty()) {
                        allSubjects.addAll(subjects);
                        for (Subject subject : subjects) {
                            // Get questions for this class and subject combination
                            List<Question> classSubjectQuestions = QuestionDAO.getQuestionsByClassAndSubject(cls.getClassId(), subject.getSubjectId());
                            if (classSubjectQuestions != null && !classSubjectQuestions.isEmpty()) {
                                allQuestions.addAll(classSubjectQuestions);
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Apply filters
    List<Question> filteredQuestions = new ArrayList<>();
    
    for (Question q : allQuestions) {
        boolean matches = true;
        
        if (filterSubject != null && !filterSubject.isEmpty()) {
            Subject subj = SubjectDAO.getSubjectById(q.getSubjectId());
            if (subj == null || !subj.getSubjectName().equals(filterSubject)) {
                matches = false;
            }
        }
        
        if (matches && filterClass != null && !filterClass.isEmpty()) {
            Class cls = ClassDAO.getClassById(q.getClassId());
            if (cls == null || !cls.getClassName().equals(filterClass)) {
                matches = false;
            }
        }
        
        if (matches && filterDifficulty != null && !filterDifficulty.isEmpty()) {
            if (!filterDifficulty.equals(q.getDifficultyLevel())) {
                matches = false;
            }
        }
        
        if (matches && filterStatus != null && !filterStatus.isEmpty()) {
            if (!filterStatus.equals(q.getStatus())) {
                matches = false;
            }
        }
        
        if (matches) {
            filteredQuestions.add(q);
        }
    }
    
    // Pagination
    int totalQuestions = filteredQuestions.size();
    int totalPages = (totalQuestions + pageSize - 1) / pageSize;
    
    if (pageNum > totalPages && totalPages > 0) {
        pageNum = totalPages;
    }
    if (pageNum < 1) {
        pageNum = 1;
    }
    
    int startIndex = (pageNum - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalQuestions);
    
    List<Question> pageQuestions = new ArrayList<>();
    if (startIndex < totalQuestions) {
        pageQuestions = filteredQuestions.subList(startIndex, endIndex);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Questions - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
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
        }
        
        .header {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            color: #667eea;
            font-size: 28px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .back-btn {
            background: #667eea;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: 0.3s;
        }
        
        .back-btn:hover {
            background: #764ba2;
        }
        
        .content {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .content h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 22px;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .stat-box {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid #667eea;
        }
        
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-label {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }
        
        .table-container {
            overflow-x: auto;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background-color: #f8f9fa;
            border-bottom: 2px solid #ddd;
        }
        
        th {
            padding: 15px;
            text-align: left;
            color: #333;
            font-weight: 600;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
        }
        
        tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        
        .badge-easy {
            background-color: #d4edda;
            color: #155724;
        }
        
        .badge-medium {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .badge-hard {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .badge-active {
            background-color: #d4edda;
            color: #155724;
        }
        
        .badge-inactive {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 20px;
            color: #ccc;
        }
        
        .message {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .message-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .message-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .message i {
            font-size: 18px;
        }
        
        .filter-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .filter-group {
            display: flex;
            flex-direction: column;
        }
        
        .filter-group label {
            font-size: 12px;
            font-weight: 600;
            color: #666;
            margin-bottom: 5px;
        }
        
        .filter-group select {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 13px;
        }
        
        .filter-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: 0.3s;
        }
        
        .btn-filter {
            background: #667eea;
            color: white;
        }
        
        .btn-filter:hover {
            background: #764ba2;
        }
        
        .btn-clear {
            background: #95a5a6;
            color: white;
        }
        
        .btn-clear:hover {
            background: #7f8c8d;
        }
        
        .btn-edit {
            background: #3498db;
            color: white;
            padding: 5px 10px;
            font-size: 11px;
        }
        
        .btn-edit:hover {
            background: #2980b9;
        }
        
        .btn-delete {
            background: #e74c3c;
            color: white;
            padding: 5px 10px;
            font-size: 11px;
        }
        
        .btn-delete:hover {
            background: #c0392b;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        
        .pagination {
            display: flex;
            gap: 5px;
            justify-content: center;
            margin-top: 20px;
            align-items: center;
        }
        
        .pagination a,
        .pagination span {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-decoration: none;
            color: #333;
            font-size: 12px;
        }
        
        .pagination a:hover {
            background: #667eea;
            color: white;
        }
        
        .pagination .active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }
        
        .pagination .disabled {
            color: #ccc;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>
                <i class="fas fa-question-circle"></i>
                View All Questions
            </h1>
            <a href="adminDashboard.jsp" class="back-btn">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
        
        <!-- Content -->
        <div class="content">
            <h2>Exam Questions Database</h2>
            
            <!-- Success/Error Messages -->
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                <div class="message message-success">
                    <i class="fas fa-check-circle"></i>
                    <% if ("deleted".equals(successMsg)) { %>
                        <span>Question deleted successfully!</span>
                    <% } %>
                </div>
            <% } %>
            
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="message message-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <% if ("deletefailed".equals(errorMsg)) { %>
                        <span>Failed to delete question. Please try again.</span>
                    <% } else if ("notfound".equals(errorMsg)) { %>
                        <span>Question not found.</span>
                    <% } else if ("invalid".equals(errorMsg)) { %>
                        <span>Invalid question ID.</span>
                    <% } else if ("exception".equals(errorMsg)) { %>
                        <span>An error occurred. Please try again.</span>
                    <% } %>
                </div>
            <% } %>
            
            <!-- Statistics -->
            <div class="stats">
                <div class="stat-box">
                    <div class="stat-number"><%= totalQuestions %></div>
                    <div class="stat-label">Total Questions</div>
                </div>
            </div>
            
            <!-- Filter Section -->
            <div class="filter-section">
                <form method="GET" action="viewQuestions.jsp" style="width: 100%;">
                    <div class="filter-grid">
                        <div class="filter-group">
                            <label for="filterSubject">Subject:</label>
                            <select name="filterSubject" id="filterSubject">
                                <option value="">All Subjects</option>
                                <%
                                    Set<String> subjectNames = new java.util.HashSet<>();
                                    for (Question q : allQuestions) {
                                        Subject subj = SubjectDAO.getSubjectById(q.getSubjectId());
                                        if (subj != null && subj.getSubjectName() != null) {
                                            subjectNames.add(subj.getSubjectName());
                                        }
                                    }
                                    List<String> sortedSubjects = new java.util.ArrayList<>(subjectNames);
                                    java.util.Collections.sort(sortedSubjects);
                                    for (String subjName : sortedSubjects) {
                                %>
                                    <option value="<%= subjName %>" <%= filterSubject != null && filterSubject.equals(subjName) ? "selected" : "" %>>
                                        <%= subjName %>
                                    </option>
                                <%
                                    }
                                %>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="filterClass">Class:</label>
                            <select name="filterClass" id="filterClass">
                                <option value="">All Classes</option>
                                <%
                                    Set<String> classNames = new java.util.HashSet<>();
                                    for (Question q : allQuestions) {
                                        Class cls = ClassDAO.getClassById(q.getClassId());
                                        if (cls != null && cls.getClassName() != null) {
                                            classNames.add(cls.getClassName());
                                        }
                                    }
                                    List<String> sortedClasses = new java.util.ArrayList<>(classNames);
                                    java.util.Collections.sort(sortedClasses);
                                    for (String clsName : sortedClasses) {
                                %>
                                    <option value="<%= clsName %>" <%= filterClass != null && filterClass.equals(clsName) ? "selected" : "" %>>
                                        <%= clsName %>
                                    </option>
                                <%
                                    }
                                %>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="filterDifficulty">Difficulty:</label>
                            <select name="filterDifficulty" id="filterDifficulty">
                                <option value="">All Levels</option>
                                <option value="EASY" <%= filterDifficulty != null && filterDifficulty.equals("EASY") ? "selected" : "" %>>Easy</option>
                                <option value="MEDIUM" <%= filterDifficulty != null && filterDifficulty.equals("MEDIUM") ? "selected" : "" %>>Medium</option>
                                <option value="HARD" <%= filterDifficulty != null && filterDifficulty.equals("HARD") ? "selected" : "" %>>Hard</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="filterStatus">Status:</label>
                            <select name="filterStatus" id="filterStatus">
                                <option value="">All Status</option>
                                <option value="ACTIVE" <%= filterStatus != null && filterStatus.equals("ACTIVE") ? "selected" : "" %>>Active</option>
                                <option value="INACTIVE" <%= filterStatus != null && filterStatus.equals("INACTIVE") ? "selected" : "" %>>Inactive</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="filter-buttons">
                        <button type="submit" class="btn btn-filter">
                            <i class="fas fa-filter"></i> Apply Filters
                        </button>
                        <a href="viewQuestions.jsp" class="btn btn-clear">
                            <i class="fas fa-times"></i> Clear Filters
                        </a>
                    </div>
                </form>
            </div>
            
            <!-- Questions Table -->
            <div class="table-container">
                <% if (pageQuestions != null && !pageQuestions.isEmpty()) { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Question Text</th>
                                <th>Subject</th>
                                <th>Class</th>
                                <th>Difficulty</th>
                                <th>Marks</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Question q : pageQuestions) { 
                                Subject subject = SubjectDAO.getSubjectById(q.getSubjectId());
                                Class cls = ClassDAO.getClassById(q.getClassId());
                                String subjectName = subject != null ? subject.getSubjectName() : "N/A";
                                String className = cls != null ? cls.getClassName() : "N/A";
                            %>
                            <tr>
                                <td>
                                    <strong><%= q.getQuestionText().length() > 50 ? q.getQuestionText().substring(0, 50) + "..." : q.getQuestionText() %></strong>
                                </td>
                                <td><%= subjectName %></td>
                                <td><%= className %></td>
                                <td>
                                    <% if ("EASY".equals(q.getDifficultyLevel())) { %>
                                        <span class="badge badge-easy">EASY</span>
                                    <% } else if ("MEDIUM".equals(q.getDifficultyLevel())) { %>
                                        <span class="badge badge-medium">MEDIUM</span>
                                    <% } else { %>
                                        <span class="badge badge-hard">HARD</span>
                                    <% } %>
                                </td>
                                <td><%= q.getMarks() %></td>
                                <td>
                                    <% if ("ACTIVE".equals(q.getStatus())) { %>
                                        <span class="badge badge-active">Active</span>
                                    <% } else { %>
                                        <span class="badge badge-inactive">Inactive</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="editQuestion.jsp?id=<%= q.getQuestionId() %>" class="btn btn-edit">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        <button class="btn btn-delete" onclick="deleteQuestion(<%= q.getQuestionId() %>)">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- Pagination Controls -->
                    <div class="pagination">
                        <% if (pageNum > 1) { %>
                            <a href="viewQuestions.jsp?page=1<%= filterSubject != null && !filterSubject.isEmpty() ? "&filterSubject=" + filterSubject : "" %><%= filterClass != null && !filterClass.isEmpty() ? "&filterClass=" + filterClass : "" %><%= filterDifficulty != null && !filterDifficulty.isEmpty() ? "&filterDifficulty=" + filterDifficulty : "" %><%= filterStatus != null && !filterStatus.isEmpty() ? "&filterStatus=" + filterStatus : "" %>">
                                First
                            </a>
                            <a href="viewQuestions.jsp?page=<%= pageNum - 1 %><%= filterSubject != null && !filterSubject.isEmpty() ? "&filterSubject=" + filterSubject : "" %><%= filterClass != null && !filterClass.isEmpty() ? "&filterClass=" + filterClass : "" %><%= filterDifficulty != null && !filterDifficulty.isEmpty() ? "&filterDifficulty=" + filterDifficulty : "" %><%= filterStatus != null && !filterStatus.isEmpty() ? "&filterStatus=" + filterStatus : "" %>">
                                Previous
                            </a>
                        <% } else { %>
                            <span class="disabled">First</span>
                            <span class="disabled">Previous</span>
                        <% } %>
                        
                        <% 
                            int startPage = Math.max(1, pageNum - 2);
                            int endPage = Math.min(totalPages, pageNum + 2);
                            for (int i = startPage; i <= endPage; i++) {
                                String pageParam1 = filterSubject != null && !filterSubject.isEmpty() ? "&filterSubject=" + filterSubject : "";
                                pageParam1 += filterClass != null && !filterClass.isEmpty() ? "&filterClass=" + filterClass : "";
                                pageParam1 += filterDifficulty != null && !filterDifficulty.isEmpty() ? "&filterDifficulty=" + filterDifficulty : "";
                                pageParam1 += filterStatus != null && !filterStatus.isEmpty() ? "&filterStatus=" + filterStatus : "";
                                
                                if (i == pageNum) {
                        %>
                                    <span class="active"><%= i %></span>
                        <%
                                } else {
                        %>
                                    <a href="viewQuestions.jsp?page=<%= i %><%= pageParam1 %>"><%= i %></a>
                        <%
                                }
                            }
                        %>
                        
                        <% if (pageNum < totalPages) { %>
                            <a href="viewQuestions.jsp?page=<%= pageNum + 1 %><%= filterSubject != null && !filterSubject.isEmpty() ? "&filterSubject=" + filterSubject : "" %><%= filterClass != null && !filterClass.isEmpty() ? "&filterClass=" + filterClass : "" %><%= filterDifficulty != null && !filterDifficulty.isEmpty() ? "&filterDifficulty=" + filterDifficulty : "" %><%= filterStatus != null && !filterStatus.isEmpty() ? "&filterStatus=" + filterStatus : "" %>">
                                Next
                            </a>
                            <a href="viewQuestions.jsp?page=<%= totalPages %><%= filterSubject != null && !filterSubject.isEmpty() ? "&filterSubject=" + filterSubject : "" %><%= filterClass != null && !filterClass.isEmpty() ? "&filterClass=" + filterClass : "" %><%= filterDifficulty != null && !filterDifficulty.isEmpty() ? "&filterDifficulty=" + filterDifficulty : "" %><%= filterStatus != null && !filterStatus.isEmpty() ? "&filterStatus=" + filterStatus : "" %>">
                                Last
                            </a>
                        <% } else { %>
                            <span class="disabled">Next</span>
                            <span class="disabled">Last</span>
                        <% } %>
                        
                        <span style="margin-left: 20px; color: #666; font-size: 12px;">
                            Page <%= pageNum %> of <%= totalPages %>
                        </span>
                    </div>
                <% } else { %>
                    <div class="empty-state">
                        <i class="fas fa-inbox"></i>
                        <h3>No Questions Found</h3>
                        <p>No questions match your filters</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <script>
        function deleteQuestion(questionId) {
            if (confirm('Are you sure you want to delete this question? This action cannot be undone.')) {
                window.location.href = 'deleteQuestion.jsp?id=' + questionId;
            }
        }
    </script>
</body>
</html>
