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
    
    String message = "";
    String messageType = "";
    
    // Get question ID from URL
    int questionId = 0;
    String idParam = request.getParameter("id");
    if (idParam != null && !idParam.isEmpty()) {
        try {
            questionId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            message = "Invalid question ID!";
            messageType = "error";
        }
    }
    
    Question question = null;
    List<Subject> subjects = new ArrayList<Subject>();
    List<Object> classList = new ArrayList<Object>();
    
    // Get question details
    if (questionId > 0) {
        question = QuestionDAO.getQuestionById(questionId);
        
        if (question != null) {
            // Get all subjects and classes
            List<School> schools = SchoolDAO.getAllSchools();
            if (schools != null && !schools.isEmpty()) {
                for (School school : schools) {
                    List<Subject> schoolSubjects = SubjectDAO.getAllSubjectsBySchool(school.getSchoolId());
                    if (schoolSubjects != null) {
                        subjects.addAll(schoolSubjects);
                    }
                    List<Class> schoolClasses = ClassDAO.getClassesBySchool(school.getSchoolId());
                    if (schoolClasses != null) {
                        classList.addAll(schoolClasses);
                    }
                }
            }
        } else {
            message = "Question not found!";
            messageType = "error";
        }
    }
    
    // Handle form submission
    if ("POST".equals(request.getMethod()) && question != null) {
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctAnswer = request.getParameter("correctAnswer");
        String difficulty = request.getParameter("difficulty");
        String marksStr = request.getParameter("marks");
        String status = request.getParameter("status");
        
        if (questionText == null || questionText.trim().isEmpty()) {
            message = "Question text is required!";
            messageType = "error";
        } else {
            question.setQuestionText(questionText);
            question.setOptionA(optionA);
            question.setOptionB(optionB);
            question.setOptionC(optionC);
            question.setOptionD(optionD);
            question.setCorrectAnswer(correctAnswer.toUpperCase());
            question.setDifficultyLevel(difficulty);
            question.setStatus(status);
            
            try {
                question.setMarks(Integer.parseInt(marksStr));
            } catch (NumberFormatException e) {
                question.setMarks(1);
            }
            
            if (QuestionDAO.updateQuestion(question)) {
                message = "Question updated successfully!";
                messageType = "success";
            } else {
                message = "Failed to update question!";
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
    <title>Edit Question - Admin Dashboard</title>
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
            max-width: 1000px;
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
        
        .form-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
        }
        
        input[type="text"],
        input[type="number"],
        textarea,
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
        }
        
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        
        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 30px;
        }
        
        button, .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-submit {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .btn-cancel {
            background: #95a5a6;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>
                <i class="fas fa-edit"></i>
                Edit Question
            </h1>
            <a href="viewQuestions.jsp" class="back-btn">
                <i class="fas fa-arrow-left"></i> Back to Questions
            </a>
        </div>
        
        <!-- Form Container -->
        <div class="form-container">
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <% if (question != null) { %>
                <form method="POST" action="editQuestion.jsp?id=<%= question.getQuestionId() %>">
                    <div class="form-group">
                        <label for="questionText">Question Text <span style="color: #e74c3c;">*</span></label>
                        <textarea id="questionText" name="questionText" required><%= question.getQuestionText() %></textarea>
                    </div>
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="optionA">Option A</label>
                            <input type="text" id="optionA" name="optionA" value="<%= question.getOptionA() %>">
                        </div>
                        <div class="form-group">
                            <label for="optionB">Option B</label>
                            <input type="text" id="optionB" name="optionB" value="<%= question.getOptionB() %>">
                        </div>
                        <div class="form-group">
                            <label for="optionC">Option C</label>
                            <input type="text" id="optionC" name="optionC" value="<%= question.getOptionC() %>">
                        </div>
                        <div class="form-group">
                            <label for="optionD">Option D</label>
                            <input type="text" id="optionD" name="optionD" value="<%= question.getOptionD() %>">
                        </div>
                    </div>
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="correctAnswer">Correct Answer <span style="color: #e74c3c;">*</span></label>
                            <select id="correctAnswer" name="correctAnswer" required>
                                <option value="" disabled>Select Correct Answer</option>
                                <option value="A" <%= "A".equals(question.getCorrectAnswer()) ? "selected" : "" %>>Option A</option>
                                <option value="B" <%= "B".equals(question.getCorrectAnswer()) ? "selected" : "" %>>Option B</option>
                                <option value="C" <%= "C".equals(question.getCorrectAnswer()) ? "selected" : "" %>>Option C</option>
                                <option value="D" <%= "D".equals(question.getCorrectAnswer()) ? "selected" : "" %>>Option D</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="difficulty">Difficulty Level</label>
                            <select id="difficulty" name="difficulty">
                                <option value="EASY" <%= "EASY".equals(question.getDifficultyLevel()) ? "selected" : "" %>>Easy</option>
                                <option value="MEDIUM" <%= "MEDIUM".equals(question.getDifficultyLevel()) ? "selected" : "" %>>Medium</option>
                                <option value="HARD" <%= "HARD".equals(question.getDifficultyLevel()) ? "selected" : "" %>>Hard</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="marks">Marks</label>
                            <input type="number" id="marks" name="marks" value="<%= question.getMarks() %>" min="1">
                        </div>
                        
                        <div class="form-group">
                            <label for="status">Status</label>
                            <select id="status" name="status">
                                <option value="ACTIVE" <%= "ACTIVE".equals(question.getStatus()) ? "selected" : "" %>>Active</option>
                                <option value="INACTIVE" <%= "INACTIVE".equals(question.getStatus()) ? "selected" : "" %>>Inactive</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="button-group">
                        <a href="viewQuestions.jsp" class="btn btn-cancel">Cancel</a>
                        <button type="submit" class="btn btn-submit">
                            <i class="fas fa-save"></i> Update Question
                        </button>
                    </div>
                </form>
            <% } else { %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <% if (message.isEmpty()) { message = "Question not found!"; } %>
                    <%= message %>
                </div>
                <div class="button-group">
                    <a href="viewQuestions.jsp" class="btn btn-cancel">Back to Questions</a>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
