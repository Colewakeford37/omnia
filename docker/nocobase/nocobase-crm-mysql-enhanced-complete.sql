-- Enhanced NocoBase CRM - Method 2: Universal SQL Import for MySQL
-- Complete South African Real Estate CRM with advanced features
-- MySQL-compatible version with 8 comprehensive collections
-- Based on official NocoBase CRM tutorial patterns

-- =====================================================
-- CORE CRM TABLES
-- =====================================================

-- 1. CRM Leads Collection (Potential customers)
CREATE TABLE IF NOT EXISTS `crm_leads` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE,
  `phone` VARCHAR(255),
  `mobile` VARCHAR(255),
  `company` VARCHAR(255),
  `job_title` VARCHAR(255),
  `status` VARCHAR(50) DEFAULT 'new' CHECK (`status` IN ('new', 'contacted', 'qualified', 'lost', 'converted')),
  `source` VARCHAR(100) CHECK (`source` IN ('website', 'referral', 'social', 'advertisement', 'cold_call', 'walk_in')),
  `assigned_to` BIGINT,
  `priority` VARCHAR(20) DEFAULT 'medium' CHECK (`priority` IN ('low', 'medium', 'high', 'urgent')),
  `budget_min` DECIMAL(15,2),
  `budget_max` DECIMAL(15,2),
  `preferred_location` VARCHAR(255),
  `property_type_interest` VARCHAR(100),
  `rsa_id` VARCHAR(13) UNIQUE,
  `fica_status` VARCHAR(50) DEFAULT 'pending' CHECK (`fica_status` IN ('pending', 'verified', 'rejected', 'expired')),
  `notes` TEXT,
  `last_contact_date` DATE,
  `next_follow_up` DATE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. CRM Contacts Collection (Existing customers/contacts)
CREATE TABLE IF NOT EXISTS `crm_contacts` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(255) NOT NULL,
  `last_name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) UNIQUE,
  `phone` VARCHAR(255),
  `mobile` VARCHAR(255),
  `company` VARCHAR(255),
  `job_title` VARCHAR(255),
  `department` VARCHAR(255),
  `contact_type` VARCHAR(50) DEFAULT 'individual' CHECK (`contact_type` IN