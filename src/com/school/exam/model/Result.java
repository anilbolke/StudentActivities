package com.school.exam.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Result implements Serializable {
    private static final long serialVersionUID = 1L;

    private int resultId;
    private int examId;
    private int studentId;
    
    private int totalQuestions;
    private Integer attemptedQuestions;
    private int correctAnswers;
    private int wrongAnswers;
    private Integer skippedQuestions;
    
    private int totalMarks;
    private int marksObtained;
    private Double percentage;
    private String grade;
    
    private Integer totalTimeMinutes;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public Result() {
    }

    public Result(int examId, int studentId, int totalQuestions, int totalMarks) {
        this.examId = examId;
        this.studentId = studentId;
        this.totalQuestions = totalQuestions;
        this.totalMarks = totalMarks;
    }

    // Getters and Setters
    public int getResultId() {
        return resultId;
    }

    public void setResultId(int resultId) {
        this.resultId = resultId;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public void setTotalQuestions(int totalQuestions) {
        this.totalQuestions = totalQuestions;
    }

    public Integer getAttemptedQuestions() {
        return attemptedQuestions;
    }

    public void setAttemptedQuestions(Integer attemptedQuestions) {
        this.attemptedQuestions = attemptedQuestions;
    }

    public int getCorrectAnswers() {
        return correctAnswers;
    }

    public void setCorrectAnswers(int correctAnswers) {
        this.correctAnswers = correctAnswers;
    }

    public int getWrongAnswers() {
        return wrongAnswers;
    }

    public void setWrongAnswers(int wrongAnswers) {
        this.wrongAnswers = wrongAnswers;
    }

    public Integer getSkippedQuestions() {
        return skippedQuestions;
    }

    public void setSkippedQuestions(Integer skippedQuestions) {
        this.skippedQuestions = skippedQuestions;
    }

    public int getTotalMarks() {
        return totalMarks;
    }

    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }

    public int getMarksObtained() {
        return marksObtained;
    }

    public void setMarksObtained(int marksObtained) {
        this.marksObtained = marksObtained;
    }

    public Double getPercentage() {
        return percentage;
    }

    public void setPercentage(Double percentage) {
        this.percentage = percentage;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public Integer getTotalTimeMinutes() {
        return totalTimeMinutes;
    }

    public void setTotalTimeMinutes(Integer totalTimeMinutes) {
        this.totalTimeMinutes = totalTimeMinutes;
    }

    public LocalDateTime getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(LocalDateTime startedAt) {
        this.startedAt = startedAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
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

    // Helper methods
    public int getSkippedCount() {
        return attemptedQuestions != null ? (totalQuestions - attemptedQuestions) : 0;
    }

    public String getGradeColor() {
        if (grade == null) return "#999";
        switch (grade) {
            case "A": return "#10b981"; // green
            case "B": return "#3b82f6"; // blue
            case "C": return "#f59e0b"; // amber
            case "D": return "#f97316"; // orange
            case "F": return "#ef4444"; // red
            default: return "#999";
        }
    }

    public String getGradeDescription() {
        if (grade == null) return "Not Graded";
        switch (grade) {
            case "A": return "Excellent";
            case "B": return "Good";
            case "C": return "Average";
            case "D": return "Below Average";
            case "F": return "Failed";
            default: return "Unknown";
        }
    }

    @Override
    public String toString() {
        return "Result{" +
                "resultId=" + resultId +
                ", examId=" + examId +
                ", studentId=" + studentId +
                ", percentage=" + percentage +
                ", grade='" + grade + '\'' +
                ", marksObtained=" + marksObtained +
                "/" + totalMarks +
                '}';
    }
}
