-- =====================================================
-- STEP 3: CLASS DATA MANAGEMENT
-- =====================================================
-- Create/Update Class table for managing class records
-- Teachers can add, modify class data
-- =====================================================

-- CLASS TABLE (Already created in STEP1_STUDENT_DATA.sql)
-- This script is for reference and additional setup if needed

-- If classes table doesn't exist, create it:
CREATE TABLE IF NOT EXISTS classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(100) NOT NULL,
    grade INT,
    section VARCHAR(50),
    school_id INT NOT NULL,
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_school (school_id),
    INDEX idx_grade (grade),
    INDEX idx_status (status),
    UNIQUE KEY unique_class_per_school (class_name, school_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Sample data for testing (optional)
-- =====================================================
-- INSERT INTO classes (class_name, grade, section, school_id, status)
-- VALUES ('Class 10-A', 10, 'A', 1, 'ACTIVE');
-- INSERT INTO classes (class_name, grade, section, school_id, status)
-- VALUES ('Class 10-B', 10, 'B', 1, 'ACTIVE');
-- INSERT INTO classes (class_name, grade, section, school_id, status)
-- VALUES ('Class 12-A', 12, 'A', 1, 'ACTIVE');
