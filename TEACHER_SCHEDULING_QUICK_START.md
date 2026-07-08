# 📅 Teacher Exam Scheduling - Quick Start (2 Minutes)

## What is This?

A system for **teachers to schedule exams for ALL students in a class on specific dates and times**.

```
Teacher schedules:
  Exam: English Mid-Term
  Class: 10
  Date: 2026-04-15
  Time: 09:00-10:00
  ↓
System automatically:
  Assigns all 45 students in Class 10
  ↓
Students see:
  "English Mid-Term scheduled for Apr 15 09:00"
  ↓
On Apr 15 at 09:00:
  Exam becomes available for students to take
```

---

## Files Created (3)

### **1. SQL Script** 
**File:** `SETUP_TEACHER_EXAM_SCHEDULING.sql`

Creates 3 database tables:
- `exam_schedule` - When exams are scheduled
- `student_exam_assignment` - Which students assigned
- `exam_supervision` - Which teacher supervises

### **2. Java Servlet**
**File:** `TeacherExamSchedulingServlet.java`

Handles:
- Schedule exam for class
- Get scheduled exams
- Get students for preview
- Update/Cancel schedules

### **3. JSP Page**
**File:** `schedule-exam.jsp`

Teacher interface with:
- Form to schedule exam
- Date/time pickers
- Preview of students
- List of scheduled exams

---

## 3-Step Implementation

### **STEP 1: Create Database Tables (1 min)**

```bash
cd C:\Users\Admin\StudentActivities\StudentActivities
mysql -u root -p school_exam_system < SETUP_TEACHER_EXAM_SCHEDULING.sql
```

### **STEP 2: Build & Deploy (3 min)**

**Eclipse:**
```
Right-click project → Clean → Build Complete
Right-click project → Export → WAR file
Location: C:\Apache\Tomcat\webapps\StudentActivities.war
```

**Tomcat (Admin Command Prompt):**
```bash
cd C:\Apache\Tomcat\bin
catalina.bat stop
(wait 10 sec)
catalina.bat start
(wait 30 sec)
```

### **STEP 3: Test (2 min)**

```
1. Login as Teacher/Admin
2. Go to: http://localhost:8080/StudentActivities/views/teacher/schedule-exam.jsp
3. Fill form:
   - Exam: English Mid-Term
   - Class: 10
   - Date: Pick a date (7+ days from now)
   - Start: 09:00
   - End: 10:00
4. Click "Preview" → See students
5. Click "Schedule Exam"
6. See: "✅ Exam scheduled successfully! 45 students assigned"
```

---

## What Happens

### **Behind the Scenes**

When teacher clicks "Schedule Exam":

1. System creates `exam_schedule` record
2. Fetches all students in Class 10
3. Creates `student_exam_assignment` for each student (45 records)
4. Assigns teacher as `exam_supervision`
5. Returns success message

### **Student Experience**

**Before scheduled date:**
```
Take Exam Page:
  English Mid-Term (Available Apr 15)
  Mathematics Mid-Term (Available Apr 16)
  Science Mid-Term (Available Apr 17)
```

**On scheduled date & time:**
```
English Mid-Term becomes clickable:
  Student clicks "Start Exam"
  Exam page loads with 60-minute timer
  Student answers questions
  Clicks "Submit"
  Sees results with score, percentage, grade
```

---

## 📊 How It Works

```
Teacher Form Input:
┌─────────────────┐
│ Exam: English   │
│ Class: 10       │
│ Date: 2026-4-15 │
│ Time: 9-10am    │
└─────────────────┘
        ↓
  Database Update:
┌──────────────────────┐
│ exam_schedule        │
│ ├─ schedule_id: 1    │
│ ├─ exam_paper_id: 1  │
│ ├─ class_id: 1       │
│ ├─ scheduled_date: * │
│ └─ status: SCHEDULED │
└──────────────────────┘
        ↓
┌──────────────────────────────┐
│ student_exam_assignment (45) │
│ ├─ schedule_id: 1            │
│ ├─ student_id: 1,2,3...      │
│ ├─ exam_paper_id: 1          │
│ └─ status: ASSIGNED          │
└──────────────────────────────┘
        ↓
Students see exam scheduled
```

---

## Key Features

✅ **Auto-Assignment**
- All students in class auto-assigned
- No manual selection needed
- Batch processing (efficient)

