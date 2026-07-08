# Load Test Data into MySQL Using Workbench

## Step 1: Open MySQL Workbench

## Step 2: Connect to Your Database
- Select your connection to localhost (if you have saved connections)
- If prompted, enter password

## Step 3: Select Your Database
- In the left panel under "SCHEMAS", find and double-click: **school_exam_system**
- It should now be highlighted/active

## Step 4: Open the SQL File
- Go to menu: **File → Open SQL Script...**
- Navigate to: `C:\Users\Admin\StudentActivities\StudentActivities\COMPLETE_TEST_DATA_WITH_QUESTIONS.sql`
- Click "Open"

The SQL file content will now appear in the editor.

## Step 5: Execute the Script
- Press **Ctrl+Shift+Enter** (or click the Execute button ⚡️)
- Wait for execution to complete (should be 2-5 seconds)

## Step 6: Verify Data Was Loaded
- Copy and paste this query into a NEW SQL editor tab:
```sql
SELECT COUNT(*) as total_questions FROM questions;
```
- Execute it (Ctrl+Enter)
- Expected result: **17**

If you see 17, the test data loaded successfully! ✓

## Troubleshooting

If you get an error like "Unknown column" or "Duplicate entry":
- That's normal if this is the second time running it
- The SQL file uses `INSERT IGNORE` to skip duplicates
- No action needed - continue to Step 7

If you get "Database does not exist":
- Make sure you selected "school_exam_system" in step 3
- Or change the database name in the first line of the SQL file

## Step 7: Next - Restart Tomcat & Test

Once you see 17 questions:
1. Stop Tomcat
2. Clear cache: `D:\apache-tomcat-9.0.100\work\Catalina\localhost\StudentActivities\`
3. Start Tomcat
4. Test preview questions (instructions in TEST_PREVIEW_QUESTIONS_STEPS.md)

---

**Let me know when you've executed the SQL and what COUNT(*) returned!**
