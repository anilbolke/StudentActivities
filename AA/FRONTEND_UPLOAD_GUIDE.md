# QUESTION UPLOAD - FRONTEND INTEGRATION GUIDE

## 🎯 Overview

The admin-only question upload feature is now available in the frontend. Only users with the "ADMIN" role can access and use the upload functionality. Non-admin users will see an access denied message.

---

## 📄 Frontend Files Created

### Main Upload Page: `uploadQuestions.jsp`
**Location:** `WebContent/uploadQuestions.jsp`  
**Access URL:** `http://localhost:8080/StudentActivities/uploadQuestions.jsp`

---

## 🔒 Role-Based Access Control

### How It Works

The JSP page checks the user's role automatically:

```jsp
<%
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    boolean isAdmin = "ADMIN".equals(userRole);
%>
```

### For ADMIN Users

✅ **Shows:** Upload form with file input, upload button, progress indicator  
✅ **Can:** Select .txt files, upload questions, see results  
✅ **Sees:** Success/error messages, statistics, failed records  

### For Non-Admin Users (TEACHER, STUDENT, PARENT)

❌ **Shows:** "Access Denied" message  
❌ **Cannot:** Upload questions  
✅ **Sees:** Their role and account information  
✅ **Can:** Contact administrator to request admin privileges  

---

## 📋 FRONTEND FEATURES

### 1. **Admin Interface (When Logged In as Admin)**

```
┌─────────────────────────────────────────┐
│     📚 Upload Exam Questions            │
│                                         │
│  ℹ️ Welcome, admin123! You can          │
│     upload questions here.              │
│                                         │
│  [Select .txt File]                     │
│  ✓ File must be .txt format             │
│  ✓ Max size: 5 MB                       │
│  ✓ Pipe-delimited format                │
│  ✓ Exactly 11 fields per line           │
│                                         │
│  📤 Upload Questions  |  Clear Form     │
│                                         │
│  ℹ️ Need Help?                          │
│  • Quick Reference Card                 │
│  • Complete Guide                       │
│  • Download Sample File                 │
└─────────────────────────────────────────┘
```

### 2. **Non-Admin Message (When Logged In as Teacher/Student)**

```
┌─────────────────────────────────────────┐
│     📚 Upload Exam Questions            │
│                                         │
│  ❌ Access Denied                       │
│     Only administrators can upload      │
│     questions.                          │
│                                         │
│  📋 Your Account Information:           │
│  Username: teacher123                   │
│  Role: TEACHER                          │
│                                         │
│  ℹ️ What This Means:                   │
│  You don't have permission to upload    │
│  questions. If you need to upload,      │
│  contact your administrator.            │
│                                         │
│  ← Back to Home                         │
└─────────────────────────────────────────┘
```

---

## 🚀 HOW TO USE

### Step 1: Navigate to Upload Page
```
URL: http://localhost:8080/StudentActivities/uploadQuestions.jsp
```

### Step 2: Login as Admin
- Username: admin (or your admin account)
- Password: your admin password

### Step 3: Select File
- Click on "Select .txt File"
- Choose your `sample-questions.txt` or your file
- System automatically validates:
  - ✓ File extension (.txt only)
  - ✓ File size (max 5 MB)

### Step 4: Upload
- Click "📤 Upload Questions" button
- See loading spinner while uploading
- Wait for success message

### Step 5: Review Results
- See how many questions uploaded successfully
- See any failed records with error reasons
- Option to upload another file

---

## 💻 Frontend Code Structure

### Key Components

#### 1. **Role Check**
```jsp
<% if (isAdmin) { %>
    <!-- ADMIN SECTION -->
<% } else { %>
    <!-- UNAUTHORIZED SECTION -->
<% } %>
```

#### 2. **File Input Validation**
```javascript
// Check file extension
if (!fileName.endsWith('.txt')) {
    showAlert('error', '❌ Invalid File Type', 'Only .txt files are allowed');
}

// Check file size (5 MB limit)
if (file.size > 5242880) {
    showAlert('error', '❌ File Too Large', 'Max 5 MB');
}
```

