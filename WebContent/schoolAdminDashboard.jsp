<%@page import="com.school.exam.model.User"%>
<%@ page import="java.util.*, com.school.exam.model.School, com.school.exam.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check authorization - only SCHOOL_ADMIN
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    Integer schoolId = (Integer) session.getAttribute("schoolId");
    String firstName = (String) session.getAttribute("firstName");
    String lastName = (String) session.getAttribute("lastName");
    
    if (username == null || !userRole.equals("SCHOOL_ADMIN") || schoolId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get school info
    School school = SchoolDAO.getSchoolById(schoolId);
    
    // Get all teachers for this school
    List<User> teachers = UserDAO.getTeachersBySchool(schoolId);
    
    // Get stats
    int totalTeachers = teachers != null ? teachers.size() : 0;
    int activeTeachers = 0;
    int inactiveTeachers = 0;
    
    if (teachers != null) {
        for (User teacher : teachers) {
            if ("ACTIVE".equals(teacher.getStatus())) {
                activeTeachers++;
            } else {
                inactiveTeachers++;
            }
        }
    }
    
    // Get messages from URL
    String successMessage = request.getParameter("message");
    String errorMessage = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>School Admin Dashboard - School Exam System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
        }

        /* Navbar */
        .navbar {
            background: linear-gradient(135deg, #1a73e8 0%, #1765cc 100%);
            color: white;
            padding: 1rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }

        .navbar-brand {
            font-size: 1.8rem;
            font-weight: bold;
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }

        .navbar-right {
            display: flex;
            gap: 1.5rem;
            align-items: center;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            background: #ffc107;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.1rem;
            color: #1a73e8;
        }

        .btn-logout {
            background-color: #d32f2f;
            color: white;
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s;
        }

        .btn-logout:hover {
            background-color: #b71c1c;
            transform: translateY(-2px);
        }

        /* Container */
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        /* Alert */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 4px;
            margin-bottom: 1rem;
        }

        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* Welcome Section */
        .welcome-section {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .welcome-text h1 {
            color: #1a73e8;
            margin-bottom: 0.5rem;
        }

        .welcome-text p {
            color: #7f8c8d;
            font-size: 0.95rem;
            margin: 0.5rem 0;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.95rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #1a73e8 0%, #1765cc 100%);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(26, 115, 232, 0.4);
        }

        /* Stats Section */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1.5rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            text-align: center;
            border-left: 4px solid #1a73e8;
        }

        .stat-card.active {
            border-left-color: #27ae60;
        }

        .stat-card.inactive {
            border-left-color: #f39c12;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            color: #1a73e8;
            margin: 0.5rem 0;
        }

        .stat-card.active .stat-number {
            color: #27ae60;
        }

        .stat-card.inactive .stat-number {
            color: #f39c12;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 0.9rem;
        }

        /* School Info Card */
        .school-info {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            margin-bottom: 2rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            border-left: 4px solid #ffc107;
        }

        .school-info h2 {
            color: #1a73e8;
            margin-bottom: 1rem;
        }

        .school-detail {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
        }

        .detail-item {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 4px;
            border-left: 3px solid #1a73e8;
        }

        .detail-label {
            color: #7f8c8d;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .detail-value {
            color: #1a73e8;
            font-size: 1.1rem;
            font-weight: 600;
            margin-top: 0.5rem;
        }

        /* Section Header */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .section-header h2 {
            color: #2c3e50;
        }

        /* Teacher Table */
        .teacher-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .teacher-table thead {
            background-color: #1a73e8;
            color: white;
        }

        .teacher-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
        }

        .teacher-table td {
            padding: 1rem;
            border-bottom: 1px solid #ecf0f1;
        }

        .teacher-table tbody tr:hover {
            background-color: #f8f9fa;
        }

        /* Status Badge */
        .badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .badge-active {
            background-color: #d4edda;
            color: #155724;
        }

        .badge-inactive {
            background-color: #fff3cd;
            color: #856404;
        }

        .badge-blocked {
            background-color: #f8d7da;
            color: #721c24;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        .btn-small {
            padding: 0.5rem 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }

        .btn-edit {
            background-color: #2196F3;
            color: white;
        }

        .btn-edit:hover {
            background-color: #1976D2;
        }

        .btn-delete {
            background-color: #d32f2f;
            color: white;
        }

        .btn-delete:hover {
            background-color: #b71c1c;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: #7f8c8d;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .empty-state p {
            margin: 1rem 0;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            max-width: 500px;
            width: 90%;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
        }

        .modal-header {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 1rem;
            color: #1a73e8;
        }

        .modal-body {
            margin-bottom: 1.5rem;
            color: #555;
        }

        .modal-footer {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 1rem;
            }

            .welcome-section {
                flex-direction: column;
                text-align: center;
            }

            .section-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .teacher-table {
                font-size: 0.9rem;
            }

            .teacher-table th, .teacher-table td {
                padding: 0.75rem;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-small {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <div class="navbar">
        <div class="navbar-brand">
            🏫 School Admin Portal
        </div>
        <div class="navbar-right">
            <div class="user-info">
                <div class="user-avatar">
                    <%= firstName != null ? firstName.charAt(0) : "S" %>
                </div>
                <div>
                    <strong><%= firstName %> <%= lastName %></strong>
                    <br>
                    <small style="color: #bdc3c7;">School Admin</small>
                </div>
            </div>
            <a href="logout.jsp" class="btn-logout">Logout</a>
        </div>
    </div>

    <!-- Container -->
    <div class="container">
        <!-- Alert Messages -->
        <% if (successMessage != null && !successMessage.isEmpty()) { %>
            <div class="alert alert-success" id="successAlert">
                ✅ <%= successMessage %>
            </div>
        <% } %>
        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
            <div class="alert alert-danger" id="errorAlert">
                ❌ <%= errorMessage %>
            </div>
        <% } %>

        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-text">
                <h1>Welcome, <%= firstName %>! 👋</h1>
                <p>Manage teachers, view statistics, and control your school's exam system</p>
            </div>
            <a href="addTeacher.jsp" class="btn btn-primary">+ Add New Teacher</a>
        </div>

        <!-- School Info -->
        <% if (school != null) { %>
            <div class="school-info">
                <h2>🏫 School Information</h2>
                <div class="school-detail">
                    <div class="detail-item">
                        <div class="detail-label">School Name</div>
                        <div class="detail-value"><%= school.getSchoolName() %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Address</div>
                        <div class="detail-value"><%= school.getAddress() != null ? school.getAddress() : "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">City</div>
                        <div class="detail-value"><%= school.getCity() != null ? school.getCity() : "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Contact Number</div>
                        <div class="detail-value"><%= school.getPhone() != null ? school.getPhone() : "N/A" %></div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Email</div>
                        <div class="detail-value"><%= school.getEmail() != null ? school.getEmail() : "N/A" %></div>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Teachers</div>
                <div class="stat-number"><%= totalTeachers %></div>
            </div>
            <div class="stat-card active">
                <div class="stat-label">Active Teachers</div>
                <div class="stat-number"><%= activeTeachers %></div>
            </div>
            <div class="stat-card inactive">
                <div class="stat-label">Inactive Teachers</div>
                <div class="stat-number"><%= inactiveTeachers %></div>
            </div>
        </div>

        <!-- Teachers List -->
        <div class="section-header">
            <h2>👨‍🏫 Teachers Management</h2>
        </div>

        <% if (teachers != null && !teachers.isEmpty()) { %>
            <table class="teacher-table">
                <thead>
                    <tr>
                        <th>First Name</th>
                        <th>Last Name</th>
                        <th>Email</th>
                        <th>Username</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (User teacher : teachers) { %>
                    <tr>
                        <td><strong><%= teacher.getFirstName() %></strong></td>
                        <td><%= teacher.getLastName() %></td>
                        <td><%= teacher.getEmail() %></td>
                        <td><code><%= teacher.getUsername() %></code></td>
                        <td>
                            <% if ("ACTIVE".equals(teacher.getStatus())) { %>
                                <span class="badge badge-active">Active</span>
                            <% } else if ("INACTIVE".equals(teacher.getStatus())) { %>
                                <span class="badge badge-inactive">Inactive</span>
                            <% } else { %>
                                <span class="badge badge-blocked">Blocked</span>
                            <% } %>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="editTeacher.jsp?teacherId=<%= teacher.getUserId() %>" class="btn-small btn-edit">✏️ Edit</a>
                                <button class="btn-small btn-delete" onclick="deleteTeacher(<%= teacher.getUserId() %>, '<%= teacher.getFirstName() + " " + teacher.getLastName() %>')">🗑️ Delete</button>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <p>👨‍🏫 No teachers added yet</p>
                <p>Click "[+ Add New Teacher]" to create the first teacher account</p>
                <a href="addTeacher.jsp" class="btn btn-primary" style="margin-top: 1rem;">+ Add New Teacher</a>
            </div>
        <% } %>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">Delete Teacher</div>
            <div class="modal-body">
                <p>Are you sure you want to delete teacher: <strong id="teacherNameToDelete"></strong>?</p>
                <p style="margin-top: 1rem; color: #d32f2f;"><strong>⚠️ Warning:</strong> This action cannot be undone!</p>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary" onclick="closeDeleteModal()">Cancel</button>
                <a id="deleteLink" href="#" style="background-color: #d32f2f; color: white; padding: 0.75rem 1.5rem; border-radius: 4px; text-decoration: none; display: inline-block;">Delete</a>
            </div>
        </div>
    </div>

    <script>
        // Auto-dismiss alerts
        function dismissAlert(elementId) {
            const alert = document.getElementById(elementId);
            if (alert) {
                setTimeout(() => {
                    alert.style.opacity = '0';
                    alert.style.transition = 'opacity 0.3s';
                    setTimeout(() => {
                        alert.style.display = 'none';
                    }, 300);
                }, 5000);
            }
        }

        window.addEventListener('load', function() {
            dismissAlert('successAlert');
            dismissAlert('errorAlert');
        });

        // Delete teacher
        function deleteTeacher(teacherId, teacherName) {
            document.getElementById('teacherNameToDelete').textContent = teacherName;
            document.getElementById('deleteLink').href = 'deleteTeacher.jsp?teacherId=' + teacherId;
            document.getElementById('deleteModal').classList.add('show');
        }

        function closeDeleteModal() {
            document.getElementById('deleteModal').classList.remove('show');
        }

        // Close modal on outside click
        window.onclick = function(event) {
            const modal = document.getElementById('deleteModal');
            if (event.target === modal) {
                modal.classList.remove('show');
            }
        }
    </script>
</body>
</html>
