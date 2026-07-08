<%@page import="com.school.exam.model.Result"%>
<%@page import="com.school.exam.model.Exam"%>
<%@ page import="java.util.*, com.school.exam.model.Student, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check authentication
    Object userRole = session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (userRole == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get exam and student ID from request
    int examId = -1;
    int studentId = -1;
    
    try {
        examId = Integer.parseInt(request.getParameter("examId"));
        if (userRole.equals("STUDENT")) {
            studentId = userId;
        } else {
            // Teacher/admin: use studentId param if given, else own ID (teacher testing mode)
            String studentIdParam = request.getParameter("studentId");
            studentId = (studentIdParam != null && !studentIdParam.isEmpty())
                    ? Integer.parseInt(studentIdParam) : userId;
        }
    } catch (NumberFormatException e) {
        e.printStackTrace();
    }
    
    if (examId <= 0 || studentId <= 0) {
        out.println("<h2>Invalid Exam or Student ID</h2>");
        return;
    }
    
    // Get exam, result, and student info
    Exam exam = ExamDAO.getExamById(examId);
    Result result = ResultDAO.getResultByExamAndStudent(examId, studentId);
    Student student = StudentDAO.getStudentById(studentId);
    
    if (exam == null || student == null) {
        out.println("<h2>Exam or Student not found</h2>");
        return;
    }
    
    if (result == null) {
        out.println("<h2>Result not yet calculated. Please submit the exam first.</h2>");
        return;
    }
    
    // Get class and class average for comparison
    Map<String, Object> classStats = ResultDAO.getClassPerformance(examId);
    Double classAverage = classStats.get("avg_percentage") != null ? (Double) classStats.get("avg_percentage") : 0.0;
    
    // Get list of all students in class with results for comparison
    List<Result> classResults = ResultDAO.getResultsByExam(examId);
    List<Student> classStudents = new ArrayList<>();
    for (Result r : classResults) {
        Student s = StudentDAO.getStudentById(r.getStudentId());
        if (s != null) {
            classStudents.add(s);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Result - Student Activities</title>
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
            max-width: 900px;
            margin: 0 auto;
        }
        
        .result-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        .score-display {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .score-box {
            background: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid #667eea;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .score-box.pass {
            border-left-color: #10b981;
        }
        
        .score-box.fail {
            border-left-color: #ef4444;
        }
        
        .score-value {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .score-label {
            font-size: 13px;
            color: #666;
            text-transform: uppercase;
        }
        
        .grade-circle {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: white;
            font-size: 48px;
            font-weight: bold;
        }
        
        .grade-circle.A {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .grade-circle.B {
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
        }
        
        .grade-circle.C {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .grade-circle.D {
            background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
        }
        
        .grade-circle.F {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        
        .section-title {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            margin-top: 30px;
            margin-bottom: 20px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: #f9fafb;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .stat-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 8px;
        }
        
        .stat-value {
            font-size: 28px;
            font-weight: bold;
            color: #333;
        }
        
        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 10px;
        }
        
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            transition: width 0.3s ease;
        }
        
        .comparison {
            background: #f0f4ff;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        
        .comparison-item {
            display: grid;
            grid-template-columns: 200px 1fr 100px 100px;
            gap: 15px;
            align-items: center;
            padding: 15px 0;
            border-bottom: 1px solid #ddd;
        }
        
        .comparison-item:last-child {
            border-bottom: none;
        }
        
        .student-name {
            font-weight: 500;
            color: #333;
        }
        
        .student-bar {
            background: white;
            border-radius: 4px;
            overflow: hidden;
            height: 30px;
            display: flex;
            align-items: center;
            position: relative;
        }
        
        .bar-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 12px;
            font-weight: bold;
        }
        
        .percentage-text {
            color: #333;
            font-weight: 600;
            text-align: right;
        }
        
        .rank-badge {
            background: #667eea;
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
            min-width: 50px;
        }
        
        .rank-badge.top {
            background: #10b981;
        }
        
        .rank-badge.middle {
            background: #f59e0b;
        }
        
        .rank-badge.low {
            background: #ef4444;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #eee;
        }
        
        button {
            padding: 12px 30px;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #5568d3;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }
        
        .btn-secondary {
            background: #6b7280;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #4b5563;
        }
        
        .medal {
            font-size: 24px;
            margin-right: 10px;
        }
        
        .performance-note {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            padding: 15px;
            border-radius: 6px;
            margin-top: 20px;
            color: #1e40af;
            line-height: 1.6;
        }
        
        .performance-note strong {
            color: #1e3a8a;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>📊 Exam Result</h1>
            <p><strong><%= exam.getExamName() %></strong></p>
            <p style="margin-top: 10px; font-size: 13px;"><%= student.getStudentName() %> | Class <%= student.getClassId() %></p>
        </div>
        
        <div class="result-card">
            <!-- Grade Circle -->
            <div style="text-align: center; margin-bottom: 30px;">
                <div class="grade-circle <%= result.getGrade() %>">
                    <%= result.getGrade() %>
                </div>
                <div style="font-size: 18px; color: #666;">
                    <strong><%= result.getGradeDescription() %></strong>
                </div>
                <% if (result.getPercentage() != null) { %>
                <div style="font-size: 13px; color: #999; margin-top: 5px;">
                    <%= String.format("%.2f", result.getPercentage()) %>% Score
                </div>
                <% } %>
            </div>
            
            <!-- Score Display -->
            <div class="score-display">
                <div class="score-box <%= result.getPercentage() >= 60 ? "pass" : "fail" %>">
                    <div class="score-value"><%= result.getMarksObtained() %>/<%= result.getTotalMarks() %></div>
                    <div class="score-label">Marks</div>
                </div>
                <div class="score-box">
                    <div class="score-value"><%= result.getCorrectAnswers() %></div>
                    <div class="score-label">Correct</div>
                </div>
                <div class="score-box">
                    <div class="score-value"><%= result.getWrongAnswers() %></div>
                    <div class="score-label">Wrong</div>
                </div>
                <div class="score-box">
                    <div class="score-value"><%= result.getSkippedCount() %></div>
                    <div class="score-label">Skipped</div>
                </div>
            </div>
            
            <!-- Performance Note -->
            <div class="performance-note">
                <% if (result.getPercentage() >= 90) { %>
                    ⭐ <strong>Excellent performance!</strong> You have demonstrated excellent understanding of the subject matter.
                <% } else if (result.getPercentage() >= 80) { %>
                    ✅ <strong>Good job!</strong> You have a solid understanding. Focus on improving the weak areas.
                <% } else if (result.getPercentage() >= 70) { %>
                    📝 <strong>Average performance.</strong> You need to strengthen your concepts in weak areas.
                <% } else if (result.getPercentage() >= 60) { %>
                    ⚠️ <strong>Below average.</strong> Please review and practice more questions in weak chapters.
                <% } else { %>
                    ❌ <strong>Needs improvement.</strong> You should review the entire chapter and practice more.
                <% } %>
            </div>
            
            <!-- Statistics -->
            <div class="section-title">📈 Detailed Statistics</div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-label">Questions</div>
                    <div class="stat-value"><%= result.getTotalQuestions() %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Attempted</div>
                    <div class="stat-value"><%= result.getAttemptedQuestions() != null ? result.getAttemptedQuestions() : 0 %></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Accuracy</div>
                    <div class="stat-value">
                        <% if (result.getAttemptedQuestions() > 0) { %>
                            <%= String.format("%.0f", (result.getCorrectAnswers() * 100.0) / result.getAttemptedQuestions()) %>%
                        <% } else { %>
                            0%
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- Class Comparison -->
            <% if (classAverage > 0) { %>
            <div class="section-title">🏆 Comparison with Class</div>
            <div class="comparison">
                <div class="comparison-item" style="background: #fff3cd; border-radius: 6px; padding: 15px; margin-bottom: 15px;">
                    <div class="student-name">Your Score</div>
                    <div class="student-bar">
                        <div class="bar-fill" style="width: <%= result.getPercentage() %>%;">
                            <%= String.format("%.1f", result.getPercentage()) %>%
                        </div>
                    </div>
                    <div class="percentage-text"><%= String.format("%.1f", result.getPercentage()) %>%</div>
                    <div class="rank-badge">YOU</div>
                </div>
                
                <div class="comparison-item">
                    <div class="student-name">Class Average</div>
                    <div class="student-bar">
                        <div class="bar-fill" style="width: <%= classAverage %>%;">
                            <%= String.format("%.1f", classAverage) %>%
                        </div>
                    </div>
                    <div class="percentage-text"><%= String.format("%.1f", classAverage) %>%</div>
                    <div style="text-align: center;">
                        <% if (result.getPercentage() > classAverage) { %>
                            <span style="color: #10b981; font-weight: bold;">↑ Above</span>
                        <% } else if (result.getPercentage() < classAverage) { %>
                            <span style="color: #ef4444; font-weight: bold;">↓ Below</span>
                        <% } else { %>
                            <span style="color: #f59e0b; font-weight: bold;">= Average</span>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
            
            <!-- Top Performers -->
            <% List<Result> topPerformers = ResultDAO.getTopPerformers(examId, 3); %>
            <% if (!topPerformers.isEmpty()) { %>
            <div class="section-title">🥇 Top Performers in Class</div>
            <div class="comparison">
                <% int rank = 1; %>
                <% for (Result topResult : topPerformers) { 
                    Student topStudent = StudentDAO.getStudentById(topResult.getStudentId());
                    String medal = rank == 1 ? "🥇" : (rank == 2 ? "🥈" : "🥉");
                %>
                <div class="comparison-item">
                    <div class="student-name"><%= medal %> <%= topStudent.getStudentName() %></div>
                    <div class="student-bar">
                        <div class="bar-fill" style="width: <%= topResult.getPercentage() %>%;">
                            <%= String.format("%.1f", topResult.getPercentage()) %>%
                        </div>
                    </div>
                    <div class="percentage-text"><%= String.format("%.1f", topResult.getPercentage()) %>%</div>
                    <div class="rank-badge top"><%= topResult.getGrade() %></div>
                </div>
                <% rank++; %>
                <% } %>
            </div>
            <% } %>
            
            <!-- Action Buttons -->
            <div class="button-group">
                <button class="btn-primary" onclick="window.print()">🖨️ Print Result</button>
                <button class="btn-secondary" onclick="history.back()">← Go Back</button>
            </div>
        </div>
    </div>
</body>
</html>