#### 3. **Upload to Backend**
```javascript
const response = await fetch(
    '/StudentActivities/api/admin/uploadQuestions',
    {
        method: 'POST',
        credentials: 'include',
        body: formData
    }
);
```

#### 4. **Results Display**
```javascript
// Show statistics
// Show success count: 36/36
// Show failure count: 0
// Show success percentage: 100%
// Show failed records with error messages
```

---

## 🎨 Styling Details

### Colors Used
- **Primary:** #667eea (Purple)
- **Success:** #28a745 (Green)
- **Error:** #dc3545 (Red)
- **Warning:** #ffeaa7 (Yellow)
- **Info:** #eef (Light Blue)

### Responsive Design
- ✅ Works on desktop
- ✅ Works on tablet
- ✅ Works on mobile
- ✅ Optimized for touch

### Interactive Elements
- ✅ Hover effects on buttons
- ✅ Loading spinner during upload
- ✅ Auto-dismissing alerts (5 seconds)
- ✅ Real-time file info display
- ✅ Smooth transitions

---

## 📝 JavaScript Functions

### Core Functions

#### 1. `showAlert(type, title, message)`
Shows alert messages that auto-dismiss after 5 seconds
```javascript
showAlert('error', '❌ Error Title', 'Error message here');
showAlert('success', '✅ Success', 'Operation completed');
showAlert('info', 'ℹ️ Info', 'Information message');
```

#### 2. `resetForm()`
Clears the upload form and hides results
```javascript
resetForm(); // Resets file input and removes results
```

#### 3. `showUploadResults(data)`
Displays upload statistics and failed records
```javascript
showUploadResults({
    status: 'success',
    totalRecords: 36,
    successCount: 36,
    failureCount: 0,
    successPercentage: 100
});
```

---

## 🔄 Integration with Backend

### API Endpoint
```
POST /api/admin/uploadQuestions
Content-Type: multipart/form-data
```

### Request
```javascript
const formData = new FormData();
formData.append('file', fileObject);

fetch('/api/admin/uploadQuestions', {
    method: 'POST',
    credentials: 'include',
    body: formData
});
```

### Response Success
```json
{
    "status": "success",
    "message": "File uploaded successfully",
    "totalRecords": 36,
    "successCount": 36,
    "failureCount": 0,
    "successPercentage": 100.0,
    "timestamp": "2026-03-24 10:30:45"
}
```

### Response Error
```json
{
    "status": "error",
    "message": "Invalid file format. Only .txt files are allowed"
}
```

---

## 🧪 Testing

### Test Case 1: Admin User (Success)
```
1. Login as admin
2. Navigate to uploadQuestions.jsp
3. Upload sample-questions.txt
4. Expect: 36 questions uploaded ✅
5. See: Success message with statistics ✅
```

### Test Case 2: Teacher User (Access Denied)
```
1. Login as teacher
2. Navigate to uploadQuestions.jsp
3. See: "Access Denied" message ✅
4. Role shown: "TEACHER" ✅
5. Cannot upload ✅
```

### Test Case 3: Invalid File
```
1. Login as admin
2. Try to upload PDF file
3. Expect: Error message "Only .txt files allowed" ✅
4. File not uploaded ✅
```

### Test Case 4: Large File
```
1. Login as admin
2. Try to upload 6 MB file
3. Expect: Error "File too large" ✅
4. File rejected ✅
```

---

## 🛠️ Customization Guide

### Change Upload Button Color
```css
.btn-upload {
    background: #667eea;  /* Change this color */
}

.btn-upload:hover {
    background: #5568d3;  /* Change hover color */
}
```

### Change Header Text
```jsp
<h1>📚 Upload Exam Questions</h1>
<!-- Change emoji or text -->
<p>Bulk upload questions via text file</p>
```

### Modify File Size Limit (Frontend)
```javascript
// Current: 5 MB
if (file.size > 5242880) {  // 5 * 1024 * 1024
    // Change 5242880 to your desired size
}
```

