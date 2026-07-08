-- Test data for login functionality
-- Add demo users for testing

-- School must exist first
INSERT IGNORE INTO schools VALUES (1, 'Demo School', 'Demo Address', 'Demo City', 'Demo State', '12345');

-- Add demo users (teachers and admin)
INSERT IGNORE INTO users (user_id, username, password, email, role, first_name, last_name, school_id, status) 
VALUES 
(1, 'admin1', 'admin123', 'admin@school.com', 'ADMIN', 'Admin', 'User', 1, 'ACTIVE'),
(2, 'teacher1', 'password123', 'teacher1@school.com', 'TEACHER', 'John', 'Doe', 1, 'ACTIVE'),
(3, 'teacher2', 'password123', 'teacher2@school.com', 'TEACHER', 'Jane', 'Smith', 1, 'ACTIVE');
