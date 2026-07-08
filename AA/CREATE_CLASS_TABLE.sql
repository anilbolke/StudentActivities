-- ============================================================================
-- CREATE CLASS TABLE FOR SCHOOL_EXAM_SYSTEM
-- ============================================================================
-- Run this SQL script in your MySQL database to create the 'class' table

USE school_exam_system;

-- Create the class table
CREATE TABLE IF NOT EXISTS `class` (
  `classId` INT NOT NULL AUTO_INCREMENT,
  `schoolId` INT NOT NULL,
  `className` VARCHAR(50) NOT NULL,
  `classSection` VARCHAR(10),
  `totalStudents` INT DEFAULT 0,
  `classTeacherId` INT,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`classId`),
  FOREIGN KEY (`schoolId`) REFERENCES `school` (`schoolId`) ON DELETE CASCADE,
  FOREIGN KEY (`classTeacherId`) REFERENCES `user` (`userId`) ON DELETE SET NULL,
  
  INDEX `idx_school_id` (`schoolId`),
  INDEX `idx_class_name` (`className`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- OPTIONAL: Insert sample data if needed
-- ============================================================================
-- Uncomment below to add sample classes (adjust schoolId if needed)

/*
INSERT INTO `class` (`schoolId`, `className`, `classSection`, `totalStudents`) VALUES
(1, '10', 'A', 50),
(1, '10', 'B', 48),
(1, '11', 'All', 60),
(1, '12', 'A', 45),
(1, '12', 'B', 52);
*/

-- ============================================================================
-- VERIFY: Check the table was created
-- ============================================================================
-- Run this to verify the table exists:
-- SELECT * FROM `class`;
-- ============================================================================
