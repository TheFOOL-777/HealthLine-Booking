CREATE DATABASE IF NOT EXISTS clinic_appointment_db;
USE clinic_appointment_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(191) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user'
    ,reset_code VARCHAR(10) NULL
    ,reset_code_expiry DATETIME NULL
);

-- Services Table
CREATE TABLE IF NOT EXISTS services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT NULL
);

-- Employees Table
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255),
    service_id INT, -- To map which service they provide
    employee_tag VARCHAR(50) UNIQUE NOT NULL,
    availability TEXT,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL
);

-- Employee Services Junction Table
CREATE TABLE IF NOT EXISTS employee_services (
    employee_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (employee_id, service_id)
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    employee_id INT NOT NULL,
    service_id INT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    end_time TIME NOT NULL DEFAULT '00:00:00',
    status ENUM('Pending', 'Approved', 'Cancelled') DEFAULT 'Pending',
    reference_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Patient Info
    patient_name VARCHAR(255) NOT NULL,
    patient_age INT NOT NULL,
    patient_gender ENUM('Male', 'Female', 'Other') NOT NULL,
    patient_contact VARCHAR(100) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
);

-- Appointment Requests Table
CREATE TABLE IF NOT EXISTS appointment_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    request_type ENUM('Reschedule', 'Cancel') NOT NULL DEFAULT 'Reschedule',
    requested_date DATE NULL,
    requested_time TIME NULL,
    requested_end_time TIME NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE
);

-- Seed an Admin User
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@yanyans.clinic', 'admin123', 'admin');

-- Employee Schedules Table (Recurring Day of Week Scheduling)
CREATE TABLE IF NOT EXISTS employee_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    time TIME NOT NULL,
    end_time TIME NOT NULL DEFAULT '00:00:00',
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE(employee_id, day_of_week, time)
);

-- Service Categories Table
CREATE TABLE IF NOT EXISTS service_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Add default General category if not exists
INSERT INTO service_categories (id, name, description)
SELECT 1, 'General', 'General clinic services'
WHERE NOT EXISTS (SELECT 1 FROM service_categories WHERE id = 1);

-- Map existing services to default category
UPDATE services SET category_id = 1 WHERE category_id IS NULL;

-- Add foreign key for category_id in services
ALTER TABLE services ADD CONSTRAINT fk_services_category_id FOREIGN KEY (category_id) REFERENCES service_categories(id) ON DELETE CASCADE;
