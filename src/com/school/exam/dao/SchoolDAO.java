package com.school.exam.dao;

import com.school.exam.model.School;
import com.school.exam.util.DatabaseConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class SchoolDAO {
    
    /**
     * Get all schools
     */
    public static List<School> getAllSchools() {
        List<School> schools = new ArrayList<>();
        String query = "SELECT * FROM schools ORDER BY school_name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                schools.add(extractSchoolFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return schools;
    }
    
    /**
     * Get school by ID
     */
    public static School getSchoolById(int schoolId) {
        School school = null;
        String query = "SELECT * FROM schools WHERE school_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, schoolId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                school = extractSchoolFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return school;
    }
    
    /**
     * Add new school
     */
    public static boolean addSchool(School school) {
        String query = "INSERT INTO schools (school_name, school_code, address, city, state, pincode, " +
                      "phone, email, principal_name, principal_contact, registration_number, status, established_year) " +
                      "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, school.getSchoolName());
            pstmt.setString(2, school.getSchoolCode());
            pstmt.setString(3, school.getAddress());
            pstmt.setString(4, school.getCity());
            pstmt.setString(5, school.getState());
            pstmt.setString(6, school.getPincode());
            pstmt.setString(7, school.getPhone());
            pstmt.setString(8, school.getEmail());
            pstmt.setString(9, school.getPrincipalName());
            pstmt.setString(10, school.getPrincipalContact());
            pstmt.setString(11, school.getRegistrationNumber());
            pstmt.setString(12, school.getStatus() != null ? school.getStatus() : "ACTIVE");
            pstmt.setInt(13, school.getEstablishedYear() != null ? school.getEstablishedYear() : Calendar.getInstance().get(Calendar.YEAR));
            
            int rowsInserted = pstmt.executeUpdate();
            return rowsInserted > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Update school details
     */
    public static boolean updateSchool(School school) {
        String query = "UPDATE schools SET school_name = ?, school_code = ?, address = ?, city = ?, " +
                      "state = ?, pincode = ?, phone = ?, email = ?, principal_name = ?, " +
                      "principal_contact = ?, registration_number = ?, status = ?, established_year = ? " +
                      "WHERE school_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, school.getSchoolName());
            pstmt.setString(2, school.getSchoolCode());
            pstmt.setString(3, school.getAddress());
            pstmt.setString(4, school.getCity());
            pstmt.setString(5, school.getState());
            pstmt.setString(6, school.getPincode());
            pstmt.setString(7, school.getPhone());
            pstmt.setString(8, school.getEmail());
            pstmt.setString(9, school.getPrincipalName());
            pstmt.setString(10, school.getPrincipalContact());
            pstmt.setString(11, school.getRegistrationNumber());
            pstmt.setString(12, school.getStatus());
            pstmt.setInt(13, school.getEstablishedYear() != null ? school.getEstablishedYear() : Calendar.getInstance().get(Calendar.YEAR));
            pstmt.setInt(14, school.getSchoolId());
            
            int rowsUpdated = pstmt.executeUpdate();
            return rowsUpdated > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Delete school
     */
    public static boolean deleteSchool(int schoolId) {
        String query = "DELETE FROM schools WHERE school_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setInt(1, schoolId);
            int rowsDeleted = pstmt.executeUpdate();
            return rowsDeleted > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get school statistics
     */
    public static Map<String, Integer> getSchoolStats(int schoolId) {
        Map<String, Integer> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Count teachers
            String teacherQuery = "SELECT COUNT(*) as count FROM users WHERE school_id = ? AND role = 'TEACHER'";
            try (PreparedStatement pstmt = conn.prepareStatement(teacherQuery)) {
                pstmt.setInt(1, schoolId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    stats.put("teachers", rs.getInt("count"));
                }
            }
            
            // Count students
            String studentQuery = "SELECT COUNT(*) as count FROM students WHERE school_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(studentQuery)) {
                pstmt.setInt(1, schoolId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    stats.put("students", rs.getInt("count"));
                }
            }
            
            // Count classes
            String classQuery = "SELECT COUNT(*) as count FROM classes WHERE school_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(classQuery)) {
                pstmt.setInt(1, schoolId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    stats.put("classes", rs.getInt("count"));
                }
            }
            
            // Count exams
            String examQuery = "SELECT COUNT(*) as count FROM exams WHERE school_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(examQuery)) {
                pstmt.setInt(1, schoolId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    stats.put("exams", rs.getInt("count"));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * Get school code exists
     */
    public static boolean schoolCodeExists(String schoolCode) {
        String query = "SELECT COUNT(*) as count FROM schools WHERE school_code = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, schoolCode);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Get school code exists (excluding current school)
     */
    public static boolean schoolCodeExistsForOtherSchool(String schoolCode, int schoolId) {
        String query = "SELECT COUNT(*) as count FROM schools WHERE school_code = ? AND school_id != ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            
            pstmt.setString(1, schoolCode);
            pstmt.setInt(2, schoolId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * Helper method to extract School object from ResultSet
     */
    private static School extractSchoolFromResultSet(ResultSet rs) throws SQLException {
        School school = new School();
        school.setSchoolId(rs.getInt("school_id"));
        school.setSchoolName(rs.getString("school_name"));
        school.setSchoolCode(rs.getString("school_code"));
        school.setAddress(rs.getString("address"));
        school.setCity(rs.getString("city"));
        school.setState(rs.getString("state"));
        school.setPincode(rs.getString("pincode"));
        school.setPhone(rs.getString("phone"));
        school.setEmail(rs.getString("email"));
        school.setPrincipalName(rs.getString("principal_name"));
        school.setPrincipalContact(rs.getString("principal_contact"));
        school.setRegistrationNumber(rs.getString("registration_number"));
        school.setStatus(rs.getString("status"));
        school.setEstablishedYear(rs.getInt("established_year"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            school.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            school.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return school;
    }
}
