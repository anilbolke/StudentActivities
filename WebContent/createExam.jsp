<%@page import="com.school.exam.model.Class"%>
<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check if user is TEACHER
    Object userRole = session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    
    if (userRole == null || (!userRole.equals("TEACHER") && !userRole.equals("ADMIN")) || userId == null || schoolId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String action = request.getParameter("action");
    
    // Get all classes for this teacher's school
    List<Class> classes = ClassDAO.getClassesBySchool(schoolId);
    
    // Get all subjects for this school
    List<Subject> subjects = new ArrayList<>();
    List<Chapter> chapters = new ArrayList<>();
    List<Question> previewQuestions = new ArrayList<>();
    
    int selectedClassId = -1;
    int selectedSubjectId = -1;
    List<Integer> selectedChapterIds = new ArrayList<>();
    String selectedDifficulty = "MIXED";
    int selectedQuestionCount = 10;
    int totalMarks = 10;
    
    if (request.getMethod().equals("POST")) {
        try {
            // Safely parse parameters with null checks
            String classIdStr = request.getParameter("classId");
            if (classIdStr != null && !classIdStr.isEmpty()) {
                selectedClassId = Integer.parseInt(classIdStr);
            }
            
            String subjectIdStr = request.getParameter("subjectId");
            if (subjectIdStr != null && !subjectIdStr.isEmpty()) {
                selectedSubjectId = Integer.parseInt(subjectIdStr);
            }
            
            String difficultyStr = request.getParameter("difficulty");
            if (difficultyStr != null && !difficultyStr.isEmpty()) {
                selectedDifficulty = difficultyStr;
            }
            
            String questionCountStr = request.getParameter("questionCount");
            if (questionCountStr != null && !questionCountStr.isEmpty()) {
                selectedQuestionCount = Integer.parseInt(questionCountStr);
            }
            
            String totalMarksStr = request.getParameter("totalMarks");
            if (totalMarksStr != null && !totalMarksStr.isEmpty()) {
                totalMarks = Integer.parseInt(totalMarksStr);
            }
            
            // Get selected chapters
            String[] chapterArray = request.getParameterValues("chapters");
            if (chapterArray != null) {
                for (String chId : chapterArray) {
                    selectedChapterIds.add(Integer.parseInt(chId));
                }
            }
            
            // Get subjects for selected class
            // ✅ Use teacher-filtered method: shows only subjects where teacher has questions
            subjects = SubjectDAO.getSubjectsBySchoolForTeacher(schoolId, userId);
            
            if (selectedSubjectId > 0 && selectedClassId > 0) {
                // Get chapters that have questions for selected class and subject
                // ✅ Use teacher-filtered method: shows only chapters from THAT SCHOOL
                chapters = ChapterDAO.getChaptersWithQuestionsByClassSubjectForTeacher(selectedClassId, selectedSubjectId, userId, schoolId);
                
                // Get preview questions
                if (!selectedChapterIds.isEmpty()) {
                    try {
                        // ✅ UPDATED: Use teacher-filtered method to get ONLY this teacher's questions + admin questions
                        previewQuestions = QuestionDAO.getQuestionsByClassSubjectChaptersForTeacher(
                            selectedClassId, selectedSubjectId, selectedChapterIds, schoolId, userId
                        );
                        
                        // Limit to selected count for preview
                        if (previewQuestions.size() > selectedQuestionCount) {
                            previewQuestions = previewQuestions.subList(0, selectedQuestionCount);
                        }
                    } catch (Exception qe) {
                        System.out.println("Error fetching preview questions: " + qe.getMessage());
                        qe.printStackTrace();
                    }
                }
            }
        } catch (NumberFormatException e) {
            System.out.println("Error parsing form parameters: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.out.println("Unexpected error in form processing: " + e.getMessage());
            e.printStackTrace();
        }
    } else {
        // ✅ Use teacher-filtered method: shows only subjects where teacher has questions
        subjects = SubjectDAO.getSubjectsBySchoolForTeacher(schoolId, userId);
    }
    
    // Handle exam creation
    String createMessage = "";
    if ("create".equals(action) && selectedClassId > 0 && selectedSubjectId > 0 && !selectedChapterIds.isEmpty()) {
        try {
            // Get questions for exam
            // ✅ UPDATED: Use teacher-filtered method
            List<Question> examQuestions = QuestionDAO.getQuestionsByClassSubjectChaptersForTeacher(
                selectedClassId, selectedSubjectId, selectedChapterIds, schoolId, userId
            );
            
            if (examQuestions.isEmpty()) {
                createMessage = "⚠️ No questions found for selected filters!";
            } else if (examQuestions.size() < selectedQuestionCount) {
                createMessage = "⚠️ Only " + examQuestions.size() + " questions available (less than requested " + selectedQuestionCount + ")";
            } else {
                // Randomize and limit questions
                java.util.Collections.shuffle(examQuestions);
                examQuestions = examQuestions.subList(0, Math.min(selectedQuestionCount, examQuestions.size()));
                
                // Create exam
                Exam exam = new Exam(
                    "Exam - " + (new java.text.SimpleDateFormat("dd-MMM-yyyy HH:mm")).format(new java.util.Date()),
                    selectedClassId,
                    selectedSubjectId,
                    examQuestions.size(),
                    totalMarks
                );
                exam.setDifficultyLevel(selectedDifficulty);
                exam.setStatus("PUBLISHED");
                exam.setCreatedBy(userId);
                exam.setDurationMinutes(60);
                
                int examId = ExamDAO.createExam(exam, examQuestions);
                
                if (examId > 0) {
                    createMessage = "✅ Exam created successfully! Exam ID: " + examId;
                } else {
                    createMessage = "❌ Failed to create exam. Please try again.";
                }
            }
        } catch (Exception e) {
            createMessage = "❌ Error: " + e.getMessage();
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Exam - Student Activities</title>
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
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 30px;
        }
        
        h1 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
        }

        .top-bar {
            margin-bottom: 20px;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #f0f2ff;
            color: #667eea;
            border: 1px solid #d5d9f7;
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.2s;
        }

        .back-btn:hover {
            background: #667eea;
            color: white;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .form-section h2 {
            font-size: 18px;
            color: #555;
            margin-bottom: 15px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-grid.full {
            grid-template-columns: 1fr;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }
        
        select, input[type="text"], input[type="number"] {
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        select:focus, input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .chapters-selection {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-top: 10px;
            max-height: 300px;
            overflow-y: auto;
            padding: 10px;
            background: #f9f9f9;
            border-radius: 5px;
        }
        
        .checkbox-item {
            display: flex;
            align-items: center;
            padding: 8px;
        }
        
        .checkbox-item input[type="checkbox"] {
            width: 18px;
            height: 18px;
            margin-right: 10px;
            cursor: pointer;
        }
        
        .checkbox-item label {
            margin: 0;
            cursor: pointer;
            font-weight: normal;
            flex: 1;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        button {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-preview {
            background: #667eea;
            color: white;
        }
        
        .btn-preview:hover {
            background: #5568d3;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }
        
        .btn-create {
            background: #10b981;
            color: white;
        }
        
        .btn-create:hover {
            background: #059669;
            box-shadow: 0 5px 15px rgba(16, 185, 129, 0.3);
        }
        
        .message {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
        }
        
        .message.success {
            background: #d1fae5;
            color: #065f46;
            border-left: 4px solid #10b981;
        }
        
        .message.error {
            background: #fee2e2;
            color: #991b1b;
            border-left: 4px solid #ef4444;
        }
        
        .message.warning {
            background: #fef3c7;
            color: #92400e;
            border-left: 4px solid #f59e0b;
        }
        
        .preview-section {
            background: #f8f9ff;
            padding: 25px;
            border-radius: 12px;
            margin-top: 30px;
            border: 1px solid #e0e4ff;
        }

        .preview-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #667eea;
        }

        .preview-header h3 {
            color: #333;
            font-size: 20px;
        }

        .preview-count {
            background: #667eea;
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
        }

        .question-preview {
            background: white;
            padding: 20px;
            margin-bottom: 15px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border: 1px solid #eef0f7;
            transition: box-shadow 0.2s;
        }

        .question-preview:hover {
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.15);
        }

        .question-top {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 15px;
        }

        .q-number {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-width: 34px;
            height: 34px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 14px;
            flex-shrink: 0;
        }

        .q-text {
            color: #1f2937;
            font-size: 15px;
            font-weight: 600;
            line-height: 1.6;
            padding-top: 6px;
            flex: 1;
        }

        .options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-left: 46px;
        }

        @media (max-width: 650px) {
            .options { grid-template-columns: 1fr; margin-left: 0; }
            .question-meta-row { margin-left: 0 !important; }
        }

        .option {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            background: #f7f8fc;
            border: 1px solid #e5e7f2;
            border-radius: 8px;
            font-size: 14px;
            color: #444;
        }

        .option .opt-letter {
            background: white;
            border: 1px solid #d5d9ea;
            color: #667eea;
            min-width: 26px;
            height: 26px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 12px;
            flex-shrink: 0;
        }

        .option.correct {
            background: #ecfdf5;
            border-color: #6ee7b7;
            color: #065f46;
            font-weight: 600;
        }

        .option.correct .opt-letter {
            background: #10b981;
            border-color: #10b981;
            color: white;
        }

        .option.correct::after {
            content: "✓ Answer";
            margin-left: auto;
            background: #10b981;
            color: white;
            font-size: 11px;
            font-weight: bold;
            padding: 2px 8px;
            border-radius: 10px;
            white-space: nowrap;
        }

        .question-meta-row {
            display: flex;
            gap: 10px;
            margin-top: 12px;
            margin-left: 46px;
            flex-wrap: wrap;
        }

        .meta-chip {
            font-size: 12px;
            padding: 4px 12px;
            border-radius: 12px;
            font-weight: 600;
            background: #f3f4f6;
            color: #555;
        }

        .meta-chip.diff-EASY   { background: #d1fae5; color: #065f46; }
        .meta-chip.diff-MEDIUM { background: #fef3c7; color: #92400e; }
        .meta-chip.diff-HARD   { background: #fee2e2; color: #991b1b; }

        .stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 25px;
        }

        @media (max-width: 650px) {
            .stats { grid-template-columns: 1fr 1fr; }
        }

        .stat-card {
            background: white;
            border: 1px solid #e0e4ff;
            border-top: 4px solid #667eea;
            color: #333;
            padding: 16px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }

        .stat-card .value {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 4px;
            color: #667eea;
        }

        .stat-card .label {
            font-size: 12px;
            color: #777;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .no-data {
            text-align: center;
            padding: 30px;
            color: #999;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            String dashboardPage = "dashboard.jsp";
            if ("ADMIN".equals(userRole)) {
                dashboardPage = "adminDashboard.jsp";
            } else if ("SCHOOL_ADMIN".equals(userRole)) {
                dashboardPage = "schoolAdminDashboard.jsp";
            }
        %>
        <div class="top-bar">
            <a href="<%= dashboardPage %>" class="back-btn">⬅ Back to Dashboard</a>
        </div>

        <h1>📝 Create Exam</h1>
        
        <% if (!createMessage.isEmpty()) { 
            String messageClass = "success";
            if (createMessage.contains("Failed") || createMessage.contains("Error")) {
                messageClass = "error";
            } else if (createMessage.contains("⚠️")) {
                messageClass = "warning";
            }
        %>
            <div class="message <%= messageClass %>"><%= createMessage %></div>
        <% } %>
        
        <form method="post" action="createExam.jsp">
            <!-- Step 1: Select Class -->
            <div class="form-section">
                <h2>Step 1: Select Class</h2>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="classId">Class *</label>
                        <select id="classId" name="classId" required onchange="this.form.submit();">
                            <option value="">-- Select Class --</option>
                            <% for (Class cls : classes) { %>
                                <option value="<%= cls.getClassId() %>" <%= selectedClassId == cls.getClassId() ? "selected" : "" %>>
                                    <%= cls.getClassName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>
            </div>
            
            <!-- Step 2: Select Subject -->
            <% if (selectedClassId > 0) { %>
            <div class="form-section">
                <h2>Step 2: Select Subject</h2>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="subjectId">Subject *</label>
                        <select id="subjectId" name="subjectId" required onchange="this.form.submit();">
                            <option value="">-- Select Subject --</option>
                            <% for (Subject subject : subjects) { %>
                                <option value="<%= subject.getSubjectId() %>" <%= selectedSubjectId == subject.getSubjectId() ? "selected" : "" %>>
                                    <%= subject.getSubjectName() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>
            </div>
            <% } %>
            
            <!-- Step 3: Select Chapters -->
            <% if (selectedSubjectId > 0) { %>
            <div class="form-section">
                <h2>Step 3: Select Chapters (Multi-Select) *</h2>
                <% if (chapters.isEmpty()) { %>
                    <p class="no-data">No chapters available for this subject. Please add chapters first.</p>
                <% } else { %>
                    <div class="chapters-selection">
                        <% for (Chapter chapter : chapters) { %>
                        <div class="checkbox-item">
                            <input type="checkbox" name="chapters" value="<%= chapter.getChapterId() %>" 
                                   <%= selectedChapterIds.contains(chapter.getChapterId()) ? "checked" : "" %>>
                            <label><%= chapter.getChapterName() %></label>
                        </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
            <% } %>
            
            <!-- Step 4: Configure Exam -->
            <% if (selectedSubjectId > 0 && !chapters.isEmpty()) { %>
            <div class="form-section">
                <h2>Step 4: Configure Exam</h2>
                <div class="form-grid">
                    <div class="form-group">
                        <label for="difficulty">Difficulty Level</label>
                        <select id="difficulty" name="difficulty">
                            <option value="MIXED" <%= "MIXED".equals(selectedDifficulty) ? "selected" : "" %>>Mixed</option>
                            <option value="EASY" <%= "EASY".equals(selectedDifficulty) ? "selected" : "" %>>Easy Only</option>
                            <option value="MEDIUM" <%= "MEDIUM".equals(selectedDifficulty) ? "selected" : "" %>>Medium Only</option>
                            <option value="HARD" <%= "HARD".equals(selectedDifficulty) ? "selected" : "" %>>Hard Only</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="questionCount">Number of Questions *</label>
                        <input type="number" id="questionCount" name="questionCount" min="1" max="100" 
                               value="<%= selectedQuestionCount %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="totalMarks">Total Marks *</label>
                        <input type="number" id="totalMarks" name="totalMarks" min="1" max="1000" 
                               value="<%= totalMarks %>" required>
                    </div>
                </div>
                
                <div class="button-group">
                    <button type="submit" class="btn-preview" name="action" value="preview">Preview Questions</button>
                </div>
            </div>
            <% } %>
        </form>
        
        <!-- Question Preview -->
        <% if (!previewQuestions.isEmpty()) { %>
        <div class="preview-section">
            <div class="preview-header">
                <h3>📋 Question Preview</h3>
                <span class="preview-count"><%= previewQuestions.size() %> question<%= previewQuestions.size() == 1 ? "" : "s" %></span>
            </div>

            <div class="stats">
                <div class="stat-card">
                    <div class="value"><%= previewQuestions.size() %></div>
                    <div class="label">Total Questions</div>
                </div>
                <div class="stat-card">
                    <div class="value"><%= totalMarks %></div>
                    <div class="label">Total Marks</div>
                </div>
                <div class="stat-card">
                    <div class="value"><%= selectedChapterIds.size() %></div>
                    <div class="label">Chapters Selected</div>
                </div>
                <div class="stat-card">
                    <div class="value"><%= selectedDifficulty %></div>
                    <div class="label">Difficulty</div>
                </div>
            </div>
            
            <% int qNum = 1; %>
            <% for (Question q : previewQuestions) {
                String correctAns = q.getCorrectAnswer();
            %>
            <div class="question-preview">
                <div class="question-top">
                    <span class="q-number"><%= qNum %></span>
                    <span class="q-text"><%= q.getQuestionText() %></span>
                </div>
                <div class="options">
                    <div class="option <%= "A".equals(correctAns) ? "correct" : "" %>"><span class="opt-letter">A</span> <%= q.getOptionA() %></div>
                    <div class="option <%= "B".equals(correctAns) ? "correct" : "" %>"><span class="opt-letter">B</span> <%= q.getOptionB() %></div>
                    <div class="option <%= "C".equals(correctAns) ? "correct" : "" %>"><span class="opt-letter">C</span> <%= q.getOptionC() %></div>
                    <div class="option <%= "D".equals(correctAns) ? "correct" : "" %>"><span class="opt-letter">D</span> <%= q.getOptionD() %></div>
                </div>
                <div class="question-meta-row">
                    <span class="meta-chip diff-<%= q.getDifficultyLevel() %>"><%= q.getDifficultyLevel() %></span>
                    <span class="meta-chip">⭐ <%= q.getMarks() %> mark<%= q.getMarks() == 1 ? "" : "s" %></span>
                </div>
            </div>
            <% qNum++; %>
            <% } %>
            
            <form method="post" action="createExam.jsp" style="margin-top: 20px;">
                <input type="hidden" name="action" value="create">
                <input type="hidden" name="classId" value="<%= selectedClassId %>">
                <input type="hidden" name="subjectId" value="<%= selectedSubjectId %>">
                <input type="hidden" name="difficulty" value="<%= selectedDifficulty %>">
                <input type="hidden" name="questionCount" value="<%= selectedQuestionCount %>">
                <input type="hidden" name="totalMarks" value="<%= totalMarks %>">
                <% for (Integer chapId : selectedChapterIds) { %>
                    <input type="hidden" name="chapters" value="<%= chapId %>">
                <% } %>
                
                <div class="button-group">
                    <button type="submit" class="btn-create">✅ Create Exam</button>
                </div>
            </form>
        </div>
        <% } else if ("POST".equals(request.getMethod()) && selectedChapterIds.isEmpty()) { %>
        <div style="background: #fff3cd; padding: 15px; margin-top: 20px; border-radius: 5px; border-left: 4px solid #ffc107;">
            <strong>⚠️ No Chapters Selected</strong><br>
            Please select at least one chapter to preview questions.
        </div>
        <% } else if ("POST".equals(request.getMethod()) && !selectedChapterIds.isEmpty() && previewQuestions.isEmpty()) { %>
        <div style="background: #f8d7da; padding: 15px; margin-top: 20px; border-radius: 5px; border-left: 4px solid #dc3545;">
            <strong>❌ No Questions Found</strong><br>
            No questions exist for the selected class, subject, and chapters.
        </div>
        <% } %>
    </div>
</body>
</html>
