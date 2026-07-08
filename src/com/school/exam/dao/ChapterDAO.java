package com.school.exam.dao;

import com.school.exam.model.Chapter;
import com.school.exam.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ChapterDAO {

    /**
     * Add a new chapter to the database
     */
    public static int addChapter(Chapter chapter) {
        String sql = "INSERT INTO chapters (chapter_name, subject_id, chapter_number, description, status) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
        		
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, chapter.getChapterName());
            pstmt.setInt(2, chapter.getSubjectId());
            
            if (chapter.getChapterNumber() != null) {
                pstmt.setInt(3, chapter.getChapterNumber());
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            
            pstmt.setString(4, chapter.getDescription());
            pstmt.setString(5, chapter.getStatus() != null ? chapter.getStatus() : "ACTIVE");

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
     * Get chapter by ID
     */
    public static Chapter getChapterById(int chapterId) {
        String sql = "SELECT * FROM chapters WHERE chapter_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, chapterId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractChapterFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get chapter by name and subject ID (case-insensitive)
     */
    public static Chapter getChapterByName(String chapterName, int subjectId) {
        String sql = "SELECT * FROM chapters WHERE LOWER(chapter_name) = LOWER(?) AND subject_id = ? LIMIT 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, chapterName);
            pstmt.setInt(2, subjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractChapterFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    /**
     * Get or create chapter by name (auto-creates if not found)
     * Returns chapter ID
     */
    public static int getOrCreateChapter(String chapterName, int subjectId) {
        // First try to find existing chapter
        Chapter existing = getChapterByName(chapterName, subjectId);
        if (existing != null) {
            return existing.getChapterId();
        }

        // Create new chapter if not found
        Chapter newChapter = new Chapter();
        newChapter.setChapterName(chapterName);
        newChapter.setSubjectId(subjectId);
        newChapter.setStatus("ACTIVE");

        int chapterId = addChapter(newChapter);
        if (chapterId > 0) {
            System.out.println("[CHAPTER] Auto-created chapter: " + chapterName + " (ID: " + chapterId + ")");
            return chapterId;
        }

        System.err.println("[CHAPTER ERROR] Failed to create chapter: " + chapterName);
        return -1;
    }

    /**
     * Get all chapters for a subject
     */
    public static List<Chapter> getChaptersBySubject(int subjectId) {
        List<Chapter> chapters = new ArrayList<>();
        String sql = "SELECT * FROM chapters WHERE subject_id = ? ORDER BY chapter_number ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    chapters.add(extractChapterFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return chapters;
    }

    /**
     * Get all active chapters for a subject
     */
    public static List<Chapter> getActiveChaptersBySubject(int subjectId) {
        List<Chapter> chapters = new ArrayList<>();
        String sql = "SELECT * FROM chapters WHERE subject_id = ? AND status = 'ACTIVE' ORDER BY chapter_number ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    chapters.add(extractChapterFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return chapters;
    }

    /**
     * Get chapters for a subject that have questions for a specific class
     * Only returns chapters that have at least one question
     */
    public static List<Chapter> getChaptersWithQuestionsByClassSubject(int classId, int subjectId) {
        List<Chapter> chapters = new ArrayList<>();
        String sql = "SELECT DISTINCT c.* FROM chapters c " +
                "INNER JOIN questions q ON c.chapter_id = q.chapter_id " +
                "WHERE c.subject_id = ? AND c.status = 'ACTIVE' " +
                "AND q.class_id = ? AND q.status = 'ACTIVE' " +
                "ORDER BY c.chapter_number ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);
            pstmt.setInt(2, classId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    chapters.add(extractChapterFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return chapters;
    }

    /**
     * ✅ Get chapters filtered by SCHOOL and logged-in teacher
     * Shows chapters from subjects in THAT SCHOOL where:
     *   - Questions created by this teacher, OR
     *   - Questions created by ADMIN (school-specific + global)
     * Does NOT show chapters from other schools
     */
    public static List<Chapter> getChaptersWithQuestionsByClassSubjectForTeacher(int classId, int subjectId, Integer teacherId, int schoolId) {
        List<Chapter> chapters = new ArrayList<>();
        String sql = "SELECT DISTINCT c.* FROM chapters c " +
                "INNER JOIN questions q ON c.chapter_id = q.chapter_id " +
                "INNER JOIN subjects s ON c.subject_id = s.subject_id " +
                "WHERE c.subject_id = ? AND c.status = 'ACTIVE' " +
                "AND s.school_id = ? " +
                "AND q.class_id = ? AND q.status = 'ACTIVE' " +
                "AND (q.created_by = ? OR q.created_by IN (SELECT user_id FROM users WHERE role = 'ADMIN') OR q.school_id IS NULL) " +
                "ORDER BY c.chapter_number ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, subjectId);
            pstmt.setInt(2, schoolId);
            pstmt.setInt(3, classId);
            
            if (teacherId != null) {
                pstmt.setInt(4, teacherId);
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    chapters.add(extractChapterFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return chapters;
    }

    /**
     * Update chapter information
     */
    public static boolean updateChapter(Chapter chapter) {
        String sql = "UPDATE chapters SET chapter_name = ?, chapter_number = ?, description = ?, status = ? " +
                "WHERE chapter_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, chapter.getChapterName());
            
            if (chapter.getChapterNumber() != null) {
                pstmt.setInt(2, chapter.getChapterNumber());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            
            pstmt.setString(3, chapter.getDescription());
            pstmt.setString(4, chapter.getStatus());
            pstmt.setInt(5, chapter.getChapterId());

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Delete a chapter
     */
    public static boolean deleteChapter(int chapterId) {
        String sql = "DELETE FROM chapters WHERE chapter_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, chapterId);

            int affectedRows = pstmt.executeUpdate();
            return affectedRows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Extract Chapter object from ResultSet
     */
    private static Chapter extractChapterFromResultSet(ResultSet rs) throws SQLException {
        Chapter chapter = new Chapter();

        chapter.setChapterId(rs.getInt("chapter_id"));
        chapter.setChapterName(rs.getString("chapter_name"));
        chapter.setSubjectId(rs.getInt("subject_id"));
        
        int chapterNumber = rs.getInt("chapter_number");
        chapter.setChapterNumber(rs.wasNull() ? null : chapterNumber);
        
        chapter.setDescription(rs.getString("description"));
        chapter.setStatus(rs.getString("status"));

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            chapter.setCreatedAt(createdAt.toLocalDateTime());
        }

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            chapter.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return chapter;
    }
}
