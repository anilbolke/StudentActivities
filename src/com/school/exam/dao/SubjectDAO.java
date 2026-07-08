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
        String sql = "INSERT INTO subjects (school_id, subject_name, description, status) " +
                "VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, subject.getSchoolId());
            pstmt.setString(2, subject.getSubjectName());
            pstmt.setString(3, subject.getDescription());
            pstmt.setString(4, subject.getStatus() != null ? subject.getStatus() : "ACTIVE");

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
     * Get subject by name (case-insensitive)
     */
    public static Subject getSubjectByName(String subjectName) {
        String sql = "SELECT * FROM subjects WHERE LOWER(subject_name) = LOWER(?) LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, subjectName);

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
        String sql = "SELECT * FROM subjects WHERE school_id = ? AND status = 'ACTIVE' ORDER BY subject_name";

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
     * ✅ Get ALL subjects for a school (with or without questions)
     * Shows ALL ACTIVE subjects from THAT SCHOOL
     * No teacher filtering at subject level - all school subjects visible
     * (Filtering happens at chapter/question level)
     */
    public static List<Subject> getSubjectsBySchoolForTeacher(int schoolId, Integer teacherId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT DISTINCT s.* FROM subjects s " +
                     "WHERE s.status = 'ACTIVE' " +
                     "AND s.school_id = ? " +
                     "ORDER BY s.subject_name";

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
     * Get all subjects for a school (including inactive)
     */
    public static List<Subject> getAllSubjectsBySchool(int schoolId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subjects WHERE school_id = ? ORDER BY subject_name";

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
                "WHERE subject_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, subject.getSubjectName());
            pstmt.setString(2, subject.getDescription());
            pstmt.setString(3, subject.getStatus());
            pstmt.setInt(4, subject.getSubjectId());

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
    public static boolean deleteSubject(int subjectId) {
        String sql = "DELETE FROM subjects WHERE subject_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a subject with school verification
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
     * Check if subject name already exists in the school
     */
    public static boolean isSubjectNameExists(String subjectName, Integer schoolId, int excludeSubjectId) {
        String sql = "SELECT COUNT(*) as count FROM subjects WHERE subject_name = ? AND school_id = ? AND subject_id != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, subjectName);
            pstmt.setInt(2, schoolId != null ? schoolId : 0);
            pstmt.setInt(3, excludeSubjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Search subjects by name
     */
    public static List<Subject> searchSubjects(int schoolId, String searchTerm) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT * FROM subjects WHERE school_id = ? AND subject_name LIKE ? AND status = 'ACTIVE' ORDER BY subject_name";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);
            pstmt.setString(2, "%" + searchTerm + "%");

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
     * Get subject count for a school
     */
    public static int getSubjectCountBySchool(int schoolId) {
        String sql = "SELECT COUNT(*) as count FROM subjects WHERE school_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);

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
     * Extract Subject object from ResultSet
     */
    public static Subject extractSubjectFromResultSet(ResultSet rs) throws SQLException {
        Subject subject = new Subject();

        subject.setSubjectId(rs.getInt("subject_id"));
        subject.setSchoolId(rs.getInt("school_id"));
        subject.setSubjectName(rs.getString("subject_name"));
        subject.setDescription(rs.getString("description"));
        subject.setStatus(rs.getString("status"));

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
