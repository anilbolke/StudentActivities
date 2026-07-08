<%@ page import="java.util.*, com.school.exam.model.*, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check authorization
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    
    if (username == null || !userRole.equals("SCHOOL_ADMIN") || schoolId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int teacherId = Integer.parseInt(request.getParameter("teacherId") != null ? request.getParameter("teacherId") : "-1");
    
    if (teacherId > 0) {
        // Verify teacher belongs to this school
        User teacher = UserDAO.getUserById(teacherId);
        if (teacher != null && teacher.getSchoolId() != null && teacher.getSchoolId().equals(schoolId)) {
            // Delete the teacher
            boolean deleted = UserDAO.deleteUser(teacherId);
            if (deleted) {
                response.sendRedirect("schoolAdminDashboard.jsp?message=Teacher deleted successfully");
            } else {
                response.sendRedirect("schoolAdminDashboard.jsp?error=Failed to delete teacher");
            }
        } else {
            response.sendRedirect("schoolAdminDashboard.jsp?error=Teacher not found");
        }
    } else {
        response.sendRedirect("schoolAdminDashboard.jsp?error=Invalid teacher ID");
    }
%>
