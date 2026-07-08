# ⚡ QUICK START GUIDE - Implementation Phase 1

**Last Updated:** March 4, 2026  
**Phase:** 1 (Foundation & Core Infrastructure)  
**Status:** ✅ Code Ready | ⏳ Waiting for Database Setup

---

## 🚀 EXECUTE IN THIS ORDER

### Step 1: Setup MySQL Database (5 minutes)

**Location:** `C:\Users\Admin\StudentActivities\StudentActivities\DATABASE_SETUP.sql`

**Option A: Command Line**
```bash
# Open Command Prompt / PowerShell
mysql -u root -p < C:\Users\Admin\StudentActivities\StudentActivities\DATABASE_SETUP.sql
# Enter your MySQL root password when prompted
```

**Option B: MySQL Workbench**
```
1. Open MySQL Workbench
2. File → Open SQL Script
3. Select: C:\Users\Admin\StudentActivities\StudentActivities\DATABASE_SETUP.sql
4. Click: Execute (Ctrl+Shift+Enter)
5. Verify: Check "Schemas" panel - should see "school_exam_system"
```

**Option C: Command Line Direct**
```bash
mysql -h localhost -u root -p school_exam_system < DATABASE_SETUP.sql
```

**Verification:**
```sql
USE school_exam_system;
SHOW TABLES;
-- Should display 18 tables
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'school_exam_system';
-- Should return: 18
```

---

### Step 2: Add Required JAR Files (10 minutes)

**Location:** `C:\Users\Admin\StudentActivities\StudentActivities\WebContent\WEB-INF\lib\`

**Download and add these files:**

1. **MySQL JDBC Driver** (Required)
   - Download: `mysql-connector-java-8.0.28.jar`
   - From: https://dev.mysql.com/downloads/connector/j/
   - Size: ~2.2 MB

2. **GSON Library** (Required - for JSON processing)
   - Download: `gson-2.8.9.jar`
   - From: https://github.com/google/gson/releases
   - Size: ~248 KB

3. **Commons FileUpload** (Required - for file uploads)
   - Download: `commons-fileupload-1.3.jar`
   - From: https://commons.apache.org/proper/commons-fileupload/
   - Size: ~186 KB

4. **Commons IO** (Required - dependency for FileUpload)
   - Download: `commons-io-2.6.jar`
   - From: https://commons.apache.org/proper/commons-io/
   - Size: ~215 KB

**After downloading:**
- Copy all JAR files to: `WebContent/WEB-INF/lib/`
- Verify files are present

---

### Step 3: Update Database Credentials (2 minutes)

**File:** `src/com/school/exam/util/DatabaseConnection.java`

**Lines to update (around line 20-25):**
```java
// BEFORE:
private static final String DB_URL = "jdbc:mysql://localhost:3306/school_exam_system";
private static final String DB_USER = "root";
private static final String DB_PASSWORD = "";

// AFTER (if different):
private static final String DB_URL = "jdbc:mysql://your-host:3306/school_exam_system";
private static final String DB_USER = "your_username";
private static final String DB_PASSWORD = "your_password";
```

**Save the file.**

---

### Step 4: Compile Java Code (5 minutes)

**Option A: Using Command Line**
```bash
# Navigate to project directory
cd C:\Users\Admin\StudentActivities\StudentActivities

# Create build directory if not exists
mkdir build

# Compile all Java files
javac -d build -sourcepath src -cp "WebContent/WEB-INF/lib/*" src/com/school/exam/**/*.java

# Verify compilation
# Should create .class files in build/ directory without errors
```

**Option B: Using Eclipse IDE**
```
1. Open Eclipse
2. File → Import → Existing Projects into Workspace
3. Select: C:\Users\Admin\StudentActivities\StudentActivities
4. Click Finish
5. Right-click project → Properties
6. Java Build Path → Libraries → Add JARs
7. Select all JAR files from WebContent/WEB-INF/lib/
8. Project → Clean → Build All
```

**Option C: Using IntelliJ IDEA**
```
1. Open IntelliJ IDEA
2. File → Open → Select project directory
3. Configure JDK (File → Project Structure → Project SDK)
4. Add libraries from WebContent/WEB-INF/lib/
5. Build → Build Project
```

---

### Step 5: Deploy to Tomcat (10 minutes)

**Option A: Using Tomcat Manager**
```
1. Navigate to: http://localhost:8080/manager/html
2. Username: tomcat / Password: tomcat (or your credentials)
3. Under "Deploy" section:
   - Context Path: /school-exam-system
   - XML Configuration File URL: [leave blank]
   - WAR or Directory URL: file:///C:/Users/Admin/StudentActivities/StudentActivities/WebContent
