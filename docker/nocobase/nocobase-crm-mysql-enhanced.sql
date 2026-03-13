-- Enhanced NocoBase CRM - Method 2: Universal SQL Import for MySQL
-- Complete South African Real Estate CRM with advanced features
-- MySQL-compatible version
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
  `