╔══════════════════════════════════════════════════════════════════════════╗
║          CREATING CLASS TABLE - STEP BY STEP INSTRUCTIONS               ║
╚══════════════════════════════════════════════════════════════════════════╝

## 🔧 PROBLEM

The database table `class` doesn't exist. The ClassDAO needs this table to
store and retrieve class information.

## ✅ SOLUTION

I've created a SQL script: **CREATE_CLASS_TABLE.sql**

Execute this script in your MySQL database to create the table.

═════════════════════════════════════════════════════════════════════════════

## 📝 SQL SCRIPT CONTENT

```sql
USE school_exam_system;

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
  FOREIGN KEY (`schoolId`) REFERENCES `school` (`schoolId`),
  FOREIGN KEY (`classTeacherId`) REFERENCES `user` (`userId`),
  
  INDEX `idx_school_id` (`schoolId`),
  INDEX `idx_class_name` (`className`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

═════════════════════════════════════════════════════════════════════════════

## 🚀 HOW TO RUN THE SCRIPT

### Option 1: Using MySQL Command Line
```
1. Open Command Prompt
2. Connect to MySQL:
   mysql -u root -p school_exam_system
3. Enter your MySQL password
4. Run the SQL commands:
   paste the CREATE TABLE statement above
5. Press Enter
6. Type: SELECT * FROM class;
   (should return empty result - table created ✅)
```

### Option 2: Using MySQL Workbench
```
1. Open MySQL Workbench
2. Connect to your database
3. Create new SQL tab (File → New Query Tab)
4. Copy and paste the CREATE TABLE statement
5. Press Execute (lightning bolt icon)
6. Check for success message ✅
```

### Option 3: Using phpMyAdmin
```
1. Go to phpMyAdmin (usually http://localhost/phpmyadmin)
2. Select database: school_exam_system
3. Click "SQL" tab at top
4. Paste the CREATE TABLE statement
5. Click "Go" button
6. Table created! ✅
```

═════════════════════════════════════════════════════════════════════════════

## 📊 TABLE STRUCTURE

The script creates a table with these columns:

| Column | Type | Purpose |
|--------|------|---------|
| classId | INT AUTO_INCREMENT | Primary key, unique ID |
| schoolId | INT | Links to school table |
| className | VARCHAR(50) | Class name (10, 11, 12, etc.) |
| classSection | VARCHAR(10) | Section (A, B, All, etc.) |
| totalStudents | INT | Number of students |
| classTeacherId | INT | Links to teacher user |
| createdAt | TIMESTAMP | When class was created |
| updatedAt | TIMESTAMP | When class was last updated |

═════════════════════════════════════════════════════════════════════════════

## ✅ VERIFY TABLE WAS CREATED

After running the script, verify the table exists:

```sql
SELECT * FROM class;
```

**Expected Result:** Empty table with all columns visible (0 rows)

If you see the table structure with 8 columns, the table was created successfully! ✅

═════════════════════════════════════════════════════════════════════════════

## 🔗 ADD SAMPLE DATA (OPTIONAL)

The script includes commented-out sample data. To add it:

```sql
INSERT INTO `class` (`schoolId`, `className`, `classSection`, `totalStudents`) VALUES
(1, '10', 'A', 50),
(1, '10', 'B', 48),
(1, '11', 'All', 60),
(1, '12', 'A', 45),
(1, '12', 'B', 52);
```

Run this if you want test data. Otherwise, leave it commented out.

═════════════════════════════════════════════════════════════════════════════

## 🚀 AFTER CREATING THE TABLE

Once the table is created:

1. Restart Tomcat:
   ```
   cd C:\Apache\Tomcat\bin
   catalina.bat stop
   catalina.bat start
   ```

2. Test the feature:
   ```
   Browser: http://localhost:8080/StudentActivities/classList.jsp
   Expected: See "Add New Class" button ✅
   ```

3. Create your first class:
   - Click "➕ Add New Class"
   - Enter: Class 10, Section A, 50 students
   - Click "➕ Add Class"
   - Class appears in table ✅

═════════════════════════════════════════════════════════════════════════════

## ❓ TROUBLESHOOTING

**Error: "Unknown database 'school_exam_system'"**
→ Create the database first:
   CREATE DATABASE school_exam_system;

**Error: "Cannot add or update a child row"**
→ The schoolId doesn't exist in school table
→ Use schoolId that exists in your school table (usually 1)

**Error: "Table already exists"**
→ That's fine! The script uses IF NOT EXISTS
→ Just proceed

**Error: "Access denied for user"**
→ You don't have permission to create tables
→ Ask your database administrator to run the script

═════════════════════════════════════════════════════════════════════════════

## ✅ WHAT'S NEXT

After the table is created:

1. Restart Tomcat
2. Go to /classList.jsp
3. Create your first class
4. Upload exam questions
5. Feature is now fully working! ✅

═════════════════════════════════════════════════════════════════════════════

## 📋 FILE LOCATION

SQL Script: CREATE_CLASS_TABLE.sql

This file is in your project root directory.

═════════════════════════════════════════════════════════════════════════════

Ready to create the table? Execute the CREATE_CLASS_TABLE.sql script and 
report back when done! 🚀

═════════════════════════════════════════════════════════════════════════════
