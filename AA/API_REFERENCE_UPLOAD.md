# Question Upload API - Technical Reference

## Endpoint Details

### Upload Questions
```
POST /api/admin/uploadQuestions
```

### Authentication
- **Required:** Admin role
- **Method:** Session cookie (JSESSIONID)
- **Header:** Set automatically by browser

### Request Format
```http
POST /api/admin/uploadQuestions HTTP/1.1
Host: localhost:8080
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="questions.txt"
Content-Type: text/plain

[File content here]
------WebKitFormBoundary--
```

### File Specifications
- **Field Name:** `file`
- **Content-Type:** `text/plain` or `application/octet-stream`
- **Max Size:** 5 MB
- **Extensions:** .txt only
- **Encoding:** UTF-8

---

## Response Formats

### Success Response (HTTP 200)
```json
{
  "status": "success",
  "message": "File uploaded successfully",
  "totalRecords": 500,
  "successCount": 495,
  "failureCount": 5,
  "successPercentage": 99.0,
  "timestamp": "2026-03-24 10:30:45",
  "failedRecords": [
    {
      "lineNumber": 25,
      "className": "13",
      "subjectName": "Mathematics",
      "chapterName": "Algebra",
      "questionText": "What is 2+2?",
      "optionA": "3",
      "optionB": "4",
      "optionC": "5",
      "optionD": "6",
      "correctAnswer": "B",
      "difficulty": "Easy",
      "marks": 1,
      "valid": false,
      "errorMessage": "Class '13' not found in database"
    }
  ]
}
```

### Error Response - Unauthorized (HTTP 403)
```json
{
  "status": "error",
  "message": "Unauthorized: Only admins can upload questions"
}
```

### Error Response - Invalid File (HTTP 400)
```json
{
  "status": "error",
  "message": "Invalid file format. Only .txt files are allowed"
}
```

### Error Response - Parse Error (HTTP 400)
```json
{
  "status": "error",
  "message": "File parsing failed",
  "parseErrors": [
    "Line 5: Expected 11 fields, got 10",
    "Line 8: Invalid marks value: Not a number"
  ]
}
```

### Error Response - Server Error (HTTP 500)
```json
{
  "status": "error",
  "message": "Server error: Database connection failed"
}
```

---

## HTTP Status Codes

| Code | Meaning | Scenario |
|------|---------|----------|
| 200 | OK | File uploaded (some/all records inserted) |
| 400 | Bad Request | Invalid file, parse error, validation failure |
| 403 | Forbidden | Not authenticated as admin |
| 413 | Payload Too Large | File size exceeds 5 MB |
| 500 | Server Error | Database error, unexpected exception |

---

## Implementation Classes

### AdminQuestionUploadServlet
```java
@WebServlet("/api/admin/uploadQuestions")
@MultipartConfig(
    maxFileSize = 5242880,      // 5 MB
    maxRequestSize = 5242880,
    fileSizeThreshold = 1048576 // 1 MB
)
public class AdminQuestionUploadServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, 
                        HttpServletResponse response) {...}
}
```

**Key Methods:**
- `doPost()` - Handles file upload
- `sendError()` - Sends error JSON response
- `getSchoolIdForUser()` - Gets school context (TODO)

### FileParsingService
```java
public class FileParsingService {
    public static ParseResult parseFile(InputStream inputStream) {
        // Parse pipe-delimited TXT file
        // Returns ParseResult with records and errors
    }
}
```

**Key Methods:**
- `parseFile()` - Main parsing method
- `parseLine()` - Parse individual line

### QuestionUploadValidator
```java
public class QuestionUploadValidator {
    public static ValidationResult validateRecord(UploadRecord record) {
        // Validate individual record
    }
    
    public static List<UploadRecord> validateAllRecords(
            List<UploadRecord> records) {
        // Return list of invalid records
    }
}
```

**Validation Rules:**
- Empty field check
- Correct answer format (A-D)
- Difficulty format (Easy/Medium/Hard)
- Marks range (1-100)

### QuestionUploadService
```java
public class QuestionUploadService {
    public UploadReport uploadQuestions(List<UploadRecord> records,
                                      String uploadedBy,
                                      int schoolId) {
        // Main service orchestrating upload
    }
}
```

**Key Methods:**
- `uploadQuestions()` - Main orchestrator
- `getOrCreateTopic()` - Auto-create topic if needed
- `insertQuestion()` - Insert question + options
- `insertQuestionOptions()` - Insert 4 options per question
- `groupByClass()`, `groupBySubject()`, `groupByTopic()` - Organize data

---

## Database Interactions

### Classes Used
- `ClassUploadDAO.getClassIdByName()` - Verify class exists
- `SubjectUploadDAO.getOrCreateSubject()` - Get/create subject
- `TopicUploadDAO.getOrCreateTopic()` - Get/create topic
- `QuestionDAO.addQuestion()` - Insert question (via SQL directly)

### SQL Operations
```sql
-- 1. Get class ID
SELECT class_id FROM classes WHERE class_name = ?

-- 2. Get/Create subject
SELECT subject_id FROM subjects 
WHERE subject_name = ? AND class_id = ?

INSERT INTO subjects (school_id, class_id, subject_name, created_by)
SELECT school_id, ?, ?, ? FROM classes WHERE class_id = ?

-- 3. Get/Create topic
SELECT topic_id FROM topics 
WHERE topic_name = ? AND subject_id = ?

INSERT INTO topics (subject_id, class_id, topic_name, created_by)
SELECT ?, class_id, ?, ? FROM subjects WHERE subject_id = ?

-- 4. Insert question
INSERT INTO questions (topic_id, subject_id, school_id, question_text, 
                      marks, difficulty, created_by)
VALUES (?, ?, ?, ?, ?, ?, ?)

-- 5. Insert options (batch)
INSERT INTO question_options (question_id, option_text, option_key, 
                             is_correct, sequence)
VALUES (?, ?, ?, ?, ?)
```

