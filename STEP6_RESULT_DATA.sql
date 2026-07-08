-- STEP 6: RESULT GENERATION & ANALYSIS - DATABASE SCHEMA
-- Tables and indexes for exam result storage, aggregation, and analytics

-- ===================================
-- TABLE: exam_results (Main Results Table)
-- ===================================
-- Stores aggregated exam results per student per exam
-- This table is denormalized from exam_answers for performance
CREATE TABLE IF NOT EXISTS exam_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    student_id INT NOT NULL,
    
    -- Question metrics
    total_questions INT NOT NULL,
    attempted_questions INT,
    correct_answers INT DEFAULT 0,
    wrong_answers INT DEFAULT 0,
    skipped_questions INT DEFAULT 0,
    
    -- Score metrics
    total_marks INT NOT NULL,
    marks_obtained INT DEFAULT 0,
    percentage DECIMAL(5, 2),
    grade VARCHAR(2),  -- A, B, C, D, F
    
    -- Timing metrics
    total_time_minutes INT,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Status
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
    INDEX idx_grade (grade),
    INDEX idx_status (status),
    INDEX idx_completed_at (completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- TABLE: chapter_performance
-- ===================================
-- Stores per-chapter accuracy metrics for each student exam
-- Helps identify weak chapters
CREATE TABLE IF NOT EXISTS chapter_performance (
    performance_id INT PRIMARY KEY AUTO_INCREMENT,
    result_id INT NOT NULL,
    chapter_id INT NOT NULL,
    
    -- Chapter metrics
    total_questions INT NOT NULL,
    correct_answers INT DEFAULT 0,
    wrong_answers INT DEFAULT 0,
    accuracy DECIMAL(5, 2),  -- Percentage
    marks_obtained INT DEFAULT 0,
    total_marks INT NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (result_id) REFERENCES exam_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE RESTRICT,
    
    -- Indexes
    INDEX idx_result (result_id),
    INDEX idx_chapter (chapter_id),
    INDEX idx_accuracy (accuracy)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- TABLE: class_performance_cache
-- ===================================
-- Cached class-wide statistics for performance dashboard
-- Recalculated whenever new results are added
CREATE TABLE IF NOT EXISTS class_performance_cache (
    cache_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    class_id INT NOT NULL,
    
    -- Summary statistics
    total_students INT DEFAULT 0,
    students_submitted INT DEFAULT 0,
    
    -- Score statistics
    average_percentage DECIMAL(5, 2),
    highest_percentage DECIMAL(5, 2),
    lowest_percentage DECIMAL(5, 2),
    median_percentage DECIMAL(5, 2),
    
    -- Grade distribution
    count_grade_a INT DEFAULT 0,
    count_grade_b INT DEFAULT 0,
    count_grade_c INT DEFAULT 0,
    count_grade_d INT DEFAULT 0,
    count_grade_f INT DEFAULT 0,
    
    -- Performance metrics
    average_marks DECIMAL(7, 2),
    total_marks_distributed INT,
    
    last_calculated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    
    -- Indexes
    UNIQUE KEY unique_exam_class (exam_id, class_id),
    INDEX idx_exam (exam_id),
    INDEX idx_class (class_id),
    INDEX idx_last_calculated (last_calculated)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- TABLE: subject_performance_cache
-- ===================================
-- Cached subject-wide statistics across all exams
CREATE TABLE IF NOT EXISTS subject_performance_cache (
    cache_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_id INT NOT NULL,
    class_id INT NOT NULL,
    
    -- Summary
    total_exams INT DEFAULT 0,
    total_attempts INT DEFAULT 0,
    
    -- Score statistics
    average_percentage DECIMAL(5, 2),
    highest_percentage DECIMAL(5, 2),
    lowest_percentage DECIMAL(5, 2),
    
    -- Chapter analysis
    strongest_chapter_id INT,
    strongest_chapter_accuracy DECIMAL(5, 2),
    weakest_chapter_id INT,
    weakest_chapter_accuracy DECIMAL(5, 2),
    
    -- Trend
    improvement_trend DECIMAL(5, 2),  -- Negative = improving, Positive = declining
    
    last_calculated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (strongest_chapter_id) REFERENCES chapters(chapter_id) ON DELETE SET NULL,
    FOREIGN KEY (weakest_chapter_id) REFERENCES chapters(chapter_id) ON DELETE SET NULL,
    
    -- Indexes
    UNIQUE KEY unique_subject_class (subject_id, class_id),
    INDEX idx_subject (subject_id),
    INDEX idx_class (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================
-- STORED PROCEDURE: Calculate Grade
-- ===================================
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS sp_calculate_grade(
    IN p_percentage DECIMAL(5, 2),
    OUT p_grade VARCHAR(2)
)
BEGIN
    IF p_percentage >= 90 THEN
        SET p_grade = 'A';
    ELSEIF p_percentage >= 80 THEN
        SET p_grade = 'B';
    ELSEIF p_percentage >= 70 THEN
        SET p_grade = 'C';
    ELSEIF p_percentage >= 60 THEN
        SET p_grade = 'D';
    ELSE
        SET p_grade = 'F';
    END IF;
END$$

DELIMITER ;

-- ===================================
-- STORED PROCEDURE: Calculate Result
-- ===================================
-- Calculates and stores result for a student-exam pair
DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS sp_calculate_exam_result(
    IN p_exam_id INT,
    IN p_student_id INT
)
BEGIN
    DECLARE v_total_questions INT;
    DECLARE v_correct INT;
    DECLARE v_wrong INT;
    DECLARE v_attempted INT;
    DECLARE v_total_marks INT;
    DECLARE v_marks_obtained INT;
    DECLARE v_percentage DECIMAL(5, 2);
    DECLARE v_grade VARCHAR(2);
    DECLARE v_result_id INT;
    
    -- Get total questions in exam
    SELECT COUNT(*) INTO v_total_questions
    FROM exam_questions_map
    WHERE exam_id = p_exam_id;
    
    -- Get total marks for exam
    SELECT total_marks INTO v_total_marks
    FROM exams
    WHERE exam_id = p_exam_id;
    
    -- Calculate metrics from exam_answers
    SELECT 
        COUNT(*) as total_attempted,
        SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct_count,
        SUM(CASE WHEN is_correct THEN 0 ELSE 1 END) as wrong_count,
        SUM(CASE WHEN is_correct THEN marks_obtained ELSE 0 END) as marks
    INTO v_attempted, v_correct, v_wrong, v_marks_obtained
    FROM exam_answers
    WHERE exam_id = p_exam_id AND student_id = p_student_id;
    
    -- Handle NULL values
    SET v_attempted = COALESCE(v_attempted, 0);
    SET v_correct = COALESCE(v_correct, 0);
    SET v_wrong = COALESCE(v_wrong, 0);
    SET v_marks_obtained = COALESCE(v_marks_obtained, 0);
    
    -- Calculate percentage
    IF v_total_marks > 0 THEN
        SET v_percentage = (v_marks_obtained * 100.0) / v_total_marks;
    ELSE
        SET v_percentage = 0;
    END IF;
    
    -- Calculate grade
    CALL sp_calculate_grade(v_percentage, v_grade);
    
    -- Insert or update result
    INSERT INTO exam_results (
        exam_id, student_id, total_questions, attempted_questions,
        correct_answers, wrong_answers, skipped_questions,
        total_marks, marks_obtained, percentage, grade, status
    ) VALUES (
        p_exam_id, p_student_id, v_total_questions, v_attempted,
        v_correct, v_wrong, (v_total_questions - v_attempted),
        v_total_marks, v_marks_obtained, v_percentage, v_grade, 'SUBMITTED'
    )
    ON DUPLICATE KEY UPDATE
        attempted_questions = v_attempted,
        correct_answers = v_correct,
        wrong_answers = v_wrong,
        skipped_questions = (v_total_questions - v_attempted),
        marks_obtained = v_marks_obtained,
        percentage = v_percentage,
        grade = v_grade,
        completed_at = NOW(),
        updated_at = NOW();
        
END$$

DELIMITER ;

-- ===================================
-- USEFUL QUERIES
-- ===================================

-- Get result for student
-- SELECT * FROM exam_results WHERE exam_id = ? AND student_id = ?;

-- Get all results for exam (class results)
-- SELECT er.*, s.student_name
-- FROM exam_results er
-- JOIN students s ON er.student_id = s.student_id
-- WHERE er.exam_id = ?
-- ORDER BY er.percentage DESC;

-- Get chapter performance for a result
-- SELECT cp.*, c.chapter_name
-- FROM chapter_performance cp
-- JOIN chapters c ON cp.chapter_id = c.chapter_id
-- WHERE cp.result_id = ?
-- ORDER BY cp.accuracy DESC;

-- Get class statistics
-- SELECT 
--     COUNT(*) as total_students,
--     AVG(percentage) as avg_percentage,
--     MAX(percentage) as highest,
--     MIN(percentage) as lowest,
--     COUNT(CASE WHEN grade='A' THEN 1 END) as count_a,
--     COUNT(CASE WHEN grade='B' THEN 1 END) as count_b,
--     COUNT(CASE WHEN grade='C' THEN 1 END) as count_c,
--     COUNT(CASE WHEN grade='D' THEN 1 END) as count_d,
--     COUNT(CASE WHEN grade='F' THEN 1 END) as count_f
-- FROM exam_results
-- WHERE exam_id = ?;

-- Get subject performance
-- SELECT 
--     s.subject_name,
--     AVG(er.percentage) as avg_percentage,
--     COUNT(DISTINCT er.exam_id) as total_exams
-- FROM exam_results er
-- JOIN exams e ON er.exam_id = e.exam_id
-- JOIN subjects s ON e.subject_id = s.subject_id
-- WHERE e.class_id = ?
-- GROUP BY s.subject_id;

-- Get chapter accuracy across all students
-- SELECT 
--     c.chapter_name,
--     AVG(cp.accuracy) as avg_accuracy,
--     COUNT(DISTINCT cp.result_id) as student_count
-- FROM chapter_performance cp
-- JOIN chapters c ON cp.chapter_id = c.chapter_id
-- WHERE cp.result_id IN (
--     SELECT result_id FROM exam_results WHERE exam_id = ?
-- )
-- GROUP BY cp.chapter_id
-- ORDER BY avg_accuracy;

-- Get top performers
-- SELECT student_name, percentage, grade
-- FROM exam_results er
-- JOIN students s ON er.student_id = s.student_id
-- WHERE er.exam_id = ?
-- ORDER BY percentage DESC
-- LIMIT 5;

-- Get struggling students
-- SELECT student_name, percentage, grade
-- FROM exam_results er
-- JOIN students s ON er.student_id = s.student_id
-- WHERE er.exam_id = ? AND percentage < 60
-- ORDER BY percentage ASC;
