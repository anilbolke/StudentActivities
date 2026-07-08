package com.school.exam.dao;

import com.school.exam.model.Result;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ResultDAO {

    /**
     * Calculate and store result for a student exam using stored procedure
     */
    public static boolean calculateAndStoreResult(int examId, int studentId) {
        String sql = "CALL sp_calculate_exam_result(?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             CallableStatement cstmt = conn.prepareCall(sql)) {

            cstmt.setInt(1, examId);
            cstmt.setInt(2, studentId);

            cstmt.execute();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Add a result to database (manual)
     */
    public static int addResult(Result result) {
        String sql = "INSERT INTO exam_results (exam_id, student_id, total_questions, attempted_questions, " +
                "correct_answers, wrong_answers, skipped_questions, total_marks, marks_obtained, percentage, grade, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, result.getExamId());
            pstmt.setInt(2, result.getStudentId());
            pstmt.setInt(3, result.getTotalQuestions());
            pstmt.setObject(4, result.getAttemptedQuestions());
            pstmt.setInt(5, result.getCorrectAnswers());
            pstmt.setInt(6, result.getWrongAnswers());
            pstmt.setObject(7, result.getSkippedQuestions());
            pstmt.setInt(8, result.getTotalMarks());
            pstmt.setInt(9, result.getMarksObtained());
            pstmt.setObject(10, result.getPercentage());
            pstmt.setString(11, result.getGrade());
            pstmt.setString(12, result.getStatus() != null ? result.getStatus() : "SUBMITTED");

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
     * Get result by ID
     */
    public static Result getResultById(int resultId) {
        String sql = "SELECT * FROM exam_results WHERE result_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, resultId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractResultFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get result for specific student exam
     */
    public static Result getResultByExamAndStudent(int examId, int studentId) {
        String sql = "SELECT * FROM exam_results WHERE exam_id = ? AND student_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);
            pstmt.setInt(2, studentId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractResultFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all results for an exam (class results)
     */
    public static List<Result> getResultsByExam(int examId) {
        List<Result> results = new ArrayList<>();
        String sql = "SELECT * FROM exam_results WHERE exam_id = ? ORDER BY percentage DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    /**
     * Get all results for a student across all exams
     */
    public static List<Result> getResultsByStudent(int studentId) {
        List<Result> results = new ArrayList<>();
        String sql = "SELECT * FROM exam_results WHERE student_id = ? ORDER BY completed_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studentId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    /**
     * Get all results for a class
     */
    public static List<Result> getResultsByClass(int classId) {
        List<Result> results = new ArrayList<>();
        String sql = "SELECT er.* FROM exam_results er " +
                "JOIN exams e ON er.exam_id = e.exam_id " +
                "WHERE e.class_id = ? " +
                "ORDER BY er.completed_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    /**
     * Get class performance statistics for dashboard
     */
    public static java.util.Map<String, Object> getClassPerformance(int examId) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        String sql = "SELECT " +
                "COUNT(*) as total_students, " +
                "SUM(CASE WHEN percentage IS NOT NULL THEN 1 ELSE 0 END) as submitted, " +
                "AVG(percentage) as avg_percentage, " +
                "MAX(percentage) as highest, " +
                "MIN(percentage) as lowest, " +
                "ROUND(AVG(percentage), 2) as avg_rounded, " +
                "AVG(marks_obtained) as avg_marks, " +
                "COUNT(CASE WHEN grade='A' THEN 1 END) as count_a, " +
                "COUNT(CASE WHEN grade='B' THEN 1 END) as count_b, " +
                "COUNT(CASE WHEN grade='C' THEN 1 END) as count_c, " +
                "COUNT(CASE WHEN grade='D' THEN 1 END) as count_d, " +
                "COUNT(CASE WHEN grade='F' THEN 1 END) as count_f " +
                "FROM exam_results WHERE exam_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("total_students", rs.getInt("total_students"));
                    stats.put("submitted", rs.getInt("submitted"));
                    stats.put("avg_percentage", rs.getDouble("avg_percentage"));
                    stats.put("highest", rs.getDouble("highest"));
                    stats.put("lowest", rs.getDouble("lowest"));
                    stats.put("avg_rounded", rs.getDouble("avg_rounded"));
                    stats.put("avg_marks", rs.getDouble("avg_marks"));
                    stats.put("count_a", rs.getInt("count_a"));
                    stats.put("count_b", rs.getInt("count_b"));
                    stats.put("count_c", rs.getInt("count_c"));
                    stats.put("count_d", rs.getInt("count_d"));
                    stats.put("count_f", rs.getInt("count_f"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * Get top performers
     */
    public static List<Result> getTopPerformers(int examId, int limit) {
        List<Result> results = new ArrayList<>();
        String sql = "SELECT * FROM exam_results WHERE exam_id = ? AND percentage IS NOT NULL " +
                "ORDER BY percentage DESC LIMIT ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);
            pstmt.setInt(2, limit);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    /**
     * Get students below passing grade
     */
    public static List<Result> getFailedStudents(int examId) {
        List<Result> results = new ArrayList<>();
        String sql = "SELECT * FROM exam_results WHERE exam_id = ? AND (grade='F' OR percentage < 60) " +
                "ORDER BY percentage ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, examId);

            try (java.sql.ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return results;
    }

    /**
     * Update result
     */
    public static boolean updateResult(Result result) {
        String sql = "UPDATE exam_results SET attempted_questions = ?, correct_answers = ?, " +
                "wrong_answers = ?, skipped_questions = ?, marks_obtained = ?, percentage = ?, " +
                "grade = ?, status = ?, completed_at = NOW() WHERE result_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setObject(1, result.getAttemptedQuestions());
            pstmt.setInt(2, result.getCorrectAnswers());
            pstmt.setInt(3, result.getWrongAnswers());
            pstmt.setObject(4, result.getSkippedQuestions());
            pstmt.setInt(5, result.getMarksObtained());
            pstmt.setObject(6, result.getPercentage());
            pstmt.setString(7, result.getGrade());
            pstmt.setString(8, result.getStatus());
            pstmt.setInt(9, result.getResultId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Extract Result object from ResultSet
     */
    private static Result extractResultFromResultSet(java.sql.ResultSet rs) throws SQLException {
        Result result = new Result();

        result.setResultId(rs.getInt("result_id"));
        result.setExamId(rs.getInt("exam_id"));
        result.setStudentId(rs.getInt("student_id"));
        result.setTotalQuestions(rs.getInt("total_questions"));
        
        int attempted = rs.getInt("attempted_questions");
        result.setAttemptedQuestions(rs.wasNull() ? null : attempted);
        
        result.setCorrectAnswers(rs.getInt("correct_answers"));
        result.setWrongAnswers(rs.getInt("wrong_answers"));
        
        int skipped = rs.getInt("skipped_questions");
        result.setSkippedQuestions(rs.wasNull() ? null : skipped);
        
        result.setTotalMarks(rs.getInt("total_marks"));
        result.setMarksObtained(rs.getInt("marks_obtained"));
        
        double percentage = rs.getDouble("percentage");
        result.setPercentage(rs.wasNull() ? null : percentage);
        
        result.setGrade(rs.getString("grade"));
        
        int totalTime = rs.getInt("total_time_minutes");
        result.setTotalTimeMinutes(rs.wasNull() ? null : totalTime);
        
        Timestamp startedAt = rs.getTimestamp("started_at");
        if (startedAt != null) {
            result.setStartedAt(startedAt.toLocalDateTime());
        }

        Timestamp completedAt = rs.getTimestamp("completed_at");
        if (completedAt != null) {
            result.setCompletedAt(completedAt.toLocalDateTime());
        }
        
        result.setStatus(rs.getString("status"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            result.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            result.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return result;
    }
}
