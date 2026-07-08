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
