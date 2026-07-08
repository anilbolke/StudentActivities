# API Structure - School Exam Management System

## Overview
All APIs follow REST-like conventions with URL-based routing via Servlets.

## Base URL
```
http://localhost:8080/school-exam-system/
```

---

## Authentication APIs

### 1. User Login
**Endpoint:** `POST /api/auth/login`
**Servlet:** `AuthServlet.java`
**Access:** Public

**Request:**
```json
{
  "username": "admin@school",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "user_id": 1,
  "role": "ADMIN",
  "school_id": 1,
  "message": "Login successful"
}
```

### 2. User Logout
**Endpoint:** `GET /api/auth/logout`
**Access:** Authenticated users

---

## Admin APIs

### School Management

#### 1. Create School
**Endpoint:** `POST /api/admin/school/create`
**Servlet:** `AdminSchoolServlet.java`
**Access:** ADMIN

**Request:**
```json
{
  "school_name": "XYZ Public School",
  "school_code": "XYZ001",
  "address": "123 Main St",
  "city": "Mumbai",
  "state": "Maharashtra",
  "pin_code": "400001",
  "contact_phone": "9876543210",
  "contact_email": "info@xyzschool.com",
  "principal_name": "Dr. Sharma"
}
```

#### 2. Get All Schools
**Endpoint:** `GET /api/admin/school/list`

#### 3. Edit School
**Endpoint:** `PUT /api/admin/school/update`

#### 4. Delete School
**Endpoint:** `DELETE /api/admin/school/delete?school_id=1`

---

### Class Management

#### 1. Create Class
**Endpoint:** `POST /api/admin/class/create`
**Servlet:** `AdminClassServlet.java`

**Request:**
```json
{
  "school_id": 1,
  "class_name": "X",
  "class_section": "A",
  "class_teacher_id": 5
}
```

#### 2. Get Classes by School
**Endpoint:** `GET /api/admin/class/list?school_id=1`

#### 3. Update Class
**Endpoint:** `PUT /api/admin/class/update`

#### 4. Delete Class
**Endpoint:** `DELETE /api/admin/class/delete?class_id=1`

---

### Subject Management

#### 1. Create Subject
**Endpoint:** `POST /api/admin/subject/create`
**Servlet:** `AdminSubjectServlet.java`

**Request:**
```json
{
  "school_id": 1,
  "class_id": 1,
  "subject_name": "Mathematics",
  "subject_code": "MTH001",
  "marks": 100
}
```

#### 2. Get Subjects by Class
**Endpoint:** `GET /api/admin/subject/list?class_id=1`

#### 3. Update Subject
**Endpoint:** `PUT /api/admin/subject/update`

#### 4. Delete Subject
**Endpoint:** `DELETE /api/admin/subject/delete?subject_id=1`

---

### Topic Management

#### 1. Create Topic
**Endpoint:** `POST /api/admin/topic/create`
**Servlet:** `AdminTopicServlet.java`

**Request:**
```json
{
  "subject_id": 1,
  "class_id": 1,
  "topic_name": "Algebra",
  "topic_description": "Basic algebraic concepts",
  "difficulty_level": "MEDIUM"
}
```

#### 2. Get Topics by Subject
**Endpoint:** `GET /api/admin/topic/list?subject_id=1`

#### 3. Update Topic
**Endpoint:** `PUT /api/admin/topic/update`

#### 4. Delete Topic
**Endpoint:** `DELETE /api/admin/topic/delete?topic_id=1`

---

### Question Management

#### 1. Create Question
**Endpoint:** `POST /api/admin/question/create`
**Servlet:** `AdminQuestionServlet.java`

**Request:**
```json
{
  "topic_id": 1,
  "subject_id": 1,
  "school_id": 1,
  "question_text": "What is 2+2?",
  "question_type": "MCQ",
  "marks": 1,
  "difficulty": "EASY",
  "options": [
    {"text": "3", "is_correct": false},
    {"text": "4", "is_correct": true},
    {"text": "5", "is_correct": false},
    {"text": "6", "is_correct": false}
  ]
}
```

#### 2. Get Questions by Topic
**Endpoint:** `GET /api/admin/question/list?topic_id=1`

#### 3. Update Question
**Endpoint:** `PUT /api/admin/question/update`

#### 4. Delete Question
**Endpoint:** `DELETE /api/admin/question/delete?question_id=1`

---

### Student Registration

#### 1. Add Manual Student
**Endpoint:** `POST /api/admin/student/add`
**Servlet:** `AdminStudentServlet.java`

