<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in as ADMIN
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");
    
    if (username == null || !("ADMIN".equals(userRole))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
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
        String establishedYearStr = request.getParameter("establishedYear");
        
        // Validation (Principal/Headmaster = Same person)
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
        } else if (principalName == null || principalName.trim().isEmpty()) {
            message = "Principal/Headmaster name is required!";
            messageType = "error";
        } else if (principalContact == null || principalContact.trim().isEmpty()) {
            message = "Principal/Headmaster mobile number is required!";
            messageType = "error";
        } else {
            // Check if school code already exists
            com.school.exam.dao.SchoolDAO schoolDAO = new com.school.exam.dao.SchoolDAO();
            if (com.school.exam.dao.SchoolDAO.schoolCodeExists(schoolCode)) {
                message = "School code already exists! Please use a different code.";
                messageType = "error";
            } else {
                // Create new school
                com.school.exam.model.School school = new com.school.exam.model.School();
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
                school.setStatus("ACTIVE");
                
                if (establishedYearStr != null && !establishedYearStr.isEmpty()) {
                    try {
                        school.setEstablishedYear(Integer.parseInt(establishedYearStr));
                    } catch (NumberFormatException e) {
                        school.setEstablishedYear(null);
                    }
                }
                
                int schoolId = -1;
                if (com.school.exam.dao.SchoolDAO.addSchool(school)) {
                    // Get the newly created school ID
                    java.util.List<com.school.exam.model.School> schools = com.school.exam.dao.SchoolDAO.getAllSchools();
                    for (com.school.exam.model.School s : schools) {
                        if (s.getSchoolCode().equals(schoolCode)) {
                            schoolId = s.getSchoolId();
                            break;
                        }
                    }
                    
                    // Create SCHOOL_ADMIN user account using Principal's contact (mobile) as username & password
                    if (schoolId > 0) {
                        String username1 = principalContact; // Principal mobile number as username
                        String password = principalContact; // Principal mobile number as password
                        String email_user = email;
                        
                        try {
                            String sql = "INSERT INTO users (username, password, email, first_name, last_name, role, school_id, created_at, updated_at) " +
                                       "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";
                            
                            java.sql.Connection conn = com.school.exam.util.DatabaseConnection.getConnection();
                            java.sql.PreparedStatement pstmt = conn.prepareStatement(sql);
                            pstmt.setString(1, username1);
                            pstmt.setString(2, password);
                            pstmt.setString(3, email_user);
                            pstmt.setString(4, principalName);
                            pstmt.setString(5, ""); // Last name empty
                            pstmt.setString(6, "SCHOOL_ADMIN");
                            pstmt.setInt(7, schoolId);
                            
                            pstmt.executeUpdate();
                            pstmt.close();
                            conn.close();
                            
                            message = "✅ School added successfully! Principal/Headmaster login account created.<br><br>" +
                                     "<strong>📱 Login Credentials:</strong><br>" +
                                     "Username: " + username + "<br>" +
                                     "Password: " + password;
                            messageType = "success";
                            // Redirect after 3 seconds
                            response.setHeader("Refresh", "3; url=adminDashboard.jsp");
                        } catch (Exception e) {
                            message = "School added but failed to create principal account. Error: " + e.getMessage();
                            messageType = "error";
                        }
                    } else {
                        message = "School added successfully but principal account creation failed!";
                        messageType = "error";
                    }
                } else {
                    message = "Failed to add school. Please try again.";
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
    <title>Add New School</title>
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
        
        .error-message {
            color: #e74c3c;
            font-size: 12px;
            margin-top: 5px;
            display: none;
            font-weight: 600;
        }
        
        .error-message.show {
            display: block;
        }
        
        .form-group.invalid input,
        .form-group.invalid textarea,
        .form-group.invalid select {
            border-color: #e74c3c;
            background-color: #fff5f5;
        }
        
        .form-group.valid input,
        .form-group.valid textarea,
        .form-group.valid select {
            border-color: #27ae60;
            background-color: #f0fff0;
        }
        
        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            border-color: #667eea !important;
            background-color: white !important;
        }
        
        .validation-icon {
            font-size: 10px;
            margin-left: 5px;
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
                    <i class="fas fa-building"></i>
                    Add New School
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
                        <input type="text" id="schoolName" name="schoolName" required placeholder="Enter school name">
                        <div class="error-message" id="schoolNameError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="schoolCode">School Code <span class="required">*</span></label>
                        <input type="text" id="schoolCode" name="schoolCode" required placeholder="e.g., SCHL001" title="Unique identifier for the school">
                        <div class="helper-text">Must be unique (e.g., SCHL001, PS-2024, etc.)</div>
                        <div class="error-message" id="schoolCodeError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="establishedYear">Year Established</label>
                        <input type="number" id="establishedYear" name="establishedYear" placeholder="e.g., 2010" min="1900" max="2099">
                        <div class="error-message" id="establishedYearError"></div>
                    </div>
                </div>
                
                <!-- Location Information -->
                <div class="section-title">
                    <i class="fas fa-map-marker-alt"></i> Location Information
                </div>
                
                <div class="form-grid">
                    <div class="form-group full">
                        <label for="address">Address</label>
                        <textarea id="address" name="address" placeholder="Street address"></textarea>
                        <div class="error-message" id="addressError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="city">City <span class="required">*</span></label>
                        <input type="text" id="city" name="city" required placeholder="Enter city">
                        <div class="error-message" id="cityError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="state">State <span class="required">*</span></label>
                        <input type="text" id="state" name="state" required placeholder="Enter state">
                        <div class="error-message" id="stateError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="pincode">Pincode</label>
                        <input type="text" id="pincode" name="pincode" placeholder="Enter pincode">
                        <div class="error-message" id="pincodeError"></div>
                    </div>
                </div>
                
                <!-- Contact Information -->
                <div class="section-title">
                    <i class="fas fa-phone"></i> Contact Information
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="phone">Phone Number <span class="required">*</span></label>
                        <input type="tel" id="phone" name="phone" required placeholder="e.g., 9876543210">
                        <div class="error-message" id="phoneError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" id="email" name="email" required placeholder="e.g., info@school.com">
                        <div class="error-message" id="emailError"></div>
                    </div>
                </div>
                
                <!-- Principal Information (Used for Admin Account) -->
                <div class="section-title">
                    <i class="fas fa-user-tie"></i> Principal / Headmaster Information
                </div>
                
                <div style="background: #e8f4f8; padding: 15px; border-radius: 5px; margin-bottom: 20px; border-left: 4px solid #3498db;">
                    <p style="color: #2c3e50; font-size: 13px; margin: 0;">
                        <strong>ℹ️ Note:</strong> The principal's mobile number will be used as both username and password for the school admin login.<br>
                        The school admin account will be created automatically.
                    </p>
                </div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="principalName">Principal / Headmaster Name <span class="required">*</span></label>
                        <input type="text" id="principalName" name="principalName" required placeholder="Enter principal name">
                        <div class="error-message" id="principalNameError"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="principalContact">Principal / Headmaster Contact (Mobile) <span class="required">*</span></label>
                        <input type="tel" id="principalContact" name="principalContact" required placeholder="e.g., 9876543210" pattern="[0-9]{10}" title="Enter a valid 10-digit mobile number">
                        <div class="helper-text">This will be used as login username and password</div>
                        <div class="error-message" id="principalContactError"></div>
                    </div>
                    
                    <div class="form-group full">
                        <label for="registrationNumber">Registration Number</label>
                        <input type="text" id="registrationNumber" name="registrationNumber" placeholder="School registration/affiliation number">
                        <div class="error-message" id="registrationNumberError"></div>
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
                        <i class="fas fa-save"></i> Add School
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        // Real-time validation configuration
        const validationRules = {
            schoolName: {
                element: document.getElementById('schoolName'),
                errorElement: document.getElementById('schoolNameError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'School name is required' };
                    }
                    if (value.trim().length < 3) {
                        return { valid: false, message: 'School name must be at least 3 characters' };
                    }
                    return { valid: true, message: '' };
                }
            },
            schoolCode: {
                element: document.getElementById('schoolCode'),
                errorElement: document.getElementById('schoolCodeError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'School code is required' };
                    }
                    if (value.trim().length < 2) {
                        return { valid: false, message: 'School code must be at least 2 characters' };
                    }
                    if (!/^[A-Z0-9\-]+$/i.test(value.trim())) {
                        return { valid: false, message: 'School code should contain only letters, numbers, and hyphens' };
                    }
                    return { valid: true, message: '' };
                }
            },
            establishedYear: {
                element: document.getElementById('establishedYear'),
                errorElement: document.getElementById('establishedYearError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: true, message: '' }; // Optional field
                    }
                    const year = parseInt(value);
                    const currentYear = new Date().getFullYear();
                    if (year < 1900 || year > currentYear) {
                        return { valid: false, message: `Year must be between 1900 and ${currentYear}` };
                    }
                    return { valid: true, message: '' };
                }
            },
            address: {
                element: document.getElementById('address'),
                errorElement: document.getElementById('addressError'),
                validate: function(value) {
                    if (value.trim().length > 500) {
                        return { valid: false, message: 'Address must not exceed 500 characters' };
                    }
                    return { valid: true, message: '' };
                }
            },
            city: {
                element: document.getElementById('city'),
                errorElement: document.getElementById('cityError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'City is required' };
                    }
                    if (value.trim().length < 2) {
                        return { valid: false, message: 'City must be at least 2 characters' };
                    }
                    return { valid: true, message: '' };
                }
            },
            state: {
                element: document.getElementById('state'),
                errorElement: document.getElementById('stateError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'State is required' };
                    }
                    if (value.trim().length < 2) {
                        return { valid: false, message: 'State must be at least 2 characters' };
                    }
                    return { valid: true, message: '' };
                }
            },
            pincode: {
                element: document.getElementById('pincode'),
                errorElement: document.getElementById('pincodeError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: true, message: '' }; // Optional field
                    }
                    if (!/^[0-9]{5,}$/.test(value.trim())) {
                        return { valid: false, message: 'Pincode must contain at least 5 digits' };
                    }
                    return { valid: true, message: '' };
                }
            },
            phone: {
                element: document.getElementById('phone'),
                errorElement: document.getElementById('phoneError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'Phone number is required' };
                    }
                    if (!/^[0-9]{10,}$/.test(value.trim().replace(/[-\s]/g, ''))) {
                        return { valid: false, message: 'Phone number must contain at least 10 digits' };
                    }
                    return { valid: true, message: '' };
                }
            },
            email: {
                element: document.getElementById('email'),
                errorElement: document.getElementById('emailError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'Email is required' };
                    }
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(value.trim())) {
                        return { valid: false, message: 'Please enter a valid email address' };
                    }
                    return { valid: true, message: '' };
                }
            },
            principalName: {
                element: document.getElementById('principalName'),
                errorElement: document.getElementById('principalNameError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'Principal name is required' };
                    }
                    if (value.trim().length < 3) {
                        return { valid: false, message: 'Principal name must be at least 3 characters' };
                    }
                    return { valid: true, message: '' };
                }
            },
            principalContact: {
                element: document.getElementById('principalContact'),
                errorElement: document.getElementById('principalContactError'),
                validate: function(value) {
                    if (!value.trim()) {
                        return { valid: false, message: 'Mobile number is required' };
                    }
                    if (!/^[0-9]{10}$/.test(value.trim())) {
                        return { valid: false, message: 'Mobile number must be exactly 10 digits' };
                    }
                    return { valid: true, message: '' };
                }
            },
            registrationNumber: {
                element: document.getElementById('registrationNumber'),
                errorElement: document.getElementById('registrationNumberError'),
                validate: function(value) {
                    if (value.trim().length > 100) {
                        return { valid: false, message: 'Registration number must not exceed 100 characters' };
                    }
                    return { valid: true, message: '' };
                }
            }
        };

        // Initialize real-time validation
        function initializeValidation() {
            Object.keys(validationRules).forEach(fieldName => {
                const rule = validationRules[fieldName];
                if (rule.element) {
                    rule.element.addEventListener('input', function() {
                        validateField(fieldName);
                    });
                    rule.element.addEventListener('blur', function() {
                        validateField(fieldName);
                    });
                }
            });
        }

        // Validate a single field
        function validateField(fieldName) {
            const rule = validationRules[fieldName];
            if (!rule || !rule.element) return true;

            const value = rule.element.value;
            const result = rule.validate(value);
            const formGroup = rule.element.closest('.form-group');

            if (result.valid) {
                // Remove error styling
                formGroup.classList.remove('invalid');
                formGroup.classList.add('valid');
                rule.errorElement.textContent = '';
                rule.errorElement.classList.remove('show');
            } else {
                // Add error styling and message
                formGroup.classList.remove('valid');
                formGroup.classList.add('invalid');
                rule.errorElement.textContent = result.message;
                rule.errorElement.classList.add('show');
            }

            return result.valid;
        }

        // Validate entire form
        function validateForm() {
            let isValid = true;

            Object.keys(validationRules).forEach(fieldName => {
                const isFieldValid = validateField(fieldName);
                if (!isFieldValid) {
                    isValid = false;
                }
            });

            return isValid;
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            initializeValidation();
        });

        // Validate on form submit
        document.querySelector('form').addEventListener('submit', function(e) {
            if (!validateForm()) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>
