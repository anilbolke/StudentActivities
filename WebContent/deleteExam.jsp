<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check authorization
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    
    if (username == null || (!userRole.equals("TEACHER") && !userRole.equals("ADMIN"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int examId = Integer.parseInt(request.getParameter("examId") != null ? request.getParameter("examId") : "-1");
    
    if (examId > 0) {
        boolean deleted = ExamDAO.deleteExam(examId);
        if (deleted) {
            response.sendRedirect("dashboard.jsp?message=Exam deleted successfully");
        } else {
            response.sendRedirect("dashboard.jsp?error=Failed to delete exam");
        }
    } else {
        response.sendRedirect("dashboard.jsp?error=Invalid exam ID");
    }
%>
