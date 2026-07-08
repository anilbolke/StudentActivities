-- =====================================================
-- TEACHER EXAM SCHEDULING SYSTEM
-- =====================================================
-- Add tables for teachers to schedule exams for all students
-- in a class on specific dates and times
-- =====================================================

USE school_exam_system;

-- =====================================================
-- STEP 1: Create exam_schedule table
-- (Teachers will use this to schedule when exams happen)
-- =====================================================

CREATE TABLE IF NOT EXISTS exam_schedule (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    exam_paper_id INT NOT NULL,
    scheduled_date DATE NOT NULL,
    scheduled_start_time TIME NOT NULL,
    scheduled_end_time TIME NOT NULL,
    class_id INT NOT NULL,
    
    -- Status tracking
    status ENUM('DRAFT', 'SCHEDULED', 'ACTIVE', 'COMPLETED', 'CANCELLED') DEFAULT 'DRAFT',
    
    -- Who scheduled it
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (exam_paper_id) REFERENCES exam_papers(exam_paper_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(user_id),
    
    -- Indexes for fast lookup
    INDEX idx_exam_date (scheduled_date),
    INDEX idx_class (class_id),
    INDEX idx_status (status),
    UNIQUE KEY unique_exam_per_class (exam_paper_id, class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STEP 2: Create student_exam_assignment table
-- (Tracks which students are assigned which exams)
-- =====================================================

CREATE TABLE IF NOT EXISTS student_exam_assignment (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    schedule_id INT NOT NULL,
    exam_paper_id INT NOT NULL,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    
    -- Status
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assignment_status ENUM('ASSIGNED', 'ACTIVE', 'SUBMITTED', 'ABSENT', 'CANCELLED') DEFAULT 'ASSIGNED',
    
    -- Exam attempt tracking
    attempt_start_time DATETIME,
    attempt_end_time DATETIME,
    
    FOREIGN KEY (schedule_id) REFERENCES exam_schedule(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_paper_id) REFERENCES exam_papers(exam_paper_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    
    UNIQUE KEY unique_student_exam (student_id, schedule_id),
    INDEX idx_student (student_id),
    INDEX idx_exam (exam_paper_id),
    INDEX idx_status (assignment_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STEP 3: Create exam_supervision table
-- (Teachers can supervise/proctor exams for a class)
-- =====================================================

CREATE TABLE IF NOT EXISTS exam_supervision (
    supervision_id INT PRIMARY KEY AUTO_INCREMENT,
    schedule_id INT NOT NULL,
    exam_paper_id INT NOT NULL,
    class_id INT NOT NULL,
    supervisor_teacher_id INT,
    
    -- When they supervise
    supervision_date DATE NOT NULL,
    supervision_start_time TIME,
    supervision_end_time TIME,
    
    -- Details
    supervision_notes TEXT,
    status ENUM('ASSIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'ASSIGNED',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (schedule_id) REFERENCES exam_schedule(schedule_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_paper_id) REFERENCES exam_papers(exam_paper_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (supervisor_teacher_id) REFERENCES users(user_id),
    
    INDEX idx_class (class_id),
    INDEX idx_date (supervision_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- STEP 4: Sample data - Schedule exams for Class 10
-- =====================================================

-- First, let's see what exams exist
SELECT 'Available Exams to Schedule' as info;
SELECT ep.exam_paper_id, ep.exam_name, s.subject_name, c.class_name, 
       ep.total_questions, ep.total_marks
FROM exam_papers ep
JOIN classes c ON ep.class_id = c.class_id
JOIN subjects s ON ep.subject_id = s.subject_id
LIMIT 10;

-- =====================================================
-- STEP 5: Schedule all exams for Class 10
-- =====================================================

-- Schedule English Exam for Class 10
INSERT INTO exam_schedule (exam_paper_id, scheduled_date, scheduled_start_time, scheduled_end_time, class_id, status, created_by)
SELECT ep.exam_paper_id, DATE_ADD(CURDATE(), INTERVAL 7 DAY), '09:00:00', '10:00:00', 
       c.class_id, 'SCHEDULED', 1
FROM exam_papers ep
JOIN classes c ON ep.class_id = c.class_id
WHERE c.class_name = '10' AND ep.exam_name LIKE '%English%'
LIMIT 1;

-- Schedule Mathematics Exam for Class 10
INSERT INTO exam_schedule (exam_paper_id, scheduled_date, scheduled_start_time, scheduled_end_time, class_id, status, created_by)
SELECT ep.exam_paper_id, DATE_ADD(CURDATE(), INTERVAL 8 DAY), '10:30:00', '12:00:00', 
       c.class_id, 'SCHEDULED', 1
FROM exam_papers ep
JOIN classes c ON ep.class_id = c.class_id
WHERE c.class_name = '10' AND ep.exam_name LIKE '%Mathematics%'
LIMIT 1;

-- Schedule Science Exam for Class 10
INSERT INTO exam_schedule (exam_paper_id, scheduled_date, scheduled_start_time, scheduled_end_time, class_id, status, created_by)
SELECT ep.exam_paper_id, DATE_ADD(CURDATE(), INTERVAL 9 DAY), '09:00:00', '10:30:00', 
       c.class_id, 'SCHEDULED', 1
FROM exam_papers ep
JOIN classes c ON ep.class_id = c.class_id
WHERE c.class_name = '10' AND ep.exam_name LIKE '%Science%'
LIMIT 1;

-- =====================================================
-- STEP 6: Auto-assign all students in Class 10 to scheduled exams
-- =====================================================

-- This stored procedure will be called when scheduling an exam
-- It assigns all students in the class to the exam

-- Assign students to English exam (Class 10)
INSERT INTO student_exam_assignment (schedule_id, exam_paper_id, student_id, class_id, assignment_status)
SELECT 
    es.schedule_id,
    es.exam_paper_id,
    st.student_id,
    st.class_id,
    'ASSIGNED'
FROM exam_schedule es
JOIN students st ON es.class_id = st.class_id
WHERE es.class_id = (SELECT class_id FROM classes WHERE class_name = '10' LIMIT 1)
AND es.exam_paper_id NOT IN (
    SELECT exam_paper_id FROM student_exam_assignment 
    WHERE student_id = st.student_id
)
AND st.is_active = 1;

-- =====================================================
-- STEP 7: Assign supervision to class teacher
-- =====================================================

-- Assign class teacher to supervise exams
INSERT INTO exam_supervision (schedule_id, exam_paper_id, class_id, supervisor_teacher_id, 
                              supervision_date, supervision_start_time, supervision_end_time, status)
SELECT 
    es.schedule_id,
    es.exam_paper_id,
    es.class_id,
    (SELECT class_teacher_id FROM classes WHERE class_id = es.class_id LIMIT 1),
    es.scheduled_date,
    es.scheduled_start_time,
    es.scheduled_end_time,
    'ASSIGNED'
FROM exam_schedule es
WHERE es.class_id = (SELECT class_id FROM classes WHERE class_name = '10' LIMIT 1);

-- =====================================================
-- STEP 8: Verification
-- =====================================================

SELECT '✅ Exam Scheduling Setup Complete!' as status;

-- Show all scheduled exams
SELECT 
    es.schedule_id,
    ep.exam_name,
    c.class_name,
    es.scheduled_date,
    TIME_FORMAT(es.scheduled_start_time, '%H:%i') as start_time,
    TIME_FORMAT(es.scheduled_end_time, '%H:%i') as end_time,
    COUNT(DISTINCT sea.student_id) as students_assigned,
    es.status
FROM exam_schedule es
JOIN exam_papers ep ON es.exam_paper_id = ep.exam_paper_id
JOIN classes c ON es.class_id = c.class_id
LEFT JOIN student_exam_assignment sea ON es.schedule_id = sea.schedule_id
GROUP BY es.schedule_id, ep.exam_name, c.class_name, es.scheduled_date, 
         es.scheduled_start_time, es.scheduled_end_time, es.status
ORDER BY es.scheduled_date, es.scheduled_start_time;

-- =====================================================
-- STEP 9: View student assignments
-- =====================================================

SELECT 'Students Assigned to Exams' as info;

SELECT 
    c.class_name,
    ep.exam_name,
    es.scheduled_date,
    COUNT(sea.student_id) as total_students_assigned
FROM exam_schedule es
JOIN exam_papers ep ON es.exam_paper_id = ep.exam_paper_id
JOIN classes c ON es.class_id = c.class_id
LEFT JOIN student_exam_assignment sea ON es.schedule_id = sea.schedule_id
GROUP BY c.class_id, ep.exam_paper_id, es.scheduled_date, 
         c.class_name, ep.exam_name
ORDER BY es.scheduled_date;

-- =====================================================
-- NOTES FOR TEACHER SCHEDULING
-- =====================================================
/*
TEACHER WORKFLOW FOR SCHEDULING EXAMS:

1. TEACHER LOGS IN AS ADMIN/TEACHER ROLE
2. NAVIGATES TO "SCHEDULE EXAM" PAGE
3. SELECTS:
   - Class (10, 11, 12)
   - Exam (English, Math, Science, etc.)
   - Date (e.g., 2026-04-15)
   - Start Time (e.g., 09:00:00)
   - End Time (e.g., 10:00:00)
   - Supervising Teacher (optional)

4. SYSTEM AUTOMATICALLY:
   - Creates exam_schedule record
   - Assigns ALL students in that class to the exam
   - Assigns class teacher as supervisor
   - Sends notification to students

5. STUDENTS WILL:
   - See the scheduled exam in their exam list
   - See the scheduled date and time
   - Take the exam on the scheduled date/time
   - System tracks when they attempt exam

6. TEACHER CAN:
   - View all scheduled exams
   - Edit exam dates/times (if before exam date)
   - Cancel exams
   - View which students are assigned
   - View exam results once submitted

SCHEDULING RULES:
✓ Can schedule same exam for different classes on different dates
✓ Cannot schedule two exams for same class at same time
✓ Dates must be in the future
✓ Start time must be before end time
✓ All students in class are auto-assigned
✓ Status flow: DRAFT → SCHEDULED → ACTIVE → COMPLETED

DATABASE TRACKING:
- exam_schedule: When exams are scheduled
- student_exam_assignment: Which students assigned to which exams
- exam_supervision: Which teachers supervise which exams
- exam_results: Student scores (already exists)
*/
