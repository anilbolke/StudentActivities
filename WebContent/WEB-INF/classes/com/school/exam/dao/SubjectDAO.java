package com.school.exam.dao;

import com.school.exam.model.Subject;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SubjectDAO {

    /**
     * Add a new subject to the database
     */
    public static int addSubject(Subject subject) {
        String sql = "INSERT INTO subjects (subject_name, school_id, description, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, subject.getSubjectName());
            pstmt.setInt(2, subject.getSchoolId());
            pstmt.setString(3, subject.getDescription());
            pstmt.setString(4, subject.getStatus() != null ? subject.getStatus() : "ACTIVE");
            pstmt.setInt(5, subject.getCreatedBy());

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
     * Get subject by ID
     */
    public static Subject getSubjectById(int subjectId) {
        String sql = "SELECT * FROM subjects WHERE subject_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractSubjectFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all subjects for a school
     */
    public static List<Subject> getSubjectsBySchool(int schoolId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subjects WHERE school_id = ? ORDER BY subject_name ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    subjects.add(extractSubjectFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return subjects;
    }

    /**
     * Get all active subjects for a school
     */
    public static List<Subject> getActiveSubjectsBySchool(int schoolId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subjects WHERE school_id = ? AND status = 'ACTIVE' ORDER BY subject_name ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    subjects.add(extractSubjectFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return subjects;
    }

    /**
     * Update subject information
     */
    public static boolean updateSubject(Subject subject) {
        String sql = "UPDATE subjects SET subject_name = ?, description = ?, status = ? " +
                "WHERE subject_id = ? AND school_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, subject.getSubjectName());
            pstmt.setString(2, subject.getDescription());
            pstmt.setString(3, subject.getStatus());
            pstmt.setInt(4, subject.getSubjectId());
            pstmt.setInt(5, subject.getSchoolId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a subject
     */
    public static boolean deleteSubject(int subjectId, int schoolId) {
        String sql = "DELETE FROM subjects WHERE subject_id = ? AND school_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);
            pstmt.setInt(2, schoolId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Check if subject name exists for a school
     */
    public static boolean isSubjectNameExists(String subjectName, int schoolId, int excludeSubjectId) {
        String sql = "SELECT COUNT(*) FROM subjects WHERE subject_name = ? AND school_id = ? AND subject_id != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, subjectName);
            pstmt.setInt(2, schoolId);
            pstmt.setInt(3, excludeSubjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Search subjects by name or description
     */
    public static List<Subject> searchSubjects(int schoolId, String searchTerm) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subjects WHERE school_id = ? AND " +
                "(LOWER(subject_name) LIKE ? OR LOWER(description) LIKE ?) " +
                "ORDER BY subject_name ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            String searchPattern = "%" + searchTerm.toLowerCase() + "%";
            pstmt.setInt(1, schoolId);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    subjects.add(extractSubjectFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return subjects;
    }

    /**
     * Extract Subject object from ResultSet
     */
    private static Subject extractSubjectFromResultSet(ResultSet rs) throws SQLException {
        Subject subject = new Subject();

        subject.setSubjectId(rs.getInt("subject_id"));
        subject.setSubjectName(rs.getString("subject_name"));
        subject.setSchoolId(rs.getInt("school_id"));
        subject.setDescription(rs.getString("description"));
        subject.setStatus(rs.getString("status"));
        subject.setCreatedBy(rs.getInt("created_by"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            subject.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            subject.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return subject;
    }
}
