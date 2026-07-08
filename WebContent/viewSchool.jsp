<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.school.exam.model.School, com.school.exam.dao.SchoolDAO, java.util.Map" %>
<%
    // Check if user is logged in as ADMIN
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !("ADMIN".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    String schoolIdStr = request.getParameter("id");
    int schoolId = 0;
    School school = null;
    Map<String, Integer> stats = null;
    
    try {
        schoolId = Integer.parseInt(schoolIdStr);
        school = SchoolDAO.getSchoolById(schoolId);
        
        if (school == null) {
            response.sendRedirect("adminDashboard.jsp");
            return;
        }
        
        stats = SchoolDAO.getSchoolStats(schoolId);
    } catch (Exception e) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>School Details: <%= school.getSchoolName() %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
        }
        
        .back-link {
            color: white;
            text-decoration: none;
            margin-bottom: 20px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: 0.3s;
        }
        
        .back-link:hover {
            opacity: 0.8;
        }
        
        .content {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 28px;
        }
        
        .action-buttons {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: 0.3s;
            text-decoration: none;
            color: white;
        }
        
        .btn-edit {
            background: #3498db;
        }
        
        .btn-edit:hover {
            background: #2980b9;
        }
        
        .body {
            padding: 30px;
        }
        
        .section {
            margin-bottom: 30px;
        }
        
        .section-title {
            color: #667eea;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }
        
        .info-item {
            display: flex;
            flex-direction: column;
        }
        
        .info-label {
            color: #999;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        
        .info-value {
            color: #333;
            font-size: 16px;
            font-weight: 500;
        }
        
        .info-value.na {
            color: #999;
            font-style: italic;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        
        .stat-card {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            border-radius: 5px;
        }
        
        .stat-card .number {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }
        
        .stat-card .label {
            color: #666;
            font-size: 12px;
            margin-top: 5px;
        }
        
        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-active {
            background: #d4edda;
            color: #155724;
        }
        
        .status-inactive {
            background: #f8d7da;
            color: #721c24;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="adminDashboard.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
        
        <div class="content">
            <div class="header">
                <h1>
                    <i class="fas fa-building"></i>
                    <%= school.getSchoolName() %>
                </h1>
                <div class="action-buttons">
                    <a href="editSchool.jsp?id=<%= school.getSchoolId() %>" class="btn btn-edit">
                        <i class="fas fa-edit"></i> Edit
                    </a>
                </div>
            </div>
            
            <div class="body">
                <!-- Basic Information -->
                <div class="section">
                    <div class="section-title">
                        <i class="fas fa-info-circle"></i> Basic Information
                    </div>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">School Name</span>
                            <span class="info-value"><%= school.getSchoolName() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">School Code</span>
                            <span class="info-value"><code><%= school.getSchoolCode() %></code></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Year Established</span>
                            <span class="info-value"><%= school.getEstablishedYear() != null ? school.getEstablishedYear() : "N/A" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Status</span>
                            <span class="status-badge <%= "ACTIVE".equals(school.getStatus()) ? "status-active" : "status-inactive" %>">
                                <%= school.getStatus() %>
                            </span>
                        </div>
                    </div>
                </div>
                
                <!-- Location Information -->
                <div class="section">
                    <div class="section-title">
                        <i class="fas fa-map-marker-alt"></i> Location Information
                    </div>
                    <div class="info-grid">
                        <div class="info-item" style="grid-column: 1 / -1;">
                            <span class="info-label">Address</span>
                            <span class="info-value"><%= school.getAddress() != null && !school.getAddress().isEmpty() ? school.getAddress() : "N/A" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">City</span>
                            <span class="info-value"><%= school.getCity() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">State</span>
                            <span class="info-value"><%= school.getState() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Pincode</span>
                            <span class="info-value"><%= school.getPincode() != null ? school.getPincode() : "N/A" %></span>
                        </div>
                    </div>
                </div>
                
                <!-- Contact Information -->
                <div class="section">
                    <div class="section-title">
                        <i class="fas fa-phone"></i> Contact Information
                    </div>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">Phone</span>
                            <span class="info-value"><%= school.getPhone() %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Email</span>
                            <span class="info-value"><a href="mailto:<%= school.getEmail() %>"><%= school.getEmail() %></a></span>
                        </div>
                    </div>
                </div>
                
                <!-- Principal Information -->
                <div class="section">
                    <div class="section-title">
                        <i class="fas fa-user-tie"></i> Principal Information
                    </div>
                    <div class="info-grid">
                        <div class="info-item">
                            <span class="info-label">Principal Name</span>
                            <span class="info-value"><%= school.getPrincipalName() != null ? school.getPrincipalName() : "N/A" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Principal Contact</span>
                            <span class="info-value"><%= school.getPrincipalContact() != null ? school.getPrincipalContact() : "N/A" %></span>
                        </div>
                        <div class="info-item">
                            <span class="info-label">Registration Number</span>
                            <span class="info-value"><%= school.getRegistrationNumber() != null ? school.getRegistrationNumber() : "N/A" %></span>
                        </div>
                    </div>
                </div>
                
                <!-- Statistics -->
                <div class="section">
                    <div class="section-title">
                        <i class="fas fa-chart-bar"></i> School Statistics
                    </div>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="number"><%= stats.getOrDefault("teachers", 0) %></div>
                            <div class="label">Teachers</div>
                        </div>
                        <div class="stat-card">
                            <div class="number"><%= stats.getOrDefault("students", 0) %></div>
                            <div class="label">Students</div>
                        </div>
                        <div class="stat-card">
                            <div class="number"><%= stats.getOrDefault("classes", 0) %></div>
                            <div class="label">Classes</div>
                        </div>
                        <div class="stat-card">
                            <div class="number"><%= stats.getOrDefault("exams", 0) %></div>
                            <div class="label">Exams</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
