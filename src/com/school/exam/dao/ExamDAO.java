package com.school.exam.dao;

import com.school.exam.model.Exam;
import com.school.exam.model.Question;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExamDAO {

    /**
     * Create a new exam with selected questions
     * This creates the exam record and maps selected questions to it
     */
    public static int createExam(Exam exam, List<Question> selectedQuestions) {
        String sql = "INSERT INTO exams (exam_name, class_id, subject_id, question_count, total_marks, " +
                "difficulty_level, duration_minutes, status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, exam.getExamName());
            pstmt.setInt(2, exam.getClassId());
            pstmt.setInt(3, exam.getSubjectId());
            pstmt.setInt(4, selectedQuestions.size());
            pstmt.setInt(5, exam.getTotalMarks());
            pstmt.setString(6, exam.getDifficultyLevel());
            
            if (exam.getDurationMinutes() != null) {
                pstmt.setInt(7, exam.getDurationMinutes());
            } else {
                pstmt.setNull(7, Types.INTEGER);
            }
            
            pstmt.setString(8, exam.getStatus() != null ? exam.getStatus() : "PUBLISHED");
            pstmt.setInt(9, exam.getCreatedBy());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int examId = generatedKeys.getInt(1);
                        
                        // Now map questions to this exam
                        if (mapQuestionsToExam(conn, examId, selectedQuestions)) {
                            return examId;
                        } else {
                            // Rollback if question mapping fails
                            deleteExam(examId);
                            return -1;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    /**
     * Map questions to an exam (internal helper)
     */
    private static boolean mapQuestionsToExam(Connection conn, int examId, List<Question> questions) {
        String sql = "INSERT INTO exam_questions_map (exam_id, question_id, question_sequence, question_marks) VALUES (?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int sequence = 1;
            for (Question question : questions) {
                pstmt.setInt(1, examId);
                pstmt.setInt(2, question.getQuestionId());
                pstmt.setInt(3, sequence);
                pstmt.setInt(4, question.getMarks());
                pstmt.addBatch();
                sequence++;
            }
            
            int[] results = pstmt.executeBatch();
            return results.length == questions.size();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get exam by ID with full details
     */
    public static Exam getExamById(int examId) {
        String sql = "SELECT * FROM exams WHERE exam_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractExamFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all exams created by a teacher
     */
    public static List<Exam> getExamsByTeacher(int teacherId) {
        List<Exam> exams = new ArrayList<>();
        String sql = "SELECT * FROM exams WHERE created_by = ? ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, teacherId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    exams.add(extractExamFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return exams;
    }

    /**
     * Get all published exams for a class
     */
    public static List<Exam> getExamsByClass(int classId) {
        List<Exam> exams = new ArrayList<>();
        String sql = "SELECT * FROM exams WHERE class_id = ? AND status = 'PUBLISHED' ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    exams.add(extractExamFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return exams;
    }

    /**
     * Get questions for an exam in order
     */
    public static List<Question> getExamQuestions(int examId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT q.*, eq.question_sequence, eq.question_marks " +
                "FROM exam_questions_map eq " +
                "JOIN questions q ON eq.question_id = q.question_id " +
                "WHERE eq.exam_id = ? " +
                "ORDER BY eq.question_sequence";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(QuestionDAO.extractQuestionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return questions;
    }

    /**
     * Update exam status (DRAFT → PUBLISHED → ARCHIVED)
     */
    public static boolean updateExamStatus(int examId, String status) {
        String sql = "UPDATE exams SET status = ? WHERE exam_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, examId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete an exam and its associated questions
     */
    public static boolean deleteExam(int examId) {
        String sql = "DELETE FROM exams WHERE exam_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get question count for verification
     */
    public static int getExamQuestionCount(int examId) {
        String sql = "SELECT COUNT(*) as count FROM exam_questions_map WHERE exam_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Extract Exam object from ResultSet
     */
    private static Exam extractExamFromResultSet(ResultSet rs) throws SQLException {
        Exam exam = new Exam();

        exam.setExamId(rs.getInt("exam_id"));
        exam.setExamName(rs.getString("exam_name"));
        exam.setClassId(rs.getInt("class_id"));
        exam.setSubjectId(rs.getInt("subject_id"));
        exam.setQuestionCount(rs.getInt("question_count"));
        exam.setTotalMarks(rs.getInt("total_marks"));
        exam.setDifficultyLevel(rs.getString("difficulty_level"));
        
        int duration = rs.getInt("duration_minutes");
        exam.setDurationMinutes(rs.wasNull() ? null : duration);
        
        exam.setStatus(rs.getString("status"));
        exam.setCreatedBy(rs.getInt("created_by"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            exam.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            exam.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return exam;
    }
}
