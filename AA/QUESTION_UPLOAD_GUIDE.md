# Question Bulk Upload Feature - Complete Guide

## Overview
This feature allows admins to bulk upload exam questions via a pipe-delimited TXT file. Questions are organized by Class → Subject → Chapter and can be instantly used by teachers to create exams.

---

## 📋 TXT FILE FORMAT

### Header (Optional)
```
CLASS|SUBJECT|CHAPTER|QUESTION_TEXT|OPTION_A|OPTION_B|OPTION_C|OPTION_D|CORRECT_ANSWER|DIFFICULTY|MARKS
```

### Data Format Example
```
10|Mathematics|Algebra|What is 2+2?|3|4|5|6|B|Easy|1
10|Mathematics|Algebra|Solve: x+5=10|x=5|x=10|x=15|x=20|A|Medium|2
10|Science|Physics|What is the SI unit of force?|Newton|Dyne|Joule|Watt|A|Easy|1
```

### Field Specifications

| Field | Description | Rules | Example |
|-------|-------------|-------|---------|
| **CLASS** | Class/Grade level | Must exist in database (e.g., 10, 11, 12) | 10 |
| **SUBJECT** | Subject name | Will be created if not exists | Mathematics |
| **CHAPTER** | Chapter/Unit/Topic name | Will be created if not exists | Algebra |
| **QUESTION_TEXT** | The actual question | Cannot be empty | What is 2+2? |
| **OPTION_A** | First multiple choice option | Cannot be empty | 3 |
| **OPTION_B** | Second option | Cannot be empty | 4 |
| **OPTION_C** | Third option | Cannot be empty | 5 |
| **OPTION_D** | Fourth option | Cannot be empty | 6 |
| **CORRECT_ANSWER** | Correct answer | Must be: A, B, C, or D | B |
| **DIFFICULTY** | Difficulty level | Must be: Easy, Medium, or Hard | Easy |
| **MARKS** | Marks for question | Integer between 1-100 | 1 |

---

## ✅ VALIDATION RULES

Before uploading, ensure your file follows these rules:

### File Rules
- ✓ File must be `.txt` format (plain text)
- ✓ File size must be ≤ 5 MB
- ✓ Use pipe character `|` as field separator
- ✓ Each record must have exactly 11 fields

### Data Rules
- ✓ All fields cannot be empty
- ✓ Correct answer must be A, B, C, or D (case-insensitive)
- ✓ Difficulty must be: Easy, Medium, or Hard (case-insensitive)
- ✓ Marks must be numeric, between 1 and 100
- ✓ Class must already exist in the system
- ✓ Subject and Chapter (Topic) will be auto-created if not present

### Examples of Valid Data
```
10|English|Literature|Who wrote Romeo and Juliet?|William Shakespeare|Christopher Marlowe|Ben Jonson|John Webster|A|Easy|1
11|Physics|Motion|What is SI unit of force?|Newton|Dyne|Joule|Watt|A|Medium|2
12|Chemistry|Organic|General formula for alkanes?|CnH2n+2|CnH2n|CnH2n-2|CnH3n|A|Hard|3
```

---

## 🚀 HOW TO UPLOAD

### Step 1: Prepare Your File
1. Create a `.txt` file with questions in pipe-delimited format
2. Validate all data before uploading
3. See `sample-questions.txt` for examples

### Step 2: Upload via API
**Endpoint:** `POST /api/admin/uploadQuestions`

**Using cURL:**
```bash
curl -X POST \
  -H "Cookie: JSESSIONID=your_session_id" \
  -F "file=@your-questions.txt" \
  http://localhost:8080/StudentActivities/api/admin/uploadQuestions
```

**Using JavaScript/Fetch:**
```javascript
const fileInput = document.getElementById('fileInput');
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('/StudentActivities/api/admin/uploadQuestions', {
    method: 'POST',
    credentials: 'include',
    body: formData
})
.then(response => response.json())
.then(data => {
    console.log('Success:', data);
    console.log('Questions uploaded: ' + data.successCount);
    console.log('Failed records: ' + data.failureCount);
    if (data.failedRecords) {
        console.log('Errors:', data.failedRecords);
    }
});
```

### Step 3: Check Response

