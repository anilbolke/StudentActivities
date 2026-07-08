# Preview Questions Debugging Guide

## Problem
Preview questions not showing in createExam.jsp even though the button is working.

## Root Cause Diagnosis Checklist

### Step 1: Load Test Data
First, you must have test questions in the database:

```sql
-- Execute this SQL file to load complete test data
COMPLETE_TEST_DATA_WITH_QUESTIONS.sql
```

This creates:
- School (ID: 1)
- Classes (10-A, 10-B)
- Subjects (Mathematics, English)
- Chapters (Algebra, Geometry, Trigonometry, Grammar, Vocabulary)
- Questions (17 total across all chapters)
- Users (admin1, teacher1, teacher2)

### Step 2: Verify Data in Database

After loading test data, run these queries:

```sql
-- Verify school exists
SELECT * FROM schools LIMIT 1;
-- Expected: 1 row with school_id=1

-- Verify subjects exist
SELECT COUNT(*) as subject_count FROM subjects;
-- Expected: 2 (Mathematics, English)

-- Verify chapters exist
SELECT COUNT(*) as chapter_count FROM chapters;
-- Expected: 5 (Algebra, Geometry, Trigonometry, Grammar, Vocabulary)

-- Verify questions exist
SELECT COUNT(*) as question_count FROM questions;
-- Expected: 17 questions

-- Verify questions are PUBLISHED
SELECT COUNT(*) as published_questions FROM questions WHERE status = 'PUBLISHED';
-- Expected: 17

-- Verify question structure
SELECT question_id, question_text, chapter_id, difficulty_level, status FROM questions LIMIT 5;
-- Expected: All fields populated
```

### Step 3: Test Using UI with Debug Output

1. Restart Tomcat:
   - Stop Tomcat
   - Clear Tomcat cache: `D:\apache-tomcat-9.0.100\work\Catalina\localhost\StudentActivities\`
   - Start Tomcat

2. Login with: teacher1 / password123

3. Navigate to: Create Exam

4. Select Form Fields:
   - Class: Class 10-A
   - Subject: Mathematics
   - Chapters: Select "Algebra" (checkbox)
   - Question Count: 5
   - Difficulty: ALL

5. Click "Preview Questions"

### Step 4: Check Debug Output

Look for the DEBUG INFO section at the top showing:
- Selected Class ID: (should be 1)
- Selected Subject ID: (should be 1)
- Selected Chapter IDs: [1] (for Algebra)
- Questions Found: (should be > 0)

### Step 5: If Questions Not Found

**Possible Causes & Fixes:**

#### Cause A: No Test Data Loaded
**Fix:** Execute COMPLETE_TEST_DATA_WITH_QUESTIONS.sql file

#### Cause B: Questions Not Published
**Fix:** Run this query:
```sql
UPDATE questions SET status = 'PUBLISHED' WHERE status != 'PUBLISHED';
```

#### Cause C: Questions Exist But Wrong Filters
**Debug:** Check which questions match your filter:
```sql
SELECT q.question_id, q.question_text, q.difficulty_level, q.status
FROM questions q
WHERE q.class_id = 1 
  AND q.subject_id = 1 
  AND q.chapter_id = 1
  AND q.status = 'PUBLISHED'
LIMIT 10;
```

#### Cause D: Chapter Selection Not Sent
**Debug:** Check if chapters parameter is being sent:
- Open browser DevTools (F12)
- Go to Network tab
- Click "Preview Questions"
- Check POST request body
- Look for: `chapters=1&chapters=2` etc.

#### Cause E: Database Connection Issue
**Fix:** 
- Verify DatabaseConnection.java can connect to MySQL
- Check MySQL is running
- Verify connection string in DatabaseConnection.java

### Step 6: Expected Behavior

**Before Clicking Preview:**
- Form shows class, subject, chapters, question count, difficulty, total marks
- No preview section visible

**After Clicking Preview (with chapters selected):**
- DEBUG INFO section shows selected values
- Questions Found: > 0
- Preview section appears showing:
  - Total questions count
  - All questions with options A-D
  - Correct answer (for teacher view)
  - Difficulty level
  - Marks for each question

**If No Chapters Selected:**
- Warning: "No Chapters Selected"
- No preview shown

**If Chapters Selected but No Questions:**
- Error: "No Questions Found"
- Debug info shows chapter IDs selected
- Verify test data exists for those chapters

## Quick Troubleshooting

| Symptom | Most Likely Cause | Fix |
|---------|------------------|-----|
| Preview button doesn't respond | Form not submitting | Check browser console for JS errors |
| Form submits but no preview | No test data | Load COMPLETE_TEST_DATA_WITH_QUESTIONS.sql |
| Preview shows 0 questions | Questions not published or wrong filters | Run UPDATE query to set status='PUBLISHED' |
| Selected chapters not showing | Chapters dropdown not rendering | Check ChapterDAO.getChaptersBySubject() |
| Correct answer shows as null | Question.getCorrectAnswer() returns null | Check correct_answer column in database |

## Testing without Frontend

You can also test QuestionDAO directly:

```java
// Create a test class in src/com/school/exam/test/
List<Integer> chapterIds = Arrays.asList(1); // Algebra
List<Question> questions = QuestionDAO.getQuestionsByClassSubjectAndChapters(1, 1, chapterIds);
System.out.println("Found " + questions.size() + " questions");
for (Question q : questions) {
    System.out.println("Q: " + q.getQuestionText());
    System.out.println("A: " + q.getCorrectAnswer());
}
```

## File Changes Made

1. **createExam.jsp**:
   - Added DEBUG INFO section (shows selected values)
   - Added error messages for empty chapters or no questions
   - Improved preview section display

2. **COMPLETE_TEST_DATA_WITH_QUESTIONS.sql**:
   - Created new SQL file with all test data
   - Includes school, classes, subjects, chapters, questions, users

## Next Steps

1. Load the test data
2. Verify data in database
3. Test using UI
4. Check debug output
5. If still not working, check Tomcat logs for SQL errors
