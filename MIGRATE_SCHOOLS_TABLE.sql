-- ===========================================================
-- Schools Table Migration - Add Missing Columns
-- ===========================================================
-- This script adds the columns needed for the admin school management system
-- If columns already exist, they will be skipped

-- Check current table structure first
-- DESC schools;

-- ===========================================================
-- ALTER TABLE to add missing columns
-- ===========================================================

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS school_code VARCHAR(50) UNIQUE AFTER school_id;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS address TEXT AFTER school_code;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS city VARCHAR(100) AFTER address;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS state VARCHAR(100) AFTER city;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS pincode VARCHAR(10) AFTER state;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS phone VARCHAR(20) AFTER pincode;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS email VARCHAR(100) AFTER phone;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS principal_name VARCHAR(100) AFTER email;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS principal_contact VARCHAR(20) AFTER principal_name;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS registration_number VARCHAR(50) AFTER principal_contact;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' AFTER registration_number;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS established_year INT AFTER status;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER established_year;

ALTER TABLE schools
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- ===========================================================
-- Verify the changes
-- ===========================================================
-- SELECT * FROM schools LIMIT 1;
-- DESC schools;

-- ===========================================================
-- SUCCESS: Schools table is now ready for the admin system!
-- ===========================================================
