<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.school.exam.model.School, com.school.exam.dao.SchoolDAO" %>
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
    
    try {
        schoolId = Integer.parseInt(schoolIdStr);
        school = SchoolDAO.getSchoolById(schoolId);
        
        if (school == null) {
            response.sendRedirect("adminDashboard.jsp");
            return;
        }
    } catch (Exception e) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }
    
    String message = "";
    String messageType = "";
    
    // Handle form submission
    if ("POST".equals(request.getMethod())) {
        String schoolName = request.getParameter("schoolName");
        String schoolCode = request.getParameter("schoolCode");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String principalName = request.getParameter("principalName");
        String principalContact = request.getParameter("principalContact");
        String registrationNumber = request.getParameter("registrationNumber");
        String status = request.getParameter("status");
        String establishedYearStr = request.getParameter("establishedYear");
        
        // Validation
        if (schoolName == null || schoolName.trim().isEmpty()) {
            message = "School name is required!";
            messageType = "error";
        } else if (schoolCode == null || schoolCode.trim().isEmpty()) {
            message = "School code is required!";
            messageType = "error";
        } else if (city == null || city.trim().isEmpty()) {
            message = "City is required!";
            messageType = "error";
        } else if (state == null || state.trim().isEmpty()) {
            message = "State is required!";
            messageType = "error";
        } else if (phone == null || phone.trim().isEmpty()) {
            message = "Phone number is required!";
            messageType = "error";
        } else if (email == null || email.trim().isEmpty()) {
            message = "Email is required!";
            messageType = "error";
        } else {
            // Check if school code already exists (for other schools)
            if (SchoolDAO.schoolCodeExistsForOtherSchool(schoolCode, schoolId)) {
                message = "School code already exists in another school! Please use a different code.";
                messageType = "error";
            } else {
                // Update school
                school.setSchoolName(schoolName);
                school.setSchoolCode(schoolCode);
                school.setAddress(address);
                school.setCity(city);
                school.setState(state);
                school.setPincode(pincode);
                school.setPhone(phone);
                school.setEmail(email);
                school.setPrincipalName(principalName);
                school.setPrincipalContact(principalContact);
                school.setRegistrationNumber(registrationNumber);
                school.setStatus(status != null ? status : "ACTIVE");
                
                if (establishedYearStr != null && !establishedYearStr.isEmpty()) {
                    try {
                        school.setEstablishedYear(Integer.parseInt(establishedYearStr));
                    } catch (NumberFormatException e) {
                        // Keep existing value
                    }
                }
                
                if (SchoolDAO.updateSchool(school)) {
                    message = "School updated successfully!";
                    messageType = "success";
                    response.setHeader("Refresh", "2; url=adminDashboard.jsp");
                } else {
                    message = "Failed to update school. Please try again.";
                    messageType = "error";
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit School</title>
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
        
        .form-container {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .form-header {
            margin-bottom: 30px;
            border-bottom: 2px solid #f0f0f0;
            padding-bottom: 20px;
        }
        
        .form-header h1 {
            color: #667eea;
            font-size: 28px;
            display: flex;
            align-items: center;
            gap: 10px;
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
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group.full {
            grid-column: 1 / -1;
        }
        
        label {
            color: #333;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .required {
            color: #e74c3c;
        }
        
        input, textarea, select {
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
            transition: 0.3s;
        }
        
        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .helper-text {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }
        
        .section-title {
            color: #333;
            font-weight: 600;
            margin-top: 30px;
            margin-bottom: 15px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }
        
        .form-buttons {
            display: flex;
            gap: 10px;
            margin-top: 30px;
            justify-content: flex-end;
        }
        
        button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: 0.3s;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-submit {
            background: #27ae60;
            color: white;
        }
        
        .btn-submit:hover {
            background: #229954;
        }
        
        .btn-cancel {
            background: #bdc3c7;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #95a5a6;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="adminDashboard.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
        
        <div class="form-container">
            <div class="form-header">
                <h1>
                    <i class="fas fa-edit"></i>
                    Edit School: <%= school.getSchoolName() %>
                </h1>
            </div>
            
            <% if (!message.isEmpty()) { %>
                <div class="alert alert-<%= messageType %>">
                    <i class="fas fa-<%= messageType.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                    <%= message %>
                </div>
            <% } %>
            
            <form method="POST" onsubmit="return validateForm()">
                <!-- Basic Information -->
                <div class="section-title">
                    <i class="fas fa-info-circle"></i> Basic Information
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="schoolName">School Name <span class="required">*</span></label>
                        <input type="text" id="schoolName" name="schoolName" value="<%= school.getSchoolName() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="schoolCode">School Code <span class="required">*</span></label>
                        <input type="text" id="schoolCode" name="schoolCode" value="<%= school.getSchoolCode() %>" required>
                        <div class="helper-text">Unique identifier for the school</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="establishedYear">Year Established</label>
                        <input type="number" id="establishedYear" name="establishedYear" value="<%= school.getEstablishedYear() != null ? school.getEstablishedYear() : "" %>" min="1900" max="2099">
                    </div>
                </div>
                
                <!-- Location Information -->
                <div class="section-title">
                    <i class="fas fa-map-marker-alt"></i> Location Information
                </div>
                
                <div class="form-grid">
                    <div class="form-group full">
                        <label for="address">Address</label>
                        <textarea id="address" name="address"><%= school.getAddress() != null ? school.getAddress() : "" %></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="city">City <span class="required">*</span></label>
                        <input type="text" id="city" name="city" value="<%= school.getCity() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="state">State <span class="required">*</span></label>
                        <input type="text" id="state" name="state" value="<%= school.getState() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="pincode">Pincode</label>
                        <input type="text" id="pincode" name="pincode" value="<%= school.getPincode() != null ? school.getPincode() : "" %>">
                    </div>
                </div>
                
                <!-- Contact Information -->
                <div class="section-title">
                    <i class="fas fa-phone"></i> Contact Information
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="phone">Phone Number <span class="required">*</span></label>
                        <input type="tel" id="phone" name="phone" value="<%= school.getPhone() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" id="email" name="email" value="<%= school.getEmail() %>" required>
                    </div>
                </div>
                
                <!-- Principal Information -->
                <div class="section-title">
                    <i class="fas fa-user-tie"></i> Principal Information
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="principalName">Principal Name</label>
                        <input type="text" id="principalName" name="principalName" value="<%= school.getPrincipalName() != null ? school.getPrincipalName() : "" %>">
                    </div>
                    
                    <div class="form-group">
                        <label for="principalContact">Principal Contact</label>
                        <input type="tel" id="principalContact" name="principalContact" value="<%= school.getPrincipalContact() != null ? school.getPrincipalContact() : "" %>">
                    </div>
                    
                    <div class="form-group full">
                        <label for="registrationNumber">Registration Number</label>
                        <input type="text" id="registrationNumber" name="registrationNumber" value="<%= school.getRegistrationNumber() != null ? school.getRegistrationNumber() : "" %>">
                    </div>
                </div>
                
                <!-- Status -->
                <div class="section-title">
                    <i class="fas fa-cog"></i> Status
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="status">School Status</label>
                        <select id="status" name="status">
                            <option value="ACTIVE" <%= "ACTIVE".equals(school.getStatus()) ? "selected" : "" %>>Active</option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(school.getStatus()) ? "selected" : "" %>>Inactive</option>
                        </select>
                    </div>
                </div>
                
                <!-- Action Buttons -->
                <div class="form-buttons">
                    <a href="adminDashboard.jsp" style="text-decoration: none;">
                        <button type="button" class="btn-cancel">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                    </a>
                    <button type="submit" class="btn-submit">
                        <i class="fas fa-save"></i> Update School
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function validateForm() {
            const schoolName = document.getElementById('schoolName').value.trim();
            const schoolCode = document.getElementById('schoolCode').value.trim();
            const city = document.getElementById('city').value.trim();
            const state = document.getElementById('state').value.trim();
            const phone = document.getElementById('phone').value.trim();
            const email = document.getElementById('email').value.trim();
            
            if (!schoolName || !schoolCode || !city || !state || !phone || !email) {
                alert('Please fill in all required fields!');
                return false;
            }
            
            // Validate email format
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                alert('Please enter a valid email address!');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>
