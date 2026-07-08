<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.school.exam.dao.SchoolDAO" %>
<%
    // Check if user is logged in as ADMIN
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !("ADMIN".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String schoolIdStr = request.getParameter("id");
    
    try {
        int schoolId = Integer.parseInt(schoolIdStr);
        
        if (SchoolDAO.deleteSchool(schoolId)) {
            response.sendRedirect("adminDashboard.jsp?message=School deleted successfully!&type=success");
        } else {
            response.sendRedirect("adminDashboard.jsp?message=Failed to delete school&type=error");
        }
    } catch (Exception e) {
        response.sendRedirect("adminDashboard.jsp?message=Invalid school ID&type=error");
    }
%>
