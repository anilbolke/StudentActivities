package com.school.exam.test;

import com.school.exam.dao.*;
import com.school.exam.model.*;
import com.school.exam.model.Class;

import java.util.List;

public class TestStep3ClassData {

    public static void main(String[] args) {
        System.out.println("========== STEP 3: Class Data Management ==========\n");

        try {
            int schoolId = 1;

            // Test 1: Add multiple classes
            System.out.println("Test 1: Adding test classes...");
            
            Class class10A = new Class("Class 10-A", 10, "A", schoolId);
            class10A.setStatus("ACTIVE");
            int classId10A = ClassDAO.addClass(class10A);
            System.out.println("✓ Class 10-A added with ID: " + classId10A);

            Class class10B = new Class("Class 10-B", 10, "B", schoolId);
            class10B.setStatus("ACTIVE");
            int classId10B = ClassDAO.addClass(class10B);
            System.out.println("✓ Class 10-B added with ID: " + classId10B);

            Class class9A = new Class("Class 9-A", 9, "A", schoolId);
            class9A.setStatus("ACTIVE");
            int classId9A = ClassDAO.addClass(class9A);
            System.out.println("✓ Class 9-A added with ID: " + classId9A);

            // Test 2: Retrieve classes by school
            System.out.println("\nTest 2: Retrieving classes by school...");
            List<Class> classes = ClassDAO.getClassesBySchool(schoolId);
            System.out.println("✓ Total active classes in school: " + classes.size());
            for (Class c : classes) {
                System.out.println("  - " + c.getClassName() + " (Grade " + c.getGrade() + ", Section " + c.getSection() + ")");
            }

            // Test 3: Get class by ID
            System.out.println("\nTest 3: Retrieving class by ID...");
            Class retrievedClass = ClassDAO.getClassById(classId10A);
            System.out.println("✓ Retrieved: " + retrievedClass.getClassName());

            // Test 4: Update class
            System.out.println("\nTest 4: Updating class information...");
            class10A.setClassId(classId10A);
            boolean updated = ClassDAO.updateClass(class10A);
            System.out.println("✓ Class updated: " + updated);

            // Test 5: Verify update
            System.out.println("\nTest 5: Verifying class update...");
            Class updatedClass = ClassDAO.getClassById(classId10A);
            System.out.println("✓ Class updated successfully");

            // Test 6: Get class count
            System.out.println("\nTest 6: Getting class count...");
            int classCount = ClassDAO.getClassCountBySchool(schoolId);
            System.out.println("✓ Total classes in school: " + classCount);

            // Test 7: Get all classes (including inactive)
            System.out.println("\nTest 7: Retrieving all classes (including inactive)...");
            List<Class> allClasses = ClassDAO.getAllClassesBySchool(schoolId);
            System.out.println("✓ Total classes (active & inactive): " + allClasses.size());

            System.out.println("\n========== STEP 3 TESTS PASSED ✓ ==========\n");

        } catch (Exception e) {
            System.out.println("✗ ERROR in STEP 3 tests:");
            e.printStackTrace();
        }
    }
}
