-- =====================================================
-- SCHOOL EXAM MANAGEMENT SYSTEM - DATABASE SETUP SCRIPT
-- =====================================================
-- Run this script in MySQL to create the complete database
-- Command: mysql -u root -p < DATABASE_SETUP.sql
-- Or copy-paste into MySQL Workbench
-- =====================================================

DROP DATABASE IF EXISTS school_exam_system;
CREATE DATABASE school_exam_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE school_exam_system;

-- =====================================================
-- USERS TABLE (Central user management)
-- =====================================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'TEACHER', 'STUDENT', 'PARENT') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- SCHOOLS TABLE
-- =====================================================
CREATE TABLE schools (
    school_id INT PRIMARY KEY AUTO_INCREMENT,
    school_name VARCHAR(255) NOT NULL,
    school_code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pin_code VARCHAR(10),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    principal_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_school_code (school_code),
    INDEX idx_city_state (city, state)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- ADMIN USERS TABLE
-- =====================================================
CREATE TABLE admin_users (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    school_id INT NOT NULL,
    admin_name VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    INDEX idx_school (school_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- CLASSES TABLE
-- =====================================================
CREATE TABLE classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    class_name VARCHAR(50) NOT NULL,
    class_section VARCHAR(10),
    total_students INT DEFAULT 0,
    class_teacher_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    UNIQUE KEY unique_class (school_id, class_name, class_section),
    INDEX idx_school (school_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- SUBJECTS TABLE
-- =====================================================
CREATE TABLE subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    class_id INT NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    subject_code VARCHAR(50),
    marks DECIMAL(5,2) DEFAULT 100.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    UNIQUE KEY unique_subject (class_id, subject_name),
    INDEX idx_school (school_id),
    INDEX idx_class (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TOPICS TABLE
-- =====================================================
CREATE TABLE topics (
    topic_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_id INT NOT NULL,
    class_id INT NOT NULL,
    topic_name VARCHAR(255) NOT NULL,
    topic_description TEXT,
    difficulty_level ENUM('EASY', 'MEDIUM', 'HARD') DEFAULT 'MEDIUM',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    UNIQUE KEY unique_topic (subject_id, topic_name),
    INDEX idx_subject (subject_id),
    INDEX idx_class (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- QUESTIONS TABLE
-- =====================================================
CREATE TABLE questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    topic_id INT NOT NULL,
    subject_id INT NOT NULL,
    school_id INT NOT NULL,
    question_text LONGTEXT NOT NULL,
    question_type ENUM('MCQ', 'SHORT_ANSWER', 'LONG_ANSWER', 'TRUE_FALSE') DEFAULT 'MCQ',
    marks DECIMAL(5,2) DEFAULT 1.00,
    difficulty ENUM('EASY', 'MEDIUM', 'HARD') DEFAULT 'MEDIUM',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (topic_id) REFERENCES topics(topic_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    INDEX idx_topic (topic_id),
    INDEX idx_subject (subject_id),
    INDEX idx_school (school_id),
    INDEX idx_difficulty (difficulty)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- QUESTION OPTIONS TABLE
-- =====================================================
CREATE TABLE question_options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text TEXT NOT NULL,
    option_key CHAR(1),
    is_correct BOOLEAN DEFAULT FALSE,
    sequence INT,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    INDEX idx_question (question_id),
    INDEX idx_is_correct (is_correct)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TEACHERS TABLE
-- =====================================================
CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    school_id INT NOT NULL,
    teacher_name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(50),
    qualification VARCHAR(100),
    specialization VARCHAR(100),
    date_of_joining DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    INDEX idx_school (school_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- TEACHER SUBJECTS TABLE
-- =====================================================
CREATE TABLE teacher_subjects (
    teacher_subject_id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    class_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    UNIQUE KEY unique_assignment (teacher_id, subject_id, class_id),
    INDEX idx_teacher (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STUDENTS TABLE
-- =====================================================
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    school_id INT NOT NULL,
    class_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    unique_student_id VARCHAR(50) UNIQUE NOT NULL,
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    roll_number INT,
    father_name VARCHAR(100),
    mother_name VARCHAR(100),
    contact_number VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    INDEX idx_school (school_id),
    INDEX idx_class (class_id),
    INDEX idx_unique_id (unique_student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- PARENTS TABLE
-- =====================================================
CREATE TABLE parents (
    parent_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    school_id INT NOT NULL,
    parent_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(50),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    INDEX idx_school (school_id),
    INDEX idx_contact_email (contact_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STUDENT PARENT MAPPING TABLE
-- =====================================================
CREATE TABLE student_parent_mapping (
    mapping_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    parent_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES parents(parent_id) ON DELETE CASCADE,
    UNIQUE KEY unique_mapping (student_id, parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- EXAM PAPERS TABLE
-- =====================================================
CREATE TABLE exam_papers (
    exam_paper_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_name VARCHAR(255) NOT NULL,
    exam_date DATE,
    exam_duration_minutes INT DEFAULT 60,
    total_questions INT DEFAULT 15,
    total_marks DECIMAL(5,2),
    created_by INT,
    status ENUM('DRAFT', 'PUBLISHED', 'ARCHIVED') DEFAULT 'DRAFT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id),
    INDEX idx_school (school_id),
    INDEX idx_class (class_id),
    INDEX idx_subject (subject_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- EXAM PAPER QUESTIONS TABLE
-- =====================================================
CREATE TABLE exam_paper_questions (
    exam_question_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_paper_id INT NOT NULL,
    question_id INT NOT NULL,
    question_order INT,
    marks DECIMAL(5,2),
    FOREIGN KEY (exam_paper_id) REFERENCES exam_papers(exam_paper_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    INDEX idx_exam_paper (exam_paper_id),
    INDEX idx_question (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- EXAM RESULTS TABLE
-- =====================================================
CREATE TABLE exam_results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_paper_id INT NOT NULL,
    student_id INT NOT NULL,
    school_id INT NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    total_marks DECIMAL(5,2),
    obtained_marks DECIMAL(5,2),
    percentage DECIMAL(5,2),
    grade VARCHAR(5),
    exam_status ENUM('NOT_STARTED', 'IN_PROGRESS', 'SUBMITTED', 'EVALUATED') DEFAULT 'NOT_STARTED',
    exam_start_time TIMESTAMP NULL,
    exam_end_time TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_paper_id) REFERENCES exam_papers(exam_paper_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_exam_paper (exam_paper_id),
    INDEX idx_school (school_id),
    INDEX idx_status (exam_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STUDENT ANSWERS TABLE
-- =====================================================
CREATE TABLE student_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    result_id INT NOT NULL,
    exam_paper_id INT NOT NULL,
    question_id INT NOT NULL,
    student_id INT NOT NULL,
    selected_option_id INT,
    selected_answer_text TEXT,
    is_correct BOOLEAN,
    marks_obtained DECIMAL(5,2) DEFAULT 0,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (result_id) REFERENCES exam_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_paper_id) REFERENCES exam_papers(exam_paper_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (selected_option_id) REFERENCES question_options(option_id),
    INDEX idx_result (result_id),
    INDEX idx_student (student_id),
    INDEX idx_is_correct (is_correct)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- SCORING CONFIGURATION TABLE
-- =====================================================
CREATE TABLE scoring_config (
    config_id INT PRIMARY KEY AUTO_INCREMENT,
    school_id INT NOT NULL,
    grade_value VARCHAR(5),
    min_percentage DECIMAL(5,2),
    max_percentage DECIMAL(5,2),
    points INT,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    INDEX idx_school (school_id),
    UNIQUE KEY unique_grade (school_id, grade_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- AUDIT LOG TABLE
-- =====================================================
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    school_id INT,
    action_type VARCHAR(100),
    action_description TEXT,
    affected_entity VARCHAR(100),
    affected_entity_id INT,
    old_value TEXT,
    new_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_school (school_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- INSERT DEFAULT SCORING CONFIGURATION
-- =====================================================
-- This is a sample configuration. Modify as needed for your school

-- First, create a test school to get school_id
INSERT INTO schools (school_name, school_code, address, city, state, pin_code, contact_phone, contact_email, principal_name)
VALUES ('Test School', 'TEST001', 'Test Address', 'Test City', 'Test State', '123456', '9876543210', 'test@school.com', 'Test Principal');

-- Get the school_id (will be 1 for fresh database)
-- Then insert scoring config:
INSERT INTO scoring_config (school_id, grade_value, min_percentage, max_percentage, points, description) 
VALUES 
(1, 'A+', 90.00, 100.00, 10, 'Excellent'),
(1, 'A', 80.00, 89.99, 9, 'Very Good'),
(1, 'B', 70.00, 79.99, 8, 'Good'),
(1, 'C', 60.00, 69.99, 7, 'Satisfactory'),
(1, 'D', 50.00, 59.99, 6, 'Pass'),
(1, 'F', 0.00, 49.99, 0, 'Fail');

-- =====================================================
-- CREATE VIEWS FOR ANALYTICS
-- =====================================================

CREATE VIEW student_results_view AS
SELECT 
    er.result_id,
    s.student_id,
    s.unique_student_id,
    s.student_name,
    cl.class_name,
    cl.class_section,
    su.subject_name,
    ep.exam_name,
    ep.exam_date,
    er.total_marks,
    er.obtained_marks,
    er.percentage,
    er.grade,
    er.exam_status
FROM exam_results er
JOIN students s ON er.student_id = s.student_id
JOIN classes cl ON er.class_id = cl.class_id
JOIN subjects su ON er.subject_id = su.subject_id
JOIN exam_papers ep ON er.exam_paper_id = ep.exam_paper_id
ORDER BY er.created_at DESC;

CREATE VIEW class_performance_view AS
SELECT 
    cl.class_id,
    cl.class_name,
    su.subject_name,
    COUNT(DISTINCT s.student_id) as total_students,
    ROUND(AVG(er.percentage), 2) as avg_percentage,
    MIN(er.percentage) as min_percentage,
    MAX(er.percentage) as max_percentage,
    COUNT(CASE WHEN er.exam_status = 'EVALUATED' THEN 1 END) as evaluated_count
FROM classes cl
LEFT JOIN students s ON cl.class_id = s.class_id
LEFT JOIN exam_results er ON s.student_id = er.student_id
LEFT JOIN subjects su ON er.subject_id = su.subject_id
GROUP BY cl.class_id, su.subject_id
ORDER BY cl.class_id, su.subject_name;

-- =====================================================
-- DATABASE SETUP COMPLETE
-- =====================================================
-- Tables: 18
-- Views: 2
-- Ready for application deployment
-- =====================================================

SHOW TABLES;
SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'school_exam_system';
