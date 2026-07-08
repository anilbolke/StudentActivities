╔══════════════════════════════════════════════════════════════════════════╗
║                   DEPLOYMENT CHECKLIST - FINAL                          ║
║                                                                          ║
║                  Exam Upload Feature - Ready to Deploy                  ║
╚══════════════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════════
                    COMPILATION FIXES COMPLETED
═══════════════════════════════════════════════════════════════════════════

All issues resolved:

✅ PHASE 1: Upload Feature (4 fixes)
   □ TopicUploadDAO - Class name corrected
   □ SchoolModel - Duplicate removed
   □ DatabaseConnection - 24 calls fixed
   □ ExamPaperGenerator - Method name fixed

✅ PHASE 2: DAOs (4 fixes)
   □ SchoolDAO - 12 method calls corrected
   □ StudentDAO - 7 field references removed
   □ SubjectDAO - 5 field references removed
   □ ClassDAO - 4 method calls corrected

✅ PHASE 3: Servlets (3 fixes)
   □ AdminClassServlet - 2 method calls corrected
   □ AdminSchoolServlet - 5 method calls corrected
   □ AdminSubjectServlet - 1 method call corrected

═══════════════════════════════════════════════════════════════════════════
                    ECLIPSE DEPLOYMENT CHECKLIST
═══════════════════════════════════════════════════════════════════════════

BEFORE STARTING:
  □ Tomcat is STOPPED (not running)
  □ You have Eclipse open with StudentActivities project
  □ Java version is 11 or higher
  □ Database is running and accessible

STEP 1: Clean Build
  □ Right-click StudentActivities project in Project Explorer
  □ Select "Clean Build"
  □ Wait 2-3 minutes for build to complete
  □ Check status bar: Should say "Build Complete"

STEP 2: Verify Build
  □ Window → Show View → Problems (if not visible)
  □ Check Problems tab: Should show 0 errors
  □ Warnings are acceptable (hover to check what they are)
  □ No red X marks anywhere

STEP 3: Export WAR
  □ Right-click StudentActivities project
  □ Select "Export..."
  □ Choose "WAR file"
  □ Click "Next"
  □ Verify export destination: C:\Apache\Tomcat\webapps\ (or your Tomcat path)
  □ Filename: StudentActivities.war
  □ Click "Finish"
  □ Wait for export to complete

STEP 4: Verify WAR Export
  □ Go to C:\Apache\Tomcat\webapps\ (or your Tomcat webapps folder)
  □ Verify StudentActivities.war file exists (file size > 1MB)
  □ Check timestamp is recent

═══════════════════════════════════════════════════════════════════════════
                    TOMCAT DEPLOYMENT CHECKLIST
═══════════════════════════════════════════════════════════════════════════

STEP 5: Stop Tomcat
  □ Open Command Prompt
  □ Navigate to Tomcat bin directory: cd C:\Apache\Tomcat\bin
  □ Run: catalina.bat stop
  □ Wait 3-5 seconds for Tomcat to fully shut down
  □ Verify console shows "INFO: Server startup completed in XXX ms"

STEP 6: Clear Old Deployment (Optional)
  □ Go to: C:\Apache\Tomcat\work\Catalina\localhost\
  □ Delete StudentActivities folder if it exists
  □ This ensures a fresh deployment

STEP 7: Start Tomcat
  □ In same Command Prompt, run: catalina.bat start
  □ Wait 10-15 seconds
  □ Look for message: "INFO: Server startup completed in XXX ms"
  □ Verify: No errors in console
  □ Verify: No "SEVERE" messages

STEP 8: Verify Deployment
  □ Open browser (Chrome/Firefox)
  □ Go to: http://localhost:8080/StudentActivities/
  □ Should see login page (not 404 error)
  □ Page should load completely (images, CSS visible)

═══════════════════════════════════════════════════════════════════════════
                    APPLICATION TESTING CHECKLIST
═══════════════════════════════════════════════════════════════════════════

TEST 1: Login & Authentication
  □ Navigate to login page: http://localhost:8080/StudentActivities/login.jsp
  □ Try login with wrong password: Should fail
  □ Login with correct admin credentials
  □ Should redirect to dashboard
  □ Session should be created

TEST 2: Admin Verification
  □ After login, check user info is displayed
  □ Verify role shows "ADMIN" (or your admin role)
  □ Check username is correct

TEST 3: Upload Feature Access
  □ Navigate to: http://localhost:8080/StudentActivities/uploadQuestions.jsp
  □ Should see upload form (NOT "Access Denied" message)
  □ Form should have:
     - File input field
     - Upload button
     - Instructions/requirements

TEST 4: File Upload
  □ Click "Choose File" button
  □ Select sample-questions.txt from project folder
  □ Click "Upload Questions" button
  □ Should see progress indicator
  □ Should see success message with count of uploaded questions

TEST 5: Access Control Test
  □ Logout from admin account
  □ Login as teacher user (if available)
  □ Try to access /uploadQuestions.jsp
  □ Should see "Access Denied" message (NOT upload form)
  □ This confirms security is working

