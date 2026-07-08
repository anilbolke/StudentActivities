╔══════════════════════════════════════════════════════════════════════════╗
║              CLASS MANAGEMENT - QUICK REFERENCE CARD                    ║
╚══════════════════════════════════════════════════════════════════════════╝

## 🚀 DEPLOY (5 MINUTES)

```
1. Eclipse → Right-click StudentActivities → Clean
2. Right-click → Export → WAR file → C:\Apache\Tomcat\webapps\
3. Command Prompt:
   cd C:\Apache\Tomcat\bin
   catalina.bat stop
   [wait 10s]
   catalina.bat start
4. Browser: http://localhost:8080/StudentActivities/classList.jsp
```

═════════════════════════════════════════════════════════════════════════════

## 📍 URLs

- View All: `/classList.jsp`
- Add New: `/addClass.jsp`
- Edit: `/editClass.jsp?id=1`

═════════════════════════════════════════════════════════════════════════════

## 📝 FIELDS

**Class Number** (Required)
- 10, 11, 12, Nursery, KG

**Class Section** (Required)
- A, B, C, All

**Total Students** (Optional)
- 50, 60, 45

═════════════════════════════════════════════════════════════════════════════

## 💻 ACTIONS

| Click | Result |
|-------|--------|
| ➕ Add Class | Create new class |
| ✏️ Edit | Open edit form |
| 💾 Update | Save changes |
| 🗑️ Delete | Remove class (with confirm) |

═════════════════════════════════════════════════════════════════════════════

## ✅ AFTER DEPLOY, TEST

- [ ] Access /classList.jsp
- [ ] Create: Class 10, Section A, 50 students
- [ ] Edit: Change to Section B
- [ ] Delete: Remove the class
- [ ] Upload: Should work for Class 10, 11, 12

═════════════════════════════════════════════════════════════════════════════

## 🔐 ONLY ADMINS CAN ACCESS

Non-admins redirected to login

═════════════════════════════════════════════════════════════════════════════

## 📱 WORKS ON ALL DEVICES

Desktop ✅ Tablet ✅ Mobile ✅

═════════════════════════════════════════════════════════════════════════════

## 🚨 IF UPLOAD FAILS

"Class '10' not found?" → Create it in /classList.jsp first!

═════════════════════════════════════════════════════════════════════════════

Ready to deploy and use! ✅