**Request:**
```json
{
  "school_id": 1,
  "class_id": 1,
  "student_name": "John Doe",
  "date_of_birth": "2008-05-15",
  "gender": "MALE",
  "roll_number": 1,
  "father_name": "Father Name",
  "mother_name": "Mother Name",
  "contact_number": "9876543210",
  "username": "john@school",
  "password": "student123"
}
```

**Response:**
```json
{
  "success": true,
  "student_id": 10,
  "unique_student_id": "STU001001",
  "message": "Student registered successfully"
}
```

#### 2. Bulk Upload Students (CSV)
**Endpoint:** `POST /api/admin/student/bulk-upload`

**CSV Format:**
```
student_name,date_of_birth,gender,father_name,mother_name,contact_number
John Doe,2008-05-15,MALE,Father,Mother,9876543210
Jane Smith,2008-06-20,FEMALE,Father,Mother,9876543211
```

#### 3. Get Students by Class
**Endpoint:** `GET /api/admin/student/list?class_id=1&school_id=1`

#### 4. Update Student
**Endpoint:** `PUT /api/admin/student/update`

#### 5. Delete Student
**Endpoint:** `DELETE /api/admin/student/delete?student_id=1`

#### 6. Generate Student ID
**Endpoint:** `POST /api/admin/student/generate-id`
**Internal Service**

---

## Teacher APIs

### Exam Paper Generation

#### 1. Get Classes for Teacher
**Endpoint:** `GET /api/teacher/classes`
**Servlet:** `TeacherExamServlet.java`
**Access:** TEACHER

**Response:**
```json
{
  "success": true,
  "classes": [
    {"class_id": 1, "class_name": "X A"},
    {"class_id": 2, "class_name": "X B"}
  ]
}
```

#### 2. Get Subjects for Selected Class
**Endpoint:** `GET /api/teacher/subjects?class_id=1`

#### 3. Get Topics for Selected Subject
**Endpoint:** `GET /api/teacher/topics?subject_id=1`

#### 4. Generate Exam Paper
**Endpoint:** `POST /api/teacher/exam/generate`

**Request:**
```json
{
  "school_id": 1,
  "class_id": 1,
  "subject_id": 1,
  "exam_name": "Mid-Term Exam",
  "exam_date": "2024-03-15",
  "exam_duration_minutes": 60,
  "total_questions": 15,
  "total_marks": 100,
  "selected_topics": [1, 2, 3],
  "shuffle_questions": true,
  "shuffle_options": true
}
```

**Response:**
```json
{
  "success": true,
  "exam_paper_id": 5,
  "total_marks": 100,
  "questions_generated": 15
}
```

#### 5. Get Exam Paper Details
**Endpoint:** `GET /api/teacher/exam/details?exam_paper_id=5`

#### 6. Generate Answer Key
**Endpoint:** `GET /api/teacher/exam/answer-key?exam_paper_id=5`

**Response:**
```json
{
  "exam_paper_id": 5,
  "answer_key": [
    {"question_id": 1, "question_text": "...", "correct_answer": "B"},
    {"question_id": 2, "question_text": "...", "correct_answer": "A"}
  ]
}
```

#### 7. Export Exam as PDF
**Endpoint:** `GET /api/teacher/exam/export-pdf?exam_paper_id=5`
**Returns:** PDF file

#### 8. Publish Exam Paper
**Endpoint:** `PUT /api/teacher/exam/publish?exam_paper_id=5`

---

## Student APIs

### Exam Taking

#### 1. Get Available Exams
**Endpoint:** `GET /api/student/exams`
**Servlet:** `StudentExamServlet.java`
**Access:** STUDENT

**Response:**
```json
{
  "success": true,
  "exams": [
    {
      "exam_paper_id": 1,
      "exam_name": "Unit Test 1",
      "subject_name": "Mathematics",
      "exam_date": "2024-03-15",
      "exam_duration_minutes": 60,
      "status": "AVAILABLE"
    }
  ]
}
```

#### 2. Start Exam
**Endpoint:** `POST /api/student/exam/start`

**Request:**
```json
{
  "exam_paper_id": 1,
  "student_id": 10,
  "student_qr_code": "STU001001" (optional)
}
```

**Response:**
```json
{
  "success": true,
  "result_id": 100,
  "exam_paper_id": 1,
  "exam_start_time": "2024-03-15 10:00:00",
  "time_limit_minutes": 60
}
```

#### 3. Submit Answer
**Endpoint:** `POST /api/student/exam/submit-answer`

**Request:**
```json
{
  "result_id": 100,
  "exam_paper_id": 1,
  "question_id": 5,
  "selected_option_id": 12
}
```

#### 4. Submit Exam
**Endpoint:** `POST /api/student/exam/submit`

