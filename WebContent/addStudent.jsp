<%@page import="com.school.exam.model.Class"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.school.exam.model.Student, com.school.exam.dao.*" %>
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
    
    // Get class list for dropdown
    List<Class> classes = ClassDAO.getClassesBySchool(schoolId);
    
    // Variables for displaying messages
    String message = "";
    String messageType = "";
    
    // Handle form submission
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            Student student = new Student();
            student.setStudentName(request.getParameter("studentName"));
            student.setRollNumber(request.getParameter("rollNumber"));
            student.setSchoolId(schoolId);
            
            String classIdStr = request.getParameter("classId");
            if (classIdStr != null && !classIdStr.isEmpty()) {
                student.setClassId(Integer.parseInt(classIdStr));
            }
            
            student.setEmail(request.getParameter("email"));
            student.setPhoneNumber(request.getParameter("phoneNumber"));
            
            String dobStr = request.getParameter("dateOfBirth");
            if (dobStr != null && !dobStr.isEmpty()) {
                student.setDateOfBirth(java.time.LocalDate.parse(dobStr));
            }
            
            student.setAddress(request.getParameter("address"));
            student.setCity(request.getParameter("city"));
            student.setGender(request.getParameter("gender"));
            student.setFatherName(request.getParameter("fatherName"));
            student.setFatherContact(request.getParameter("fatherContact"));
            student.setMotherName(request.getParameter("motherName"));
            student.setMotherContact(request.getParameter("motherContact"));
            student.setStatus("ACTIVE");
            
            // Check if roll number already exists
            if (StudentDAO.isRollNumberExists(student.getRollNumber(), schoolId, 0)) {
                message = "Roll number already exists for this school!";
                messageType = "error";
            } else {
                int studentId = StudentDAO.addStudent(student);
                if (studentId > 0) {
                    message = "Student added successfully!";
                    messageType = "success";
                } else {
                    message = "Failed to add student. Please try again.";
                    messageType = "error";
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Student - School Exam System</title>
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
        
        .form-row.full {
            grid-template-columns: 1fr;
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
            min-height: 80px;
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
            <h1>Add New Student</h1>
            <p>Register a new student in your school</p>
        </div>
        
        <div class="content">
            <a href="studentList.jsp" class="back-link">← Back to Student List</a>
            
            <% if (!message.isEmpty()) { %>
                <div class="message <%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form method="POST" action="addStudent.jsp">
                <input type="hidden" name="action" value="add">
                
                <!-- Basic Information -->
                <div class="form-section">
                    <h3>Basic Information</h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="studentName">Student Name <span>*</span></label>
                            <input type="text" id="studentName" name="studentName" placeholder="Enter full name" required>
                        </div>
                        <div class="form-group">
                            <label for="rollNumber">Roll Number <span>*</span></label>
                            <input type="text" id="rollNumber" name="rollNumber" placeholder="Enter roll number" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="classId">Class</label>
                            <select id="classId" name="classId">
                                <option value="">Select Class</option>
                                <% for (Class cls : classes) { %>
                                    <option value="<%= cls.getClassId() %>"><%= cls.getClassName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="gender">Gender</label>
                            <select id="gender" name="gender">
                                <option value="">Select Gender</option>
                                <option value="MALE">Male</option>
                                <option value="FEMALE">Female</option>
                                <option value="OTHER">Other</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="dateOfBirth">Date of Birth</label>
                            <input type="date" id="dateOfBirth" name="dateOfBirth">
                        </div>
                    </div>
                </div>
                
                <!-- Contact Information -->
                <div class="form-section">
                    <h3>Contact Information</h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" placeholder="Enter email">
                        </div>
                        <div class="form-group">
                            <label for="phoneNumber">Phone Number</label>
                            <input type="tel" id="phoneNumber" name="phoneNumber" placeholder="Enter phone number">
                        </div>
                    </div>
                    
                    <div class="form-row full">
                        <div class="form-group">
                            <label for="address">Address</label>
                            <textarea id="address" name="address" placeholder="Enter complete address"></textarea>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="city">City</label>
                            <input type="text" id="city" name="city" placeholder="Enter city">
                        </div>
                    </div>
                </div>
                
                <!-- Parent Information -->
                <div class="form-section">
                    <h3>Parent/Guardian Information</h3>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="fatherName">Father's Name</label>
                            <input type="text" id="fatherName" name="fatherName" placeholder="Enter father's name">
                        </div>
                        <div class="form-group">
                            <label for="fatherContact">Father's Contact</label>
                            <input type="tel" id="fatherContact" name="fatherContact" placeholder="Enter father's phone">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="motherName">Mother's Name</label>
                            <input type="text" id="motherName" name="motherName" placeholder="Enter mother's name">
                        </div>
                        <div class="form-group">
                            <label for="motherContact">Mother's Contact</label>
                            <input type="tel" id="motherContact" name="motherContact" placeholder="Enter mother's phone">
                        </div>
                    </div>
                </div>
                
                <!-- Buttons -->
                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Add Student</button>
                    <a href="studentList.jsp"><button type="button" class="btn btn-secondary">Cancel</button></a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
