-- =====================================================
-- STEP 1: STUDENT DATA MANAGEMENT
-- =====================================================
-- Create Student table for managing student records
-- Teachers can add, modify student data
-- =====================================================

-- Create the schools table first (if not exists)
CREATE TABLE IF NOT EXISTS schools (
    school_id INT PRIMARY KEY AUTO_INCREMENT,
    school_name VARCHAR(255) NOT NULL UNIQUE,
    address VARCHAR(500),
    city VARCHAR(100),
    contact_number VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create the users table (if not exists) - for teachers and admins
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role ENUM('ADMIN', 'TEACHER', 'STUDENT') DEFAULT 'TEACHER',
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    school_id INT,
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE SET NULL,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_school (school_id),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STEP 1: Create STUDENTS table
-- =====================================================
CREATE TABLE IF NOT EXISTS students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(150) NOT NULL,
    roll_number VARCHAR(50) NOT NULL,
    school_id INT NOT NULL,
    class_id INT,
    email VARCHAR(100),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    address VARCHAR(500),
    city VARCHAR(100),
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    father_name VARCHAR(150),
    father_contact VARCHAR(20),
    mother_name VARCHAR(150),
    mother_contact VARCHAR(20),
    enrollment_date DATE DEFAULT CURDATE(),
    status ENUM('ACTIVE', 'INACTIVE', 'PASSED', 'FAILED') DEFAULT 'ACTIVE',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (school_id) REFERENCES schools(school_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    
    -- Indexes for faster searches
    INDEX idx_school (school_id),
    INDEX idx_class (class_id),
    INDEX idx_roll_number (roll_number),
    INDEX idx_email (email),
    INDEX idx_status (status),
    UNIQUE KEY unique_roll_per_school (roll_number, school_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Optional: Create CLASSES table (dependency for students)
-- =====================================================
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
    UNIQUE KEY unique_class_per_school (class_name, school_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- Sample data for testing
-- =====================================================
-- INSERT INTO schools (school_name, address, city, contact_number, email)
-- VALUES ('Springfield High School', '123 Main St', 'Springfield', '555-1234', 'info@springfield.edu');

-- INSERT INTO classes (class_name, grade, section, school_id)
-- VALUES ('Class 10-A', 10, 'A', 1);
