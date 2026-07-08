<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate session and logout user
    session.invalidate();
    
    // Redirect to login page
    response.sendRedirect(request.getContextPath() + "/login.jsp?logout=1");
%>
