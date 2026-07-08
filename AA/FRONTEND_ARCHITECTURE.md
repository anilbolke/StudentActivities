# Frontend Architecture - School Exam Management System

## Technology Stack
- **Framework:** Bootstrap 5 + jQuery
- **Layout:** Responsive Grid System
- **Charts:** Chart.js
- **Tables:** DataTables
- **PDF Generation:** jsPDF
- **File Upload:** jQuery File Upload

---

## Project Directory Structure

```
WebContent/
├── index.html
├── login.html
├── css/
│   ├── bootstrap.min.css
│   ├── custom.css
│   ├── responsive.css
│   ├── dashboard.css
│   ├── forms.css
│   └── tables.css
├── js/
│   ├── jquery-3.6.0.min.js
│   ├── bootstrap.min.js
│   ├── bootstrap.bundle.min.js
│   ├── datatables.min.js
│   ├── chart.min.js
│   ├── api-client.js
│   ├── auth.js
│   ├── validation.js
│   ├── utils.js
│   └── modules/
│       ├── admin.js
│       ├── teacher.js
│       ├── student.js
│       └── parent.js
├── images/
│   ├── logo.png
│   ├── icons/
│   └── backgrounds/
├── jsp/
│   ├── admin/
│   │   ├── dashboard.jsp
│   │   ├── schoolSetup.jsp
│   │   ├── classManagement.jsp
│   │   ├── subjectManagement.jsp
│   │   ├── topicManagement.jsp
│   │   ├── questionManagement.jsp
│   │   ├── studentRegistration.jsp
│   │   ├── bulkUpload.jsp
│   │   └── reports.jsp
│   ├── teacher/
│   │   ├── dashboard.jsp
│   │   ├── examGeneration.jsp
│   │   ├── examDetails.jsp
│   │   ├── answerKey.jsp
│   │   └── examList.jsp
│   ├── student/
│   │   ├── dashboard.jsp
│   │   ├── availableExams.jsp
│   │   ├── examInterface.jsp
│   │   ├── results.jsp
│   │   └── resultDetails.jsp
│   ├── parent/
│   │   ├── dashboard.jsp
│   │   ├── childResults.jsp
│   │   ├── subjectPerformance.jsp
│   │   ├── trendAnalysis.jsp
│   │   └── weakTopics.jsp
│   ├── common/
│   │   ├── header.jsp
│   │   ├── sidebar.jsp
│   │   ├── footer.jsp
│   │   └── error.jsp
│   └── login.jsp
└── assets/
    └── fonts/
```

---

## Core Frontend Components

### 1. API Client (api-client.js)

```javascript
// js/api-client.js
const API_BASE = '/school-exam-system/api';

const ApiClient = {
    
    // Generic HTTP method
    async request(method, endpoint, data = null) {
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            }
        };
        
        if (data) {
            options.body = JSON.stringify(data);
        }
        
        try {
            const response = await fetch(`${API_BASE}${endpoint}`, options);
            const result = await response.json();
            
            if (!response.ok && result.error_code === 'UNAUTHORIZED') {
                window.location.href = '/school-exam-system/login.jsp';
                return null;
            }
            
            return result;
        } catch (error) {
            console.error('API Error:', error);
            showAlert('An error occurred. Please try again.', 'error');
            return null;
        }
    },
    
    // Auth endpoints
    auth: {
        login(username, password) {
            return ApiClient.request('POST', '/auth/login', 
                { username, password });
        },
        logout() {
            return ApiClient.request('GET', '/auth/logout');
        }
    },
    
    // Admin endpoints
    admin: {
        school: {
            create(data) {
                return ApiClient.request('POST', '/admin/school/create', data);
            },
            list() {
                return ApiClient.request('GET', '/admin/school/list');
            },
            update(data) {
                return ApiClient.request('PUT', '/admin/school/update', data);
            }
        },
        
        class: {
            create(data) {
                return ApiClient.request('POST', '/admin/class/create', data);
            },
            list(schoolId) {
                return ApiClient.request('GET', 
                    `/admin/class/list?school_id=${schoolId}`);
            }
        },
        
        student: {
            add(data) {
                return ApiClient.request('POST', '/admin/student/add', data);
            },
            bulkUpload(formData) {
                // File upload doesn't use JSON
                return fetch(`${API_BASE}/admin/student/bulk-upload`, {
                    method: 'POST',
                    body: formData
                }).then(r => r.json());
            }
        }
    },
    
    // Teacher endpoints
    teacher: {
        exam: {
            generate(data) {
                return ApiClient.request('POST', '/teacher/exam/generate', data);
            },
            getClasses() {
                return ApiClient.request('GET', '/teacher/classes');
            }
        }
    },
    
    // Student endpoints
    student: {
        exam: {
            getAvailable() {
                return ApiClient.request('GET', '/student/exams');
            },
            start(examPaperId, studentId) {
                return ApiClient.request('POST', '/student/exam/start', 
                    { exam_paper_id: examPaperId, student_id: studentId });
            },
            submitAnswer(data) {
                return ApiClient.request('POST', '/student/exam/submit-answer', data);
            }
        }
    }
};
```

