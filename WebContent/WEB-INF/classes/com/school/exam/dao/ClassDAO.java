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
    public static int addClass(Class classObj) {
        String sql = "INSERT INTO classes (class_name, grade, section, school_id, status) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, classObj.getClassName());
            pstmt.setInt(2, classObj.getGrade());
            pstmt.setString(3, classObj.getSection());
            pstmt.setInt(4, classObj.getSchoolId());
            pstmt.setString(5, classObj.getStatus() != null ? classObj.getStatus() : "ACTIVE");

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
     * Get all classes for a school
     */
    public static List<Class> getClassesBySchool(int schoolId) {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT * FROM classes WHERE school_id = ? ORDER BY class_name ASC";

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
    public static boolean updateClass(Class classObj) {
        String sql = "UPDATE classes SET class_name = ?, grade = ?, section = ?, status = ? " +
                "WHERE class_id = ? AND school_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, classObj.getClassName());
            pstmt.setInt(2, classObj.getGrade());
            pstmt.setString(3, classObj.getSection());
            pstmt.setString(4, classObj.getStatus());
            pstmt.setInt(5, classObj.getClassId());
            pstmt.setInt(6, classObj.getSchoolId());

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
     * Check if class name exists for a school
     */
    public static boolean isClassNameExists(String className, int schoolId, int excludeClassId) {
        String sql = "SELECT COUNT(*) FROM classes WHERE class_name = ? AND school_id = ? AND class_id != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, className);
            pstmt.setInt(2, schoolId);
            pstmt.setInt(3, excludeClassId);

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
     * Extract Class object from ResultSet
     */
    private static Class extractClassFromResultSet(ResultSet rs) throws SQLException {
        Class classObj = new Class();

        classObj.setClassId(rs.getInt("class_id"));
        classObj.setClassName(rs.getString("class_name"));
        classObj.setGrade(rs.getInt("grade"));
        classObj.setSection(rs.getString("section"));
        classObj.setSchoolId(rs.getInt("school_id"));
        classObj.setStatus(rs.getString("status"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            classObj.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            classObj.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return classObj;
    }
}
