-- School Admin System - Database Update Script
-- Execute this script to add SCHOOL_ADMIN role and create sample school admin user

-- ===================================================
-- Step 1: Update users table role enum to include SCHOOL_ADMIN
-- ===================================================
ALTER TABLE users MODIFY role ENUM('ADMIN', 'TEACHER', 'STUDENT', 'SCHOOL_ADMIN');

-- ===================================================
-- Step 2: Insert sample SCHOOL_ADMIN user
-- This admin manages teachers for School ID 1 (Demo School)
-- ===================================================
INSERT INTO users (username, password, email, role, first_name, last_name, school_id, status)
VALUES ('schooladmin1', 'school123', 'admin@school1.com', 'SCHOOL_ADMIN', 'School', 'Admin', 1, 'ACTIVE');

-- ===================================================
-- Verification Queries
-- ===================================================
-- Check if role enum was updated
-- SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'role';

-- Check school admin user was created
-- SELECT * FROM users WHERE role = 'SCHOOL_ADMIN';

-- Check all users in Demo School
-- SELECT user_id, username, first_name, last_name, role, status FROM users WHERE school_id = 1;

-- ===================================================
-- SUCCESS: School Admin System is ready!
-- ===================================================
-- Login credentials:
-- Username: schooladmin1
-- Password: school123
-- Role: SCHOOL_ADMIN
-- School: Demo School (ID: 1)
