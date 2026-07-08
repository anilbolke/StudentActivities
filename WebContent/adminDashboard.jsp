<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.school.exam.model.School, com.school.exam.dao.SchoolDAO, java.util.List, java.util.Map" %>
<%
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !("ADMIN".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get all schools
    List<School> schools = SchoolDAO.getAllSchools();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - School Management</title>
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
            max-width: 1400px;
            margin: 0 auto;
        }
        
        /* Header */
        .header {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            color: #667eea;
            font-size: 28px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .user-info span {
            color: #666;
            font-weight: 600;
        }
        
        .logout-btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            transition: 0.3s;
        }
        
        .logout-btn:hover {
            background: #c0392b;
        }
        
        /* Welcome Card */
        .welcome-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        
        .welcome-card h2 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .welcome-card p {
            opacity: 0.9;
            font-size: 16px;
        }
        
        /* Statistics */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            text-align: center;
            transition: 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
        }
        
        .stat-card .icon {
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .stat-card .number {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
            margin: 10px 0;
        }
        
        .stat-card .label {
            color: #666;
            font-size: 14px;
        }
        
        /* Section Header */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .section-header h2 {
            color: white;
            font-size: 22px;
        }
        
        .add-btn {
            background: #27ae60;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: 0.3s;
        }
        
        .add-btn:hover {
            background: #229954;
        }
        
        /* Schools Table */
        .schools-table {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            overflow-x: auto;
        }
        
        .schools-table table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .schools-table thead {
            background: #f8f9fa;
            border-bottom: 2px solid #ddd;
        }
        
        .schools-table th {
            padding: 15px;
            text-align: left;
            color: #333;
            font-weight: 600;
        }
        
        .schools-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
        }
        
        .schools-table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .btn-sm {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: 0.3s;
        }
        
        .btn-edit {
            background: #3498db;
            color: white;
        }
        
        .btn-edit:hover {
            background: #2980b9;
        }
        
        .btn-delete {
            background: #e74c3c;
            color: white;
        }
        
        .btn-delete:hover {
            background: #c0392b;
        }
        
        .btn-view {
            background: #667eea;
            color: white;
        }
        
        .btn-view:hover {
            background: #5568d3;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
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
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.5;
        }
        
        .alert {
            padding: 12px 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-dismiss {
            margin-left: auto;
            cursor: pointer;
            font-size: 18px;
        }
        
        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal.show {
            display: flex;
        }
        
        .modal-content {
            background: white;
            border-radius: 10px;
            padding: 30px;
            max-width: 400px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        
        .modal-content h3 {
            color: #333;
            margin-bottom: 15px;
        }
        
        .modal-content p {
            color: #666;
            margin-bottom: 20px;
        }
        
        .modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        .btn-cancel {
            background: #bdc3c7;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .btn-confirm {
            background: #e74c3c;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        
        /* Quick Actions Grid */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .action-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            color: inherit;
            border: 2px solid transparent;
        }
        
        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            border-color: #667eea;
        }
        
        .action-card .icon {
            font-size: 40px;
            margin-bottom: 15px;
        }
        
        .action-card h3 {
            color: #333;
            margin-bottom: 5px;
            font-size: 16px;
        }
        
        .action-card p {
            color: #999;
            font-size: 13px;
        }
        
        .action-card.upload-card .icon {
            color: #e74c3c;
        }
        
        .action-card.schools-card .icon {
            color: #667eea;
        }
        
        .action-card.questions-card .icon {
            color: #f39c12;
        }
        
        .action-card.reports-card .icon {
            color: #16a085;
        }
        
        .action-card.upload-card:hover {
            border-color: #e74c3c;
        }
        
        .action-card.schools-card:hover {
            border-color: #667eea;
        }
        
        .action-card.questions-card:hover {
            border-color: #f39c12;
        }
        
        .action-card.reports-card:hover {
            border-color: #16a085;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>
                <i class="fas fa-cog"></i>
                System Admin Dashboard
            </h1>
            <div class="user-info">
                <span>Welcome, <%= session.getAttribute("firstName") %> <%= session.getAttribute("lastName") %></span>
                <form action="logout.jsp" method="POST" style="margin: 0;">
                    <button type="submit" class="logout-btn">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </button>
                </form>
            </div>
        </div>
        
        <!-- Welcome Card -->
        <div class="welcome-card">
            <h2>Welcome to School Management System</h2>
            <p>Manage all schools, view statistics, and maintain system integrity</p>
        </div>
        
        <!-- Quick Actions -->
        <div class="quick-actions">
            <a href="viewSchool.jsp" class="action-card schools-card">
                <div class="icon">
                    <i class="fas fa-building"></i>
                </div>
                <h3>View Schools</h3>
                <p>View all registered schools</p>
            </a>
            
            <a href="addSchool.jsp" class="action-card schools-card">
                <div class="icon">
                    <i class="fas fa-plus-square"></i>
                </div>
                <h3>Add School</h3>
                <p>Create new school</p>
            </a>
            
            <a href="viewQuestions.jsp" class="action-card questions-card">
                <div class="icon">
                    <i class="fas fa-question-circle"></i>
                </div>
                <h3>View Questions</h3>
                <p>View and manage exam questions</p>
            </a>
            
            <a href="uploadQuestionsEnhanced.jsp" class="action-card upload-card">
                <div class="icon">
                    <i class="fas fa-file-upload"></i>
                </div>
                <h3>Upload Questions</h3>
                <p>Bulk upload exam questions</p>
            </a>
            
            <a href="systemReports.jsp" class="action-card reports-card">
                <div class="icon">
                    <i class="fas fa-chart-bar"></i>
                </div>
                <h3>System Reports</h3>
                <p>View system statistics & reports</p>
            </a>
        </div>
        
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="icon" style="color: #667eea;">
                    <i class="fas fa-school"></i>
                </div>
                <div class="number"><%= schools.size() %></div>
                <div class="label">Total Schools</div>
            </div>
        </div>
        
        <!-- Schools Section -->
        <div class="section-header">
            <h2>
                <i class="fas fa-building"></i> Schools Management
            </h2>
            <a href="addSchool.jsp" class="add-btn">
                <i class="fas fa-plus"></i> Add New School
            </a>
        </div>
        
        <!-- Schools Table -->
        <div class="schools-table">
            <% if (schools.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <h3>No Schools Found</h3>
                    <p>Click "Add New School" to create your first school</p>
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>School Name</th>
                            <th>Code</th>
                            <th>City</th>
                            <th>Principal</th>
                            <th>Contact</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (School school : schools) { %>
                            <tr>
                                <td><strong><%= school.getSchoolName() %></strong></td>
                                <td><code><%= school.getSchoolCode() %></code></td>
                                <td><%= school.getCity() %></td>
                                <td><%= school.getPrincipalName() != null ? school.getPrincipalName() : "N/A" %></td>
                                <td><%= school.getPhone() != null ? school.getPhone() : "N/A" %></td>
                                <td>
                                    <span class="status-badge <%= "ACTIVE".equals(school.getStatus()) ? "status-active" : "status-inactive" %>">
                                        <%= school.getStatus() %>
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="viewSchool.jsp?id=<%= school.getSchoolId() %>" class="btn-sm btn-view">
                                            <i class="fas fa-eye"></i> View
                                        </a>
                                        <a href="editSchool.jsp?id=<%= school.getSchoolId() %>" class="btn-sm btn-edit">
                                            <i class="fas fa-edit"></i> Edit
                                        </a>
                                        <button class="btn-sm btn-delete" onclick="confirmDelete(<%= school.getSchoolId() %>, '<%= school.getSchoolName() %>')">
                                            <i class="fas fa-trash"></i> Delete
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <h3><i class="fas fa-exclamation-triangle" style="color: #e74c3c;"></i> Confirm Deletion</h3>
            <p>Are you sure you want to delete the school "<span id="schoolName"></span>"?</p>
            <p style="font-size: 12px; color: #e74c3c;"><strong>Warning:</strong> This action cannot be undone.</p>
            <div class="modal-buttons">
                <button class="btn-cancel" onclick="closeDeleteModal()">Cancel</button>
                <button class="btn-confirm" onclick="confirmDeleteAction()">Delete</button>
            </div>
        </div>
    </div>
    
    <script>
        let deleteSchoolId = null;
        
        function confirmDelete(schoolId, schoolName) {
            deleteSchoolId = schoolId;
            document.getElementById('schoolName').textContent = schoolName;
            document.getElementById('deleteModal').classList.add('show');
        }
        
        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.remove('show');
            deleteSchoolId = null;
        }
        
        function confirmDeleteAction() {
            if (deleteSchoolId) {
                window.location.href = 'deleteSchool.jsp?id=' + deleteSchoolId;
            }
        }
        
        // Close modal when clicking outside
        document.getElementById('deleteModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeDeleteModal();
            }
        });
        
        // Dismiss alerts after 5 seconds
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            setTimeout(() => {
                const dismiss = alert.querySelector('.alert-dismiss');
                if (dismiss) {
                    dismiss.click();
                }
            }, 5000);
        });
        
        function dismissAlert(element) {
            element.parentElement.remove();
        }
    </script>
</body>
</html>