### Add Custom Styling
```html
<style>
    /* Add your custom CSS here */
</style>
```

---

## 📱 Mobile Responsiveness

The page is fully responsive:

### Desktop (1024px+)
- ✅ Full width form
- ✅ Side-by-side buttons
- ✅ Full styling

### Tablet (768px - 1023px)
- ✅ Optimized width
- ✅ Touch-friendly buttons
- ✅ Readable text

### Mobile (< 768px)
- ✅ Full-width form
- ✅ Stacked layout
- ✅ Large touch targets

---

## 🔐 Security Features

### Frontend Security
1. ✅ Role-based visibility (JSP)
2. ✅ File extension validation
3. ✅ File size limit (5 MB)
4. ✅ Session cookie required (`credentials: 'include'`)

### Backend Security (Already Implemented)
1. ✅ Admin role verification
2. ✅ Server-side file validation
3. ✅ SQL injection protection
4. ✅ Input sanitization

---

## 🎓 USER FLOWS

### Admin User Flow
```
1. Login
   ↓
2. Navigate to Upload Page
   ↓
3. Select .txt file (validated client-side)
   ↓
4. Click Upload
   ↓
5. Show loading spinner
   ↓
6. Send to backend (/api/admin/uploadQuestions)
   ↓
7. Receive response (success or error)
   ↓
8. Display results (statistics + failed records)
   ↓
9. Option to upload another file
```

### Non-Admin User Flow
```
1. Login as teacher/student
   ↓
2. Navigate to Upload Page
   ↓
3. See: "Access Denied" message
   ↓
4. See: Your role information
   ↓
5. See: Contact admin message
   ↓
6. Click: Back to Home
```

---

## 📊 Error Handling

### Client-Side Errors (Shown Immediately)
- ❌ File is not .txt
- ❌ File is too large (> 5 MB)
- ❌ No file selected
- ❌ Network error

### Server-Side Errors (Shown in Response)
- ❌ User not authenticated
- ❌ User is not admin
- ❌ File parsing failed
- ❌ Validation failed
- ❌ Database error

### Error Display
```
┌─────────────────────────────────────┐
│  ❌ Upload Failed                   │
│  File size must be less than 5 MB   │
└─────────────────────────────────────┘
```

Auto-dismisses after 5 seconds

---

## 📚 Documentation Links

Inside the page, users can access:
1. **Quick Reference Card** - QUESTION_UPLOAD_QUICK_REF.md
2. **Complete Guide** - QUESTION_UPLOAD_GUIDE.md
3. **Sample File Download** - sample-questions.txt

---

## ✅ TESTING CHECKLIST

- [ ] Admin can see upload form
- [ ] Teacher sees "Access Denied" message
- [ ] File validation works (extension)
- [ ] File size limit enforced
- [ ] Upload success shows results
- [ ] Failed records listed with errors
- [ ] "Upload Another File" works
- [ ] Page is responsive on mobile
- [ ] Alerts auto-dismiss
- [ ] Links to documentation work
- [ ] Session timeout redirects to login
- [ ] Back button works for non-admins

---

## 🚀 Deployment

1. ✅ JSP file already in place: `WebContent/uploadQuestions.jsp`
2. ✅ Java backend already created
3. ✅ No additional dependencies needed
4. ✅ Ready to deploy

### Deploy Steps
```
1. Compile project
2. Build WAR
3. Deploy to Tomcat
4. Test: http://localhost:8080/StudentActivities/uploadQuestions.jsp
```

---

## 💡 Tips & Tricks

### For Admins
- Upload 10-20 questions first to test
- Have documentation handy when uploading
- Check failed records if upload not 100% successful
- Save upload receipt for audit trail

### For Developers
- Use browser dev tools (F12) to see API calls
- Check console for JavaScript errors
- Test with sample-questions.txt first
- Check server logs for backend errors

---

**Status:** ✅ PRODUCTION READY

Upload page is complete and integrated with backend API.

Ready to deploy!
