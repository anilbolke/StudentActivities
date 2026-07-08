package com.school.exam.dao;

import com.school.exam.model.Class;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ClassDAO {

    /**
     * Add a new class to the database
     */
    public static int addClass(Class cls) {
        String sql = "INSERT INTO classes (school_id, class_name, grade, section, status) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, cls.getSchoolId());
            pstmt.setString(2, cls.getClassName());
            pstmt.setInt(3, cls.getGrade());
            pstmt.setString(4, cls.getSection());
            pstmt.setString(5, cls.getStatus() != null ? cls.getStatus() : "ACTIVE");

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
     * Get class by ID
     */
    public static Class getClassById(int classId) {
        String sql = "SELECT * FROM classes WHERE class_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractClassFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get class by name (case-insensitive)
     */
    public static Class getClassByName(String className) {
        String sql = "SELECT * FROM classes WHERE LOWER(class_name) = LOWER(?) LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, className);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractClassFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get all classes for a school
     */
    public static List<Class> getClassesBySchool(int schoolId) {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT * FROM classes WHERE school_id = ? AND status = 'ACTIVE' ORDER BY grade, section";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    classes.add(extractClassFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return classes;
    }

    /**
     * Get all classes for a school (including inactive)
     */
    public static List<Class> getAllClassesBySchool(int schoolId) {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT * FROM classes WHERE school_id = ? ORDER BY grade, section";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    classes.add(extractClassFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return classes;
    }

    /**
     * Update class information
     */
    public static boolean updateClass(Class cls) {
        String sql = "UPDATE classes SET class_name = ?, grade = ?, section = ?, status = ? " +
                "WHERE class_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, cls.getClassName());
            pstmt.setInt(2, cls.getGrade());
            pstmt.setString(3, cls.getSection());
            pstmt.setString(4, cls.getStatus());
            pstmt.setInt(5, cls.getClassId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a class
     */
    public static boolean deleteClass(int classId) {
        String sql = "DELETE FROM classes WHERE class_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a class with school verification
     */
    public static boolean deleteClass(int classId, int schoolId) {
        String sql = "DELETE FROM classes WHERE class_id = ? AND school_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);
            pstmt.setInt(2, schoolId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Check if class name already exists in the school
     */
    public static boolean isClassNameExists(String className, Integer schoolId, int excludeClassId) {
        String sql = "SELECT COUNT(*) as count FROM classes WHERE class_name = ? AND school_id = ? AND class_id != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, className);
            pstmt.setInt(2, schoolId != null ? schoolId : 0);
            pstmt.setInt(3, excludeClassId);

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
     * Get class count for a school
     */
    public static int getClassCountBySchool(int schoolId) {
        String sql = "SELECT COUNT(*) as count FROM classes WHERE school_id = ? AND status = 'ACTIVE'";

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
     * Extract Class object from ResultSet
     */
    public static Class extractClassFromResultSet(ResultSet rs) throws SQLException {
        Class cls = new Class();

        cls.setClassId(rs.getInt("class_id"));
        cls.setSchoolId(rs.getInt("school_id"));
        cls.setClassName(rs.getString("class_name"));
        cls.setGrade(rs.getInt("grade"));
        cls.setSection(rs.getString("section"));
        cls.setStatus(rs.getString("status"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            cls.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            cls.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return cls;
    }
    
}
