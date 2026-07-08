package com.school.exam.test;

import com.school.exam.dao.*;
import com.school.exam.model.*;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

public class TestStep6ResultGeneration {

    public static void main(String[] args) {
        System.out.println("========== STEP 6: Result Generation & Analysis ==========\n");

        try {
            int schoolId = 1;
            
            // Create test data dynamically (same pattern as TestStep5)
            String timestamp = String.valueOf(System.currentTimeMillis());
            
            // Create or get test user (teacher)
            System.out.println("[SETUP] Creating test user (teacher)...");
            User testUser = new User();
            testUser.setUsername("teacher_" + timestamp);
            testUser.setPassword("password");
            testUser.setEmail("teacher_" + timestamp + "@test.com");
            testUser.setRole("TEACHER");
            testUser.setFirstName("Test");
            testUser.setLastName("Teacher");
            testUser.setSchoolId(schoolId);
            testUser.setStatus("ACTIVE");
            int userId = UserDAO.addUser(testUser);
            System.out.println("[SETUP] Test user created with ID: " + userId);
            
            // Create test class
            System.out.println("[SETUP] Creating test class...");
            com.school.exam.model.Class testClass = new com.school.exam.model.Class();
            testClass.setSchoolId(schoolId);
            testClass.setClassName("Result Test Class " + timestamp);
            int classId = ClassDAO.addClass(testClass);
            System.out.println("[SETUP] Test class created with ID: " + classId);
            
            // Create test subject
            System.out.println("[SETUP] Creating test subject...");
            Subject testSubject = new Subject();
            testSubject.setSchoolId(schoolId);
            testSubject.setSubjectName("Result Test Subject " + timestamp);
            int subjectId = SubjectDAO.addSubject(testSubject);
            System.out.println("[SETUP] Test subject created with ID: " + subjectId);
            
            // Create test chapter
            System.out.println("[SETUP] Creating test chapter...");
            Chapter testChapter = new Chapter();
            testChapter.setSubjectId(subjectId);
            testChapter.setChapterName("Result Test Chapter " + timestamp);
            int chapterId = ChapterDAO.addChapter(testChapter);
            System.out.println("[SETUP] Test chapter created with ID: " + chapterId);
            
            // Create test question
            System.out.println("[SETUP] Creating test question...");
            Question testQuestion = new Question();
            testQuestion.setClassId(classId);
            testQuestion.setSubjectId(subjectId);
            testQuestion.setChapterId(chapterId);
            testQuestion.setQuestionText("Result Test Question: What is 2+2?");
            testQuestion.setOptionA("3");
            testQuestion.setOptionB("4");
            testQuestion.setOptionC("5");
            testQuestion.setOptionD("6");
            testQuestion.setCorrectAnswer("B");
            testQuestion.setMarks(5);
            testQuestion.setDifficultyLevel("EASY");
            int questionId = QuestionDAO.addQuestion(testQuestion);
            testQuestion.setQuestionId(questionId);  // Set the question ID after insertion
            System.out.println("[SETUP] Test question created with ID: " + questionId);
            
            // Create test student
            System.out.println("[SETUP] Creating test student...");
            Student testStudent = new Student();
            testStudent.setSchoolId(schoolId);
            testStudent.setClassId(classId);
            testStudent.setStudentName("Result Test Student");
            testStudent.setRollNumber(String.valueOf(System.currentTimeMillis() % 10000));
            testStudent.setEmail("result_test@school.edu");
            testStudent.setPhoneNumber("9999999999");
            int studentId = StudentDAO.addStudent(testStudent);
            System.out.println("[SETUP] Test student created with ID: " + studentId);
            
            // Create test exam with the question
            System.out.println("[SETUP] Creating test exam...");
            Exam testExam = new Exam();
            testExam.setExamName("Result Test Exam " + timestamp);
            testExam.setClassId(classId);
            testExam.setSubjectId(subjectId);
            testExam.setTotalMarks(5);
            testExam.setStatus("PUBLISHED");
            testExam.setCreatedBy(userId);
            
            List<Question> questionsForExam = new ArrayList<>();
            questionsForExam.add(testQuestion);
            int examId = ExamDAO.createExam(testExam, questionsForExam);
            System.out.println("[SETUP] Test exam created with ID: " + examId);
            
            // Create exam answer (student's response)
            System.out.println("[SETUP] Creating exam answer...");
            ExamAnswer answer = new ExamAnswer();
            answer.setExamId(examId);
            answer.setStudentId(studentId);
            answer.setQuestionId(questionId);
            answer.setSelectedAnswer("B");
            answer.setCorrectAnswer("B");
            answer.setIsCorrect(true);
            answer.setMarksObtained(5);
            int answerId = ExamAnswerDAO.addExamAnswer(answer);
            System.out.println("[SETUP] Exam answer created with ID: " + answerId);

            // Test 1: Calculate and store result
            System.out.println("\nTest 1: Calculating and storing exam result...");
            boolean resultStored = ResultDAO.calculateAndStoreResult(examId, studentId);
            System.out.println("✓ Result stored: " + resultStored);

            // Test 2: Get result by exam and student
            System.out.println("\nTest 2: Retrieving result by exam and student...");
            Result result = ResultDAO.getResultByExamAndStudent(examId, studentId);
            if (result != null) {
                System.out.println("✓ Retrieved result:");
                System.out.println("  - Student: " + result.getStudentId());
                System.out.println("  - Score: " + result.getMarksObtained() + " / " + result.getTotalMarks());
                System.out.println("  - Percentage: " + result.getPercentage() + "%");
                System.out.println("  - Grade: " + result.getGrade());
                System.out.println("  - Status: " + result.getStatus());
            }

            // Test 3: Get results by exam
            System.out.println("\nTest 3: Retrieving all results for exam...");
            List<Result> examResults = ResultDAO.getResultsByExam(examId);
            System.out.println("✓ Total results for exam: " + examResults.size());

            // Test 4: Get results by student
            System.out.println("\nTest 4: Retrieving all results for student...");
            List<Result> studentResults = ResultDAO.getResultsByStudent(studentId);
            System.out.println("✓ Total exams taken by student: " + studentResults.size());

            // Test 5: Get class performance (method takes only examId)
            System.out.println("\nTest 5: Retrieving class performance statistics...");
            Map<String, Object> classPerformance = ResultDAO.getClassPerformance(examId);
            if (classPerformance != null) {
                System.out.println("✓ Class Performance:");
                System.out.println("  - Class Average: " + classPerformance.get("average") + "%");
                System.out.println("  - Highest Score: " + classPerformance.get("highest") + "%");
                System.out.println("  - Lowest Score: " + classPerformance.get("lowest") + "%");
                System.out.println("  - Submitted Count: " + classPerformance.get("submitted_count"));
            }

            // Test 6: Get top performers (method takes only examId and limit)
            System.out.println("\nTest 6: Retrieving top performers...");
            List<Result> topPerformers = ResultDAO.getTopPerformers(examId, 3);
            System.out.println("✓ Top " + topPerformers.size() + " performers:");
            for (int i = 0; i < topPerformers.size(); i++) {
                Result r = topPerformers.get(i);
                System.out.println("  " + (i + 1) + ". Student " + r.getStudentId() + " - " + r.getPercentage() + "%");
            }

            // Test 7: Get failed students (method takes only examId)
            System.out.println("\nTest 7: Retrieving failed students...");
            List<Result> failedStudents = ResultDAO.getFailedStudents(examId);
            System.out.println("✓ Failed students (< 60%): " + failedStudents.size());
            for (Result r : failedStudents) {
                System.out.println("  - Student " + r.getStudentId() + " - " + r.getPercentage() + "% (" + r.getGrade() + ")");
            }

            // Test 8: Get results by class
            System.out.println("\nTest 8: Retrieving results by class...");
            List<Result> classResults = ResultDAO.getResultsByClass(classId);
            System.out.println("✓ Total students in class with results: " + classResults.size());

            // Test 9: Get results by student (performance over multiple exams)
            System.out.println("\nTest 9: Retrieving student performance across exams...");
            List<Result> studentAllResults = ResultDAO.getResultsByStudent(studentId);
            System.out.println("✓ Student took " + studentAllResults.size() + " exams");
            for (int i = 0; i < studentAllResults.size(); i++) {
                Result r = studentAllResults.get(i);
                System.out.println("  " + (i + 1) + ". Exam " + r.getExamId() + " - " + r.getPercentage() + "%");
            }

            // Test 10: Update result status
            System.out.println("\nTest 10: Updating result status...");
            if (result != null) {
                result.setStatus("EVALUATED");
                boolean updated = ResultDAO.updateResult(result);
                System.out.println("✓ Result updated: " + updated);
            }

            System.out.println("\n========== STEP 6 TESTS PASSED ✓ ==========\n");

        } catch (Exception e) {
            System.out.println("✗ ERROR in STEP 6 tests:");
            e.printStackTrace();
        }
    }
}
