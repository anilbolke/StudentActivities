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
        String sql = "INSERT INTO students (school_id, class_id, student_name, roll_number, email, phone_number, " +
                "date_of_birth, address, city, gender, father_name, father_contact, " +
                "mother_name, mother_contact, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, student.getSchoolId());
            
            if (student.getClassId() != null) {
                pstmt.setInt(2, student.getClassId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            
            pstmt.setString(3, student.getStudentName());
            pstmt.setString(4, student.getRollNumber());
            pstmt.setString(5, student.getEmail());
            pstmt.setString(6, student.getPhoneNumber());
            
            if (student.getDateOfBirth() != null) {
                pstmt.setDate(7, java.sql.Date.valueOf(student.getDateOfBirth()));
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
            pstmt.setString(15, student.getStatus() != null ? student.getStatus() : "ACTIVE");

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
        String sql = "SELECT * FROM students WHERE school_id = ? AND status = 'ACTIVE' ORDER BY student_name";

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
     * Get students by class
     */
    public static List<Student> getStudentsByClass(int classId) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students WHERE class_id = ? AND status = 'ACTIVE' ORDER BY roll_number";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, classId);

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
        String sql = "UPDATE students SET student_name = ?, roll_number = ?, class_id = ?, email = ?, " +
                "phone_number = ?, date_of_birth = ?, address = ?, city = ?, " +
                "gender = ?, father_name = ?, father_contact = ?, mother_name = ?, mother_contact = ?, status = ? " +
                "WHERE student_id = ?";

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
                pstmt.setDate(6, java.sql.Date.valueOf(student.getDateOfBirth()));
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
    public static boolean deleteStudent(int studentId) {
        String sql = "DELETE FROM students WHERE student_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, studentId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a student with school verification
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
     * Search students by name
     */
    public static List<Student> searchStudents(int schoolId, String searchTerm) {
        return searchStudentsByName(schoolId, searchTerm);
    }

    /**
     * Search students by name
     */
    public static List<Student> searchStudentsByName(int schoolId, String searchName) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students WHERE school_id = ? AND student_name LIKE ? AND status = 'ACTIVE'";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, schoolId);
            pstmt.setString(2, "%" + searchName + "%");

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
     * Get student count for a school
     */
    public static int getStudentCountBySchool(int schoolId) {
        String sql = "SELECT COUNT(*) as count FROM students WHERE school_id = ? AND status = 'ACTIVE'";

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
     * Check if roll number already exists in the school
     */
    public static boolean isRollNumberExists(String rollNumber, Integer schoolId, int excludeStudentId) {
        String sql = "SELECT COUNT(*) as count FROM students WHERE roll_number = ? AND school_id = ? AND student_id != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, rollNumber);
            pstmt.setInt(2, schoolId != null ? schoolId : 0);
            pstmt.setInt(3, excludeStudentId);

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
     * Extract Student object from ResultSet
     */
    public static Student extractStudentFromResultSet(ResultSet rs) throws SQLException {
        Student student = new Student();

        student.setStudentId(rs.getInt("student_id"));
        student.setSchoolId(rs.getInt("school_id"));
        
        int classId = rs.getInt("class_id");
        student.setClassId(rs.wasNull() ? null : classId);
        
        student.setStudentName(rs.getString("student_name"));
        student.setRollNumber(rs.getString("roll_number"));
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
        student.setStatus(rs.getString("status"));

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
