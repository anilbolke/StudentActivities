<%@page import="com.school.exam.model.Class"%>
<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check authorization
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    
    // Redirect to login if not authorized
    if (username == null || (!userRole.equals("TEACHER") && !userRole.equals("ADMIN"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get messages from URL
    String successMessage = request.getParameter("message");
    String errorMessage = request.getParameter("error");
    
    // Get teacher's exams
    List<Exam> exams = ExamDAO.getExamsByTeacher(userId);
    
    // Get stats
    int totalExams = exams != null ? exams.size() : 0;
    int publishedExams = 0;
    int draftExams = 0;
    int archivedExams = 0;
    
    if (exams != null) {
        for (Exam exam : exams) {
            if ("PUBLISHED".equals(exam.getStatus())) {
                publishedExams++;
            } else if ("DRAFT".equals(exam.getStatus())) {
                draftExams++;
            } else if ("ARCHIVED".equals(exam.getStatus())) {
                archivedExams++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - School Exam System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
        }

        /* Navbar */
        .navbar {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }

        .navbar-brand {
            font-size: 1.8rem;
            font-weight: bold;
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }

        .navbar-brand i {
            font-size: 2rem;
        }

        .navbar-right {
            display: flex;
            gap: 1.5rem;
            align-items: center;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: #667eea;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.1rem;
        }

        .btn-logout {
            background-color: #e74c3c;
            color: white;
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s;
        }

        .btn-logout:hover {
            background-color: #c0392b;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }

        /* Main Container */
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        /* Welcome Section */
        .welcome-section {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .welcome-text h1 {
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .welcome-text p {
            color: #7f8c8d;
            font-size: 0.95rem;
        }

        .quick-actions {
            display: flex;
            gap: 1rem;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.95rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background-color: #3498db;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }

        /* Stats Section */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid #667eea;
        }

        .stat-card.draft {
            border-left-color: #f39c12;
        }

        .stat-card.published {
            border-left-color: #27ae60;
        }

        .stat-card.archived {
            border-left-color: #95a5a6;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #667eea;
            margin: 0.5rem 0;
        }

        .stat-card.draft .stat-number {
            color: #f39c12;
        }

        .stat-card.published .stat-number {
            color: #27ae60;
        }

        .stat-card.archived .stat-number {
            color: #95a5a6;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        /* Tabs */
        .tabs {
            margin-bottom: 2rem;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .tab-buttons {
            display: flex;
            background-color: #ecf0f1;
            border-bottom: 2px solid #bdc3c7;
        }

        .tab-button {
            flex: 1;
            padding: 1rem;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.3s;
            color: #7f8c8d;
        }

        .tab-button.active {
            background-color: white;
            color: #667eea;
            border-bottom: 3px solid #667eea;
            margin-bottom: -2px;
        }

        .tab-button:hover {
            background-color: #f8f9fa;
        }

        .tab-content {
            display: none;
            padding: 1.5rem;
        }

        .tab-content.active {
            display: block;
        }

        /* Exam Table */
        .exam-table {
            width: 100%;
            border-collapse: collapse;
        }

        .exam-table thead {
            background-color: #34495e;
            color: white;
        }

        .exam-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }

        .exam-table td {
            padding: 1rem;
            border-bottom: 1px solid #ecf0f1;
        }

        .exam-table tbody tr:hover {
            background-color: #f8f9fa;
        }

        /* Status Badges */
        .badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .badge-published {
            background-color: #d4edda;
            color: #155724;
        }

        .badge-draft {
            background-color: #fff3cd;
            color: #856404;
        }

        .badge-archived {
            background-color: #e2e3e5;
            color: #383d41;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        .btn-small {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-view {
            background-color: #3498db;
            color: white;
        }

        .btn-view:hover {
            background-color: #2980b9;
        }

        .btn-edit {
            background-color: #f39c12;
            color: white;
        }

        .btn-edit:hover {
            background-color: #d68910;
        }

        .btn-delete {
            background-color: #e74c3c;
            color: white;
        }

        .btn-delete:hover {
            background-color: #c0392b;
        }

        .btn-start {
            background: linear-gradient(135deg, #27ae60 0%, #229954 100%);
            color: white;
        }

        .btn-start:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(39, 174, 96, 0.3);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
        }

        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #bdc3c7;
        }

        .empty-state p {
            margin: 1rem 0;
        }

        /* Alert */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            max-width: 500px;
            width: 90%;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }

        .modal-header {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
            color: #2c3e50;
        }

        .modal-body {
            margin-bottom: 1.5rem;
            color: #555;
        }

        .modal-footer {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }

        .close {
            cursor: pointer;
            float: right;
            font-size: 1.5rem;
            color: #7f8c8d;
        }

        .close:hover {
            color: #2c3e50;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
            }

            .welcome-section {
                flex-direction: column;
                text-align: center;
            }

            .quick-actions {
                width: 100%;
                justify-content: center;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .exam-table {
                font-size: 0.9rem;
            }

            .exam-table th, .exam-table td {
                padding: 0.75rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-small {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <div class="navbar">
        <div class="navbar-brand">
            📚 School Exam System
        </div>
        <div class="navbar-right">
            <div class="user-info">
                <div class="user-avatar">
                    <%= firstName != null ? firstName.charAt(0) : "T" %>
                </div>
                <div>
                    <strong><%= firstName %> <%= lastName %></strong>
                    <br>
                    <small style="color: #bdc3c7;"><%= userRole %></small>
                </div>
            </div>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        </div>
    </div>

    <!-- Main Container -->
    <div class="container">
        <!-- Success/Error Messages -->
        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success" id="successAlert">
                ✅ <%= successMessage %>
            </div>
        <% } %>
        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger" id="errorAlert">
                ❌ <%= errorMessage %>
            </div>
        <% } %>

        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-text">
                <h1>Welcome back, <%= firstName %>! 👋</h1>
                <p>Manage your exams, upload questions, and analyze student performance</p>
            </div>
            <div class="quick-actions">
                <a href="createExam.jsp" class="btn btn-primary">+ Create New Exam</a>
                <a href="uploadQuestionsEnhanced.jsp" class="btn btn-secondary">📤 Upload Questions</a>
                <a href="addSubject.jsp" class="btn btn-secondary">➕ Add Subject</a>
                <a href="addClass.jsp" class="btn btn-secondary">➕ Add Class</a>
            </div>
        </div>

        <!-- Stats Section -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Exams</div>
                <div class="stat-number"><%= totalExams %></div>
            </div>
            <div class="stat-card published">
                <div class="stat-label">Published</div>
                <div class="stat-number"><%= publishedExams %></div>
            </div>
            <div class="stat-card draft">
                <div class="stat-label">Draft</div>
                <div class="stat-number"><%= draftExams %></div>
            </div>
            <div class="stat-card archived">
                <div class="stat-label">Archived</div>
                <div class="stat-number"><%= archivedExams %></div>
            </div>
        </div>

        <!-- Activities Section -->
        <div style="margin-bottom: 2rem;">
            <h2 style="color: #2c3e50; margin-bottom: 1.5rem; font-size: 1.5rem;">📋 Quick Activities</h2>
            <div class="quick-actions" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1rem;">
                <a href="addSubject.jsp" style="text-decoration: none;">
                    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; transition: all 0.3s; border-top: 3px solid #9b59b6;">
                        <div style="font-size: 2rem; margin-bottom: 0.5rem;">📚</div>
                        <div style="font-weight: 600; color: #2c3e50;">Add Subject</div>
                        <div style="font-size: 0.9rem; color: #7f8c8d; margin-top: 0.5rem;">Create new subject</div>
                    </div>
                </a>
                <a href="addClass.jsp" style="text-decoration: none;">
                    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; transition: all 0.3s; border-top: 3px solid #3498db;">
                        <div style="font-size: 2rem; margin-bottom: 0.5rem;">👥</div>
                        <div style="font-weight: 600; color: #2c3e50;">Add Class</div>
                        <div style="font-size: 0.9rem; color: #7f8c8d; margin-top: 0.5rem;">Create new class/section</div>
                    </div>
                </a>
                <a href="uploadQuestionsEnhanced.jsp" style="text-decoration: none;">
                    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; transition: all 0.3s; border-top: 3px solid #27ae60;">
                        <div style="font-size: 2rem; margin-bottom: 0.5rem;">📤</div>
                        <div style="font-weight: 600; color: #2c3e50;">Upload Questions</div>
                        <div style="font-size: 0.9rem; color: #7f8c8d; margin-top: 0.5rem;">Bulk upload questions</div>
                    </div>
                </a>
                <a href="createExam.jsp" style="text-decoration: none;">
                    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; transition: all 0.3s; border-top: 3px solid #e74c3c;">
                        <div style="font-size: 2rem; margin-bottom: 0.5rem;">✏️</div>
                        <div style="font-weight: 600; color: #2c3e50;">Create Exam</div>
                        <div style="font-size: 0.9rem; color: #7f8c8d; margin-top: 0.5rem;">Design new exam</div>
                    </div>
                </a>
            </div>
        </div>
        <div class="tabs">
            <div class="tab-buttons">
                <button class="tab-button active" onclick="switchTab('all')">All Exams</button>
                <button class="tab-button" onclick="switchTab('published')">Published</button>
                <button class="tab-button" onclick="switchTab('draft')">Draft</button>
                <button class="tab-button" onclick="switchTab('archived')">Archived</button>
            </div>

            <!-- All Exams Tab -->
            <div id="all" class="tab-content active">
                <% if (exams != null && !exams.isEmpty()) { %>
                    <table class="exam-table">
                        <thead>
                            <tr>
                                <th>Exam Name</th>
                                <th>Class</th>
                                <th>Subject</th>
                                <th>Questions</th>
                                <th>Total Marks</th>
                                <th>Duration</th>
                                <th>Status</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Exam exam : exams) { 
                                Class cls = ClassDAO.getClassById(exam.getClassId());
                                Subject subject = SubjectDAO.getSubjectById(exam.getSubjectId());
                                String className = cls != null ? cls.getClassName() : "N/A";
                                String subjectName = subject != null ? subject.getSubjectName() : "N/A";
                            %>
                            <tr>
                                <td><strong><%= exam.getExamName() %></strong></td>
                                <td><%= className %></td>
                                <td><%= subjectName %></td>
                                <td><%= exam.getQuestionCount() %></td>
                                <td><%= exam.getTotalMarks() %></td>
                                <td><%= exam.getDurationMinutes() %> mins</td>
                                <td>
                                    <% if ("PUBLISHED".equals(exam.getStatus())) { %>
                                        <span class="badge badge-published">Published</span>
                                    <% } else if ("DRAFT".equals(exam.getStatus())) { %>
                                        <span class="badge badge-draft">Draft</span>
                                    <% } else if ("ARCHIVED".equals(exam.getStatus())) { %>
                                        <span class="badge badge-archived">Archived</span>
                                    <% } %>
                                </td>
                                <td><small><%= exam.getCreatedAt() != null ? exam.getCreatedAt().toString().substring(0, 10) : "N/A" %></small></td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="examResult.jsp?examId=<%= exam.getExamId() %>" class="btn-small btn-view">📊 View Results</a>
                                        <% if ("PUBLISHED".equals(exam.getStatus())) { %>
                                            <button class="btn-small btn-start" onclick="openStartModal(<%= exam.getExamId() %>, '<%= exam.getExamName() %>')">▶️ Start Exam</button>
                                        <% } %>
                                        <button class="btn-small btn-delete" onclick="deleteExam(<%= exam.getExamId() %>, '<%= exam.getExamName() %>')">🗑️ Delete</button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div class="empty-state">
                        <p>📋 No exams created yet</p>
                        <p>Create your first exam by clicking "Create New Exam" button above</p>
                    </div>
                <% } %>
            </div>

            <!-- Published Exams Tab -->
            <div id="published" class="tab-content">
                <% if (publishedExams > 0) { %>
                    <table class="exam-table">
                        <thead>
                            <tr>
                                <th>Exam Name</th>
                                <th>Class</th>
                                <th>Subject</th>
                                <th>Questions</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Exam exam : exams) {
                                if ("PUBLISHED".equals(exam.getStatus())) {
                                    Class cls = ClassDAO.getClassById(exam.getClassId());
                                    Subject subject = SubjectDAO.getSubjectById(exam.getSubjectId());
                                    String className = cls != null ? cls.getClassName() : "N/A";
                                    String subjectName = subject != null ? subject.getSubjectName() : "N/A";
                            %>
                            <tr>
                                <td><strong><%= exam.getExamName() %></strong></td>
                                <td><%= className %></td>
                                <td><%= subjectName %></td>
                                <td><%= exam.getQuestionCount() %></td>
                                <td><span class="badge badge-published">Published</span></td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="examResult.jsp?examId=<%= exam.getExamId() %>" class="btn-small btn-view">📊 Results</a>
                                        <button class="btn-small btn-start" onclick="openStartModal(<%= exam.getExamId() %>, '<%= exam.getExamName() %>')">▶️ Start</button>
                                    </div>
                                </td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div class="empty-state">
                        <p>📋 No published exams</p>
                    </div>
                <% } %>
            </div>

            <!-- Draft Exams Tab -->
            <div id="draft" class="tab-content">
                <% if (draftExams > 0) { %>
                    <table class="exam-table">
                        <thead>
                            <tr>
                                <th>Exam Name</th>
                                <th>Class</th>
                                <th>Subject</th>
                                <th>Questions</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Exam exam : exams) {
                                if ("DRAFT".equals(exam.getStatus())) {
                                    Class cls = ClassDAO.getClassById(exam.getClassId());
                                    Subject subject = SubjectDAO.getSubjectById(exam.getSubjectId());
                                    String className = cls != null ? cls.getClassName() : "N/A";
                                    String subjectName = subject != null ? subject.getSubjectName() : "N/A";
                            %>
                            <tr>
                                <td><strong><%= exam.getExamName() %></strong></td>
                                <td><%= className %></td>
                                <td><%= subjectName %></td>
                                <td><%= exam.getQuestionCount() %></td>
                                <td><span class="badge badge-draft">Draft</span></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-small btn-edit" onclick="publishExam(<%= exam.getExamId() %>, '<%= exam.getExamName() %>')">📤 Publish</button>
                                    </div>
                                </td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div class="empty-state">
                        <p>📋 No draft exams</p>
                    </div>
                <% } %>
            </div>

            <!-- Archived Exams Tab -->
            <div id="archived" class="tab-content">
                <% if (archivedExams > 0) { %>
                    <table class="exam-table">
                        <thead>
                            <tr>
                                <th>Exam Name</th>
                                <th>Class</th>
                                <th>Subject</th>
                                <th>Questions</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Exam exam : exams) {
                                if ("ARCHIVED".equals(exam.getStatus())) {
                                    Class cls = ClassDAO.getClassById(exam.getClassId());
                                    Subject subject = SubjectDAO.getSubjectById(exam.getSubjectId());
                                    String className = cls != null ? cls.getClassName() : "N/A";
                                    String subjectName = subject != null ? subject.getSubjectName() : "N/A";
                            %>
                            <tr>
                                <td><strong><%= exam.getExamName() %></strong></td>
                                <td><%= className %></td>
                                <td><%= subjectName %></td>
                                <td><%= exam.getQuestionCount() %></td>
                                <td><span class="badge badge-archived">Archived</span></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-small btn-edit" onclick="restoreExam(<%= exam.getExamId() %>, '<%= exam.getExamName() %>')">♻️ Restore</button>
                                    </div>
                                </td>
                            </tr>
                            <% }} %>
                        </tbody>
                    </table>
                <% } else { %>
                    <div class="empty-state">
                        <p>📋 No archived exams</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Start Exam Modal -->
    <div id="startModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeStartModal()">&times;</span>
            <div class="modal-header">Start Exam</div>
            <div class="modal-body">
                <p id="examModalText"></p>
                <p style="margin-top: 1rem; color: #e74c3c;"><strong>⚠️ Note:</strong> This exam will be made available to students immediately. Students will be able to take this exam.</p>
            </div>
            <div class="modal-footer">
                <button onclick="closeStartModal()" class="btn btn-secondary">Cancel</button>
                <a id="startExamLink" href="#" class="btn btn-primary">Start Exam</a>
            </div>
        </div>
    </div>

    <script>
        // Auto-dismiss alerts after 5 seconds
        function dismissAlert(elementId) {
            const alert = document.getElementById(elementId);
            if (alert) {
                setTimeout(() => {
                    alert.style.opacity = '0';
                    alert.style.transition = 'opacity 0.3s';
                    setTimeout(() => {
                        alert.style.display = 'none';
                    }, 300);
                }, 5000);
            }
        }

        // Dismiss alerts on load
        window.addEventListener('load', function() {
            dismissAlert('successAlert');
            dismissAlert('errorAlert');
        });

        // Tab switching
        function switchTab(tabName) {
            // Hide all tabs
            const tabs = document.querySelectorAll('.tab-content');
            tabs.forEach(tab => tab.classList.remove('active'));

            // Remove active class from all buttons
            const buttons = document.querySelectorAll('.tab-button');
            buttons.forEach(btn => btn.classList.remove('active'));

            // Show selected tab
            document.getElementById(tabName).classList.add('active');

            // Add active class to clicked button
            event.target.classList.add('active');
        }

        // Start exam modal
        function openStartModal(examId, examName) {
            document.getElementById('examModalText').textContent = 'Are you sure you want to start: "' + examName + '"?';
            document.getElementById('startExamLink').href = 'takeExam.jsp?examId=' + examId;
            document.getElementById('startModal').classList.add('show');
        }

        function closeStartModal() {
            document.getElementById('startModal').classList.remove('show');
        }

        // Delete exam
        function deleteExam(examId, examName) {
            if (confirm('Are you sure you want to delete the exam: "' + examName + '"?')) {
                window.location.href = 'deleteExam.jsp?examId=' + examId;
            }
        }

        // Publish exam
        function publishExam(examId, examName) {
            if (confirm('Publish exam: "' + examName + '"? It will be available to students immediately.')) {
                window.location.href = 'publishExam.jsp?examId=' + examId;
            }
        }

        // Restore exam
        function restoreExam(examId, examName) {
            if (confirm('Restore exam: "' + examName + '"?')) {
                window.location.href = 'restoreExam.jsp?examId=' + examId;
            }
        }

        // Close modal on outside click
        window.onclick = function(event) {
            const modal = document.getElementById('startModal');
            if (event.target === modal) {
                modal.classList.remove('show');
            }
        }
    </script>
</body>
</html>
