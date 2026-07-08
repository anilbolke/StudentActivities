package com.school.exam.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class ExamAnswer implements Serializable {
    private static final long serialVersionUID = 1L;

    private int answerId;
    private int examId;
    private int studentId;
    private int questionId;
    
    private String selectedAnswer;
    private String correctAnswer;
    private Boolean isCorrect;
    private int marksObtained;
    private Integer timeTakenSeconds;
    private int attemptNumber;
    private String status;
    private LocalDateTime answeredAt;

    // Constructors
    public ExamAnswer() {
    }

    public ExamAnswer(int examId, int studentId, int questionId, String correctAnswer) {
        this.examId = examId;
        this.studentId = studentId;
        this.questionId = questionId;
        this.correctAnswer = correctAnswer;
    }

    // Getters and Setters
    public int getAnswerId() {
        return answerId;
    }

    public void setAnswerId(int answerId) {
        this.answerId = answerId;
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

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public String getSelectedAnswer() {
        return selectedAnswer;
    }

    public void setSelectedAnswer(String selectedAnswer) {
        this.selectedAnswer = selectedAnswer;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public Boolean getIsCorrect() {
        return isCorrect;
    }

    public void setIsCorrect(Boolean isCorrect) {
        this.isCorrect = isCorrect;
    }

    public int getMarksObtained() {
        return marksObtained;
    }

    public void setMarksObtained(int marksObtained) {
        this.marksObtained = marksObtained;
    }

    public Integer getTimeTakenSeconds() {
        return timeTakenSeconds;
    }

    public void setTimeTakenSeconds(Integer timeTakenSeconds) {
        this.timeTakenSeconds = timeTakenSeconds;
    }

    public int getAttemptNumber() {
        return attemptNumber;
    }

    public void setAttemptNumber(int attemptNumber) {
        this.attemptNumber = attemptNumber;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getAnsweredAt() {
        return answeredAt;
    }

    public void setAnsweredAt(LocalDateTime answeredAt) {
        this.answeredAt = answeredAt;
    }

    @Override
    public String toString() {
        return "ExamAnswer{" +
                "answerId=" + answerId +
                ", examId=" + examId +
                ", studentId=" + studentId +
                ", questionId=" + questionId +
                ", selectedAnswer='" + selectedAnswer + '\'' +
                ", isCorrect=" + isCorrect +
                ", marksObtained=" + marksObtained +
                '}';
    }
}
