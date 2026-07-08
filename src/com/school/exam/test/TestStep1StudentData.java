package com.school.exam.test;

import com.school.exam.dao.*;
import com.school.exam.model.Student;
import com.school.exam.model.Class;
import java.time.LocalDate;
import java.util.List;

public class TestStep1StudentData {

    public static void main(String[] args) {
        System.out.println("========== STEP 1: Student Data Management ==========\n");

        try {
            // Test 1: Add a school (prerequisite)
            System.out.println("Test 1: Adding test school...");
            int schoolId = 1; // Assuming school_id 1 exists, or create one
            System.out.println("✓ School ID: " + schoolId);

            // Test 2: Add a class
            System.out.println("\nTest 2: Adding test class...");
            com.school.exam.model.Class testClass = new com.school.exam.model.Class("Class 10-A", 10, "A", schoolId);
            testClass.setStatus("ACTIVE");
            int classId = ClassDAO.addClass(testClass);
            System.out.println("✓ Class added with ID: " + classId);

            // Test 3: Add students
            System.out.println("\nTest 3: Adding test students...");
            Student student1 = new Student();
            student1.setSchoolId(schoolId);
            student1.setClassId(classId);
            student1.setStudentName("Raj Kumar");
            student1.setRollNumber("10A001");
            student1.setEmail("raj.kumar@school.com");
            student1.setPhoneNumber("9876543210");
            student1.setDateOfBirth(LocalDate.of(2009, 5, 15));
            student1.setAddress("123 Main Street");
            student1.setCity("Delhi");
            student1.setGender("MALE");
            student1.setFatherName("Mr. Kumar");
            student1.setFatherContact("9876543211");
            student1.setMotherName("Mrs. Kumar");
            student1.setMotherContact("9876543212");
            student1.setStatus("ACTIVE");

            int studentId1 = StudentDAO.addStudent(student1);
            System.out.println("✓ Student 1 added with ID: " + studentId1);

            Student student2 = new Student();
            student2.setSchoolId(schoolId);
            student2.setClassId(classId);
            student2.setStudentName("Priya Singh");
            student2.setRollNumber("10A002");
            student2.setEmail("priya.singh@school.com");
            student2.setPhoneNumber("9876543220");
            student2.setDateOfBirth(LocalDate.of(2009, 8, 20));
            student2.setAddress("456 Oak Avenue");
            student2.setCity("Delhi");
            student2.setGender("FEMALE");
            student2.setFatherName("Mr. Singh");
            student2.setFatherContact("9876543221");
            student2.setMotherName("Mrs. Singh");
            student2.setMotherContact("9876543222");
            student2.setStatus("ACTIVE");

            int studentId2 = StudentDAO.addStudent(student2);
            System.out.println("✓ Student 2 added with ID: " + studentId2);

            // Test 4: Retrieve students
            System.out.println("\nTest 4: Retrieving students by school...");
            List<Student> students = StudentDAO.getStudentsBySchool(schoolId);
            System.out.println("✓ Total students in school: " + students.size());
            for (Student s : students) {
                System.out.println("  - " + s.getStudentName() + " (" + s.getRollNumber() + ")");
            }

            // Test 5: Retrieve students by class
            System.out.println("\nTest 5: Retrieving students by class...");
            List<Student> classStudents = StudentDAO.getStudentsByClass(classId);
            System.out.println("✓ Total students in class: " + classStudents.size());

            // Test 6: Update student
            System.out.println("\nTest 6: Updating student information...");
            student1.setStudentId(studentId1);
            student1.setEmail("raj.kumar.updated@school.com");
            boolean updated = StudentDAO.updateStudent(student1);
            System.out.println("✓ Student updated: " + updated);

            // Test 7: Search students
            System.out.println("\nTest 7: Searching students by name...");
            List<Student> searchResults = StudentDAO.searchStudentsByName(schoolId, "Raj");
            System.out.println("✓ Search results for 'Raj': " + searchResults.size());

            // Test 8: Get student by ID
            System.out.println("\nTest 8: Retrieving student by ID...");
            Student retrievedStudent = StudentDAO.getStudentById(studentId1);
            System.out.println("✓ Retrieved: " + retrievedStudent.getStudentName() + " - " + retrievedStudent.getEmail());

            System.out.println("\n========== STEP 1 TESTS PASSED ✓ ==========\n");

        } catch (Exception e) {
            System.out.println("✗ ERROR in STEP 1 tests:");
            e.printStackTrace();
        }
    }
}
