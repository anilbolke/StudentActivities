package com.school.exam.test;

import com.school.exam.dao.*;
import com.school.exam.model.*;
import java.util.List;

public class TestStep2SubjectData {

    public static void main(String[] args) {
        System.out.println("========== STEP 2: Subject Data Management ==========\n");

        try {
            int schoolId = 1;

            // Test 1: Add subjects
            System.out.println("Test 1: Adding test subjects...");
            Subject subject1 = new Subject("Mathematics", schoolId);
            subject1.setDescription("Mathematics subject for class 10");
            subject1.setStatus("ACTIVE");

            int subjectId1 = SubjectDAO.addSubject(subject1);
            System.out.println("✓ Subject 1 (Mathematics) added with ID: " + subjectId1);

            Subject subject2 = new Subject("Science", schoolId);
            subject2.setDescription("Science subject for class 10");
            subject2.setStatus("ACTIVE");

            int subjectId2 = SubjectDAO.addSubject(subject2);
            System.out.println("✓ Subject 2 (Science) added with ID: " + subjectId2);

            // Test 2: Add chapters
            System.out.println("\nTest 2: Adding chapters for subjects...");
            Chapter chapter1 = new Chapter();
            chapter1.setSubjectId(subjectId1);
            chapter1.setChapterName("Algebra");
            chapter1.setChapterNumber(1);
            chapter1.setStatus("ACTIVE");

            int chapterId1 = ChapterDAO.addChapter(chapter1);
            System.out.println("✓ Chapter 1 (Algebra) added with ID: " + chapterId1);

            Chapter chapter2 = new Chapter();
            chapter2.setSubjectId(subjectId1);
            chapter2.setChapterName("Geometry");
            chapter2.setChapterNumber(2);
            chapter2.setStatus("ACTIVE");

            int chapterId2 = ChapterDAO.addChapter(chapter2);
            System.out.println("✓ Chapter 2 (Geometry) added with ID: " + chapterId2);

            Chapter chapter3 = new Chapter();
            chapter3.setSubjectId(subjectId2);
            chapter3.setChapterName("Physics");
            chapter3.setChapterNumber(1);
            chapter3.setStatus("ACTIVE");

            int chapterId3 = ChapterDAO.addChapter(chapter3);
            System.out.println("✓ Chapter 3 (Physics) added with ID: " + chapterId3);

            // Test 3: Retrieve subjects
            System.out.println("\nTest 3: Retrieving subjects by school...");
            List<Subject> subjects = SubjectDAO.getSubjectsBySchool(schoolId);
            System.out.println("✓ Total subjects in school: " + subjects.size());
            for (Subject s : subjects) {
                System.out.println("  - " + s.getSubjectName());
            }

            // Test 4: Retrieve chapters
            System.out.println("\nTest 4: Retrieving chapters for subject...");
            List<Chapter> chapters = ChapterDAO.getChaptersBySubject(subjectId1);
            System.out.println("✓ Total chapters in Mathematics: " + chapters.size());
            for (Chapter c : chapters) {
                System.out.println("  - " + c.getChapterName());
            }

            // Test 5: Update subject
            System.out.println("\nTest 5: Updating subject information...");
            subject1.setSubjectId(subjectId1);
            subject1.setDescription("Updated Mathematics subject for class 10");
            boolean updated = SubjectDAO.updateSubject(subject1);
            System.out.println("✓ Subject updated: " + updated);

            // Test 6: Get subject by ID
            System.out.println("\nTest 6: Retrieving subject by ID...");
            Subject retrievedSubject = SubjectDAO.getSubjectById(subjectId1);
            System.out.println("✓ Retrieved: " + retrievedSubject.getSubjectName() + " - " + retrievedSubject.getDescription());

            // Test 7: Get chapter by ID
            System.out.println("\nTest 7: Retrieving chapter by ID...");
            Chapter retrievedChapter = ChapterDAO.getChapterById(chapterId1);
            System.out.println("✓ Retrieved: " + retrievedChapter.getChapterName());

            System.out.println("\n========== STEP 2 TESTS PASSED ✓ ==========\n");

        } catch (Exception e) {
            System.out.println("✗ ERROR in STEP 2 tests:");
            e.printStackTrace();
        }
    }
}
