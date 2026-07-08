package com.school.exam.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Chapter implements Serializable {
    private static final long serialVersionUID = 1L;

    private int chapterId;
    private String chapterName;
    private int subjectId;
    private Integer chapterNumber;
    private String description;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public Chapter() {
    }

    public Chapter(String chapterName, int subjectId) {
        this.chapterName = chapterName;
        this.subjectId = subjectId;
    }

    // Getters and Setters
    public int getChapterId() {
        return chapterId;
    }

    public void setChapterId(int chapterId) {
        this.chapterId = chapterId;
    }

    public String getChapterName() {
        return chapterName;
    }

    public void setChapterName(String chapterName) {
        this.chapterName = chapterName;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public Integer getChapterNumber() {
        return chapterNumber;
    }

    public void setChapterNumber(Integer chapterNumber) {
        this.chapterNumber = chapterNumber;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Chapter{" +
                "chapterId=" + chapterId +
                ", chapterName='" + chapterName + '\'' +
                ", subjectId=" + subjectId +
                ", chapterNumber=" + chapterNumber +
                ", status='" + status + '\'' +
                '}';
    }
}