**Success Response (HTTP 200):**
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
            "errorMessage": "Class '13' not found in database"
        }
    ]
}
```

**Error Response (HTTP 400/403/500):**
```json
{
    "status": "error",
    "message": "Invalid file format. Only .txt files are allowed"
}
```

---

## 🔍 TROUBLESHOOTING

### Error: "Unauthorized: Only admins can upload questions"
- **Cause:** You are not logged in as an admin
- **Solution:** Log in with admin credentials

### Error: "No file uploaded"
- **Cause:** File was not selected or is empty
- **Solution:** Select a valid .txt file and ensure it has content

### Error: "Invalid file format. Only .txt files are allowed"
- **Cause:** File extension is not .txt
- **Solution:** Save your file as `.txt` format

### Error: "Class '10' not found in database"
- **Cause:** The specified class doesn't exist
- **Solution:** Ensure the class exists in the system before uploading questions

### Error: "Correct answer must be A, B, C, or D"
- **Cause:** The correct answer field has invalid value (e.g., 'E', '1', or empty)
- **Solution:** Ensure correct answer is exactly A, B, C, or D

### Error: "Marks must be between 1 and 100"
- **Cause:** Marks field is 0, negative, or greater than 100
- **Solution:** Set marks to a value between 1 and 100

### Error: "File parsing failed"
- **Cause:** File format is incorrect (wrong delimiter, wrong number of fields)
- **Solution:** Verify each line has exactly 11 pipe-separated fields

### Partial Upload Success (Some Records Failed)
- **Response:** You'll see successCount and failedRecords list
- **Action:** Check the error messages for each failed record and re-upload with corrections

---

## 📊 DATABASE SCHEMA USED

### Questions Table
```sql
CREATE TABLE questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    topic_id INT NOT NULL,          -- Chapter/Topic
    subject_id INT NOT NULL,        -- Subject
    school_id INT NOT NULL,         -- School
    question_text LONGTEXT NOT NULL,
    marks DECIMAL(5,2) DEFAULT 1.00,
    difficulty ENUM('EASY', 'MEDIUM', 'HARD'),
    created_by VARCHAR(100),
    created_at TIMESTAMP
);
```

### Question Options Table
```sql
CREATE TABLE question_options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text TEXT NOT NULL,
    option_key CHAR(1),             -- A, B, C, or D
    is_correct BOOLEAN,
    sequence INT                    -- Order (1, 2, 3, 4)
);
```

### Class → Subject → Topic Hierarchy
```
Classes (10, 11, 12)
  └── Subjects (Mathematics, Science, English)
      └── Topics/Chapters (Algebra, Physics, Literature)
          └── Questions (With 4 options each)
```

---

## 💡 BEST PRACTICES

1. **Test with Small File First**
   - Upload 10-20 questions before uploading 500+
   - Verify everything works correctly

2. **Use UTF-8 Encoding**
   - Save text files with UTF-8 encoding
   - Ensures special characters work correctly

3. **Verify Classes Exist**
   - Classes (10, 11, 12) must already be in the database
   - Subjects and Chapters will be auto-created

4. **Keep File Organized**
   - Group questions by class, then subject, then chapter
   - Makes debugging easier if errors occur

5. **Review Sample File**
   - Use `sample-questions.txt` as template
   - Copy-paste structure to your file

6. **Backup Original File**
   - Keep a backup before uploading
   - Useful for re-uploading if needed

---

## 🔧 IMPLEMENTATION DETAILS

### Services Used
1. **FileParsingService** - Parses TXT file into UploadRecord objects
2. **QuestionUploadValidator** - Validates each record
3. **QuestionUploadService** - Batch inserts into database
4. **AdminQuestionUploadServlet** - HTTP endpoint

### Processing Flow
```
1. File Upload
   ↓
2. Parse file (FileParsingService)
   ↓
3. Validate all records (QuestionUploadValidator)
   ↓
4. Group by Class → Subject → Chapter
   ↓
5. Get/Create Class, Subject, Topic
   ↓
6. Insert Questions + Options (Batch)
   ↓
7. Generate Report (Success/Failed)
   ↓
8. Return JSON Response
```

### Batch Processing
- Questions are inserted in batches for performance
- Supports 500+ questions per upload
- Uses transactions for data integrity

---

## 📝 SAMPLE QUESTIONS FILE

A sample file `sample-questions.txt` is provided with 36 questions across different classes and subjects. You can:
- Use it as a template
- Copy it and modify with your data
- Upload it to test the feature

---

## 🎯 NEXT STEPS FOR TEACHERS

After questions are uploaded:
1. Log in as Teacher
2. Go to "Create Exam"
3. Select Class → Subject → Chapter
4. Questions will be available to add to exam papers
5. Arrange questions in desired order
6. Publish exam for students

---

## 📞 SUPPORT

For issues or questions:
- Check the Troubleshooting section above
- Verify your file format matches the spec
- Ensure all required fields are populated
- Check response error messages for details

---

## 📈 PERFORMANCE NOTES

- **Recommended batch size:** 500-1000 questions per file
- **Max file size:** 5 MB (configurable)
- **Expected upload time:** < 10 seconds for 500 questions
- **Database optimization:** Indexes on topic_id, subject_id for fast retrieval

---

**Last Updated:** 2026-03-24  
**Version:** 1.0  
**Status:** Production Ready