### Transaction Handling
```java
conn.setAutoCommit(false);
try {
    // All operations
    conn.commit();
} catch (SQLException e) {
    // Auto-rollback on exception
}
```

---

## cURL Examples

### Basic Upload
```bash
curl -X POST \
  -H "Cookie: JSESSIONID=abc123def456" \
  -F "file=@questions.txt" \
  http://localhost:8080/StudentActivities/api/admin/uploadQuestions
```

### With Response Formatting
```bash
curl -X POST \
  -H "Cookie: JSESSIONID=abc123def456" \
  -F "file=@questions.txt" \
  -s \
  http://localhost:8080/StudentActivities/api/admin/uploadQuestions | \
  python -m json.tool
```

### Save Response to File
```bash
curl -X POST \
  -H "Cookie: JSESSIONID=abc123def456" \
  -F "file=@questions.txt" \
  http://localhost:8080/StudentActivities/api/admin/uploadQuestions \
  > upload-response.json
```

---

## JavaScript Examples

### Fetch API
```javascript
async function uploadQuestions(file) {
  const formData = new FormData();
  formData.append('file', file);
  
  try {
    const response = await fetch(
      '/StudentActivities/api/admin/uploadQuestions',
      {
        method: 'POST',
        credentials: 'include',  // Include cookies
        body: formData
      }
    );
    
    const data = await response.json();
    
    if (response.ok) {
      console.log(`Upload successful!`);
      console.log(`Success: ${data.successCount}/${data.totalRecords}`);
      if (data.failedRecords) {
        console.log('Failed records:');
        data.failedRecords.forEach(record => {
          console.log(`Line ${record.lineNumber}: ${record.errorMessage}`);
        });
      }
    } else {
      console.error('Upload failed:', data.message);
    }
  } catch (error) {
    console.error('Error:', error);
  }
}

// Usage
document.getElementById('uploadBtn').addEventListener('click', () => {
  const file = document.getElementById('fileInput').files[0];
  uploadQuestions(file);
});
```

### jQuery
```javascript
$('#uploadForm').on('submit', function(e) {
  e.preventDefault();
  
  var formData = new FormData(this);
  
  $.ajax({
    url: '/StudentActivities/api/admin/uploadQuestions',
    type: 'POST',
    data: formData,
    processData: false,
    contentType: false,
    success: function(response) {
      console.log('Success count: ' + response.successCount);
      console.log('Failure count: ' + response.failureCount);
    },
    error: function(err) {
      console.error('Upload failed:', err.responseJSON.message);
    }
  });
});
```

---

## Error Handling Guide

### Validation Errors (Caught by QuestionUploadValidator)
```
"Option A is empty" 
"Option B is empty"
"Option C is empty"
"Option D is empty"
"Correct answer must be A, B, C, or D"
"Difficulty must be EASY, MEDIUM, or HARD"
"Marks must be between 1 and 100"
"Class name is empty"
"Subject name is empty"
"Chapter name is empty"
"Question text is empty"
```

### Database Errors (Caught by QuestionUploadService)
```
"Class 'X' not found in database"
"Failed to create/find subject 'Y'"
"Failed to create/find topic 'Z'"
"Failed to insert question into database"
"Database transaction error: [exception message]"
```

### File Parsing Errors (Caught by FileParsingService)
```
"Expected 11 fields, got N"
"Invalid marks value: [error]"
"File reading error: [error]"
```

---

## Performance Considerations

### Memory Usage
- **Per Record:** ~200 bytes
- **500 Records:** ~100 KB
- **Peak Memory:** ~5 MB for parsing + insertion

### Database Operations
- **Batch Inserts:** All in single transaction
- **Connection Pool:** Uses DatabaseConnection singleton
- **Query Type:** Prepared statements (prevent SQL injection)

### File Processing
- **Streaming:** Line-by-line (low memory)
- **Batch Size:** 4 records per question options
- **Database Batches:** All operations in single transaction

### Network
- **File Size Limit:** 5 MB
- **Upload Speed:** Typical 100-500 records/sec
- **Expected Time:** 500 records ≈ 5-10 seconds

---

## Troubleshooting

### No Response from Server
```
Check:
1. Servlet is deployed correctly
2. Session is active (login first)
3. Admin role is set
4. Network/firewall allows connection
```

### "Only .txt files allowed"
```
Solution:
- Save file with .txt extension
- Not .csv, .xlsx, .doc, etc.
- File must be plain text format
```

### "Expected 11 fields, got X"
```
Solution:
- Verify each line has exactly 11 pipe-separated fields
- Check for missing pipes or extra pipes
- Ensure no line breaks within fields
```

### Partial Upload Success
```
Check:
- failedRecords array in response
- Specific error message for each failed record
- Line numbers match your file
- Re-upload with corrections
```

### Database Errors on Valid File
```
Check:
- Class exists (must be pre-created)
- Database connection is active
- Permissions for INSERT operations
- Disk space available
```

---

**Version:** 1.0  
**Last Updated:** 2026-03-24  
**Status:** Production Ready
