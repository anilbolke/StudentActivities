package com.school.exam.model;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Class implements Serializable {
    private static final long serialVersionUID = 1L;

    private int classId;
    private String className;
    private int grade;
    private String section;
    private int schoolId;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public Class() {
    }

    public Class(String className, int grade, String section, int schoolId) {
        this.className = className;
        this.grade = grade;
        this.section = section;
        this.schoolId = schoolId;
    }

    // Getters and Setters
    public int getClassId() {
        return classId;
    }

    public void setClassId(int classId) {
        this.classId = classId;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public int getGrade() {
        return grade;
    }

    public void setGrade(int grade) {
        this.grade = grade;
    }

    public String getSection() {
        return section;
    }

    public void setSection(String section) {
        this.section = section;
    }

    public int getSchoolId() {
        return schoolId;
    }

    public void setSchoolId(int schoolId) {
        this.schoolId = schoolId;
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
        return "Class{" +
                "classId=" + classId +
                ", className='" + className + '\'' +
                ", grade=" + grade +
                ", section='" + section + '\'' +
                ", schoolId=" + schoolId +
                ", status='" + status + '\'' +
                '}';
    }
}
