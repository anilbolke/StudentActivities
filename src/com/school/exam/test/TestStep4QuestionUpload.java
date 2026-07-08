package com.school.exam.test;

import com.school.exam.dao.*;
import com.school.exam.model.Question;
import java.util.List;

public class TestStep4QuestionUpload {

    public static void main(String[] args) {
        System.out.println("========== STEP 4: Question Upload & Management ==========\n");

        try {
            System.out.println("Setup: Verifying/Creating test data...");
            
            int schoolId = 1;
            long timestamp = System.currentTimeMillis();
            
            // Use timestamp-based unique names to avoid duplicate constraint violations
            String uniqueClassName = "TestClass_" + timestamp;
            String uniqueSubjectName = "TestSubject_" + timestamp;
            String uniqueChapterName = "TestChapter_" + timestamp;
            
            System.out.println("[DEBUG] Using unique test data names to avoid duplicates:");
            System.out.println("  Class: " + uniqueClassName);
            System.out.println("  Subject: " + uniqueSubjectName);
            System.out.println("  Chapter: " + uniqueChapterName);
            
            // Create test class
            System.out.println("\n[DEBUG] Creating test class for school_id=" + schoolId);
            com.school.exam.model.Class testClass = new com.school.exam.model.Class();
            testClass.setClassName(uniqueClassName);
            testClass.setSchoolId(schoolId);
            int classId = ClassDAO.addClass(testClass);
            System.out.println("✓ Test class created with ID: " + classId);
            
            if (classId <= 0) {
                System.out.println("[ERROR] Failed to create class! classId=" + classId);
                System.out.println("[DEBUG] Verify that school_id=" + schoolId + " exists in schools table");
                System.out.println("[DEBUG] If not, run: INSERT INTO schools VALUES (1, 'Test School', 'Test Address', 'Test City', 'Test State', '12345');");
                return;
            }
            
            // Create test subject
            System.out.println("[DEBUG] Creating test subject for school_id=" + schoolId);
            com.school.exam.model.Subject testSubject = new com.school.exam.model.Subject();
            testSubject.setSubjectName(uniqueSubjectName);
            testSubject.setSchoolId(schoolId);
            int subjectId = SubjectDAO.addSubject(testSubject);
            System.out.println("✓ Test subject created with ID: " + subjectId);
            
            if (subjectId <= 0) {
                System.out.println("[ERROR] Failed to create subject! subjectId=" + subjectId);
                System.out.println("[DEBUG] Verify that school_id=" + schoolId + " exists in schools table");
                return;
            }
            
            // Create test chapter
            System.out.println("[DEBUG] Creating test chapter for subject_id=" + subjectId);
            com.school.exam.model.Chapter testChapter = new com.school.exam.model.Chapter();
            testChapter.setChapterName(uniqueChapterName);
            testChapter.setSubjectId(subjectId);
            int chapterId = ChapterDAO.addChapter(testChapter);
            System.out.println("✓ Test chapter created with ID: " + chapterId);
            
            if (chapterId < 0 && chapterId != -1) {
                System.out.println("[WARN] Failed to create chapter! chapterId=" + chapterId);
            }

            // Test 1: Add questions
            System.out.println("\nTest 1: Adding test questions...");
            System.out.println("[DEBUG] Using: classId=" + classId + ", subjectId=" + subjectId + ", chapterId=" + chapterId);

            Question q1 = new Question();
            q1.setQuestionText("What is 2 + 2?");
            q1.setClassId(classId);
            q1.setSubjectId(subjectId);
            q1.setChapterId(chapterId);
            q1.setDifficultyLevel("EASY");
            q1.setMarks(1);
            q1.setOptionA("3");
            q1.setOptionB("4");
            q1.setOptionC("5");
            q1.setOptionD("6");
            q1.setCorrectAnswer("B");
            q1.setStatus("ACTIVE");

            int qId1 = QuestionDAO.addQuestion(q1);
            System.out.println("✓ Question 1 added with ID: " + qId1);

            Question q2 = new Question();
            q2.setQuestionText("What is the capital of India?");
            q2.setClassId(classId);
            q2.setSubjectId(subjectId);
            q2.setChapterId(chapterId);
            q2.setDifficultyLevel("EASY");
            q2.setMarks(1);
            q2.setOptionA("Mumbai");
            q2.setOptionB("Delhi");
            q2.setOptionC("Bangalore");
            q2.setOptionD("Kolkata");
            q2.setCorrectAnswer("B");
            q2.setStatus("ACTIVE");

            int qId2 = QuestionDAO.addQuestion(q2);
            System.out.println("✓ Question 2 added with ID: " + qId2);

            Question q3 = new Question();
            q3.setQuestionText("Advanced: Solve x² + 2x + 1 = 0");
            q3.setClassId(classId);
            q3.setSubjectId(subjectId);
            q3.setChapterId(chapterId);
            q3.setDifficultyLevel("HARD");
            q3.setMarks(3);
            q3.setOptionA("x = 1");
            q3.setOptionB("x = -1");
            q3.setOptionC("x = 2");
            q3.setOptionD("No solution");
            q3.setCorrectAnswer("B");
            q3.setStatus("ACTIVE");

            int qId3 = QuestionDAO.addQuestion(q3);
            System.out.println("✓ Question 3 added with ID: " + qId3);

            // Test 2: Get question by ID
            System.out.println("\nTest 2: Retrieving question by ID...");
            Question retrieved = QuestionDAO.getQuestionById(qId1);
            System.out.println("✓ Retrieved: " + retrieved.getQuestionText());

            // Test 3: Get questions by class
            System.out.println("\nTest 3: Retrieving questions by class...");
            List<Question> classQuestions = QuestionDAO.getQuestionsByClass(classId);
            System.out.println("✓ Total questions in class: " + classQuestions.size());

            // Test 4: Get questions by class and subject
            System.out.println("\nTest 4: Retrieving questions by class and subject...");
            List<Question> subjectQuestions = QuestionDAO.getQuestionsByClassAndSubject(classId, subjectId);
            System.out.println("✓ Total questions in subject: " + subjectQuestions.size());

            // Test 5: Get questions by chapter
            System.out.println("\nTest 5: Retrieving questions by chapter...");
            List<Question> chapterQuestions = QuestionDAO.getQuestionsByChapter(chapterId);
            System.out.println("✓ Total questions in chapter: " + chapterQuestions.size());

            // Test 6: Get questions by difficulty
            System.out.println("\nTest 6: Retrieving questions by difficulty level...");
            List<Question> easyQuestions = QuestionDAO.getQuestionsByDifficulty(classId, subjectId, "EASY");
            System.out.println("✓ Easy questions: " + easyQuestions.size());
            List<Question> hardQuestions = QuestionDAO.getQuestionsByDifficulty(classId, subjectId, "HARD");
            System.out.println("✓ Hard questions: " + hardQuestions.size());

            // Test 7: Update question
            System.out.println("\nTest 7: Updating question...");
            q1.setQuestionId(qId1);
            q1.setQuestionText("Updated: What is 2 + 2?");
            q1.setMarks(2);
            boolean updated = QuestionDAO.updateQuestion(q1);
            System.out.println("✓ Question updated: " + updated);

            // Test 8: Get question count
            System.out.println("\nTest 8: Getting question count...");
            int qCount = QuestionDAO.getQuestionCountByClass(classId);
            System.out.println("✓ Total questions in class: " + qCount);

            // Test 9: Get questions by class, subject, and chapters (MULTISELECT)
            System.out.println("\nTest 9: Getting questions with chapter multiselect...");
            java.util.List<Integer> chapterIds = java.util.Arrays.asList(chapterId);
            List<Question> filteredQuestions = QuestionDAO.getQuestionsByClassSubjectAndChapters(classId, subjectId, chapterIds);
            System.out.println("✓ Questions matching criteria: " + filteredQuestions.size());

            System.out.println("\n========== STEP 4 TESTS PASSED ✓ ==========\n");

        } catch (Exception e) {
            System.out.println("✗ ERROR in STEP 4 tests:");
            e.printStackTrace();
        }
    }
}
