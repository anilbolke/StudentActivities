-- =====================================================
-- STEP 4: QUESTION UPLOAD & MANAGEMENT
-- =====================================================
-- Create tables for questions and chapters
-- Admin can upload questions class-wise in bulk
-- =====================================================

-- =====================================================
-- CHAPTERS TABLE (was created in STEP 2, now complete)
-- Organize questions within subjects
-- =====================================================
-- CREATE TABLE IF NOT EXISTS chapters (
--     chapter_id INT PRIMARY KEY AUTO_INCREMENT,
--     chapter_name VARCHAR(150) NOT NULL,
--     subject_id INT NOT NULL,
--     chapter_number INT,
--     description VARCHAR(500),
--     status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
--     INDEX idx_subject (subject_id),
--     INDEX idx_status (status)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- QUESTIONS TABLE
-- Store exam questions with all metadata
-- =====================================================
CREATE TABLE IF NOT EXISTS questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    question_text VARCHAR(1000) NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    chapter_id INT,
    difficulty_level ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL,
    marks INT DEFAULT 1,
    
    -- Answer options (Multiple Choice)
    option_a VARCHAR(500),
    option_b VARCHAR(500),
    option_c VARCHAR(500),
    option_d VARCHAR(500),
    correct_answer VARCHAR(1) NOT NULL COMMENT 'A, B, C, or D',
    
    -- Metadata
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    -- Indexes for faster searches
    INDEX idx_class (class_id),
    INDEX idx_subject (subject_id),
    INDEX idx_chapter (chapter_id),
    INDEX idx_difficulty (difficulty_level),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- EXAM QUESTIONS MAP TABLE (optional - for flexibility)
-- Links questions to specific exams
-- =====================================================
CREATE TABLE IF NOT EXISTS exam_questions (
    exam_question_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    question_id INT NOT NULL,
    question_sequence INT,
    
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    UNIQUE KEY unique_exam_question (exam_id, question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Sample data for testing
-- =====================================================
-- INSERT INTO questions (question_text, class_id, subject_id, chapter_id, difficulty_level, marks, option_a, option_b, option_c, option_d, correct_answer, created_by)
-- VALUES ('Who wrote Romeo and Juliet?', 10, 1, 1, 'EASY', 1, 'William Shakespeare', 'Christopher Marlowe', 'Ben Jonson', 'John Webster', 'A', 1);
