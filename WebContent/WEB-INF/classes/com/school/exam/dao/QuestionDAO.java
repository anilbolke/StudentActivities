package com.school.exam.dao;

import com.school.exam.model.Question;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class QuestionDAO {

    /**
     * Add a new question to the database
     */
    public static int addQuestion(Question question) {
        String sql = "INSERT INTO questions (question_text, class_id, subject_id, chapter_id, " +
                "difficulty_level, marks, option_a, option_b, option_c, option_d, correct_answer, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, question.getQuestionText());
            pstmt.setInt(2, question.getClassId());
            pstmt.setInt(3, question.getSubjectId());
            
            if (question.getChapterId() != null) {
                pstmt.setInt(4, question.getChapterId());
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }
            
            pstmt.setString(5, question.getDifficultyLevel());
            pstmt.setInt(6, question.getMarks() > 0 ? question.getMarks() : 1);
            pstmt.setString(7, question.getOptionA());
            pstmt.setString(8, question.getOptionB());
            pstmt.setString(9, question.getOptionC());
            pstmt.setString(10, question.getOptionD());
            pstmt.setString(11, question.getCorrectAnswer());
            pstmt.setString(12, question.getStatus() != null ? question.getStatus() : "ACTIVE");
            pstmt.setInt(13, question.getCreatedBy());

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
     * Get question by ID
     */
    public static Question getQuestionById(int questionId) {
        String sql = "SELECT * FROM questions WHERE question_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, questionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractQuestionFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all questions for a class
     */
    public static List<Question> getQuestionsByClass(int classId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE class_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(extractQuestionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return questions;
    }

    /**
     * Get questions by class and subject
     */
    public static List<Question> getQuestionsByClassAndSubject(int classId, int subjectId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE class_id = ? AND subject_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);
            pstmt.setInt(2, subjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(extractQuestionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return questions;
    }

    /**
     * Get questions by class, subject, and chapters (MULTISELECT)
     * This is critical for STEP 5 exam creation
     */
    public static List<Question> getQuestionsByClassSubjectAndChapters(int classId, int subjectId, List<Integer> chapterIds) {
        List<Question> questions = new ArrayList<>();
        
        if (chapterIds == null || chapterIds.isEmpty()) {
            return questions;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < chapterIds.size(); i++) {
            if (i > 0) placeholders.append(",");
            placeholders.append("?");
        }

        String sql = "SELECT * FROM questions WHERE class_id = ? AND subject_id = ? AND chapter_id IN (" + placeholders + ") AND status = 'ACTIVE' ORDER BY RAND()";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);
            pstmt.setInt(2, subjectId);
            
            for (int i = 0; i < chapterIds.size(); i++) {
                pstmt.setInt(3 + i, chapterIds.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(extractQuestionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return questions;
    }

    /**
     * Get questions by difficulty level
     */
    public static List<Question> getQuestionsByDifficulty(int classId, int subjectId, String difficulty) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE class_id = ? AND subject_id = ? AND difficulty_level = ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);
            pstmt.setInt(2, subjectId);
            pstmt.setString(3, difficulty);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(extractQuestionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return questions;
    }

    /**
     * Get questions by chapter
     */
    public static List<Question> getQuestionsByChapter(int chapterId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE chapter_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, chapterId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    questions.add(extractQuestionFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return questions;
    }

    /**
     * Update question information
     */
    public static boolean updateQuestion(Question question) {
        String sql = "UPDATE questions SET question_text = ?, chapter_id = ?, difficulty_level = ?, marks = ?, " +
                "option_a = ?, option_b = ?, option_c = ?, option_d = ?, correct_answer = ?, status = ? " +
                "WHERE question_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, question.getQuestionText());
            
            if (question.getChapterId() != null) {
                pstmt.setInt(2, question.getChapterId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            
            pstmt.setString(3, question.getDifficultyLevel());
            pstmt.setInt(4, question.getMarks());
            pstmt.setString(5, question.getOptionA());
            pstmt.setString(6, question.getOptionB());
            pstmt.setString(7, question.getOptionC());
            pstmt.setString(8, question.getOptionD());
            pstmt.setString(9, question.getCorrectAnswer());
            pstmt.setString(10, question.getStatus());
            pstmt.setInt(11, question.getQuestionId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a question
     */
    public static boolean deleteQuestion(int questionId) {
        String sql = "DELETE FROM questions WHERE question_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, questionId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Get question count for a class
     */
    public static int getQuestionCountByClass(int classId) {
        String sql = "SELECT COUNT(*) as count FROM questions WHERE class_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

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
     * Extract Question object from ResultSet
     */
    private static Question extractQuestionFromResultSet(ResultSet rs) throws SQLException {
        Question question = new Question();

        question.setQuestionId(rs.getInt("question_id"));
        question.setQuestionText(rs.getString("question_text"));
        question.setClassId(rs.getInt("class_id"));
        question.setSubjectId(rs.getInt("subject_id"));
        
        int chapterId = rs.getInt("chapter_id");
        question.setChapterId(rs.wasNull() ? null : chapterId);
        
        question.setDifficultyLevel(rs.getString("difficulty_level"));
        question.setMarks(rs.getInt("marks"));
        question.setOptionA(rs.getString("option_a"));
        question.setOptionB(rs.getString("option_b"));
        question.setOptionC(rs.getString("option_c"));
        question.setOptionD(rs.getString("option_d"));
        question.setCorrectAnswer(rs.getString("correct_answer"));
        question.setStatus(rs.getString("status"));
        question.setCreatedBy(rs.getInt("created_by"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            question.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            question.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return question;
    }
}
