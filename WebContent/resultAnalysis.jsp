<%@page import="com.school.exam.model.Class"%>
<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check if user is TEACHER
    Object userRole = session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    
    if (userRole == null || !userRole.equals("TEACHER") || userId == null || schoolId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get exam ID from request
    int examId = -1;
    try {
        examId = Integer.parseInt(request.getParameter("examId"));
    } catch (NumberFormatException e) {
        e.printStackTrace();
    }
    
    if (examId <= 0) {
        out.println("<h2>Invalid Exam ID</h2>");
        return;
    }
    
    // Get exam and class details
    Exam exam = ExamDAO.getExamById(examId);
    if (exam == null) {
        out.println("<h2>Exam not found</h2>");
        return;
    }
    
    Class examClass = ClassDAO.getClassById(exam.getClassId());
    Subject examSubject = SubjectDAO.getSubjectById(exam.getSubjectId());
    
    // Get class performance statistics
    Map<String, Object> classStats = ResultDAO.getClassPerformance(examId);
    List<Result> allResults = ResultDAO.getResultsByExam(examId);
    
    // Get top and bottom performers
    List<Result> topPerformers = ResultDAO.getTopPerformers(examId, 5);
    List<Result> failedStudents = ResultDAO.getFailedStudents(examId);
    
    // Calculate grade distribution
    int totalStudents = (Integer) classStats.get("total_students");
    int countA = (Integer) classStats.get("count_a");
    int countB = (Integer) classStats.get("count_b");
    int countC = (Integer) classStats.get("count_c");
    int countD = (Integer) classStats.get("count_d");
    int countF = (Integer) classStats.get("count_f");
    
    // Build student list with results
    List<Map<String, Object>> studentResults = new ArrayList<>();
    for (Result result : allResults) {
        Map<String, Object> studentMap = new HashMap<>();
        Student student = StudentDAO.getStudentById(result.getStudentId());
        studentMap.put("student", student);
        studentMap.put("result", result);
        studentResults.add(studentMap);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Analysis - Student Activities</title>
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
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .header h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 28px;
        }
        
        .header-meta {
            color: #666;
            font-size: 14px;
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-top: 20px;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .meta-value {
            font-weight: bold;
            color: #333;
            font-size: 16px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            border-left: 4px solid #667eea;
        }
        
        .stat-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .stat-subtext {
            font-size: 12px;
            color: #999;
        }
        
        .section {
            background: white;
            border-radius: 8px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .section-title {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            margin-bottom: 20px;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        
        .grade-distribution {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .grade-box {
            text-align: center;
            padding: 20px;
            border-radius: 8px;
            color: white;
        }
        
        .grade-box.A {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .grade-box.B {
            background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
        }
        
        .grade-box.C {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .grade-box.D {
            background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
        }
        
        .grade-box.F {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        
        .grade-count {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .grade-label {
            font-size: 12px;
            opacity: 0.9;
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
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        thead {
            background: #f3f4f6;
            border-bottom: 2px solid #e5e7eb;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            font-size: 13px;
            text-transform: uppercase;
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #e5e7eb;
            color: #666;
        }
        
        tr:hover {
            background: #f9fafb;
        }
        
        .rank-badge {
            display: inline-block;
            background: #667eea;
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            min-width: 35px;
            text-align: center;
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
        
        .percentage-cell {
            font-weight: 600;
            color: #333;
        }
        
        .grade-cell {
            font-weight: bold;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            display: inline-block;
        }
        
        .grade-A { background: #10b981; }
        .grade-B { background: #3b82f6; }
        .grade-C { background: #f59e0b; }
        .grade-D { background: #f97316; }
        .grade-F { background: #ef4444; }
        
        .alert-box {
            background: #fee2e2;
            border: 1px solid #fecaca;
            padding: 15px;
            border-radius: 6px;
            color: #991b1b;
            margin-bottom: 20px;
        }
        
        .alert-box strong {
            color: #7f1d1d;
        }
        
        .alert-title {
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .button-group {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 20px;
        }
        
        button {
            padding: 12px 30px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-print {
            background: #667eea;
            color: white;
        }
        
        .btn-print:hover {
            background: #5568d3;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }
        
        .btn-back {
            background: #6b7280;
            color: white;
        }
        
        .btn-back:hover {
            background: #4b5563;
        }
        
        .medal {
            font-size: 18px;
            margin-right: 8px;
        }
        
        @media print {
            body {
                background: white;
            }
            .button-group {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>📊 Exam Analysis & Performance Dashboard</h1>
            <div class="header-meta">
                <div class="meta-item">
                    <span>Exam:</span>
                    <span class="meta-value"><%= exam.getExamName() %></span>
                </div>
                <div class="meta-item">
                    <span>Class:</span>
                    <span class="meta-value"><%= examClass != null ? examClass.getGrade() + "-" + examClass.getSection() : "N/A" %></span>
                </div>
                <div class="meta-item">
                    <span>Subject:</span>
                    <span class="meta-value"><%= examSubject != null ? examSubject.getSubjectName() : "N/A" %></span>
                </div>
            </div>
        </div>
        
        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Students</div>
                <div class="stat-value"><%= totalStudents %></div>
                <div class="stat-subtext"><%= classStats.get("submitted") %> submitted</div>
            </div>
            
            <div class="stat-card" style="border-left-color: #10b981;">
                <div class="stat-label">Class Average</div>
                <div class="stat-value"><%= String.format("%.1f", classStats.get("avg_rounded")) %>%</div>
                <div class="stat-subtext">Average percentage</div>
            </div>
            
            <div class="stat-card" style="border-left-color: #f59e0b;">
                <div class="stat-label">Highest Score</div>
                <div class="stat-value"><%= String.format("%.1f", classStats.get("highest")) %>%</div>
                <div class="stat-subtext">Maximum percentage</div>
            </div>
            
            <div class="stat-card" style="border-left-color: #ef4444;">
                <div class="stat-label">Lowest Score</div>
                <div class="stat-value"><%= String.format("%.1f", classStats.get("lowest")) %>%</div>
                <div class="stat-subtext">Minimum percentage</div>
            </div>
        </div>
        
        <!-- Grade Distribution -->
        <div class="section">
            <div class="section-title">📈 Grade Distribution</div>
            
            <div class="grade-distribution">
                <div class="grade-box A">
                    <div class="grade-count"><%= countA %></div>
                    <div class="grade-label">A (90+)</div>
                </div>
                <div class="grade-box B">
                    <div class="grade-count"><%= countB %></div>
                    <div class="grade-label">B (80-89)</div>
                </div>
                <div class="grade-box C">
                    <div class="grade-count"><%= countC %></div>
                    <div class="grade-label">C (70-79)</div>
                </div>
                <div class="grade-box D">
                    <div class="grade-count"><%= countD %></div>
                    <div class="grade-label">D (60-69)</div>
                </div>
                <div class="grade-box F">
                    <div class="grade-count"><%= countF %></div>
                    <div class="grade-label">F (< 60)</div>
                </div>
            </div>
            
            <!-- Grade Distribution Bars -->
            <div style="margin-top: 20px;">
                <% 
                    double aPercent = totalStudents > 0 ? (countA * 100.0) / totalStudents : 0;
                    double bPercent = totalStudents > 0 ? (countB * 100.0) / totalStudents : 0;
                    double cPercent = totalStudents > 0 ? (countC * 100.0) / totalStudents : 0;
                    double dPercent = totalStudents > 0 ? (countD * 100.0) / totalStudents : 0;
                    double fPercent = totalStudents > 0 ? (countF * 100.0) / totalStudents : 0;
                %>
                <div style="margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span style="font-weight: 600; color: #333;">Grade A (90+)</span>
                        <span><%= String.format("%.1f", aPercent) %>%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: <%= aPercent %>%; background: linear-gradient(90deg, #10b981 0%, #059669 100%);"></div>
                    </div>
                </div>
                
                <div style="margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span style="font-weight: 600; color: #333;">Grade B (80-89)</span>
                        <span><%= String.format("%.1f", bPercent) %>%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: <%= bPercent %>%; background: linear-gradient(90deg, #3b82f6 0%, #1d4ed8 100%);"></div>
                    </div>
                </div>
                
                <div style="margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span style="font-weight: 600; color: #333;">Grade C (70-79)</span>
                        <span><%= String.format("%.1f", cPercent) %>%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: <%= cPercent %>%; background: linear-gradient(90deg, #f59e0b 0%, #d97706 100%);"></div>
                    </div>
                </div>
                
                <div style="margin-bottom: 15px;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span style="font-weight: 600; color: #333;">Grade D (60-69)</span>
                        <span><%= String.format("%.1f", dPercent) %>%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: <%= dPercent %>%; background: linear-gradient(90deg, #f97316 0%, #ea580c 100%);"></div>
                    </div>
                </div>
                
                <div>
                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                        <span style="font-weight: 600; color: #333;">Grade F (< 60)</span>
                        <span><%= String.format("%.1f", fPercent) %>%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: <%= fPercent %>%; background: linear-gradient(90deg, #ef4444 0%, #dc2626 100%);"></div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Alerts if needed -->
        <% if (!failedStudents.isEmpty()) { %>
        <div class="section">
            <div class="alert-box">
                <div class="alert-title">⚠️ Students Below Passing Grade (<60%)</div>
                <p>The following <%= failedStudents.size() %> student(s) need immediate attention and remedial support.</p>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>Roll No.</th>
                        <th>Score</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Result failResult : failedStudents) { 
                        Student failStudent = StudentDAO.getStudentById(failResult.getStudentId());
                    %>
                    <tr>
                        <td><strong><%= failStudent.getStudentName() %></strong></td>
                        <td><%= failStudent.getRollNumber() %></td>
                        <td class="percentage-cell"><%= String.format("%.1f", failResult.getPercentage()) %>%</td>
                        <td>
                            <span class="grade-cell grade-<%= failResult.getGrade() %>">
                                <%= failResult.getGrade() %>
                            </span>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
        
        <!-- Top Performers -->
        <% if (!topPerformers.isEmpty()) { %>
        <div class="section">
            <div class="section-title">🏆 Top Performers</div>
            
            <table>
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Student Name</th>
                        <th>Roll No.</th>
                        <th>Correct/Total</th>
                        <th>Score</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                    <% int rank = 1; %>
                    <% for (Result topResult : topPerformers) { 
                        Student topStudent = StudentDAO.getStudentById(topResult.getStudentId());
                        String medal = rank == 1 ? "🥇" : (rank == 2 ? "🥈" : "🥉");
                    %>
                    <tr>
                        <td>
                            <span class="rank-badge top">
                                <span class="medal"><%= medal %></span><%= rank %>
                            </span>
                        </td>
                        <td><strong><%= topStudent.getStudentName() %></strong></td>
                        <td><%= topStudent.getRollNumber() %></td>
                        <td><%= topResult.getCorrectAnswers() %>/<%= topResult.getTotalQuestions() %></td>
                        <td class="percentage-cell"><%= String.format("%.1f", topResult.getPercentage()) %>%</td>
                        <td>
                            <span class="grade-cell grade-<%= topResult.getGrade() %>">
                                <%= topResult.getGrade() %>
                            </span>
                        </td>
                    </tr>
                    <% rank++; %>
                    <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
        
        <!-- All Results Table -->
        <div class="section">
            <div class="section-title">📋 Detailed Results - All Students</div>
            
            <table>
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>Roll No.</th>
                        <th>Correct</th>
                        <th>Wrong</th>
                        <th>Skipped</th>
                        <th>Score</th>
                        <th>Percentage</th>
                        <th>Grade</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> item : studentResults) { 
                        Student student = (Student) item.get("student");
                        Result result = (Result) item.get("result");
                    %>
                    <tr>
                        <td><strong><%= student.getStudentName() %></strong></td>
                        <td><%= student.getRollNumber() %></td>
                        <td><%= result.getCorrectAnswers() %></td>
                        <td><%= result.getWrongAnswers() %></td>
                        <td><%= result.getSkippedCount() %></td>
                        <td><%= result.getMarksObtained() %>/<%= result.getTotalMarks() %></td>
                        <td class="percentage-cell"><%= String.format("%.1f", result.getPercentage()) %>%</td>
                        <td>
                            <span class="grade-cell grade-<%= result.getGrade() %>">
                                <%= result.getGrade() %>
                            </span>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Action Buttons -->
        <div class="button-group">
            <button class="btn-print" onclick="window.print()">🖨️ Print Report</button>
            <button class="btn-back" onclick="history.back()">← Go Back</button>
        </div>
    </div>
</body>
</html>
