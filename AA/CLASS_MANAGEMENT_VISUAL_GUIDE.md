╔══════════════════════════════════════════════════════════════════════════╗
║           CLASS MANAGEMENT FEATURE - VISUAL GUIDE                       ║
╚══════════════════════════════════════════════════════════════════════════╝

## 🖼️ CLASS LIST VIEW (classList.jsp)

```
┌────────────────────────────────────────────────────────────────────┐
│                          StudentActivities                          │
│  ← Back to Dashboard                                               │
├────────────────────────────────────────────────────────────────────┤
│  📚 Classes                            [➕ Add New Class]           │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────┬──────────┬──────────┬──────────────┬────────────────┐ │
│  │ Class # │ Section  │ Students │ Created At   │ Actions        │ │
│  ├─────────┼──────────┼──────────┼──────────────┼────────────────┤ │
│  │ 10      │ A        │ 50       │ 2026-03-24   │ [✏️ Edit] [🗑️]  │ │
│  ├─────────┼──────────┼──────────┼──────────────┼────────────────┤ │
│  │ 10      │ B        │ 48       │ 2026-03-24   │ [✏️ Edit] [🗑️]  │ │
│  ├─────────┼──────────┼──────────┼──────────────┼────────────────┤ │
│  │ 11      │ All      │ 60       │ 2026-03-24   │ [✏️ Edit] [🗑️]  │ │
│  ├─────────┼──────────┼──────────┼──────────────┼────────────────┤ │
│  │ 12      │ A        │ 45       │ 2026-03-24   │ [✏️ Edit] [🗑️]  │ │
│  └─────────┴──────────┴──────────┴──────────────┴────────────────┘ │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

**Key Elements:**
- ✅ Table with all classes
- ✅ Class number, section, student count
- ✅ Edit button (✏️) for each class
- ✅ Delete button (🗑️) for each class
- ✅ "Add New Class" button in header

---

## 🖼️ ADD CLASS FORM VIEW (addClass.jsp)

```
┌────────────────────────────────────────────────────────────────────┐
│  ← Back to Classes                                                  │
├────────────────────────────────────────────────────────────────────┤
│  📚 Add New Class                                                   │
│  Create a new class in the system                                   │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ℹ️  Note: Create classes before uploading exam questions.         │
│      Questions must be assigned to existing classes.               │
│                                                                     │
│  Class Number *                                                     │
│  [e.g., 10, 11, 12 or Nursery, KG...............]                  │
│  The class identifier (e.g., 10, 11, 12)                           │
│                                                                     │
│  Class Section *                                                    │
│  [e.g., A, B, C or All..................................]          │
│  Section name or 'All' if not divided by sections                  │
│                                                                     │
│  Total Students                                                     │
│  [e.g., 50.................................]                         │
│  Number of students in this class (optional)                       │
│                                                                     │
│  [➕ Add Class..................] [Clear Form]                      │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

**Key Elements:**
- ✅ Three form fields (one required, one required, one optional)
- ✅ Help text under each field
- ✅ Back link to class list
- ✅ Info box about creating classes first
- ✅ Submit and Clear buttons

---

## 🖼️ EDIT CLASS FORM VIEW (editClass.jsp)

```
┌────────────────────────────────────────────────────────────────────┐
│  ← Back to Classes                                                  │
├────────────────────────────────────────────────────────────────────┤
│  📚 Edit Class                                                      │
│  Update class details                                               │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Class Number *                                                     │
│  [10....................................................]          │
│  The class identifier (e.g., 10, 11, 12)                           │
│                                                                     │
│  Class Section *                                                    │
│  [A.....................................................]          │
│  Section name or 'All' if not divided by sections                  │
│                                                                     │
│  Total Students                                                     │
│  [50....................................................]         │
│  Number of students in this class                                  │
│                                                                     │
│  [💾 Update Class.............] [Reset]                            │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

**Key Elements:**
- ✅ Pre-filled form fields with current values
- ✅ Edit button labeled "💾 Update Class"
- ✅ Reset button to discard changes
- ✅ Back link to class list

---

## 🔄 WORKFLOW DIAGRAM

```
                    ┌─────────────────────┐
                    │  Admin Dashboard    │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                v              v              v
        ┌─────────────┐  ┌────────────┐  ┌──────────────┐
        │  Upload Q's │  │  Classes   │  │   Other     │
        └──────┬──────┘  └──────┬─────┘  └──────────────┘
               │                │
               │                ├─→ classList.jsp
               │                │   (View all)
               │                │
               │                ├─→ addClass.jsp
               │                │   (Create new)
               │                │
               │                ├─→ editClass.jsp
               │                │   (Edit)
               │                │
               │                ├─→ Delete via API
               │                │   (Remove)
               │
               └─→ uploadQuestions.jsp
                   (Bulk upload)
                   └─→ Success (with classes) ✅
                   └─→ Fails (without classes) ❌