TEST 6: Database Verification
  □ Connect to database with MySQL client or tool
  □ Check questions table: SELECT COUNT(*) FROM questions;
  □ Should show questions were inserted (36 if you uploaded sample file)
  □ Verify topics table has new entries
  □ Verify subjects table has entries
  □ Verify class hierarchy is correct

═══════════════════════════════════════════════════════════════════════════
                    TROUBLESHOOTING GUIDE
═══════════════════════════════════════════════════════════════════════════

PROBLEM: Build fails with errors
SOLUTION:
  □ Check Problems tab for specific error message
  □ Close and reopen project
  □ Right-click project → Properties
  □ Check Java Build Path has JRE System Library
  □ Remove and re-add if needed
  □ Do Clean Build again

PROBLEM: WAR export fails
SOLUTION:
  □ Make sure build completed successfully first
  □ Check destination folder is writable
  □ Check you have permission to write to webapps folder
  □ Try exporting to a different location first
  □ Delete old war file and try again

PROBLEM: Tomcat won't start
SOLUTION:
  □ Check if port 8080 is already in use
  □ Run: netstat -ano | findstr :8080
  □ If port is in use, kill the process: taskkill /F /IM java.exe
  □ Wait 10 seconds
  □ Try starting Tomcat again
  □ Check Java is installed: java -version

PROBLEM: Application shows 404 error
SOLUTION:
  □ Check Tomcat console for errors
  □ Verify StudentActivities.war was deployed
  □ Check webapps folder has StudentActivities folder
  □ Check Tomcat logs in logs/ folder
  □ May need to manually extract war: jar xf StudentActivities.war

PROBLEM: Login doesn't work
SOLUTION:
  □ Check database is running
  □ Verify database connection in web.xml
  □ Check admin user exists in database
  □ Verify password is correct
  □ Check AuthServlet is being called

PROBLEM: Upload shows "Access Denied"
SOLUTION:
  □ Verify you're logged in as admin
  □ Check session attribute "userRole" is set
  □ Look at AdminQuestionUploadServlet code
  □ Verify AuthServlet sets userRole in session
  □ Try logout and login again
  □ Clear browser cache (Ctrl+Shift+Delete)

PROBLEM: Upload fails with error
SOLUTION:
  □ Check file is in correct format (.txt)
  □ Verify file size is under 5MB
  □ Check sample-questions.txt is properly formatted
  □ Look at upload servlet error logs
  □ Check database tables exist
  □ Verify database permissions

PROBLEM: Questions don't appear in database
SOLUTION:
  □ Check upload shows success message
  □ Verify database connection string is correct
  □ Check if questions table exists
  □ Run: SELECT * FROM questions LIMIT 1;
  □ Check transaction is committed
  □ Verify no foreign key constraint violations
  □ Check class/subject/topic exist before questions

═══════════════════════════════════════════════════════════════════════════
                    ROLLBACK PROCEDURE (If Issues)
═══════════════════════════════════════════════════════════════════════════

If something goes wrong and you need to rollback:

  1. Stop Tomcat: catalina.bat stop
  
  2. Delete the deployed version:
     - Go to: C:\Apache\Tomcat\webapps\
     - Delete StudentActivities folder
     - Delete StudentActivities.war file
  
  3. Clear work folder:
     - Go to: C:\Apache\Tomcat\work\Catalina\localhost\
     - Delete StudentActivities folder
  
  4. Restore from backup or previous version:
     - Copy previous .war file to webapps folder
  
  5. Start Tomcat: catalina.bat start
  
  6. Test: http://localhost:8080/StudentActivities/

═══════════════════════════════════════════════════════════════════════════
                    SUCCESS INDICATORS
═══════════════════════════════════════════════════════════════════════════

When you see these, it's working! ✅

  ✅ Eclipse: "Build Complete" in status bar
  ✅ Eclipse: 0 errors in Problems tab
  ✅ Tomcat: "Server startup completed" in console
  ✅ Browser: Login page loads and displays correctly
  ✅ Login: Dashboard appears after entering credentials
  ✅ Upload Page: Form shows (not "Access Denied")
  ✅ Upload: File selected and upload button visible
  ✅ Upload: "Success" message with question count
  ✅ Database: Query shows questions were inserted
  ✅ Non-admin: "Access Denied" message shown

═══════════════════════════════════════════════════════════════════════════
                    FINAL VERIFICATION
═══════════════════════════════════════════════════════════════════════════

After deployment, verify all components work:

BACKEND:
  □ Servlets respond to requests
  □ File parsing works
  □ Validation passes
  □ Database insertion successful
  □ No exceptions in logs

FRONTEND:
  □ Login page works
  □ Admin dashboard displays
  □ Upload page accessible to admins
  □ Upload page blocked for non-admins
  □ File upload form functional

SECURITY:
  □ Only admins can upload
  □ Non-admins see appropriate error
  □ Sessions created correctly
  □ Roles verified server-side

DATABASE:
  □ Questions inserted
  □ Hierarchy maintained
  □ No duplicate entries
  □ Data integrity maintained

═══════════════════════════════════════════════════════════════════════════

✅ DEPLOYMENT COMPLETE

When all tests pass, the exam upload feature is live and production-ready!

═══════════════════════════════════════════════════════════════════════════
