# ⚡ QUICK START - ALTER SCHOOLS TABLE

## Current Status
✅ Your schools table exists with **8 columns**
❌ Admin system needs **9 more columns**

## Solution: ALTER TABLE
✅ Keep all existing data
✅ Add missing 9 columns
✅ Auto-generate school_code
✅ Set status to ACTIVE

---

## EXECUTE NOW (1 Click!)

### Files Created:
1. **ALTER_SCHOOLS_TABLE.sql** - SQL script
2. **ALTER_SCHOOLS.bat** - One-click runner

### How to Run:
```
Location: C:\Users\Admin\StudentActivities\StudentActivities\

1. Double-click: ALTER_SCHOOLS.bat
2. Type: YES
3. Wait: Success message
4. Done! ✅
```

---

## What Gets Added (9 Columns)

| Column | Type | Notes |
|--------|------|-------|
| school_code | VARCHAR(50) | Auto-generated: SCHOOL-001, SCHOOL-002, etc |
| state | VARCHAR(100) | Location info |
| pincode | VARCHAR(10) | Postal code |
| phone | VARCHAR(20) | Phone number |
| principal_name | VARCHAR(100) | School principal |
| principal_contact | VARCHAR(20) | Principal's phone |
| registration_number | VARCHAR(50) | Registration ID |
| status | ENUM | Auto-set to ACTIVE |
| established_year | INT | Founding year |

---

## After Execution

1. **Restart Tomcat**
2. **Login:** admin1 / admin123
3. **Test:** Add/Edit School → Works! ✅

---

## Documentation
📖 **Complete Guide:** ALTER_SCHOOLS_TABLE_GUIDE.md

---

**Status:** Ready ✅ | **Time:** 1 minute | **Risk:** None
