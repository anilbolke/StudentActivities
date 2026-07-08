# Servlet Architecture & Implementation Guide

## Servlet Structure Overview

### Base Servlet Class
All servlets extend a common `BaseServlet` that handles:
- Authentication
- Authorization (role-based)
- Request parsing
- Response formatting
- Exception handling
- Logging

```java
// com/school/exam/servlet/BaseServlet.java
public abstract class BaseServlet extends HttpServlet {
    
    protected Logger logger = LoggerFactory.getLogger(this.getClass());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        handleRequest(request, response, "GET");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        handleRequest(request, response, "POST");
    }
    
    protected abstract void handleRequest(HttpServletRequest request, 
                                         HttpServletResponse response, 
                                         String method) throws ServletException, IOException;
    
    protected User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }
    
    protected void sendJsonResponse(HttpServletResponse response, 
                                   Map<String, Object> responseData) throws IOException {
        response.setContentType("application/json");
        response.getWriter().print(convertToJson(responseData));
    }
    
    protected void sendErrorResponse(HttpServletResponse response, 
                                    String errorCode, 
                                    String message, 
                                    int statusCode) throws IOException {
        response.setStatus(statusCode);
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("success", false);
        errorData.put("error_code", errorCode);
        errorData.put("message", message);
        sendJsonResponse(response, errorData);
    }
    
    protected void authorize(User user, String... allowedRoles) throws ServletException {
        if (user == null) throw new ServletException("User not authenticated");
        
        boolean authorized = false;
        for (String role : allowedRoles) {
            if (user.getRole().equals(role)) {
                authorized = true;
                break;
            }
        }
        if (!authorized) throw new ServletException("User not authorized");
    }
}
```

---

## Servlet Classes by Module

### Authentication Servlets

#### 1. AuthServlet
```java
// com/school/exam/servlet/AuthServlet.java
@WebServlet("/api/auth/*")
public class AuthServlet extends BaseServlet {
    
    private UserDAO userDAO = new UserDAO();
    private PasswordEncryption passwordEncryption = new PasswordEncryption();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/login") && "POST".equals(method)) {
            handleLogin(request, response);
        } else if (pathInfo.equals("/logout") && "GET".equals(method)) {
            handleLogout(request, response);
        } else {
            sendErrorResponse(response, "INVALID_REQUEST", "Invalid endpoint", 400);
        }
    }
    
    private void handleLogin(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Parse JSON request
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            
            // Validate user credentials
            User user = userDAO.getUserByUsername(username);
            
            if (user == null || !passwordEncryption.matches(password, user.getPasswordHash())) {
                sendErrorResponse(response, "INVALID_CREDENTIALS", 
                                "Invalid username or password", 401);
                return;
            }
            
            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("user_id", user.getUserId());
            session.setAttribute("role", user.getRole());
            session.setAttribute("school_id", user.getSchoolId());
            
            // Send success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("user_id", user.getUserId());
            responseData.put("role", user.getRole());
            responseData.put("school_id", user.getSchoolId());
            responseData.put("message", "Login successful");
            
            sendJsonResponse(response, responseData);
            
        } catch (Exception e) {
            logger.error("Login error", e);
            sendErrorResponse(response, "SERVER_ERROR", 
                            "An error occurred during login", 500);
        }
    }
    
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("message", "Logout successful");
        sendJsonResponse(response, responseData);
    }
}
```

---

### Admin Servlets

