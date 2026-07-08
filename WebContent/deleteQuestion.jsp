<%@ page import="com.school.exam.dao.QuestionDAO" %>
<%@ page import="com.school.exam.model.Question" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String userRole = (String) session.getAttribute("userRole");
    
    // Check authorization - only ADMIN can delete questions
    if (userRole == null || !"ADMIN".equals(userRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    try {
        int questionId = Integer.parseInt(request.getParameter("id"));
        
        // Get question to verify it exists
        Question question = QuestionDAO.getQuestionById(questionId);
        
        if (question != null) {
            // Delete the question
            boolean deleted = QuestionDAO.deleteQuestion(questionId);
            
            if (deleted) {
                // Redirect back to view questions with success message
                response.sendRedirect("viewQuestions.jsp?success=deleted");
            } else {
                // Redirect back with error message
                response.sendRedirect("viewQuestions.jsp?error=deletefailed");
            }
        } else {
            // Question not found
            response.sendRedirect("viewQuestions.jsp?error=notfound");
        }
    } catch (NumberFormatException e) {
        response.sendRedirect("viewQuestions.jsp?error=invalid");
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewQuestions.jsp?error=exception");
    }
%>
