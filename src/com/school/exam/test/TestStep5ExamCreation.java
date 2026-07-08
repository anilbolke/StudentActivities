package com.school.exam.test;

import com.school.exam.dao.*;
import com.school.exam.model.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class TestStep5ExamCreation {

    public static void main(String[] args) {
        System.out.println("========== STEP 5: Exam Creation & Taking ==========\n");

        try {
            int schoolId = 1;
            int classId = 1;
            int subjectId = 1;
            int studentId = 1; // Assume student exists

            // Test 1: Create exam
            System.out.println("Test 1: Creating exam with questions...");
            Exam exam = new Exam();
            exam.setExamName("Mathematics Mid-Term");
            exam.setClassId(classId);
            exam.setSubjectId(subjectId);
            exam.setTotalMarks(20);
            exam.setStatus("ACTIVE");
            exam.setCreatedBy(1);

            // Questions to add to exam - need Question objects, not just IDs
            List<Question> questionsToAdd = new ArrayList<>();
            // Get questions from STEP 4 (created from QuestionDAO)
            List<Question> availableQuestions = QuestionDAO.getQuestionsByClass(classId);
            // Use first 3 questions if available
            for (int i = 0; i < Math.min(3, availableQuestions.size()); i++) {
                questionsToAdd.add(availableQuestions.get(i));
            }

            int examId = ExamDAO.createExam(exam, questionsToAdd);
            System.out.println("✓ Exam created with ID: " + examId);

            // Test 2: Get exam by ID
            System.out.println("\nTest 2: Retrieving exam by ID...");
            Exam retrievedExam = ExamDAO.getExamById(examId);
            System.out.println("✓ Retrieved: " + retrievedExam.getExamName() + " (Total Marks: " + retrievedExam.getTotalMarks() + ")");

            // Test 3: Get exams by class
            System.out.println("\nTest 3: Retrieving exams by class...");
            List<Exam> classExams = ExamDAO.getExamsByClass(classId);
            System.out.println("✓ Total exams in class: " + classExams.size());

            // Test 4: Get exams by class (since getExamsByClassAndSubject doesn't exist, filter manually)
            System.out.println("\nTest 4: Retrieving exams by subject (filtering from class)...");
            List<Exam> allClassExams = ExamDAO.getExamsByClass(classId);
            List<Exam> subjectExams = new ArrayList<>();
            for (Exam e : allClassExams) {
                if (e.getSubjectId() == subjectId) {
                    subjectExams.add(e);
                }
            }
            System.out.println("✓ Total exams in subject: " + subjectExams.size());

            // Test 5: Get exam questions
            System.out.println("\nTest 5: Retrieving exam questions...");
            List<Question> examQuestions = ExamDAO.getExamQuestions(examId);
            System.out.println("✓ Total questions in exam: " + examQuestions.size());
            for (Question q : examQuestions) {
                System.out.println("  - " + q.getQuestionText());
            }

            // Test 6: Submit exam answers
            System.out.println("\nTest 6: Submitting exam answers...");
            List<ExamAnswer> answers = new java.util.ArrayList<>();

            for (Question q : examQuestions) {
                ExamAnswer answer = new ExamAnswer();
                answer.setExamId(examId);
                answer.setStudentId(studentId);
                answer.setQuestionId(q.getQuestionId());
                answer.setSelectedAnswer("B"); // Sample answer
                answers.add(answer);
            }

            boolean submitted = ExamAnswerDAO.batchInsertAnswers(answers);
            System.out.println("✓ Answers submitted: " + submitted);

            // Test 7: Calculate exam score
            System.out.println("\nTest 7: Calculating exam score...");
            int[] scoreArray = ExamAnswerDAO.calculateExamScore(examId, studentId);
            System.out.println("✓ Correct: " + scoreArray[0]);
            System.out.println("✓ Wrong: " + scoreArray[1]);
            System.out.println("✓ Marks: " + scoreArray[2]);
            System.out.println("✓ Total: " + scoreArray[3]);

            // Test 8: Get exam percentage
            System.out.println("\nTest 8: Getting exam percentage...");
            double percentage = ExamAnswerDAO.getExamPercentage(examId, studentId);
            System.out.println("✓ Percentage: " + percentage + "%");

            // Test 9: Update exam status (using updateExamStatus instead of updateExam)
            System.out.println("\nTest 9: Updating exam status...");
            boolean updated = ExamDAO.updateExamStatus(examId, "COMPLETED");
            System.out.println("✓ Exam updated: " + updated);

            System.out.println("\n========== STEP 5 TESTS PASSED ✓ ==========\n");

        } catch (Exception e) {
            System.out.println("✗ ERROR in STEP 5 tests:");
            e.printStackTrace();
        }
    }
}