#### 1. AdminSchoolServlet
```java
// com/school/exam/servlet/AdminSchoolServlet.java
@WebServlet("/api/admin/school/*")
public class AdminSchoolServlet extends BaseServlet {
    
    private SchoolDAO schoolDAO = new SchoolDAO();
    private AuditLogger auditLogger = new AuditLogger();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "ADMIN");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/create") && "POST".equals(method)) {
            handleCreateSchool(request, response, user);
        } else if (pathInfo.equals("/list") && "GET".equals(method)) {
            handleListSchools(request, response, user);
        } else if (pathInfo.equals("/update") && "PUT".equals(method)) {
            handleUpdateSchool(request, response, user);
        } else if (pathInfo.equals("/delete") && "DELETE".equals(method)) {
            handleDeleteSchool(request, response, user);
        }
    }
    
    private void handleCreateSchool(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   User user) throws IOException {
        try {
            String schoolName = request.getParameter("school_name");
            String schoolCode = request.getParameter("school_code");
            String address = request.getParameter("address");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String pinCode = request.getParameter("pin_code");
            String contactPhone = request.getParameter("contact_phone");
            String contactEmail = request.getParameter("contact_email");
            String principalName = request.getParameter("principal_name");
            
            // Validate input
            if (schoolName == null || schoolName.trim().isEmpty()) {
                sendErrorResponse(response, "VALIDATION_ERROR", 
                                "School name is required", 400);
                return;
            }
            
            // Create school
            School school = new School();
            school.setSchoolName(schoolName);
            school.setSchoolCode(schoolCode);
            school.setAddress(address);
            school.setCity(city);
            school.setState(state);
            school.setPinCode(pinCode);
            school.setContactPhone(contactPhone);
            school.setContactEmail(contactEmail);
            school.setPrincipalName(principalName);
            
            int schoolId = schoolDAO.createSchool(school);
            
            // Log action
            auditLogger.logAction(user.getUserId(), schoolId, "CREATE", 
                                "School created", "SCHOOL", schoolId, null, schoolName);
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("school_id", schoolId);
            responseData.put("message", "School created successfully");
            
            sendJsonResponse(response, responseData);
            
        } catch (Exception e) {
            logger.error("Error creating school", e);
            sendErrorResponse(response, "SERVER_ERROR", 
                            "An error occurred while creating school", 500);
        }
    }
    
    // ... other handler methods
}
```

#### 2. AdminClassServlet
```java
@WebServlet("/api/admin/class/*")
public class AdminClassServlet extends BaseServlet {
    
    private ClassDAO classDAO = new ClassDAO();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "ADMIN");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/create") && "POST".equals(method)) {
            handleCreateClass(request, response, user);
        } else if (pathInfo.equals("/list") && "GET".equals(method)) {
            handleListClasses(request, response, user);
        }
        // ... other operations
    }
    
    private void handleCreateClass(HttpServletRequest request, 
                                  HttpServletResponse response, 
                                  User user) throws IOException {
        // Implementation similar to AdminSchoolServlet
    }
    
    // ... other handler methods
}
```

#### 3. AdminQuestionServlet
```java
@WebServlet("/api/admin/question/*")
public class AdminQuestionServlet extends BaseServlet {
    
    private QuestionDAO questionDAO = new QuestionDAO();
    private QuestionOptionDAO optionDAO = new QuestionOptionDAO();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        // Implementation for question management
    }
}
```

#### 4. AdminStudentServlet
```java
@WebServlet("/api/admin/student/*")
public class AdminStudentServlet extends BaseServlet {
    
    private StudentDAO studentDAO = new StudentDAO();
    private UserDAO userDAO = new UserDAO();
    private CSVValidator csvValidator = new CSVValidator();
    private FileUploadHandler fileUploadHandler = new FileUploadHandler();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "ADMIN");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/add") && "POST".equals(method)) {
            handleAddStudent(request, response, user);
        } else if (pathInfo.equals("/bulk-upload") && "POST".equals(method)) {
            handleBulkUpload(request, response, user);
        } else if (pathInfo.equals("/list") && "GET".equals(method)) {
            handleListStudents(request, response, user);
        }
    }
    
    private void handleAddStudent(HttpServletRequest request, 
                                 HttpServletResponse response, 
                                 User user) throws IOException {
        // Add single student with auto-generated ID
    }
    
    private void handleBulkUpload(HttpServletRequest request, 
                                 HttpServletResponse response, 
                                 User user) throws ServletException, IOException {
        // Handle CSV file upload and validation
    }
}
```

---

### Teacher Servlets