✅ **Date/Time Validation**
- Dates must be in future
- Start time before end time
- Duration auto-calculated

✅ **Preview Before Scheduling**
- Shows exam name
- Shows class name
- Shows date/time
- Lists all students to be assigned

✅ **Manage Scheduled Exams**
- View all scheduled exams
- Edit date/time
- Cancel schedules
- Track student assignments

---

## Database Tables Created

### exam_schedule
```
schedule_id ........... Unique ID
exam_paper_id ......... Which exam (1-6)
scheduled_date ........ When to take exam
scheduled_start_time .. Start time (09:00)
scheduled_end_time .... End time (10:00)
class_id .............. Which class (1-3)
status ................ SCHEDULED, ACTIVE, COMPLETED
created_by ............ Admin/Teacher ID
```

### student_exam_assignment
```
assignment_id ......... Unique ID
schedule_id ........... Links to exam_schedule
exam_paper_id ......... Which exam
student_id ............ Which student
class_id .............. Which class
assignment_status ..... ASSIGNED, ACTIVE, SUBMITTED
```

### exam_supervision
```
supervision_id ........ Unique ID
schedule_id ........... Links to exam_schedule
supervisor_teacher_id . Which teacher supervises
supervision_date ...... Supervision date
supervision_start_time . Supervision start
supervision_end_time .. Supervision end
status ................ ASSIGNED, IN_PROGRESS, COMPLETED
```

---

## API Endpoints

### Schedule an Exam
```
POST /api/teacher/schedule-exam?action=schedule

Input:
  examPaperId=1&classId=1&scheduledDate=2026-04-15&startTime=09:00&endTime=10:00

Output:
  { "status": "success", "studentsAssigned": 45 }
```

### Get Scheduled Exams
```
GET /api/teacher/schedule-exam?action=get-scheduled-exams

Output:
  { "status": "success", "exams": [...] }
```

### Get Students for Preview
```
GET /api/teacher/schedule-exam?action=get-students-for-schedule&classId=1

Output:
  { "status": "success", "totalStudents": 45, "students": [...] }
```

---

## Troubleshooting

### Problem: "Failed to schedule exam"

**Check:**
- Is date in the future? (Cannot schedule for past dates)
- Is start time before end time?
- Does exam exist? (1-6)
- Does class exist? (1-3)

### Problem: Students not showing in preview

**Check:**
```sql
SELECT COUNT(*) FROM students WHERE class_id = 1 AND is_active = 1;
-- Should return > 0
```

### Problem: Scheduled exams not visible

**Check:**
```sql
SELECT COUNT(*) FROM exam_schedule WHERE status = 'SCHEDULED';
-- Should return > 0
```

---

## Files Location

| File | Path |
|------|------|
| SQL Script | `StudentActivities/SETUP_TEACHER_EXAM_SCHEDULING.sql` |
| Servlet | `StudentActivities/src/com/school/exam/servlet/TeacherExamSchedulingServlet.java` |
| JSP Page | `StudentActivities/WebContent/views/teacher/schedule-exam.jsp` |
| Guide | `StudentActivities/TEACHER_EXAM_SCHEDULING_GUIDE.md` |

---

## Quick Commands

```bash
# Run SQL script
mysql -u root -p school_exam_system < SETUP_TEACHER_EXAM_SCHEDULING.sql

# Verify tables created
mysql -u root -p school_exam_system -e "SHOW TABLES LIKE '%exam%';"

# Check scheduled exams
mysql -u root -p school_exam_system -e "SELECT * FROM exam_schedule;"

# Stop/Start Tomcat
cd C:\Apache\Tomcat\bin
catalina.bat stop
catalina.bat start
```

---

## ⏱️ Time Estimate

| Task | Time |
|------|------|
| Run SQL script | 1 min |
| Build in Eclipse | 2 min |
| Deploy & restart | 3 min |
| Test in browser | 2 min |
| **TOTAL** | **~10 min** |

---

## Status: ✅ Ready to Deploy

All files created and documented. Just:

1. Run SQL script
2. Build in Eclipse
3. Deploy to Tomcat
4. Test in browser

---

## Next Steps

1. Execute: `SETUP_TEACHER_EXAM_SCHEDULING.sql`
2. Add 2 files to project (servlet + JSP)
3. Build & Deploy
4. Login as teacher
5. Try scheduling an exam!

**That's it! Teachers can now schedule exams for all students at once.**

