-- Complete Test Data Setup for Exam System with Questions
-- This script creates all necessary data including questions for preview testing

-- 1. Create School
INSERT IGNORE INTO schools (school_id, school_name, address, city, state, postal_code) 
VALUES (1, 'Demo School', 'Demo Address', 'Demo City', 'Demo State', '12345');

-- 2. Create Classes
INSERT IGNORE INTO classes (class_id, school_id, class_name, grade, section, status, created_at)
VALUES 
(1, 1, 'Class 10-A', 10, 'A', 'ACTIVE', NOW()),
(2, 1, 'Class 10-B', 10, 'B', 'ACTIVE', NOW());

-- 3. Create Subjects
INSERT IGNORE INTO subjects (subject_id, school_id, subject_name, description, status, created_at)
VALUES 
(1, 1, 'Mathematics', 'Mathematics Subject', 'ACTIVE', NOW()),
(2, 1, 'English', 'English Subject', 'ACTIVE', NOW());

-- 4. Create Chapters for Mathematics
INSERT IGNORE INTO chapters (chapter_id, subject_id, chapter_name, description, status, created_at)
VALUES 
(1, 1, 'Algebra', 'Algebraic Equations', 'ACTIVE', NOW()),
(2, 1, 'Geometry', 'Geometric Shapes', 'ACTIVE', NOW()),
(3, 1, 'Trigonometry', 'Trigonometric Functions', 'ACTIVE', NOW());

-- 5. Create Chapters for English
INSERT IGNORE INTO chapters (chapter_id, subject_id, chapter_name, description, status, created_at)
VALUES 
(4, 2, 'Grammar', 'English Grammar', 'ACTIVE', NOW()),
(5, 2, 'Vocabulary', 'English Vocabulary', 'ACTIVE', NOW());

-- 6. Create Users (Teachers)
INSERT IGNORE INTO users (user_id, username, password, email, role, first_name, last_name, school_id, status, created_at)
VALUES 
(1, 'admin1', 'admin123', 'admin@school.com', 'ADMIN', 'Admin', 'User', 1, 'ACTIVE', NOW()),
(2, 'teacher1', 'password123', 'teacher1@school.com', 'TEACHER', 'John', 'Doe', 1, 'ACTIVE', NOW()),
(3, 'teacher2', 'password123', 'teacher2@school.com', 'TEACHER', 'Jane', 'Smith', 1, 'ACTIVE', NOW());

-- 7. Create Questions for Algebra (Chapter 1)
INSERT IGNORE INTO questions (question_id, class_id, subject_id, chapter_id, question_text, option_a, option_b, option_c, option_d, correct_answer, marks, difficulty_level, status, created_by, created_at)
VALUES 
(1, 1, 1, 1, 'Solve: 2x + 5 = 15', 'x = 5', 'x = 10', 'x = -5', 'x = 3', 'A', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(2, 1, 1, 1, 'Simplify: (3x + 2y) + (2x + 3y)', '5x + 5y', '5x - 5y', 'x + y', '6xy', 'A', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(3, 1, 1, 1, 'Solve: x^2 - 4 = 0', 'x = 2 or x = -2', 'x = 2', 'x = -2', 'x = 4', 'A', 1, 'MEDIUM', 'PUBLISHED', 2, NOW()),
(4, 1, 1, 1, 'Find the value of x: 3x^2 + 6x + 3 = 0', 'x = -1', 'x = 1', 'x = 2', 'x = 0', 'A', 1, 'HARD', 'PUBLISHED', 2, NOW()),
(5, 1, 1, 1, 'Solve: 4x - 8 = 0', 'x = 2', 'x = 4', 'x = -2', 'x = 8', 'A', 1, 'EASY', 'PUBLISHED', 2, NOW());

-- 8. Create Questions for Geometry (Chapter 2)
INSERT IGNORE INTO questions (question_id, class_id, subject_id, chapter_id, question_text, option_a, option_b, option_c, option_d, correct_answer, marks, difficulty_level, status, created_by, created_at)
VALUES 
(6, 1, 1, 2, 'The sum of angles in a triangle is:', '90°', '180°', '270°', '360°', 'B', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(7, 1, 1, 2, 'Find the area of a circle with radius 5:', '25π', '10π', '50π', '100π', 'A', 1, 'MEDIUM', 'PUBLISHED', 2, NOW()),
(8, 1, 1, 2, 'In a right triangle, if one angle is 90°, the other two angles sum to:', '90°', '180°', '270°', '360°', 'A', 1, 'EASY', 'PUBLISHED', 2, NOW());

-- 9. Create Questions for Trigonometry (Chapter 3)
INSERT IGNORE INTO questions (question_id, class_id, subject_id, chapter_id, question_text, option_a, option_b, option_c, option_d, correct_answer, marks, difficulty_level, status, created_by, created_at)
VALUES 
(9, 1, 1, 3, 'sin(90°) = ?', '0', '1', '0.5', '-1', 'B', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(10, 1, 1, 3, 'cos(0°) = ?', '0', '1', '0.5', '-1', 'B', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(11, 1, 1, 3, 'tan(45°) = ?', '0', '1', '√3', '∞', 'B', 1, 'MEDIUM', 'PUBLISHED', 2, NOW());

-- 10. Create Questions for English Grammar (Chapter 4)
INSERT IGNORE INTO questions (question_id, class_id, subject_id, chapter_id, question_text, option_a, option_b, option_c, option_d, correct_answer, marks, difficulty_level, status, created_by, created_at)
VALUES 
(12, 1, 2, 4, 'Choose the correct form: "She ____ gone to the market."', 'is', 'has', 'have', 'was', 'B', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(13, 1, 2, 4, 'What is the past tense of "go"?', 'goed', 'went', 'going', 'goes', 'B', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(14, 1, 2, 4, 'Identify the noun: "The quick brown fox jumps over the fence."', 'quick', 'jumps', 'fox', 'over', 'C', 1, 'MEDIUM', 'PUBLISHED', 2, NOW());

-- 11. Create Questions for English Vocabulary (Chapter 5)
INSERT IGNORE INTO questions (question_id, class_id, subject_id, chapter_id, question_text, option_a, option_b, option_c, option_d, correct_answer, marks, difficulty_level, status, created_by, created_at)
VALUES 
(15, 1, 2, 5, 'Synonym of "Happy" is:', 'Sad', 'Joyful', 'Angry', 'Tired', 'B', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(16, 1, 2, 5, 'Antonym of "Big" is:', 'Large', 'Huge', 'Small', 'Enormous', 'C', 1, 'EASY', 'PUBLISHED', 2, NOW()),
(17, 1, 2, 5, 'What does "Benevolent" mean?', 'Cruel', 'Kind', 'Angry', 'Sad', 'B', 1, 'HARD', 'PUBLISHED', 2, NOW());

-- Verify data was inserted
SELECT '=== Schools ===' as info;
SELECT school_id, school_name FROM schools;

SELECT '=== Classes ===' as info;
SELECT class_id, school_id, class_name, grade, section FROM classes;

SELECT '=== Subjects ===' as info;
SELECT subject_id, subject_name FROM subjects;

SELECT '=== Chapters ===' as info;
SELECT chapter_id, subject_id, chapter_name FROM chapters;

SELECT '=== Questions Count ===' as info;
SELECT subject_id, COUNT(*) as total_questions FROM questions GROUP BY subject_id;

SELECT '=== Users ===' as info;
SELECT user_id, username, role FROM users;
