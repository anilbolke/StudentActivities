<%@page import="com.school.exam.model.Class"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%
    // Check if user is logged in and is TEACHER (or ADMIN)
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (username == null || (!("TEACHER".equals(userRole)) && !("ADMIN".equals(userRole)))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Variables for messages
    String message = "";
    String messageType = "";
    int successCount = 0;
    int errorCount = 0;
    List<String> errorDetails = new ArrayList<>();
    
    // Handle file upload
    if ("POST".equals(request.getMethod())) {
        try {
            String fileContent = request.getParameter("fileContent");
            
            if (fileContent == null || fileContent.trim().isEmpty()) {
                message = "Please paste question data!";
                messageType = "error";
            } else {
                // Parse and process questions
                String[] lines = fileContent.split("\n");
                boolean skipHeader = true;
                
                for (String line : lines) {
                    line = line.trim();
                    if (line.isEmpty()) continue;
                    
                    // Skip header row (contains column names)
                    if (skipHeader && line.contains("CLASS")) {
                        skipHeader = false;
                        continue;
                    }
                    
                    try {
                        // Parse pipe-separated format: CLASS|SUBJECT|CHAPTER|QUESTION_TEXT|OPTION_A|OPTION_B|OPTION_C|OPTION_D|CORRECT_ANSWER|DIFFICULTY|MARKS
                        String[] parts = line.split("\\|");
                        
                        if (parts.length < 11) {
                            errorDetails.add("Line skipped - insufficient fields: " + line.substring(0, Math.min(50, line.length())));
                            errorCount++;
                            continue;
                        }
                        
                        Question question = new Question();
                        
                        // Extract class name and subject name from data (parts[0] and parts[1])
                        String className = parts[0].trim();
                        String subjectName = parts[1].trim();
                        
                        Class cls = null;
                        Subject subject = null;
                        
                        // Try to find class and subject
                        // If not found, skip this question but continue processing others
                        try {
                            // Look up class and subject IDs by name
                            cls = ClassDAO.getClassByName(className);
                            subject = SubjectDAO.getSubjectByName(subjectName);
                            
                            // ✅ SIMPLIFIED: Only check for existence, don't enforce strict validation
                            if (cls == null) {
                                errorDetails.add("⚠️ Skipped - Class not found: " + className);
                                errorCount++;
                                continue;
                            }
                            
                            if (subject == null) {
                                errorDetails.add("⚠️ Skipped - Subject not found: " + subjectName);
                                errorCount++;
                                continue;
                            }
                            
                            question.setClassId(cls.getClassId());
                            question.setSubjectId(subject.getSubjectId());
                        } catch (Exception e) {
                            errorDetails.add("⚠️ Skipped - Error looking up class/subject: " + e.getMessage());
                            errorCount++;
                            continue;
                        }
                        
                        question.setQuestionText(parts[3].trim());
                        question.setOptionA(parts[4].trim());
                        question.setOptionB(parts[5].trim());
                        question.setOptionC(parts[6].trim());
                        question.setOptionD(parts[7].trim());
                        question.setCorrectAnswer(parts[8].trim().toUpperCase());
                        
                        // ✅ SIMPLIFIED: Just set difficulty as provided (default to MEDIUM if empty or invalid)
                        String difficultyStr = parts[9].trim().toUpperCase();
                        if (difficultyStr.isEmpty()) {
                            difficultyStr = "MEDIUM";
                        }
                        // Auto-default invalid values to MEDIUM instead of rejecting
                        if (!difficultyStr.matches("EASY|MEDIUM|HARD")) {
                            difficultyStr = "MEDIUM";
                        }
                        question.setDifficultyLevel(difficultyStr);
                        
                        // ✅ SIMPLIFIED: Try to parse marks, if fails, default to 1 (don't reject)
                        try {
                            int marks = Integer.parseInt(parts[10].trim());
                            question.setMarks(marks > 0 ? marks : 1);
                        } catch (NumberFormatException e) {
                            question.setMarks(1);  // Default to 1 mark if parse fails
                        }
                        
                        // ✅ ENABLED: Auto-create chapter if provided
                        // Auto-create chapter if provided
                        String chapterName = parts[2].trim();
                        if (!chapterName.isEmpty() && !chapterName.equalsIgnoreCase("NULL")) {
                            try {
                                int chapterId = ChapterDAO.getOrCreateChapter(chapterName, subject.getSubjectId());
                                if (chapterId > 0) {
                                    question.setChapterId(chapterId);
                                } else {
                                    System.err.println("[UPLOAD] Warning: Could not create/get chapter: " + chapterName);
                                }
                            } catch (Exception e) {
                                System.err.println("[UPLOAD] Error creating chapter: " + e.getMessage());
                                e.printStackTrace();
                            }
                        }
                        
                        question.setStatus("ACTIVE");
                        question.setCreatedBy(userId != null ? userId : 1); // Use logged-in user's ID, fallback to 1
                        
                        // ✅ NEW: Set school_id for school-specific visibility
                        // If user is TEACHER, questions belong to their school only (schoolId from session)
                        // If user is ADMIN, questions are global (schoolId = null, visible to all)
                        if ("TEACHER".equals(userRole)) {
                            Integer schoolId = (Integer) session.getAttribute("schoolId");
                            if (schoolId != null) {
                                question.setSchoolId(schoolId);
                            }
                            // If teacher has no schoolId in session, questions will have null (less ideal but won't break)
                        }
                        // For ADMIN, schoolId remains null (global questions)

                        
                        int questionId = QuestionDAO.addQuestion(question);
                        if (questionId > 0) {
                            successCount++;
                        } else {
                            errorDetails.add("Failed to insert question: " + question.getQuestionText().substring(0, Math.min(40, question.getQuestionText().length())));
                            errorCount++;
                        }
                        
                    } catch (Exception e) {
                        errorDetails.add("Error processing line: " + e.getMessage());
                        errorCount++;
                    }
                }
                
                if (successCount > 0) {
                    message = successCount + " question(s) uploaded successfully!";
                    if (errorCount > 0) {
                        message += " (" + errorCount + " errors)";
                    }
                    messageType = "success";
                } else {
                    message = "Failed to upload questions. Please check the format.";
                    messageType = "error";
                }
            }
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
            messageType = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Questions - School Exam System</title>
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
        .form-group select,
        .form-group textarea {
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 5px rgba(102, 126, 234, 0.3);
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 300px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
        }
        
        .format-info {
            background: #f0f4ff;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
            font-size: 13px;
            color: #333;
        }
        
        .format-info strong {
            color: #667eea;
        }
        
        .format-info code {
            background: white;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: monospace;
            color: #e74c3c;
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
        
        .error-details {
            background: #fff3cd;
            border: 1px solid #ffeeba;
            border-radius: 5px;
            padding: 15px;
            margin-top: 20px;
            max-height: 200px;
            overflow-y: auto;
        }
        
        .error-details h4 {
            color: #856404;
            margin-bottom: 10px;
        }
        
        .error-details li {
            color: #856404;
            font-size: 12px;
            margin-bottom: 5px;
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
            <h1>Upload Exam Questions</h1>
            <p>Bulk upload questions with class and subject data included in each row</p>
        </div>
        
        <div class="content">
            <a href="dashboard.jsp" class="back-link">← Back to Dashboard</a>
            
            <% if (!message.isEmpty()) { %>
                <div class="message <%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form method="POST" action="uploadQuestionsEnhanced.jsp">
                <!-- Selection Section -->
                
                <!-- Format Information -->
                <div class="form-section">
                    <h3>Question Format</h3>
                    <div class="format-info">
                        <strong>Format:</strong> Use pipe-separated (|) values with this exact order:<br><br>
                        <code>CLASS|SUBJECT|CHAPTER|QUESTION_TEXT|OPTION_A|OPTION_B|OPTION_C|OPTION_D|CORRECT_ANSWER|DIFFICULTY|MARKS</code><br><br>
                        <strong>Example:</strong><br>
                        <code>10|Mathematics|Algebra|What is 2+2?|3|4|5|6|B|EASY|1</code><br><br>
                        <strong>Notes:</strong>
                        <ul>
                            <li><strong>CORRECT_ANSWER:</strong> Must be A, B, C, or D</li>
                            <li><strong>DIFFICULTY:</strong> Must be EASY, MEDIUM, or HARD</li>
                            <li><strong>MARKS:</strong> Integer value (usually 1-3)</li>
                            <li><strong>CHAPTER:</strong> Optional - can leave blank or use "NULL"</li>
                            <li>First line (header) will be skipped if it contains column names</li>
                        </ul>
                    </div>
                </div>
                
                <!-- Questions Input Section -->
                <div class="form-section">
                    <h3>Paste Question Data</h3>
                    
                    <div class="form-group">
                        <label for="fileContent">Question Data (Pipe-Separated) <span>*</span></label>
                        <textarea id="fileContent" name="fileContent" placeholder="Paste your question data here (each line is one question)..." required></textarea>
                    </div>
                </div>
                
                <!-- Buttons -->
                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Upload Questions</button>
                    <a href="dashboard.jsp" class="btn btn-secondary" style="text-decoration: none; display: inline-block;">Cancel</a>
                </div>
            </form>
            
            <!-- Error Details -->
            <% if (errorDetails.size() > 0) { %>
                <div class="error-details">
                    <h4>⚠️ Error Details (showing first 10)</h4>
                    <ul>
                        <% 
                            int count = 0;
                            for (String error : errorDetails) {
                                if (count >= 10) break;
                        %>
                            <li><%= error %></li>
                        <% 
                                count++;
                            }
                        %>
                    </ul>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
