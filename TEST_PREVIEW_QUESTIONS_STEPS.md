# Step-by-Step Guide: Load Test Data & Test Preview Questions

## Step 1: Load Test Data into MySQL

1. Open MySQL Client or Workbench
2. Select your exam system database (e.g., `student_activities`)
3. Copy and paste the contents of: `COMPLETE_TEST_DATA_WITH_QUESTIONS.sql`
4. Execute the script

**What it creates:**
- Demo School (ID: 1)
- Classes: Class 10-A, Class 10-B
- Subjects: Mathematics, English
- Chapters: Algebra, Geometry, Trigonometry, Grammar, Vocabulary
- Questions: 17 questions across all chapters (with options and answers)
- Users: admin1, teacher1, teacher2 (all with password123/admin123)

## Step 2: Verify Data Was Loaded

Run this query to confirm:
```sql
SELECT COUNT(*) as total_questions FROM questions;
```

Should return: **17 questions**

## Step 3: Restart Tomcat (Important!)

**This clears JSP compilation cache:**

1. Stop Tomcat (CTRL+C if running, or stop from services)
2. Wait 5 seconds for complete shutdown
3. Delete cache folder: `D:\apache-tomcat-9.0.100\work\Catalina\localhost\StudentActivities\`
4. Start Tomcat again

## Step 4: Test in Browser

1. Open: `http://localhost:8080/StudentActivities/`
2. Login with:
   - **Username:** teacher1
   - **Password:** password123
3. Click: "Create Exam" (or navigate to createExam.jsp)

## Step 5: Select Form Fields

Fill out the exam creation form:
- **Class:** Class 10-A
- **Subject:** Mathematics
- **Chapters:** ✓ Algebra (check the checkbox)
- **Question Count:** 5
- **Difficulty:** ALL
- **Total Marks:** 5

## Step 6: Click "Preview Questions"

**Expected Result:**
- You should see a section titled "📋 Question Preview (5 questions)"
- DEBUG INFO showing selected values
- Questions 1-5 displayed with:
  - Question text (e.g., "Solve: 2x + 5 = 15")
  - Options A, B, C, D
  - Correct Answer (for teacher view)
  - Difficulty Level
  - Marks

**If It Works:**
✅ Preview questions are now functional!
✅ You can proceed to create and submit the exam

**If Questions Don't Show:**

Check for these error messages:
1. **"No Chapters Selected"** → You must check at least one chapter checkbox
2. **"No Questions Found"** → Database doesn't have questions for this class/subject/chapters combination

If you see error message, report exactly which one and we'll debug further.

## Step 7 (If Something's Wrong)

Send me this information:
1. The exact error message you see (if any)
2. Screenshot of the page
3. Output from browser console (Press F12 → Console tab)
4. Result of this SQL query:
```sql
SELECT COUNT(*) FROM questions 
WHERE class_id = 1 AND subject_id = 1 AND chapter_id IN (1,2,3) AND status = 'PUBLISHED';
```

## Troubleshooting Quick Reference

| Problem | Solution |
|---------|----------|
| "Undefined" errors when accessing page | Restart Tomcat and clear cache folder |
| 0 Questions Found | Run test data SQL file again, verify it executed |
| Login page keeps showing | Make sure you logged in successfully (check if error messages appear) |
| Preview button doesn't respond | Check browser console (F12) for JavaScript errors |
| Database connection error | Verify MySQL is running and StudentActivities database exists |

## Important Files Location

- Test Data SQL: `C:\Users\Admin\StudentActivities\StudentActivities\COMPLETE_TEST_DATA_WITH_QUESTIONS.sql`
- Debug Guide: `C:\Users\Admin\StudentActivities\StudentActivities\PREVIEW_QUESTIONS_DEBUG_GUIDE.md`
- Form File: `C:\Users\Admin\StudentActivities\StudentActivities\WebContent\createExam.jsp`

---

**Ready to test? Start with Step 1 (Load Test Data) and report back with what you see!**
