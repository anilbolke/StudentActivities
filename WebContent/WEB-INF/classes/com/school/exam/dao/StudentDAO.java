package com.school.exam.dao;

import com.school.exam.model.Student;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {

    /**
     * Add a new student to the database
     */
    public static int addStudent(Student student) {
        String sql = "INSERT INTO students " +
                "(student_name, roll_number, school_id, class_id, email, phone_number, " +
                "date_of_birth, address, city, gender, father_name, father_contact, " +
                "mother_name, mother_contact, enrollment_date, status, created_by) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, student.getStudentName());
            pstmt.setString(2, student.getRollNumber());
            pstmt.setInt(3, student.getSchoolId());
            
            if (student.getClassId() != null) {
                pstmt.setInt(4, student.getClassId());
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }
            
            pstmt.setString(5, student.getEmail());
            pstmt.setString(6, student.getPhoneNumber());
            
            if (student.getDateOfBirth() != null) {
                pstmt.setDate(7, Date.valueOf(student.getDateOfBirth()));
            } else {
                pstmt.setNull(7, Types.DATE);
            }
            
            pstmt.setString(8, student.getAddress());
            pstmt.setString(9, student.getCity());
            pstmt.setString(10, student.getGender());
            pstmt.setString(11, student.getFatherName());
            pstmt.setString(12, student.getFatherContact());
            pstmt.setString(13, student.getMotherName());
            pstmt.setString(14, student.getMotherContact());
            
            if (student.getEnrollmentDate() != null) {
                pstmt.setDate(15, Date.valueOf(student.getEnrollmentDate()));
            } else {
                pstmt.setDate(15, Date.valueOf(LocalDate.now()));
            }
            
            pstmt.setString(16, student.getStatus() != null ? student.getStatus() : "ACTIVE");
            pstmt.setInt(17, student.getCreatedBy());

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
     * Get student by ID
     */
    public static Student getStudentById(int studentId) {
        String sql = "SELECT * FROM students WHERE student_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractStudentFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Get all students for a school
     */
    public static List<Student> getStudentsBySchool(int schoolId) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students WHERE school_id = ? ORDER BY student_name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, schoolId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    students.add(extractStudentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return students;
    }

    /**
     * Get all students for a school and class
     */
    public static List<Student> getStudentsBySchoolAndClass(int schoolId, int classId) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students WHERE school_id = ? AND class_id = ? ORDER BY student_name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, schoolId);
            pstmt.setInt(2, classId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    students.add(extractStudentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return students;
    }

    /**
     * Update student information
     */
    public static boolean updateStudent(Student student) {
        String sql = "UPDATE students SET " +
                "student_name = ?, roll_number = ?, class_id = ?, email = ?, " +
                "phone_number = ?, date_of_birth = ?, address = ?, city = ?, " +
                "gender = ?, father_name = ?, father_contact = ?, " +
                "mother_name = ?, mother_contact = ?, status = ? " +
                "WHERE student_id = ? AND school_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, student.getStudentName());
            pstmt.setString(2, student.getRollNumber());
            
            if (student.getClassId() != null) {
                pstmt.setInt(3, student.getClassId());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            
            pstmt.setString(4, student.getEmail());
            pstmt.setString(5, student.getPhoneNumber());
            
            if (student.getDateOfBirth() != null) {
                pstmt.setDate(6, Date.valueOf(student.getDateOfBirth()));
            } else {
                pstmt.setNull(6, Types.DATE);
            }
            
            pstmt.setString(7, student.getAddress());
            pstmt.setString(8, student.getCity());
            pstmt.setString(9, student.getGender());
            pstmt.setString(10, student.getFatherName());
            pstmt.setString(11, student.getFatherContact());
            pstmt.setString(12, student.getMotherName());
            pstmt.setString(13, student.getMotherContact());
            pstmt.setString(14, student.getStatus());
            pstmt.setInt(15, student.getStudentId());
            pstmt.setInt(16, student.getSchoolId());
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Delete a student
     */
    public static boolean deleteStudent(int studentId, int schoolId) {
        String sql = "DELETE FROM students WHERE student_id = ? AND school_id = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentId);
            pstmt.setInt(2, schoolId);
            
            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * Check if roll number exists for a school
     */
    public static boolean isRollNumberExists(String rollNumber, int schoolId, int excludeStudentId) {
        String sql = "SELECT COUNT(*) FROM students WHERE roll_number = ? AND school_id = ? AND student_id != ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, rollNumber);
            pstmt.setInt(2, schoolId);
            pstmt.setInt(3, excludeStudentId);
            
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
     * Search students by name
     */
    public static List<Student> searchStudents(int schoolId, String searchTerm) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students WHERE school_id = ? AND " +
                "(LOWER(student_name) LIKE ? OR LOWER(email) LIKE ? OR roll_number LIKE ?) " +
                "ORDER BY student_name ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + searchTerm.toLowerCase() + "%";
            pstmt.setInt(1, schoolId);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            pstmt.setString(4, searchPattern);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    students.add(extractStudentFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return students;
    }

    /**
     * Extract Student object from ResultSet
     */
    private static Student extractStudentFromResultSet(ResultSet rs) throws SQLException {
        Student student = new Student();
        
        student.setStudentId(rs.getInt("student_id"));
        student.setStudentName(rs.getString("student_name"));
        student.setRollNumber(rs.getString("roll_number"));
        student.setSchoolId(rs.getInt("school_id"));
        
        int classId = rs.getInt("class_id");
        student.setClassId(rs.wasNull() ? null : classId);
        
        student.setEmail(rs.getString("email"));
        student.setPhoneNumber(rs.getString("phone_number"));
        
        Date dob = rs.getDate("date_of_birth");
        if (dob != null) {
            student.setDateOfBirth(dob.toLocalDate());
        }
        
        student.setAddress(rs.getString("address"));
        student.setCity(rs.getString("city"));
        student.setGender(rs.getString("gender"));
        student.setFatherName(rs.getString("father_name"));
        student.setFatherContact(rs.getString("father_contact"));
        student.setMotherName(rs.getString("mother_name"));
        student.setMotherContact(rs.getString("mother_contact"));
        
        Date enrollmentDate = rs.getDate("enrollment_date");
        if (enrollmentDate != null) {
            student.setEnrollmentDate(enrollmentDate.toLocalDate());
        }
        
        student.setStatus(rs.getString("status"));
        student.setCreatedBy(rs.getInt("created_by"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            student.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            student.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return student;
    }
}
