// API Client Module
const ApiClient = {
    baseUrl: '/StudentActivities/api',

    async get(endpoint) {
        try {
            const response = await fetch(this.baseUrl + endpoint);
            if (!response.ok) throw new Error('API Error: ' + response.statusText);
            return await response.json();
        } catch (error) {
            console.error('GET Error:', error);
            throw error;
        }
    },

    async post(endpoint, data) {
        try {
            const response = await fetch(this.baseUrl + endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });
            if (!response.ok) throw new Error('API Error: ' + response.statusText);
            return await response.json();
        } catch (error) {
            console.error('POST Error:', error);
            throw error;
        }
    },

    async put(endpoint, data) {
        try {
            const response = await fetch(this.baseUrl + endpoint, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(data)
            });
            if (!response.ok) throw new Error('API Error: ' + response.statusText);
            return await response.json();
        } catch (error) {
            console.error('PUT Error:', error);
            throw error;
        }
    },

    async delete(endpoint) {
        try {
            const response = await fetch(this.baseUrl + endpoint, {
                method: 'DELETE'
            });
            if (!response.ok) throw new Error('API Error: ' + response.statusText);
            return await response.json();
        } catch (error) {
            console.error('DELETE Error:', error);
            throw error;
        }
    }
};

// UI Utilities
const UI = {
    showAlert(message, type = 'success') {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type}`;
        alertDiv.textContent = message;
        
        const container = document.querySelector('.container') || document.body;
        container.insertBefore(alertDiv, container.firstChild);
        
        setTimeout(() => alertDiv.remove(), 3000);
    },

    showError(message) {
        this.showAlert(message, 'danger');
    },

    showSuccess(message) {
        this.showAlert(message, 'success');
    }
};

// Form Utilities
const FormUtils = {
    getFormData(formElement) {
        const formData = new FormData(formElement);
        const data = Object.fromEntries(formData);
        return data;
    },

    clearForm(formElement) {
        formElement.reset();
    }
};

// Document Ready
document.addEventListener('DOMContentLoaded', function() {
    console.log('Application loaded');
});
