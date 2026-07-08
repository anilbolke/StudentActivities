# Deployment Scripts - School Exam Management System

This directory contains automated deployment scripts for the School Exam Management System.

## Available Scripts

### 1. **DEPLOY.bat** (Recommended - Full Deployment)
**Complete one-step deployment of the entire system**

What it does:
- ✅ Executes SQL database updates (adds SCHOOL_ADMIN role)
- ✅ Compiles Java files (UserDAO enhancements)
- ✅ Restarts Apache Tomcat
- ✅ Verifies all steps succeed

Usage:
```batch
DEPLOY.bat
```

**Requirements:**
- MySQL running and accessible
- MySQL credentials configured (see script - default: root/root)
- Java Development Kit (JDK) installed
- Apache Tomcat installed

**Time:** ~30-45 seconds

---

### 2. **SETUP_DB.bat** (Database Only)
**Execute SQL database updates without compilation or restart**

What it does:
- ✅ Executes SCHOOL_ADMIN_SETUP.sql
- ✅ Adds SCHOOL_ADMIN role to database
- ✅ Creates sample schooladmin1 user

Usage:
```batch
SETUP_DB.bat
```

**When to use:**
- After modifying database schema
- To re-initialize the database
- For database-only updates

---

### 3. **COMPILE.bat** (Compilation Only)
**Compile Java files without database or Tomcat changes**

What it does:
- ✅ Compiles UserDAO.java and dependencies
- ✅ Outputs to bin/ directory

Usage:
```batch
COMPILE.bat
```

**When to use:**
- After modifying Java source code
- To update compiled classes without restart
- For development/testing builds

---

## Quick Start (Choose One)

### Option A: Complete Setup (Recommended for first deployment)
```batch
DEPLOY.bat
```
This handles everything in one step.

### Option B: Step-by-Step Setup
```batch
SETUP_DB.bat      # 1. Set up database
COMPILE.bat       # 2. Compile code
```
Then manually restart Tomcat or use:
```bash
cd C:\Program Files\Apache Software Foundation\Tomcat 9.0\bin
shutdown.bat
startup.bat
```

### Option C: Development Workflow
```batch
COMPILE.bat       # After code changes
# Tomcat auto-reloads changes
```

---

## Configuration

### MySQL Credentials
Edit **DEPLOY.bat** and **SETUP_DB.bat** to set your MySQL credentials:

```batch
set "MYSQL_HOST=localhost"    # MySQL server address
set "MYSQL_USER=root"         # MySQL username
set "MYSQL_PASS=root"         # MySQL password
set "MYSQL_DB=exam_db"        # Database name
```

### Tomcat Path
Edit **DEPLOY.bat** to set Tomcat location if different:

```batch
set "TOMCAT_HOME=C:\Program Files\Apache Software Foundation\Tomcat 9.0"
```

---

## Demo Credentials

After deployment, login with:

**School Admin:**
- Username: `schooladmin1`
- Password: `school123`
- URL: `http://localhost:8080/StudentActivities/login.jsp`

**Teacher:**
- Username: `teacher1`
- Password: `password123`
- URL: `http://localhost:8080/StudentActivities/login.jsp`

---

## Troubleshooting

### Error: "MySQL command not found"
**Solution:** Add MySQL bin directory to PATH
1. MySQL is usually at: `C:\Program Files\MySQL\MySQL Server 8.0\bin`
2. Add to system PATH variable

### Error: "javac command not found"
**Solution:** Install JDK (Java Development Kit) or add to PATH
1. Download JDK from oracle.com
2. Add JDK bin directory to system PATH

### Error: "Tomcat not found"
**Solution:** Update TOMCAT_HOME in DEPLOY.bat
1. Find your Tomcat installation
2. Update the path in the script

### Error: "Database connection failed"
**Solution:** Verify MySQL settings
1. Check MySQL is running
2. Verify credentials in the script
3. Ensure database `exam_db` exists
4. Check MySQL user has required permissions

---

## Files Modified During Deployment

When you run DEPLOY.bat, the following actions occur:

**Database Changes:**
- `SCHOOL_ADMIN_SETUP.sql` - Executed
  - Adds SCHOOL_ADMIN role enum
  - Inserts schooladmin1 user

**Code Compilation:**
- `src/com/school/exam/dao/UserDAO.java` - Compiled
  - New methods: getTeachersBySchool, updateUser, deleteUser, etc.
  - Output: `bin/com/school/exam/dao/UserDAO.class`

**Server Restart:**
- Apache Tomcat - Stopped and started
  - Reloads all WAR files
  - Applies new compiled classes
  - Clears session cache

---

## Verification Checklist

After deployment, verify everything works:

- [ ] Script completed without errors
- [ ] MySQL reported successful connection
- [ ] Java compilation showed 0 errors
- [ ] Tomcat restarted successfully
- [ ] Wait 10-15 seconds for Tomcat to fully start
- [ ] Open http://localhost:8080/StudentActivities/
- [ ] Login with schooladmin1 / school123
- [ ] Can see School Admin Dashboard
- [ ] Login with teacher1 / password123
- [ ] Can see Teacher Exam Dashboard

---

## Support

**For issues or questions:**
1. Check the script output for error messages
2. Review troubleshooting section above
3. Verify all prerequisites are installed
4. Check Tomcat logs: `TOMCAT_HOME\logs\catalina.out`
5. Check MySQL logs for connection issues

---

## System Overview

**School Admin Tier:**
- Manage teachers (Add, Edit, Delete)
- View school statistics
- Dashboard: schoolAdminDashboard.jsp

**Teacher Tier:**
- Create and manage exams
- Upload bulk questions
- View student results
- Dashboard: dashboard.jsp

---

*Last Updated: 2026-03-28*
*School Exam Management System v1.0*
