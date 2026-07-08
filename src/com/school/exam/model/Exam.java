package com.school.exam.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Exam implements Serializable {
    private static final long serialVersionUID = 1L;

    private int examId;
    private String examName;
    private int classId;
    private int subjectId;
    
    private int questionCount;
    private int totalMarks;
    private String difficultyLevel;
    private Integer durationMinutes;
    
    private String status;
    private int createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public Exam() {
    }

    public Exam(String examName, int classId, int subjectId, int questionCount, int totalMarks) {
        this.examName = examName;
        this.classId = classId;
        this.subjectId = subjectId;
        this.questionCount = questionCount;
        this.totalMarks = totalMarks;
    }

    // Getters and Setters
    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public String getExamName() {
        return examName;
    }

    public void setExamName(String examName) {
        this.examName = examName;
    }

    public int getClassId() {
        return classId;
    }

    public void setClassId(int classId) {
        this.classId = classId;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public int getTotalMarks() {
        return totalMarks;
    }

    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }

    public String getDifficultyLevel() {
        return difficultyLevel;
    }

    public void setDifficultyLevel(String difficultyLevel) {
        this.difficultyLevel = difficultyLevel;
    }

    public Integer getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
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
        return "Exam{" +
                "examId=" + examId +
                ", examName='" + examName + '\'' +
                ", classId=" + classId +
                ", subjectId=" + subjectId +
                ", questionCount=" + questionCount +
                ", totalMarks=" + totalMarks +
                ", difficultyLevel='" + difficultyLevel + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}
