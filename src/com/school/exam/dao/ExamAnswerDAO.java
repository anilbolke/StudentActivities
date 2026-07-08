package com.school.exam.dao;

import com.school.exam.model.ExamAnswer;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExamAnswerDAO {

    /**
     * Add a single exam answer
     */
    public static int addExamAnswer(ExamAnswer answer) {
        String sql = "INSERT INTO exam_answers (exam_id, student_id, question_id, selected_answer, " +
                "correct_answer, is_correct, marks_obtained, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, answer.getExamId());
            pstmt.setInt(2, answer.getStudentId());
            pstmt.setInt(3, answer.getQuestionId());
            pstmt.setString(4, answer.getSelectedAnswer());
            pstmt.setString(5, answer.getCorrectAnswer());
            pstmt.setBoolean(6, answer.getIsCorrect() != null ? answer.getIsCorrect() : false);
            pstmt.setInt(7, answer.getMarksObtained());
            pstmt.setString(8, answer.getStatus() != null ? answer.getStatus() : "ATTEMPTED");

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    /**
     * Batch insert multiple answers (for exam submission)
     */
    public static boolean batchInsertAnswers(List<ExamAnswer> answers) {
        String sql = "INSERT INTO exam_answers (exam_id, student_id, question_id, selected_answer, " +
                "correct_answer, is_correct, marks_obtained, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (ExamAnswer answer : answers) {
                pstmt.setInt(1, answer.getExamId());
                pstmt.setInt(2, answer.getStudentId());
                pstmt.setInt(3, answer.getQuestionId());
                pstmt.setString(4, answer.getSelectedAnswer());
                pstmt.setString(5, answer.getCorrectAnswer());
                pstmt.setBoolean(6, answer.getIsCorrect() != null ? answer.getIsCorrect() : false);
                pstmt.setInt(7, answer.getMarksObtained());
                pstmt.setString(8, answer.getStatus() != null ? answer.getStatus() : "ATTEMPTED");
                pstmt.addBatch();
            }

            int[] results = pstmt.executeBatch();
            return results.length == answers.size();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get all answers for an exam
     */
    public static List<ExamAnswer> getExamAnswersByExam(int examId) {
        List<ExamAnswer> answers = new ArrayList<>();
        String sql = "SELECT * FROM exam_answers WHERE exam_id = ? ORDER BY student_id, question_id";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    answers.add(extractExamAnswerFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return answers;
    }

    /**
     * Get all answers submitted by a student for a specific exam
     */
    public static List<ExamAnswer> getStudentAnswersForExam(int examId, int studentId) {
        List<ExamAnswer> answers = new ArrayList<>();
        String sql = "SELECT * FROM exam_answers WHERE exam_id = ? AND student_id = ? ORDER BY question_id";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);
            pstmt.setInt(2, studentId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    answers.add(extractExamAnswerFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return answers;
    }

    /**
     * Calculate exam score for a student
     * Returns: [correct_count, wrong_count, total_marks_obtained, total_possible_marks]
     */
    public static int[] calculateExamScore(int examId, int studentId) {
        String sql = "SELECT " +
                "COUNT(*) as total_questions, " +
                "SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct_answers, " +
                "SUM(CASE WHEN is_correct THEN marks_obtained ELSE 0 END) as marks_obtained " +
                "FROM exam_answers WHERE exam_id = ? AND student_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);
            pstmt.setInt(2, studentId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int totalQuestions = rs.getInt("total_questions");
                    int correctAnswers = rs.getInt("correct_answers");
                    int marksObtained = rs.getInt("marks_obtained");
                    int wrongAnswers = totalQuestions - correctAnswers;

                    return new int[]{correctAnswers, wrongAnswers, marksObtained, totalQuestions};
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return new int[]{0, 0, 0, 0};
    }

    /**
     * Get percentage score for a student's exam
     */
    public static double getExamPercentage(int examId, int studentId) {
        String sql = "SELECT e.total_marks, SUM(ea.marks_obtained) as marks_obtained " +
                "FROM exam_answers ea " +
                "JOIN exams e ON ea.exam_id = e.exam_id " +
                "WHERE ea.exam_id = ? AND ea.student_id = ? " +
                "GROUP BY e.exam_id";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);
            pstmt.setInt(2, studentId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int totalMarks = rs.getInt("total_marks");
                    int marksObtained = rs.getInt("marks_obtained");
                    
                    if (totalMarks > 0) {
                        return (double) (marksObtained * 100) / totalMarks;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0.0;
    }

    /**
     * Extract ExamAnswer object from ResultSet
     */
    private static ExamAnswer extractExamAnswerFromResultSet(ResultSet rs) throws SQLException {
        ExamAnswer answer = new ExamAnswer();

        answer.setAnswerId(rs.getInt("answer_id"));
        answer.setExamId(rs.getInt("exam_id"));
        answer.setStudentId(rs.getInt("student_id"));
        answer.setQuestionId(rs.getInt("question_id"));
        answer.setSelectedAnswer(rs.getString("selected_answer"));
        answer.setCorrectAnswer(rs.getString("correct_answer"));
        
        boolean isCorrect = rs.getBoolean("is_correct");
        answer.setIsCorrect(rs.wasNull() ? null : isCorrect);
        
        answer.setMarksObtained(rs.getInt("marks_obtained"));
        
        int timeTaken = rs.getInt("time_taken_seconds");
        answer.setTimeTakenSeconds(rs.wasNull() ? null : timeTaken);
        
        answer.setAttemptNumber(rs.getInt("attempt_number"));
        answer.setStatus(rs.getString("status"));

        Timestamp answeredAt = rs.getTimestamp("answered_at");
        if (answeredAt != null) {
            answer.setAnsweredAt(answeredAt.toLocalDateTime());
        }

        return answer;
    }
}