---

### 2. Authentication Module (auth.js)

```javascript
// js/auth.js
const Auth = {
    
    async login() {
        const username = $('#username').val();
        const password = $('#password').val();
        
        if (!username || !password) {
            showAlert('Please enter username and password', 'warning');
            return;
        }
        
        const result = await ApiClient.auth.login(username, password);
        
        if (result && result.success) {
            sessionStorage.setItem('user_id', result.user_id);
            sessionStorage.setItem('role', result.role);
            sessionStorage.setItem('school_id', result.school_id);
            
            // Redirect based on role
            const redirectUrl = getRoleRedirectUrl(result.role);
            window.location.href = redirectUrl;
        } else {
            showAlert(result?.message || 'Login failed', 'error');
        }
    },
    
    logout() {
        if (confirm('Are you sure you want to logout?')) {
            ApiClient.auth.logout().then(() => {
                sessionStorage.clear();
                window.location.href = '/school-exam-system/login.jsp';
            });
        }
    },
    
    getCurrentUser() {
        return {
            userId: sessionStorage.getItem('user_id'),
            role: sessionStorage.getItem('role'),
            schoolId: sessionStorage.getItem('school_id')
        };
    },
    
    isAuthenticated() {
        return sessionStorage.getItem('user_id') !== null;
    },
    
    requireRole(...roles) {
        const user = Auth.getCurrentUser();
        if (!roles.includes(user.role)) {
            window.location.href = '/school-exam-system/access-denied.jsp';
        }
    }
};

function getRoleRedirectUrl(role) {
    const redirects = {
        'ADMIN': '/school-exam-system/admin/dashboard.jsp',
        'TEACHER': '/school-exam-system/teacher/dashboard.jsp',
        'STUDENT': '/school-exam-system/student/dashboard.jsp',
        'PARENT': '/school-exam-system/parent/dashboard.jsp'
    };
    return redirects[role] || '/school-exam-system/login.jsp';
}
```

---

### 3. Validation Module (validation.js)

```javascript
// js/validation.js
const Validation = {
    
    rules: {
        email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
        phone: /^\d{10}$/,
        pincode: /^\d{6}$/,
        password: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
        username: /^[a-zA-Z0-9_]{3,20}$/
    },
    
    validateForm(formId) {
        let isValid = true;
        
        $(`#${formId} [data-validate]`).each(function() {
            const rule = $(this).data('validate');
            if (!Validation.validate($(this).val(), rule)) {
                $(this).addClass('is-invalid');
                isValid = false;
            } else {
                $(this).removeClass('is-invalid');
            }
        });
        
        return isValid;
    },
    
    validate(value, rule) {
        if (!value && rule !== 'required') return true;
        
        if (rule === 'required') return value && value.trim() !== '';
        if (rule === 'email') return this.rules.email.test(value);
        if (rule === 'phone') return this.rules.phone.test(value);
        if (rule === 'pincode') return this.rules.pincode.test(value);
        if (rule === 'password') return this.rules.password.test(value);
        if (rule === 'username') return this.rules.username.test(value);
        
        return true;
    }
};
```

---

### 4. Utility Functions (utils.js)

```javascript
// js/utils.js

