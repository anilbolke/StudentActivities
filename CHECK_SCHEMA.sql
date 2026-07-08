-- Check existing schools table structure
DESC schools;

-- Check what columns exist
SELECT COLUMN_NAME, COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'schools' AND TABLE_SCHEMA = 'exam_db';
