-- NocoBase CRM Demo - Method 2: Universal SQL Import
-- This script follows the official NocoBase CRM tutorial for Community Edition compatibility
-- Source: https://www.nocobase.com/en/tutorials/nocobase-crm-demo-deployment-guide

-- Create CRM collections with proper NocoBase structure
-- These will automatically appear in the Data Source Manager and can be configured for UI

-- 1. CRM Leads Collection
CREATE TABLE IF NOT EXISTS "crm_leads" (
  "id" BIGSERIAL PRIMARY KEY,
  "first_name" VARCHAR(255),
  "last_name" VARCHAR(255),
  "email" VARCHAR(255),
  "phone" VARCHAR(255),
  "company" VARCHAR(255),
  "status" VARCHAR(50) DEFAULT 'new',
  "source" VARCHAR(100),
  "assigned_to" BIGINT,
  "rsa_id" VARCHAR(13),
  "fica_status" VARCHAR(50) DEFAULT 'pending',
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CRM Contacts Collection  
CREATE TABLE IF NOT EXISTS "crm_contacts" (
  "id" BIGSERIAL PRIMARY KEY,
  "first_name" VARCHAR(255),
  "last_name" VARCHAR(255),
  "email" VARCHAR(255),
  "phone" VARCHAR(255),
  "company" VARCHAR(255),
  "job_title" VARCHAR(255),
  "rsa_id" VARCHAR(13),
  "fica_status" VARCHAR(50) DEFAULT 'pending',
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. CRM Properties Collection
CREATE TABLE IF NOT EXISTS "crm_properties" (
  "id" BIGSERIAL PRIMARY KEY,
  "title" VARCHAR(255),
  "description" TEXT,
  "property_type" VARCHAR(100),
  "price" DECIMAL(15,2),
  "address" TEXT,
  "suburb" VARCHAR(255),
  "city" VARCHAR(255),
  "province" VARCHAR(255),
  "postal_code" VARCHAR(20),
  "bedrooms" INTEGER,
  "bathrooms" INTEGER,
  "parking_spaces" INTEGER,
  "square_meters" INTEGER,
  "status" VARCHAR(50) DEFAULT 'available',
  "listing_agent" BIGINT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. CRM Deals Collection
CREATE TABLE IF NOT EXISTS "crm_deals" (
  "id" BIGSERIAL PRIMARY KEY,
  "title" VARCHAR(255),
  "description" TEXT,
  "value" DECIMAL(15,2),
  "currency" VARCHAR(3) DEFAULT 'ZAR',
  "stage" VARCHAR(50) DEFAULT 'prospecting',
  "probability" INTEGER DEFAULT 0,
  "expected_close_date" DATE,
  "actual_close_date" DATE,
  "lead_id" BIGINT,
  "contact_id" BIGINT,
  "property_id" BIGINT,
  "assigned_to" BIGINT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. CRM Suburbs Collection
CREATE TABLE IF NOT EXISTS "crm_suburbs" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(255),
  "city" VARCHAR(255),
  "province" VARCHAR(255),
  "postal_code" VARCHAR(20),
  "average_price" DECIMAL(15,2),
  "property_count" INTEGER DEFAULT 0,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. FICA Documents Collection
CREATE TABLE IF NOT EXISTS "crm_fica_documents" (
  "id" BIGSERIAL PRIMARY KEY,
  "document_type" VARCHAR(100),
  "file_name" VARCHAR(255),
  "file_path" VARCHAR(500),
  "file_size" BIGINT,
  "mime_type" VARCHAR(100),
  "status" VARCHAR(50) DEFAULT 'pending',
  "verified_by" BIGINT,
  "verified_at" TIMESTAMP,
  "lead_id" BIGINT,
  "contact_id" BIGINT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Register collections in NocoBase collections table
-- This makes them appear in Data Source Manager
INSERT INTO "collections" ("name", "title", "inherits", "model", "filterTargetKey", "createdAt", "updatedAt") VALUES
('crm_leads', 'CRM Leads', NULL, 'Model', 'id', NOW(), NOW()),
('crm_contacts', 'CRM Contacts', NULL, 'Model', 'id', NOW(), NOW()),
('crm_properties', 'CRM Properties', NULL, 'Model', 'id', NOW(), NOW()),
('crm_deals', 'CRM Deals', NULL, 'Model', 'id', NOW(), NOW()),
('crm_suburbs', 'CRM Suburbs', NULL, 'Model', 'id', NOW(), NOW()),
('crm_fica_documents', 'FICA Documents', NULL, 'Model', 'id', NOW(), NOW());

-- Add collection fields to NocoBase fields table
-- This defines the schema for each collection
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
-- CRM Leads Fields
('crm_leads', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_leads', 'first_name', 'string', 'input', '{"title":"First Name","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'last_name', 'string', 'input', '{"title":"Last Name","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'email', 'string', 'email', '{"title":"Email","type":"string","x-component":"Input","x-validator":"email"}', NOW(), NOW()),
('crm_leads', 'phone', 'string', 'phone', '{"title":"Phone","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'company', 'string', 'input', '{"title":"Company","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"new","label":"New"},{"value":"contacted","label":"Contacted"},{"value":"qualified","label":"Qualified"},{"value":"lost","label":"Lost"}]}', NOW(), NOW()),
('crm_leads', 'source', 'string', 'select', '{"title":"Source","type":"string","x-component":"Select","enum":[{"value":"website","label":"Website"},{"value":"referral","label":"Referral"},{"value":"social","label":"Social Media"},{"value":"advertisement","label":"Advertisement"}]}', NOW(), NOW()),
('crm_leads', 'rsa_id', 'string', 'input', '{"title":"RSA ID Number","type":"string","x-component":"Input","pattern":"^[0-9]{13}$"}', NOW(), NOW()),
('crm_leads', 'fica_status', 'string', 'select', '{"title":"FICA Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"verified","label":"Verified"},{"value":"rejected","label":"Rejected"}]}', NOW(), NOW()),
('crm_leads', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_leads', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),

-- CRM Contacts Fields
('crm_contacts', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_contacts', 'first_name', 'string', 'input', '{"title":"First Name","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'last_name', 'string', 'input', '{"title":"Last Name","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'email', 'string', 'email', '{"title":"Email","type":"string","x-component":"Input","x-validator":"email"}', NOW(), NOW()),
('crm_contacts', 'phone', 'string', 'phone', '{"title":"Phone","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'company', 'string', 'input', '{"title":"Company","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'job_title', 'string', 'input', '{"title":"Job Title","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'rsa_id', 'string', 'input', '{"title":"RSA ID Number","type":"string","x-component":"Input","pattern":"^[0-9]{13}$"}', NOW(), NOW()),
('crm_contacts', 'fica_status', 'string', 'select', '{"title":"FICA Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"verified","label":"Verified"},{"value":"rejected","label":"Rejected"}]}', NOW(), NOW()),
('crm_contacts', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_contacts', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),

-- CRM Properties Fields
('crm_properties', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_properties', 'title', 'string', 'input', '{"title":"Property Title","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_properties', 'description', 'text', 'textarea', '{"title":"Description","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_properties', 'property_type', 'string', 'select', '{"title":"Property Type","type":"string","x-component":"Select","enum":[{"value":"house","label":"House"},{"value":"apartment","label":"Apartment"},{"value":"townhouse","label":"Townhouse"},{"value":"commercial","label":"Commercial"},{"value":"land","label":"Land"}]}', NOW(), NOW()),
('crm_properties', 'price', 'decimal', 'number', '{"title":"Price","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_properties', 'address', 'text', 'textarea', '{"title":"Address","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_properties', 'suburb', 'string', 'input', '{"title":"Suburb","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_properties', 'city', 'string', 'input', '{"title":"City","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_properties', 'province', 'string', 'select', '{"title":"Province","type":"string","x-component":"Select","enum":[{"value":"EC","label":"Eastern Cape"},{"value":"FS","label":"Free State"},{"value":"GP","label":"Gauteng"},{"value":"KZN","label":"KwaZulu-Natal"},{"value":"L","label":"Limpopo"},{"value":"MP","label":"Mpumalanga"},{"value":"NC","label":"Northern Cape"},{"value":"NW","label":"North West"},{"value":"WC","label":"Western Cape"}]}', NOW(), NOW()),
('crm_properties', 'postal_code', 'string', 'input', '{"title":"Postal Code","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_properties', 'bedrooms', 'integer', 'integer', '{"title":"Bedrooms","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'bathrooms', 'integer', 'integer', '{"title":"Bathrooms","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'parking_spaces', 'integer', 'integer', '{"title":"Parking Spaces","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'square_meters', 'integer', 'integer', '{"title":"Square Meters","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"available","label":"Available"},{"value":"sold","label":"Sold"},{"value":"pending","label":"Pending"},{"value":"withdrawn","label":"Withdrawn"}]}', NOW(), NOW()),
('crm_properties', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_properties', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),

-- CRM Deals Fields
('crm_deals', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_deals', 'title', 'string', 'input', '{"title":"Deal Title","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_deals', 'description', 'text', 'textarea', '{"title":"Description","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_deals', 'value', 'decimal', 'number', '{"title":"Deal Value","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_deals', 'currency', 'string', 'select', '{"title":"Currency","type":"string","x-component":"Select","enum":[{"value":"ZAR","label":"South African Rand"}]}', NOW(), NOW()),
('crm_deals', 'stage', 'string', 'select', '{"title":"Stage","type":"string","x-component":"Select","enum":[{"value":"prospecting","label":"Prospecting"},{"value":"qualification","label":"Qualification"},{"value":"proposal","label":"Proposal"},{"value":"negotiation","label":"Negotiation"},{"value":"closed_won","label":"Closed Won"},{"value":"closed_lost","label":"Closed Lost"}]}', NOW(), NOW()),
('crm_deals', 'probability', 'integer', 'integer', '{"title":"Probability (%)","type":"number","x-component":"InputNumber","x-min":0,"x-max":100}', NOW(), NOW()),
('crm_deals', 'expected_close_date', 'date', 'date', '{"title":"Expected Close Date","type":"string","x-component":"DatePicker"}', NOW(), NOW()),
('crm_deals', 'actual_close_date', 'date', 'date', '{"title":"Actual Close Date","type":"string","x-component":"DatePicker"}', NOW(), NOW()),
('crm_deals', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_deals', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),

-- CRM Suburbs Fields
('crm_suburbs', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_suburbs', 'name', 'string', 'input', '{"title":"Suburb Name","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_suburbs', 'city', 'string', 'input', '{"title":"City","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_suburbs', 'province', 'string', 'select', '{"title":"Province","type":"string","x-component":"Select","enum":[{"value":"EC","label":"Eastern Cape"},{"value":"FS","label":"Free State"},{"value":"GP","label":"Gauteng"},{"value":"KZN","label":"KwaZulu-Natal"},{"value":"L","label":"Limpopo"},{"value":"MP","label":"Mpumalanga"},{"value":"NC","label":"Northern Cape"},{"value":"NW","label":"North West"},{"value":"WC","label":"Western Cape"}]}', NOW(), NOW()),
('crm_suburbs', 'postal_code', 'string', 'input', '{"title":"Postal Code","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_suburbs', 'average_price', 'decimal', 'number', '{"title":"Average Price","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_suburbs', 'property_count', 'integer', 'integer', '{"title":"Property Count","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_suburbs', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_suburbs', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),

-- FICA Documents Fields
('crm_fica_documents', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'document_type', 'string', 'select', '{"title":"Document Type","type":"string","x-component":"Select","enum":[{"value":"id_document","label":"ID Document"},{"value":"proof_of_address","label":"Proof of Address"},{"value":"proof_of_income","label":"Proof of Income"},{"value":"bank_statement","label":"Bank Statement"}]}', NOW(), NOW()),
('crm_fica_documents', 'file_name', 'string', 'input', '{"title":"File Name","type":"string","x-component":"Input","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'file_path', 'string', 'input', '{"title":"File Path","type":"string","x-component":"Input","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'file_size', 'bigInt', 'integer', '{"title":"File Size","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'mime_type', 'string', 'input', '{"title":"MIME Type","type":"string","x-component":"Input","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"verified","label":"Verified"},{"value":"rejected","label":"Rejected"}]}', NOW(), NOW()),
('crm_fica_documents', 'verified_at', 'date', 'datetime', '{"title":"Verified At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_fica_documents', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- Create UI Schemas for Menu Integration
-- This creates the sidebar menu structure following NocoBase patterns
INSERT INTO "uiSchemas" ("name", "uiSchema", "xUid", "createdAt", "updatedAt") VALUES
-- Main CRM Menu Group
('crm_menu_group', '{
  "type": "void",
  "title": "Real Estate CRM",
  "name": "crm",
  "icon": "ShopOutlined",
  "x-designer": {"placement": "sidebar"},
  "x-uid": "crm-menu-group",
  "x-async": false,
  "x-index": 10
}', 'crm-menu-group', NOW(), NOW()),

-- CRM Dashboard Menu Item
('crm_dashboard', '{
  "type": "void",
  "title": "Dashboard",
  "name": "crm_dashboard",
  "icon": "DashboardOutlined",
  "x-uid": "crm-dashboard",
  "x-async": false,
  "x-index": 1,
  "parent": "crm-menu-group"
}', 'crm-dashboard', NOW(), NOW()),

-- Leads Menu Item
('crm_leads_menu', '{
  "type": "void", 
  "title": "Leads",
  "name": "crm_leads_menu",
  "icon": "UserOutlined",
  "x-uid": "crm-leads-menu",
  "x-async": false,
  "x-index": 2,
  "parent": "crm-menu-group"
}', 'crm-leads-menu', NOW(), NOW()),

-- Contacts Menu Item
('crm_contacts_menu', '{
  "type": "void",
  "title": "Contacts", 
  "name": "crm_contacts_menu",
  "icon": "TeamOutlined",
  "x-uid": "crm-contacts-menu",
  "x-async": false,
  "x-index": 3,
  "parent": "crm-menu-group"
}', 'crm-contacts-menu', NOW(), NOW()),

-- Properties Menu Item
('crm_properties_menu', '{
  "type": "void",
  "title": "Properties",
  "name": "crm_properties_menu", 
  "icon": "HomeOutlined",
  "x-uid": "crm-properties-menu",
  "x-async": false,
  "x-index": 4,
  "parent": "crm-menu-group"
}', 'crm-properties-menu', NOW(), NOW()),

-- Deals Menu Item
('crm_deals_menu', '{
  "type": "void",
  "title": "Deals",
  "name": "crm_deals_menu",
  "icon": "DollarOutlined", 
  "x-uid": "crm-deals-menu",
  "x-async": false,
  "x-index": 5,
  "parent": "crm-menu-group"
}', 'crm-deals-menu', NOW(), NOW()),

-- Suburbs Menu Item
('crm_suburbs_menu', '{
  "type": "void",
  "title": "Suburbs",
  "name": "crm_suburbs_menu",
  "icon": "EnvironmentOutlined",
  "x-uid": "crm-suburbs-menu", 
  "x-async": false,
  "x-index": 6,
  "parent": "crm-menu-group"
}', 'crm-suburbs-menu', NOW(), NOW()),

-- FICA Compliance Menu Item
('crm_fica_menu', '{
  "type": "void",
  "title": "FICA Compliance",
  "name": "crm_fica_menu",
  "icon": "SafetyOutlined",
  "x-uid": "crm-fica-menu",
  "x-async": false,
  "x-index": 7,
  "parent": "crm-menu-group"
}', 'crm-fica-menu', NOW(), NOW());

-- Insert sample data for testing
INSERT INTO "crm_suburbs" ("name", "city", "province", "postal_code", "average_price", "property_count") VALUES
('Sandton', 'Johannesburg', 'GP', '2196', 2500000, 45),
('Rosebank', 'Johannesburg', 'GP', '2196', 1800000, 32),
('Fourways', 'Johannesburg', 'GP', '2055', 1500000, 28),
('Randburg', 'Johannesburg', 'GP', '2194', 1200000, 56),
('Bryanston', 'Johannesburg', 'GP', '2191', 3200000, 38);

INSERT INTO "crm_leads" ("first_name", "last_name", "email", "phone", "company", "status", "source", "rsa_id", "fica_status") VALUES
('John', 'Smith', 'john.smith@email.com', '0821234567', 'ABC Corporation', 'new', 'website', '8001015009087', 'pending'),
('Sarah', 'Johnson', 'sarah.j@company.co.za', '0832345678', 'XYZ Industries', 'contacted', 'referral', '8502150090876', 'verified'),
('Michael', 'Brown', 'm.brown@email.com', '0843456789', 'Brown Properties', 'qualified', 'social', '7503305009081', 'pending'),
('Emma', 'Davis', 'emma.davis@webmail.com', '0854567890', 'Davis Consulting', 'new', 'advertisement', '9005150090872', 'pending'),
('James', 'Wilson', 'j.wilson@corp.co.za', '0865678901', 'Wilson Holdings', 'contacted', 'website', '8807205009083', 'verified');

INSERT INTO "crm_contacts" ("first_name", "last_name", "email", "phone", "company", "job_title", "rsa_id", "fica_status") VALUES
('Peter', 'Anderson', 'p.anderson@email.com', '0711234567', 'Anderson Realty', 'CEO', '7001015009084', 'verified'),
('Lisa', 'Thompson', 'lisa.t@company.co.za', '0722345678', 'Thompson Properties', 'Sales Manager', '8002150090875', 'pending'),
('David', 'Martinez', 'd.martinez@webmail.com', '0733456789', 'Martinez Investments', 'Property Consultant', '8503305009086', 'verified'),
('Jennifer', 'White', 'j.white@corp.co.za', '0744567890', 'White Real Estate', 'Director', '9005150090877', 'pending'),
('Robert', 'Lee', 'r.lee@email.com', '0755678901', 'Lee Property Group', 'Managing Director', '7807205009088', 'verified');

INSERT INTO "crm_properties" ("title", "description", "property_type", "price", "address", "suburb", "city", "province", "postal_code", "bedrooms", "bathrooms", "parking_spaces", "square_meters", "status") VALUES
('Modern Family Home', 'Beautiful 4-bedroom family home with garden and pool', 'house', 2850000, '123 Oak Street', 'Sandton', 'Johannesburg', 'GP', '2196', 4, 3, 2, 450, 'available'),
('Luxury Apartment', 'Stunning 2-bedroom apartment in secure complex', 'apartment', 1650000, '456 Pine Avenue', 'Rosebank', 'Johannesburg', 'GP', '2196', 2, 2, 1, 120, 'available'),
('Townhouse Complex', 'Modern 3-bedroom townhouse with private garden', 'townhouse', 1350000, '789 Elm Road', 'Fourways', 'Johannesburg', 'GP', '2055', 3, 2, 1, 180, 'sold'),
('Commercial Property', 'Prime retail space in busy shopping center', 'commercial', 4200000, '321 Main Street', 'Randburg', 'Johannesburg', 'GP', '2194', 0, 2, 15, 850, 'available'),
('Vacant Land', 'Large plot perfect for development', 'land', 850000, '654 Valley View', 'Bryanston', 'Johannesburg', 'GP', '2191', 0, 0, 0, 1200, 'available');

INSERT INTO "crm_deals" ("title", "description", "value", "currency", "stage", "probability", "expected_close_date") VALUES
('Sandton House Sale', 'Family home in prime location', 2850000, 'ZAR', 'negotiation', 85, '2024-04-15'),
('Rosebank Apartment', 'Luxury apartment for young professional', 1650000, 'ZAR', 'proposal', 70, '2024-03-30'),
('Fourways Townhouse', 'Modern townhouse complex unit', 1350000, 'ZAR', 'closed_won', 100, '2024-02-28'),
('Randburg Commercial', 'Retail space investment opportunity', 4200000, 'ZAR', 'qualification', 45, '2024-05-20'),
('Bryanston Land Deal', 'Development land acquisition', 850000, 'ZAR', 'prospecting', 25, '2024-06-30');

-- Grant permissions for NocoBase access
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Create indexes for better performance
CREATE INDEX idx_crm_leads_status ON crm_leads(status);
CREATE INDEX idx_crm_leads_email ON crm_leads(email);
CREATE INDEX idx_crm_contacts_email ON crm_contacts(email);
CREATE INDEX idx_crm_properties_status ON crm_properties(status);
CREATE INDEX idx_crm_properties_suburb ON crm_properties(suburb);
CREATE INDEX idx_crm_deals_stage ON crm_deals(stage);
CREATE INDEX idx_crm_suburbs_name ON crm_suburbs(name);
CREATE INDEX idx_crm_fica_documents_status ON crm_fica_documents(status);

-- Set up triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_crm_leads_updated_at BEFORE UPDATE ON crm_leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_contacts_updated_at BEFORE UPDATE ON crm_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_properties_updated_at BEFORE UPDATE ON crm_properties FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_deals_updated_at BEFORE UPDATE ON crm_deals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_suburbs_updated_at BEFORE UPDATE ON crm_suburbs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_fica_documents_updated_at BEFORE UPDATE ON crm_fica_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();