4. Click "Deploy"
```

**Option B: Manual Deployment**
```
1. Locate Tomcat directory: C:\Program Files\Apache Software Foundation\Tomcat 10.0\ (example)
2. Copy project to: C:\...\Tomcat\webapps\school-exam-system\
3. Restart Tomcat service
```

**Option C: Using Tomcat Eclipse Plugin**
```
1. In Eclipse: Preferences → Server → Runtime Environments
2. Add Tomcat 9+ as runtime
3. Right-click project → Run As → Run on Server
4. Select Tomcat server
5. Click Finish
```

---

### Step 6: Verify Deployment (5 minutes)

**Test Application Access:**

1. **Open Browser:**
   ```
   http://localhost:8080/school-exam-system/
   ```

2. **Expected Response:**
   - Should see login page or index page
   - OR browser console should show JSON error (not HTTP 404)

3. **Test Database Connection:**
   ```
   Create a test servlet or use curl:
   curl http://localhost:8080/school-exam-system/api/auth/test
   ```

4. **Check Tomcat Logs:**
   ```
   C:\...\Tomcat\logs\catalina.out
   Look for: "Database connection established"
   ```

---

## 🔍 TROUBLESHOOTING

### Issue: "ClassNotFoundException: com.mysql.jdbc.Driver"
**Solution:**
- Verify `mysql-connector-java-8.0.28.jar` is in `WebContent/WEB-INF/lib/`
- Restart Tomcat
- Clear browser cache

### Issue: "Connection refused"
**Solution:**
- Verify MySQL is running: `mysql -u root -p -e "SELECT 1;"`
- Check database credentials in DatabaseConnection.java
- Verify database exists: `SHOW DATABASES;`

### Issue: "SQLException: No database selected"
**Solution:**
- Run DATABASE_SETUP.sql script
- Verify database was created: `USE school_exam_system; SHOW TABLES;`

### Issue: "404 Not Found"
**Solution:**
- Verify deployment path is correct
- Check web.xml servlet mappings
- Restart Tomcat
- Clear browser cache (Ctrl+F5)

### Issue: "Cannot find symbol" during compilation
**Solution:**
- Add all JAR files to classpath: `-cp "WebContent/WEB-INF/lib/*"`
- Verify GSON and commons libraries are present
- Use full command with all JAR files

---

## ✅ VERIFICATION CHECKLIST

After following all steps, verify:

- [ ] MySQL database created with 18 tables
- [ ] All JAR files downloaded and placed in lib/
- [ ] Database credentials updated in DatabaseConnection.java
- [ ] Java code compiled successfully (no errors)
- [ ] Application deployed to Tomcat
- [ ] Can access: http://localhost:8080/school-exam-system/
- [ ] Database logs show connection established

---

## 📊 EXPECTED CONSOLE OUTPUT

After successful setup:

```
✅ MySQL JDBC Driver loaded successfully
✅ Database connection established
```

---

## 🎯 NEXT PHASE (After Verification)

Once database is setup and code compiles:

1. Create remaining model classes (Topic, Question, etc.)
2. Implement DAO classes (SchoolDAO, ClassDAO, etc.)
3. Create AuthServlet for login
4. Build admin management servlets
5. Implement teacher exam generation
6. Build student exam interface
7. Create parent reporting module

---

## 📞 QUICK REFERENCE

**Database:**
- Name: `school_exam_system`
- User: `root`
- Location: `C:\Users\Admin\StudentActivities\StudentActivities\DATABASE_SETUP.sql`

**Source Code:**
- Location: `C:\Users\Admin\StudentActivities\StudentActivities\src\`
- Compiled to: `C:\Users\Admin\StudentActivities\StudentActivities\build\`

**Web Application:**
- WebContent: `C:\Users\Admin\StudentActivities\StudentActivities\WebContent\`
- Config: `WebContent/WEB-INF/web.xml`
- Libraries: `WebContent/WEB-INF/lib/`

**Tomcat:**
- Default Port: 8080
- Manager URL: http://localhost:8080/manager/html
- App URL: http://localhost:8080/school-exam-system/

---

## ⏱️ TOTAL SETUP TIME

- Database Setup: 5 minutes
- JAR Downloads: 10 minutes
- Configuration: 2 minutes
- Compilation: 5 minutes
- Deployment: 10 minutes
- **Total: ~30 minutes**

---

**Ready to Start? Follow the 6 steps above! 🚀**