function showAlert(message, type = 'info') {
    const alertClass = {
        'info': 'alert-info',
        'success': 'alert-success',
        'warning': 'alert-warning',
        'error': 'alert-danger'
    };
    
    const alertHtml = `
        <div class="alert ${alertClass[type]} alert-dismissible fade show" role="alert">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    $('#alert-container').html(alertHtml);
    
    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        $('#alert-container .alert').fadeOut();
    }, 5000);
}

function formatDate(dateStr) {
    const date = new Date(dateStr);
    return date.toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR'
    }).format(amount);
}

function getGradeColor(grade) {
    const colors = {
        'A+': 'success',
        'A': 'success',
        'B': 'info',
        'C': 'warning',
        'D': 'warning',
        'F': 'danger'
    };
    return colors[grade] || 'secondary';
}

function initializeDataTable(tableId, options = {}) {
    return $(`#${tableId}`).DataTable({
        responsive: true,
        pageLength: 10,
        dom: 'Bfrtip',
        buttons: ['copy', 'csv', 'excel', 'pdf', 'print'],
        ...options
    });
}

function loadTemplate(templateId, containerId) {
    const template = $(`#${templateId}`).html();
    $(`#${containerId}`).html(template);
}
```

---

## Page Components

### Admin Dashboard (admin/dashboard.jsp)

```html
<%@ include file="../common/header.jsp" %>

<div class="container-fluid">
    <div class="row mt-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white">
                <div class="card-body">
                    <h5 class="card-title">Schools</h5>
                    <h2 id="school-count">0</h2>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card bg-info text-white">
                <div class="card-body">
                    <h5 class="card-title">Classes</h5>
                    <h2 id="class-count">0</h2>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <h5 class="card-title">Students</h5>
                    <h2 id="student-count">0</h2>
                </div>
            </div>
        </div>
        
        <div class="col-md-3">
            <div class="card bg-warning text-white">
                <div class="card-body">
                    <h5 class="card-title">Exams</h5>
                    <h2 id="exam-count">0</h2>
                </div>
            </div>
        </div>
    </div>
    
    <div class="row mt-5">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h5>Class Performance</h5>
                </div>
                <div class="card-body">
                    <canvas id="classPerformanceChart"></canvas>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card">
                <div class="card-header">
                    <h5>Subject Distribution</h5>
                </div>
                <div class="card-body">
                    <canvas id="subjectChart"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="../../js/modules/admin.js"></script>
<%@ include file="../common/footer.jsp" %>
```

### Teacher Exam Generation (teacher/examGeneration.jsp)

```html
<%@ include file="../common/header.jsp" %>

<div class="container-fluid mt-5">
    <div class="card">
        <div class="card-header">
            <h5>Generate Exam Paper</h5>
        </div>
        
        <div class="card-body">
            <form id="examForm" class="needs-validation">
                
                <!-- Step 1: Select Class -->
                <div class="mb-3">
                    <label for="class">Select Class *</label>
                    <select id="class" class="form-select" data-validate="required" required>
                        <option value="">Choose a class...</option>
                    </select>
                </div>
                
                <!-- Step 2: Select Subject -->
                <div class="mb-3">
                    <label for="subject">Select Subject *</label>
                    <select id="subject" class="form-select" data-validate="required" required>
                        <option value="">Choose a subject...</option>
                    </select>
                </div>
                
                <!-- Step 3: Select Topics -->
                <div class="mb-3">
                    <label>Select Topics *</label>
                    <div id="topicsList" class="border p-3 rounded">
                        <!-- Topics will be loaded here -->
                    </div>
                </div>
                
                <!-- Exam Details -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="examName">Exam Name *</label>
                            <input type="text" id="examName" class="form-control" 
                                   data-validate="required" required>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="examDate">Exam Date *</label>
                            <input type="date" id="examDate" class="form-control" 
                                   data-validate="required" required>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="duration">Duration (Minutes) *</label>
                            <input type="number" id="duration" class="form-control" 
                                   value="60" data-validate="required" required>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="totalQuestions">Total Questions *</label>
                            <input type="number" id="totalQuestions" class="form-control" 
                                   value="15" data-validate="required" required>
                        </div>
                    </div>
                    
                    <div class="col-md-4">
                        <div class="mb-3">
                            <label for="totalMarks">Total Marks *</label>
                            <input type="number" id="totalMarks" class="form-control" 
                                   value="100" data-validate="required" required>
                        </div>
                    </div>
                </div>
                
                <!-- Options -->
                <div class="form-check mt-3">
                    <input type="checkbox" id="shuffleQuestions" class="form-check-input" checked>
                    <label class="form-check-label" for="shuffleQuestions">
                        Shuffle Questions
                    </label>
                </div>
                
                <div class="form-check">
                    <input type="checkbox" id="shuffleOptions" class="form-check-input" checked>
                    <label class="form-check-label" for="shuffleOptions">
                        Shuffle Answer Options
                    </label>
                </div>
                
                <!-- Action Buttons -->
                <div class="mt-5">
                    <button type="submit" class="btn btn-primary btn-lg">
                        <i class="bi bi-file-earmark-pdf"></i> Generate Exam
                    </button>
                    <button type="reset" class="btn btn-secondary btn-lg">Reset</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="../../js/modules/teacher.js"></script>
