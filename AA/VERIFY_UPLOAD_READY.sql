-- ============================================================
-- Question Upload Feature - Database Verification Script
-- ============================================================
-- Run this script to verify the database is ready for the
-- Question Upload feature. No changes are made to the database.
-- ============================================================

-- 1. Check if required tables exist
SELECT 'Checking required tables...' as 'Status';

SHOW TABLES WHERE Tables_in_school_exam_system IN 
('classes', 'subjects', 'topics', 'questions', 'question_options');

-- 2. Verify table structures
SELECT 'Verifying table structures...' as 'Status';

-- Check classes table
DESC classes;

-- Check subjects table
DESC subjects;

-- Check topics table
DESC topics;

-- Check questions table
DESC questions;

-- Check question_options table
DESC question_options;

-- 3. Verify sample data exists
SELECT 'Checking sample data...' as 'Status';

-- Count classes
SELECT COUNT(*) as 'Total Classes' FROM classes;

-- List available classes
SELECT class_id, class_name, class_section FROM classes LIMIT 10;

-- Count existing subjects
SELECT COUNT(*) as 'Total Subjects' FROM subjects;

-- Count existing topics
SELECT COUNT(*) as 'Total Topics' FROM topics;

-- Count existing questions
SELECT COUNT(*) as 'Total Questions' FROM questions;

-- 4. Verify class/subject/topic hierarchy
SELECT 'Sample Class → Subject → Topic Hierarchy' as 'Status';

SELECT 
    c.class_id,
    c.class_name,
    COUNT(DISTINCT s.subject_id) as 'Subject Count',
    COUNT(DISTINCT t.topic_id) as 'Topic Count'
FROM classes c
LEFT JOIN subjects s ON c.class_id = s.class_id
LEFT JOIN topics t ON s.subject_id = t.subject_id
WHERE c.class_id IN (10, 11, 12)
GROUP BY c.class_id, c.class_name;

-- 5. Check for data issues
SELECT 'Checking for potential data issues...' as 'Status';

-- Questions without topics
SELECT COUNT(*) as 'Questions without topic' 
FROM questions WHERE topic_id IS NULL;

-- Subjects without class
SELECT COUNT(*) as 'Subjects without class' 
FROM subjects WHERE class_id IS NULL;

-- Topics without subject
SELECT COUNT(*) as 'Topics without subject' 
FROM topics WHERE subject_id IS NULL;

-- Questions without options
SELECT 
    q.question_id, 
    q.question_text,
    COUNT(qo.option_id) as 'Option Count'
FROM questions q
LEFT JOIN question_options qo ON q.question_id = qo.question_id
GROUP BY q.question_id, q.question_text
HAVING COUNT(qo.option_id) != 4
LIMIT 10;

-- 6. Verify indexing (for performance)
SELECT 'Verifying indexes...' as 'Status';

-- Check if indexes exist
SHOW INDEX FROM questions;
SHOW INDEX FROM question_options;
SHOW INDEX FROM topics;
SHOW INDEX FROM subjects;

-- 7. Test query performance
SELECT 'Testing query performance...' as 'Status';

-- Get all questions for a class
SELECT 'Questions for Class 10: ' as 'Info',
    COUNT(q.question_id) as 'Count'
FROM classes c
JOIN subjects s ON c.class_id = s.class_id
JOIN topics t ON s.subject_id = t.subject_id
JOIN questions q ON t.topic_id = q.topic_id
WHERE c.class_id = 10;

-- Get questions by subject and topic
SELECT 'Questions by Subject→Topic: ' as 'Info';

SELECT 
    s.subject_name,
    t.topic_name,
    COUNT(q.question_id) as 'Question Count'
FROM subjects s
LEFT JOIN topics t ON s.subject_id = t.subject_id
LEFT JOIN questions q ON t.topic_id = q.topic_id
WHERE s.class_id = 10
GROUP BY s.subject_id, t.topic_id
ORDER BY s.subject_name, t.topic_name;

-- 8. Verify foreign keys
SELECT 'Verifying foreign key relationships...' as 'Status';

-- Questions referencing non-existent topics
SELECT COUNT(*) as 'Orphaned Questions'
FROM questions q
WHERE NOT EXISTS (
    SELECT 1 FROM topics t WHERE t.topic_id = q.topic_id
);

-- Subjects referencing non-existent classes
SELECT COUNT(*) as 'Orphaned Subjects'
FROM subjects s
WHERE NOT EXISTS (
    SELECT 1 FROM classes c WHERE c.class_id = s.class_id
);

-- 9. Check user/created_by information
SELECT 'Checking creator information...' as 'Status';

-- Sample created_by values in questions
SELECT DISTINCT created_by 
FROM questions 
LIMIT 5;

-- Count questions by creator
SELECT created_by, COUNT(*) as 'Count'
FROM questions
GROUP BY created_by;

-- 10. Summary Report
SELECT 'UPLOAD FEATURE READINESS SUMMARY' as 'Report';

SELECT 
    'Classes Available' as 'Item',
    COUNT(*) as 'Count'
FROM classes
UNION ALL
SELECT 
    'Subjects in System',
    COUNT(*)
FROM subjects
UNION ALL
SELECT 
    'Topics in System',
    COUNT(*)
FROM topics
UNION ALL
SELECT 
    'Questions in System',
    COUNT(*)
FROM questions
UNION ALL
SELECT 
    'Question Options',
    COUNT(*)
FROM question_options;

-- ============================================================
-- NEXT STEPS AFTER VERIFICATION:
-- ============================================================
-- 1. If all queries return results, database is ready
-- 2. Ensure at least one class (10, 11, 12) exists
-- 3. If no data, run sample data initialization script
-- 4. Deploy the Java upload classes
-- 5. Test upload with sample-questions.txt file
-- ============================================================

-- END OF VERIFICATION SCRIPT
