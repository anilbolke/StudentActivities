-- ===========================================================
-- ALTER Schools Table - Add Missing Columns
-- ===========================================================
-- This script safely adds 9 missing columns to the existing
-- schools table while preserving all existing data

-- ===========================================================
-- Step 1: Add Missing Columns
-- ===========================================================

ALTER TABLE schools ADD COLUMN school_code VARCHAR(50) UNIQUE AFTER school_id;

ALTER TABLE schools ADD COLUMN state VARCHAR(100) AFTER city;

ALTER TABLE schools ADD COLUMN pincode VARCHAR(10) AFTER state;

ALTER TABLE schools ADD COLUMN phone VARCHAR(20) AFTER email;

ALTER TABLE schools ADD COLUMN principal_name VARCHAR(100) AFTER phone;

ALTER TABLE schools ADD COLUMN principal_contact VARCHAR(20) AFTER principal_name;

ALTER TABLE schools ADD COLUMN registration_number VARCHAR(50) AFTER principal_contact;

ALTER TABLE schools ADD COLUMN status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' AFTER registration_number;

ALTER TABLE schools ADD COLUMN established_year INT AFTER status;

-- ===========================================================
-- Step 2: Generate school_code from school_id if not exists
-- ===========================================================
-- This creates codes like: SCHOOL-001, SCHOOL-002, etc.

UPDATE schools 
SET school_code = CONCAT('SCHOOL-', LPAD(school_id, 3, '0')) 
WHERE school_code IS NULL;

-- ===========================================================
-- Step 3: Set default status to ACTIVE for all schools
-- ===========================================================

UPDATE schools 
SET status = 'ACTIVE' 
WHERE status IS NULL;

-- ===========================================================
-- Step 4: Add Indexes for Performance
-- ===========================================================

ALTER TABLE schools ADD INDEX idx_school_code (school_code);
ALTER TABLE schools ADD INDEX idx_city (city);
ALTER TABLE schools ADD INDEX idx_status (status);

-- ===========================================================
-- Verification Queries (Uncomment to check)
-- ===========================================================

-- DESC schools;
-- SELECT school_id, school_code, school_name, city, state, status FROM schools;
-- SHOW CREATE TABLE schools;

-- ===========================================================
-- SUCCESS: Schools table updated with all required columns!
-- ===========================================================
-- The table now has:
-- • All original columns (preserved)
-- • 9 new columns added
-- • Auto-generated school_code for existing schools
-- • All existing data is safe
-- • Performance indexes added
-- • Ready for admin system
-- ===========================================================