<%@ include file="../common/footer.jsp" %>
```

### Student Exam Interface (student/examInterface.jsp)

```html
<%@ include file="../common/header.jsp" %>

<div class="container-fluid mt-5">
    <div class="row">
        
        <!-- Questions Panel (Left) -->
        <div class="col-md-8">
            <div class="card">
                <div class="card-header bg-dark text-white">
                    <h5>Question <span id="currentQuestion">1</span> of <span id="totalQuestions">15</span></h5>
                </div>
                
                <div class="card-body">
                    <div id="questionContainer">
                        <!-- Question will be loaded here -->
                    </div>
                </div>
                
                <div class="card-footer">
                    <button id="prevBtn" class="btn btn-outline-primary">
                        <i class="bi bi-chevron-left"></i> Previous
                    </button>
                    <button id="nextBtn" class="btn btn-outline-primary">
                        Next <i class="bi bi-chevron-right"></i>
                    </button>
                    <button id="submitBtn" class="btn btn-danger float-end">
                        <i class="bi bi-check-circle"></i> Submit Exam
                    </button>
                </div>
            </div>
        </div>
        
        <!-- Question Navigation (Right) -->
        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Time Left: <span id="timeLeft">60:00</span></h5>
                </div>
                
                <div class="card-body">
                    <h6>Question Status</h6>
                    <div id="questionNav" style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 5px;">
                        <!-- Question numbers will be displayed here -->
                    </div>
                </div>
                
                <div class="card-footer">
                    <div class="small">
                        <div class="mb-2">
                            <span class="badge bg-success">Answered</span>
                        </div>
                        <div class="mb-2">
                            <span class="badge bg-warning">Not Answered</span>
                        </div>
                        <div>
                            <span class="badge bg-secondary">Not Visited</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
    </div>
</div>

<script src="../../js/modules/student.js"></script>
<%@ include file="../common/footer.jsp" %>
```

---

## Responsive CSS (responsive.css)

```css
/* Mobile First Approach */

/* Tablets (768px and up) */
@media (min-width: 768px) {
    .card {
        margin-bottom: 20px;
    }
    
    .sidebar {
        position: fixed;
        left: 0;
        height: 100vh;
        width: 250px;
    }
    
    .main-content {
        margin-left: 250px;
    }
}

/* Desktops (992px and up) */
@media (min-width: 992px) {
    .container-fluid {
        max-width: 1400px;
        margin: 0 auto;
    }
}

/* Large screens (1200px and up) */
@media (min-width: 1200px) {
    .grid-4 {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 20px;
    }
}

/* Mobile (less than 768px) */
@media (max-width: 767px) {
    .sidebar {
        position: fixed;
        left: -250px;
        height: 100vh;
        width: 250px;
        transition: left 0.3s;
        z-index: 1000;
    }
    
    .sidebar.active {
        left: 0;
    }
    
    .card {
        margin-bottom: 15px;
    }
    
    .btn-sm {
        padding: 0.25rem 0.5rem;
        font-size: 0.875rem;
    }
}
```

---

## Asset Organization

### Images Directory Structure
```
images/
├── logo.png (500x100)
├── favicon.ico
├── icons/
│   ├── home.svg
│   ├── settings.svg
│   ├── user.svg
│   └── logout.svg
└── backgrounds/
    └── dashboard-bg.jpg
```

### Font Integration
```html
<link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.8.1/font/bootstrap-icons.min.css" rel="stylesheet">
```

---

## Key Frontend Features

1. **Responsive Design** - Works on all devices
2. **Real-time Validation** - Client-side form validation
3. **Loading States** - Visual feedback during API calls
4. **Modal Dialogs** - For confirmations and alerts
5. **Data Tables** - Sortable, searchable, paginated tables
6. **Charts & Graphs** - Visual analytics with Chart.js
7. **Keyboard Navigation** - Accessibility support
8. **Dark Mode Option** - Theme toggle
9. **Offline Support** - Service Worker for offline mode
10. **Accessibility** - WCAG 2.1 Level AA compliance