#### TeacherExamServlet
```java
@WebServlet("/api/teacher/exam/*")
public class TeacherExamServlet extends BaseServlet {
    
    private ExamPaperDAO examDAO = new ExamPaperDAO();
    private QuestionDAO questionDAO = new QuestionDAO();
    private ExamPaperGenerator examGenerator = new ExamPaperGenerator();
    private QuestionShuffler shuffler = new QuestionShuffler();
    private PDFExporter pdfExporter = new PDFExporter();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "TEACHER");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/generate") && "POST".equals(method)) {
            handleGenerateExam(request, response, user);
        } else if (pathInfo.equals("/answer-key") && "GET".equals(method)) {
            handleGetAnswerKey(request, response, user);
        } else if (pathInfo.equals("/export-pdf") && "GET".equals(method)) {
            handleExportPDF(request, response, user);
        } else if (pathInfo.equals("/publish") && "PUT".equals(method)) {
            handlePublishExam(request, response, user);
        }
    }
    
    private void handleGenerateExam(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   User user) throws IOException {
        try {
            int schoolId = Integer.parseInt(request.getParameter("school_id"));
            int classId = Integer.parseInt(request.getParameter("class_id"));
            int subjectId = Integer.parseInt(request.getParameter("subject_id"));
            String examName = request.getParameter("exam_name");
            String examDate = request.getParameter("exam_date");
            int duration = Integer.parseInt(request.getParameter("exam_duration_minutes"));
            int totalQuestions = Integer.parseInt(request.getParameter("total_questions"));
            
            // Parse selected topics (JSON array)
            String topicsJson = request.getParameter("selected_topics");
            List<Integer> topicIds = parseJsonArray(topicsJson);
            
            // Fetch questions from selected topics
            List<Question> allQuestions = questionDAO.getQuestionsByTopics(topicIds);
            
            // Shuffle if required
            boolean shuffleQuestions = Boolean.parseBoolean(
                request.getParameter("shuffle_questions"));
            if (shuffleQuestions) {
                allQuestions = shuffler.shuffleQuestions(allQuestions);
            }
            
            // Select required number of questions
            List<Question> selectedQuestions = allQuestions.subList(0, 
                Math.min(totalQuestions, allQuestions.size()));
            
            // Create exam paper
            ExamPaper examPaper = examGenerator.generateExamPaper(
                schoolId, classId, subjectId, examName, examDate, 
                duration, selectedQuestions, user.getUserId());
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("exam_paper_id", examPaper.getExamPaperId());
            responseData.put("total_marks", examPaper.getTotalMarks());
            responseData.put("questions_generated", selectedQuestions.size());
            responseData.put("message", "Exam paper generated successfully");
            
            sendJsonResponse(response, responseData);
            
        } catch (Exception e) {
            logger.error("Error generating exam", e);
            sendErrorResponse(response, "SERVER_ERROR", 
                            "An error occurred while generating exam", 500);
        }
    }
    
    private void handleGetAnswerKey(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   User user) throws IOException {
        // Generate and return answer key
    }
    
    private void handleExportPDF(HttpServletRequest request, 
                                HttpServletResponse response, 
                                User user) throws IOException {
        // Export exam paper as PDF
    }
}
```

---

### Student Servlets

#### StudentExamServlet
```java
@WebServlet("/api/student/exam/*")
public class StudentExamServlet extends BaseServlet {
    
    private ExamDAO examDAO = new ExamDAO();
    private ResultDAO resultDAO = new ResultDAO();
    private StudentAnswerDAO answerDAO = new StudentAnswerDAO();
    private ScoringEngine scoringEngine = new ScoringEngine();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "STUDENT");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/start") && "POST".equals(method)) {
            handleStartExam(request, response, user);
        } else if (pathInfo.equals("/submit-answer") && "POST".equals(method)) {
            handleSubmitAnswer(request, response, user);
        } else if (pathInfo.equals("/submit") && "POST".equals(method)) {
            handleSubmitExam(request, response, user);
        } else if (pathInfo.equals("/results") && "GET".equals(method)) {
            handleGetResults(request, response, user);
        }
    }
    
    private void handleStartExam(HttpServletRequest request, 
                                HttpServletResponse response, 
                                User user) throws IOException {
        // Initialize exam session for student
    }
    
    private void handleSubmitAnswer(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   User user) throws IOException {
        // Save individual answer
    }
    
    private void handleSubmitExam(HttpServletRequest request, 
                                 HttpServletResponse response, 
                                 User user) throws IOException {
        try {
            int resultId = Integer.parseInt(request.getParameter("result_id"));
            int examPaperId = Integer.parseInt(request.getParameter("exam_paper_id"));
            
            // Evaluate exam
            ExamResult result = scoringEngine.evaluateExam(resultId, examPaperId);
            
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("obtained_marks", result.getObtainedMarks());
            responseData.put("percentage", result.getPercentage());
            responseData.put("grade", result.getGrade());
            responseData.put("message", "Exam submitted successfully");
            
            sendJsonResponse(response, responseData);
            
        } catch (Exception e) {
            logger.error("Error submitting exam", e);
            sendErrorResponse(response, "SERVER_ERROR", 
                            "An error occurred while submitting exam", 500);
        }
    }
}
```

