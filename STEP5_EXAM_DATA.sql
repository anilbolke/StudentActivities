-- STEP 5: EXAM CREATION & TAKING - DATABASE SCHEMA
-- Tables for storing exams, exam-question mappings, and student answers

-- ===================================
-- TABLE: exams
-- ===================================
-- Stores exam metadata created by teachers
CREATE TABLE IF NOT EXISTS exams (
    exam_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(200) NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    
    -- Exam configuration
    question_count INT NOT NULL DEFAULT 10,
    total_marks INT NOT NULL DEFAULT 10,
    difficulty_level VARCHAR(50),  -- EASY, MEDIUM, HARD, or MIXED
    duration_minutes INT DEFAULT 60,  -- Time allowed for exam (optional)
    
    -- Metadata
    status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') DEFAULT 'DRAFT',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_class (class_id),
    INDEX idx_subject (subject_id),
    INDEX idx_status (status),
    INDEX idx_created_by (created_by),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- TABLE: exam_questions_map
-- ===================================
-- Maps specific questions to specific exams
-- This creates a snapshot of questions for the exam at creation time
CREATE TABLE IF NOT EXISTS exam_questions_map (
    map_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    question_id INT NOT NULL,
    question_sequence INT NOT NULL,  -- Order of questions in exam
    question_marks INT NOT NULL DEFAULT 1,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    
    -- Indexes & Constraints
    UNIQUE KEY unique_exam_question (exam_id, question_id),
    INDEX idx_exam (exam_id),
    INDEX idx_question (question_id),
    INDEX idx_sequence (exam_id, question_sequence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- TABLE: exam_answers
-- ===================================
-- Stores student answers during/after exam taking
CREATE TABLE IF NOT EXISTS exam_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    student_id INT NOT NULL,
    question_id INT NOT NULL,
    
    -- Student's response
    selected_answer VARCHAR(1),  -- A, B, C, or D (NULL if unanswered)
    correct_answer VARCHAR(1) NOT NULL,  -- Expected correct answer from question
    is_correct BOOLEAN,  -- TRUE if selected_answer == correct_answer
    marks_obtained INT DEFAULT 0,  -- Marks awarded for this question
    
    -- Metadata
    time_taken_seconds INT,  -- Time spent on this question (optional)
    attempt_number INT DEFAULT 1,  -- 1 for first attempt, 2+ if revision allowed
    status ENUM('ATTEMPTED', 'SKIPPED', 'REVIEWED') DEFAULT 'ATTEMPTED',
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_exam (exam_id),
    INDEX idx_student (student_id),
    INDEX idx_question (question_id),
    INDEX idx_exam_student (exam_id, student_id),
    INDEX idx_is_correct (is_correct)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- TABLE: exam_results (OPTIONAL - for STEP 6)
-- ===================================
-- Aggregated results per student per exam
CREATE TABLE IF NOT EXISTS exam_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    student_id INT NOT NULL,
    
    -- Score metrics
    total_questions INT NOT NULL,
    attempted_questions INT,
    correct_answers INT DEFAULT 0,
    wrong_answers INT DEFAULT 0,
    total_marks INT NOT NULL,
    marks_obtained INT DEFAULT 0,
    percentage DECIMAL(5, 2),  -- Percentage score
    grade VARCHAR(2),  -- A, B, C, D, F (optional)
    
    -- Timing
    total_time_minutes INT,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Metadata
    status ENUM('IN_PROGRESS', 'SUBMITTED', 'EVALUATED') DEFAULT 'SUBMITTED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    
    -- Indexes & Constraints
    UNIQUE KEY unique_exam_student (exam_id, student_id),
    INDEX idx_exam (exam_id),
    INDEX idx_student (student_id),
    INDEX idx_percentage (percentage),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- SAMPLE DATA (for testing)
-- ===================================

-- Sample Exam 1: Class 10, Mathematics
-- Note: Replace exam_id, class_id, subject_id, created_by with actual IDs from your database
-- INSERT INTO exams (exam_name, class_id, subject_id, question_count, total_marks, difficulty_level, created_by, status)
-- VALUES ('Mathematics Mid-Term Exam', 1, 1, 15, 15, 'MIXED', 2, 'PUBLISHED');

-- Sample Exam Questions
-- INSERT INTO exam_questions_map (exam_id, question_id, question_sequence, question_marks)
-- VALUES (1, 5, 1, 1), (1, 6, 2, 1), (1, 7, 3, 1);

-- Sample Student Answers
-- INSERT INTO exam_answers (exam_id, student_id, question_id, selected_answer, correct_answer, is_correct, marks_obtained)
-- VALUES 
-- (1, 1, 5, 'A', 'A', TRUE, 1),
-- (1, 1, 6, 'B', 'C', FALSE, 0),
-- (1, 1, 7, 'D', 'D', TRUE, 1);

-- ===================================
-- USEFUL QUERIES
-- ===================================

-- Get all exams created by a teacher
-- SELECT * FROM exams WHERE created_by = ? AND status = 'PUBLISHED';

-- Get exam details with question count
-- SELECT e.*, COUNT(eq.question_id) as actual_question_count 
-- FROM exams e
-- LEFT JOIN exam_questions_map eq ON e.exam_id = eq.exam_id
-- WHERE e.exam_id = ?
-- GROUP BY e.exam_id;

-- Get questions for an exam (in order)
-- SELECT q.*, eq.question_sequence, eq.question_marks
-- FROM exam_questions_map eq
-- JOIN questions q ON eq.question_id = q.question_id
-- WHERE eq.exam_id = ?
-- ORDER BY eq.question_sequence;

-- Get student exam result summary
-- SELECT 
--     e.exam_name,
--     s.student_name,
--     COUNT(ea.answer_id) as total_questions,
--     SUM(CASE WHEN ea.is_correct THEN 1 ELSE 0 END) as correct_answers,
--     SUM(CASE WHEN ea.is_correct THEN ea.marks_obtained ELSE 0 END) as total_marks_obtained,
--     e.total_marks as total_marks_possible,
--     ROUND(SUM(CASE WHEN ea.is_correct THEN ea.marks_obtained ELSE 0 END) * 100 / e.total_marks, 2) as percentage
-- FROM exam_answers ea
-- JOIN exams e ON ea.exam_id = e.exam_id
-- JOIN students s ON ea.student_id = s.student_id
-- WHERE ea.exam_id = ? AND ea.student_id = ?
-- GROUP BY ea.exam_id, ea.student_id;
