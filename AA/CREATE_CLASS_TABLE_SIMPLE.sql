-- ============================================================================
-- CREATE CLASS TABLE FOR SCHOOL_EXAM_SYSTEM (WITHOUT FOREIGN KEY CONSTRAINTS)
-- ============================================================================
-- This version removes foreign key constraints in case the referenced tables don't exist
-- You can enable foreign keys after verifying both tables exist

USE school_exam_system;

-- Create the class table (simplified version without foreign keys)
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
  INDEX `idx_school_id` (`schoolId`),
  INDEX `idx_class_name` (`className`),
  INDEX `idx_teacher_id` (`classTeacherId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- OPTIONAL: Add foreign key constraints if school and user tables exist
-- (Uncomment if needed after verifying table names)
-- ============================================================================

/*
ALTER TABLE `class` 
ADD CONSTRAINT `fk_class_school` 
FOREIGN KEY (`schoolId`) REFERENCES `school` (`schoolId`) ON DELETE CASCADE;

ALTER TABLE `class` 
ADD CONSTRAINT `fk_class_teacher` 
FOREIGN KEY (`classTeacherId`) REFERENCES `user` (`userId`) ON DELETE SET NULL;
*/

-- ============================================================================
-- OPTIONAL: Insert sample data
-- ============================================================================

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
-- SELECT * FROM `class`;
-- ============================================================================