---

### Parent Servlets

#### ParentReportServlet
```java
@WebServlet("/api/parent/*")
public class ParentReportServlet extends BaseServlet {
    
    private StudentDAO studentDAO = new StudentDAO();
    private ResultDAO resultDAO = new ResultDAO();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "PARENT");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/child/results") && "GET".equals(method)) {
            handleGetChildResults(request, response, user);
        }
    }
}
```

---

### Report Servlets

#### ReportServlet
```java
@WebServlet("/api/report/*")
public class ReportServlet extends BaseServlet {
    
    private ReportGenerator reportGenerator = new ReportGenerator();
    private PDFExporter pdfExporter = new PDFExporter();
    private ExcelExporter excelExporter = new ExcelExporter();
    
    @Override
    protected void handleRequest(HttpServletRequest request, 
                                HttpServletResponse response, 
                                String method) throws ServletException, IOException {
        
        User user = getCurrentUser(request.getSession());
        authorize(user, "ADMIN", "TEACHER", "PARENT");
        
        String pathInfo = request.getPathInfo();
        
        if (pathInfo.equals("/class-performance") && "GET".equals(method)) {
            handleClassPerformance(request, response, user);
        } else if (pathInfo.equals("/rank-list") && "GET".equals(method)) {
            handleRankList(request, response, user);
        } else if (pathInfo.equals("/export-pdf") && "GET".equals(method)) {
            handleExportPDF(request, response, user);
        } else if (pathInfo.equals("/export-excel") && "GET".equals(method)) {
            handleExportExcel(request, response, user);
        }
    }
}
```

---

## web.xml Configuration

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/javaee"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
   http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd"
   version="3.0">
  
  <display-name>School Exam Management System</display-name>
  
  <!-- Session configuration -->
  <session-config>
    <cookie-config>
      <secure>true</secure>
      <http-only>true</http-only>
    </cookie-config>
    <tracking-mode>COOKIE</tracking-mode>
  </session-config>
  
  <!-- Error pages -->
  <error-page>
    <error-code>404</error-code>
    <location>/error.jsp</location>
  </error-page>
  
  <error-page>
    <error-code>500</error-code>
    <location>/error.jsp</location>
  </error-page>

</web-app>
```

---

## Servlet URL Mapping Summary

| Servlet | URL Pattern | Methods |
|---------|-------------|---------|
| AuthServlet | /api/auth/* | POST, GET |
| AdminSchoolServlet | /api/admin/school/* | POST, GET, PUT, DELETE |
| AdminClassServlet | /api/admin/class/* | POST, GET, PUT, DELETE |
| AdminSubjectServlet | /api/admin/subject/* | POST, GET, PUT, DELETE |
| AdminTopicServlet | /api/admin/topic/* | POST, GET, PUT, DELETE |
| AdminQuestionServlet | /api/admin/question/* | POST, GET, PUT, DELETE |
| AdminStudentServlet | /api/admin/student/* | POST, GET, PUT, DELETE |
| TeacherExamServlet | /api/teacher/exam/* | POST, GET, PUT |
| StudentExamServlet | /api/student/exam/* | POST, GET |
| ParentReportServlet | /api/parent/* | GET |
| ReportServlet | /api/report/* | GET |

