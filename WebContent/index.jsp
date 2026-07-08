<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>School Exam Management System</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .container {
            text-align: center;
            background: white;
            padding: 50px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            max-width: 500px;
            width: 90%;
        }
        
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 2.5em;
        }
        
        p {
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
            line-height: 1.6;
        }
        
        .buttons {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            justify-content: center;
        }
        
        .btn {
            padding: 12px 30px;
            font-size: 1em;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #f0f0f0;
            color: #333;
            border: 2px solid #667eea;
        }
        
        .btn-secondary:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }
        
        .features {
            margin-top: 40px;
            text-align: left;
            background: #f9f9f9;
            padding: 20px;
            border-radius: 5px;
        }
        
        .features h3 {
            color: #667eea;
            margin-bottom: 15px;
        }
        
        .features ul {
            list-style-position: inside;
            color: #666;
        }
        
        .features li {
            margin-bottom: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📚 School Exam Management System</h1>
        <p>Comprehensive exam management platform for schools</p>
        
        <div class="buttons">
            <a href="addStudent.jsp" class="btn btn-primary">Start Testing</a>
            <a href="studentList.jsp" class="btn btn-secondary">View Students</a>
        </div>
        
        <div class="features">
            <h3>Available Modules</h3>
            <ul>
                <li><strong>Student Management</strong> - Add, edit, view students</li>
                <li><strong>Subject Management</strong> - Create and manage subjects</li>
                <li><strong>Class Management</strong> - Organize classes by school</li>
                <li><strong>Question Upload</strong> - Upload exam questions with chapters</li>
                <li><strong>Exam Creation</strong> - Create exams with multi-select chapters</li>
                <li><strong>Result Analysis</strong> - View student performance analytics</li>
            </ul>
        </div>
    </div>
</body>
</html>
