-- =====================================================
-- STEP 2: SUBJECT DATA MANAGEMENT
-- =====================================================
-- Create Subject table for managing subject records
-- Teachers can add, modify subject data
-- =====================================================

CREATE TABLE IF NOT EXISTS subjects (
    subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(150) NOT NULL,
    school_id INT NOT NULL,
    description VARCHAR(500),
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    -- Indexes for faster searches
    INDEX idx_school (school_id),
    INDEX idx_status (status),
    UNIQUE KEY unique_subject_per_school (subject_name, school_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Create CHAPTERS table (dependency for subjects)
-- =====================================================
CREATE TABLE IF NOT EXISTS chapters (
    chapter_id INT PRIMARY KEY AUTO_INCREMENT,
    chapter_name VARCHAR(150) NOT NULL,
    subject_id INT NOT NULL,
    chapter_number INT,
    description VARCHAR(500),
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_subject (subject_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Sample data for testing
-- =====================================================
-- INSERT INTO subjects (subject_name, school_id, description, status, created_by)
-- VALUES ('Mathematics', 1, 'Comprehensive Mathematics curriculum', 'ACTIVE', 1);
-- INSERT INTO subjects (subject_name, school_id, description, status, created_by)
-- VALUES ('English', 1, 'English Language and Literature', 'ACTIVE', 1);
-- INSERT INTO subjects (subject_name, school_id, description, status, created_by)
-- VALUES ('Science', 1, 'Physics, Chemistry, Biology', 'ACTIVE', 1);