```

---

## 🎯 USER JOURNEY

### Scenario: New Admin Setting Up System

```
Step 1: Login
┌─────────────────────────────────┐
│ Enter username & password       │
│ Click Login                     │
└────────────┬────────────────────┘
             │
Step 2: Go to Classes
┌────────────▼────────────────────┐
│ Click "Classes" in dashboard    │
│ Sees classList.jsp              │
│ Table is empty                  │
└────────────┬────────────────────┘
             │
Step 3: Add Classes
┌────────────▼────────────────────┐
│ Click "➕ Add New Class"         │
│ Enters: 10, A, 50               │
│ Click "➕ Add Class"             │
│ Redirects to classList.jsp      │
│ Class 10-A appears in table ✅  │
└────────────┬────────────────────┘
             │
Step 4: Repeat for More Classes
┌────────────▼────────────────────┐
│ Click "➕ Add New Class" again   │
│ Enters: 10, B, 48               │
│ Enters: 11, All, 60             │
│ Enters: 12, A, 45               │
│ Now 4 classes in table ✅       │
└────────────┬────────────────────┘
             │
Step 5: Upload Questions
┌────────────▼────────────────────┐
│ Click "Upload Questions"        │
│ Upload sample-questions.txt     │
│ Questions for classes exist! ✅ │
│ All 36 questions inserted! ✅   │
└─────────────────────────────────┘
```

---

## 🎨 COLOR SCHEME

Used throughout the UI:

```
Primary Color:      #2c3e50  (Dark Blue-Gray)
├─ Headers
├─ Main buttons
└─ Table headers

Secondary Color:    #3498db  (Light Blue)
├─ Links
├─ Edit buttons
└─ Focus states

Danger Color:       #e74c3c  (Red)
└─ Delete buttons

Success Color:      #27ae60  (Green)
└─ Success messages

Warning Color:      #f39c12  (Orange)
└─ Edit buttons

Background:         #f5f5f5  (Light Gray)
└─ Page background

Text Color:         #2c3e50  (Dark)
├─ Headings
└─ Body text

Borders:            #bdc3c7  (Light Gray)
└─ Form inputs

Error Messages:     Red background (#f8d7da)
Success Messages:   Green background (#d4edda)
Info Messages:      Blue background (#d1ecf1)
```

---

## 📱 RESPONSIVE DESIGN

**Desktop (1920×1080):**
```
┌─────────────────────────────────────────────────────────┐
│  📚 Classes              [➕ Add New Class]              │
├─────────────────────────────────────────────────────────┤
│  Full-width table with all columns visible              │
│  Comfortable spacing                                    │
└─────────────────────────────────────────────────────────┘
```

**Tablet (768×1024):**
```
┌───────────────────────────┐
│  📚 Classes               │
│  [➕ Add New Class]        │
├───────────────────────────┤
│  Responsive table         │
│  Some columns may wrap    │
└───────────────────────────┘
```

**Mobile (375×667):**
```
┌──────────────────┐
│  📚 Classes      │
│ [➕ Add Class]   │
├──────────────────┤
│  Stacked layout  │
│  Action buttons  │
│  below each row  │
└──────────────────┘
```

---

## 🔐 ACCESS CONTROL

```
User Visits:  /classList.jsp
               │
               ├─ Admin user?
               │  ├─ YES → Show page ✅
               │  └─ NO → Redirect to login ❌
               │
               ├─ Logged in?
               │  ├─ YES → Check role ✅
               │  └─ NO → Show login page ❌
               │
               └─ Result:
                  └─ Only admin users see class management
```

---

## 📊 DATABASE OPERATIONS

```
User Action          Method  URL                      DB Operation
─────────────────────────────────────────────────────────────────
Create Class         POST    /api/admin/class        INSERT
View All Classes     GET     /api/admin/class        SELECT
View One Class       GET     /api/admin/class/{id}   SELECT
Update Class         PUT     /api/admin/class/{id}   UPDATE
Delete Class         DELETE  /api/admin/class/{id}   DELETE
```

---

## ✨ SUCCESS INDICATORS

After each action, user sees:

```
✅ Class added successfully! Redirecting...
✅ Class updated successfully! Redirecting...
✅ Class deleted successfully!

❌ Please fill in all required fields
❌ Failed to add class: [error message]
❌ Server error occurred. Please try again.
```

═════════════════════════════════════════════════════════════════════════════

This comprehensive visual guide shows users exactly what to expect from the
class management interface and how to interact with it!

═════════════════════════════════════════════════════════════════════════════
