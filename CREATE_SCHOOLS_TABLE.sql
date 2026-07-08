-- ===========================================================
-- CREATE NEW Schools Table - Complete Schema
-- ===========================================================
-- This script drops the old schools table and creates a new one
-- with all required columns for the admin school management system

-- ===========================================================
-- Step 1: Drop existing table (BACKUP FIRST if you have data!)
-- ===========================================================
DROP TABLE IF EXISTS schools;

-- ===========================================================
-- Step 2: Create new schools table with complete schema
-- ===========================================================
CREATE TABLE schools (
    school_id INT PRIMARY KEY AUTO_INCREMENT,
    school_name VARCHAR(255) NOT NULL,
    school_code VARCHAR(50) NOT NULL UNIQUE,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(100),
    principal_name VARCHAR(100),
    principal_contact VARCHAR(20),
    registration_number VARCHAR(50),
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    established_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    INDEX idx_school_code (school_code),
    INDEX idx_city (city),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===========================================================
-- Step 3: Insert sample data
-- ===========================================================
INSERT INTO schools (
    school_name, 
    school_code, 
    address, 
    city, 
    state, 
    pincode, 
    phone, 
    email, 
    principal_name, 
    principal_contact, 
    registration_number, 
    status, 
    established_year
) VALUES 
(
    'Demo School',
    'DEMO-001',
    '123 Main Street',
    'New Delhi',
    'Delhi',
    '110001',
    '9876543210',
    'info@demoschool.com',
    'Mr. Rajesh Kumar',
    '9111234567',
    'REG-2010-001',
    'ACTIVE',
    2010
),
(
    'City Public School',
    'CPS-001',
    '456 Park Avenue',
    'Mumbai',
    'Maharashtra',
    '400001',
    '9988776655',
    'contact@cityschool.com',
    'Mrs. Priya Sharma',
    '9222345678',
    'REG-2015-002',
    'ACTIVE',
    2015
);

-- ===========================================================
-- Verification
-- ===========================================================
-- SELECT * FROM schools;
-- DESC schools;

-- ===========================================================
-- SUCCESS: New schools table created with sample data!
-- ===========================================================
-- The table now has:
-- • school_id (AUTO_INCREMENT PRIMARY KEY)
-- • school_code (UNIQUE - required by admin system)
-- • All required columns (address, city, state, phone, email, principal info, etc.)
-- • Timestamps (created_at, updated_at)
-- • Status field (ACTIVE/INACTIVE)
-- • Proper indexes for performance
-- • Sample data for testing
-- ===========================================================