**Request:**
```json
{
  "result_id": 100,
  "exam_paper_id": 1
}
```

**Response:**
```json
{
  "success": true,
  "message": "Exam submitted successfully",
  "result_id": 100
}
```

#### 5. Get Exam Results
**Endpoint:** `GET /api/student/exam/results`

**Response:**
```json
{
  "success": true,
  "results": [
    {
      "result_id": 100,
      "exam_name": "Unit Test 1",
      "subject_name": "Mathematics",
      "total_marks": 100,
      "obtained_marks": 85,
      "percentage": 85.0,
      "grade": "A",
      "exam_date": "2024-03-15"
    }
  ]
}
```

---

## Parent APIs

### Result Viewing

#### 1. Get Child Results
**Endpoint:** `GET /api/parent/child/results`
**Servlet:** `ParentReportServlet.java`
**Access:** PARENT

**Response:**
```json
{
  "success": true,
  "child": {
    "student_id": 10,
    "student_name": "John Doe",
    "class_name": "X A"
  },
  "results": [
    {
      "exam_name": "Unit Test 1",
      "subject_name": "Mathematics",
      "total_marks": 100,
      "obtained_marks": 85,
      "percentage": 85.0,
      "grade": "A",
      "exam_date": "2024-03-15"
    }
  ]
}
```

#### 2. Get Subject Performance
**Endpoint:** `GET /api/parent/child/subject-performance?student_id=10`

**Response:**
```json
{
  "success": true,
  "performance": [
    {
      "subject_name": "Mathematics",
      "avg_percentage": 82.5,
      "avg_grade": "A",
      "exam_count": 4
    }
  ]
}
```

#### 3. Get Weak Topics
**Endpoint:** `GET /api/parent/child/weak-topics?student_id=10&subject_id=1`

**Response:**
```json
{
  "success": true,
  "weak_topics": [
    {
      "topic_name": "Algebra",
      "avg_score": 60.0,
      "total_attempts": 3,
      "incorrect_attempts": 2
    }
  ]
}
```

---

## Reporting APIs

### Analytics and Reports

#### 1. Get Class Performance
**Endpoint:** `GET /api/report/class-performance?school_id=1&class_id=1`
**Servlet:** `ReportServlet.java`
**Access:** ADMIN, TEACHER

**Response:**
```json
{
  "class_name": "X A",
  "subject_analytics": [
    {
      "subject_name": "Mathematics",
      "avg_percentage": 75.5,
      "min_percentage": 45.0,
      "max_percentage": 98.0,
      "total_students": 30,
      "evaluated_students": 30
    }
  ]
}
```

#### 2. Get Rank List
**Endpoint:** `GET /api/report/rank-list?school_id=1&class_id=1&exam_paper_id=5`

**Response:**
```json
{
  "exam_name": "Unit Test 1",
  "rank_list": [
    {
      "rank": 1,
      "student_name": "John Doe",
      "obtained_marks": 98,
      "percentage": 98.0,
      "grade": "A+"
    }
  ]
}
```

#### 3. Get Student-wise Report
**Endpoint:** `GET /api/report/student-wise?school_id=1&class_id=1`

**Response:**
```json
{
  "reports": [
    {
      "student_id": 10,
      "student_name": "John Doe",
      "total_exams": 4,
      "avg_percentage": 85.0,
      "subjects": [
        {"subject_name": "Math", "percentage": 88}
      ]
    }
  ]
}
```

#### 4. Export Report to PDF
**Endpoint:** `GET /api/report/export-pdf?report_type=class-performance&school_id=1&class_id=1`
**Returns:** PDF file

#### 5. Export Report to Excel
**Endpoint:** `GET /api/report/export-excel?report_type=rank-list&exam_paper_id=5`
**Returns:** Excel file

---

## Error Response Format

All error responses follow this format:

```json
{
  "success": false,
  "error_code": "VALIDATION_ERROR",
  "message": "Descriptive error message",
  "details": {
    "field": "error details"
  }
}
```

## Common Error Codes

| Code | Meaning |
|------|---------|
| UNAUTHORIZED | User not authenticated |
| FORBIDDEN | User lacks permission |
| VALIDATION_ERROR | Input validation failed |
| NOT_FOUND | Resource not found |
| DUPLICATE_ENTRY | Duplicate record |
| SERVER_ERROR | Internal server error |
| INVALID_ROLE | User role mismatch |

---

## HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created
- `400 Bad Request` - Validation error
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Permission denied
- `404 Not Found` - Resource not found
- `409 Conflict` - Duplicate entry
- `500 Internal Server Error` - Server error

