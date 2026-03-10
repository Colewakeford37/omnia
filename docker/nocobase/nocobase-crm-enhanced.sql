-- Enhanced NocoBase CRM - Method 2: Universal SQL Import
-- Complete South African Real Estate CRM with advanced features
-- Based on official NocoBase CRM tutorial patterns

-- =====================================================
-- CORE CRM TABLES
-- =====================================================

-- 1. CRM Leads Collection (Potential customers)
CREATE TABLE IF NOT EXISTS "crm_leads" (
  "id" BIGSERIAL PRIMARY KEY,
  "first_name" VARCHAR(255) NOT NULL,
  "last_name" VARCHAR(255) NOT NULL,
  "email" VARCHAR(255) UNIQUE,
  "phone" VARCHAR(255),
  "mobile" VARCHAR(255),
  "company" VARCHAR(255),
  "job_title" VARCHAR(255),
  "status" VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'lost', 'converted')),
  "source" VARCHAR(100) CHECK (source IN ('website', 'referral', 'social', 'advertisement', 'cold_call', 'walk_in')),
  "assigned_to" BIGINT,
  "priority" VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  "budget_min" DECIMAL(15,2),
  "budget_max" DECIMAL(15,2),
  "preferred_location" VARCHAR(255),
  "property_type_interest" VARCHAR(100),
  "rsa_id" VARCHAR(13) UNIQUE,
  "fica_status" VARCHAR(50) DEFAULT 'pending' CHECK (fica_status IN ('pending', 'verified', 'rejected', 'expired')),
  "notes" TEXT,
  "last_contact_date" DATE,
  "next_follow_up" DATE,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CRM Contacts Collection (Existing customers/contacts)
CREATE TABLE IF NOT EXISTS "crm_contacts" (
  "id" BIGSERIAL PRIMARY KEY,
  "first_name" VARCHAR(255) NOT NULL,
  "last_name" VARCHAR(255) NOT NULL,
  "email" VARCHAR(255) UNIQUE,
  "phone" VARCHAR(255),
  "mobile" VARCHAR(255),
  "company" VARCHAR(255),
  "job_title" VARCHAR(255),
  "department" VARCHAR(255),
  "contact_type" VARCHAR(50) DEFAULT 'individual' CHECK (contact_type IN ('individual', 'company', 'investor', 'developer')),
  "category" VARCHAR(50) DEFAULT 'client' CHECK (category IN ('client', 'prospect', 'partner', 'vendor', 'other')),
  "rsa_id" VARCHAR(13) UNIQUE,
  "fica_status" VARCHAR(50) DEFAULT 'pending' CHECK (fica_status IN ('pending', 'verified', 'rejected', 'expired')),
  "date_of_birth" DATE,
  "anniversary" DATE,
  "preferred_contact_method" VARCHAR(50) CHECK (preferred_contact_method IN ('email', 'phone', 'sms', 'whatsapp')),
  "preferred_contact_time" VARCHAR(50),
  "address_line1" VARCHAR(255),
  "address_line2" VARCHAR(255),
  "suburb" VARCHAR(255),
  "city" VARCHAR(255),
  "province" VARCHAR(2),
  "postal_code" VARCHAR(20),
  "country" VARCHAR(50) DEFAULT 'South Africa',
  "tags" TEXT,
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. CRM Properties Collection (Real estate properties)
CREATE TABLE IF NOT EXISTS "crm_properties" (
  "id" BIGSERIAL PRIMARY KEY,
  "property_ref" VARCHAR(100) UNIQUE NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "property_type" VARCHAR(50) CHECK (property_type IN ('house', 'apartment', 'townhouse', 'cluster', 'commercial', 'industrial', 'land', 'farm', 'retirement')),
  "listing_type" VARCHAR(50) DEFAULT 'sale' CHECK (listing_type IN ('sale', 'rent', 'lease', 'auction')),
  "price" DECIMAL(15,2),
  "price_per_sqm" DECIMAL(10,2),
  "currency" VARCHAR(3) DEFAULT 'ZAR',
  "address" TEXT NOT NULL,
  "suburb_id" BIGINT,
  "suburb" VARCHAR(255),
  "city" VARCHAR(255),
  "province" VARCHAR(2),
  "postal_code" VARCHAR(20),
  "latitude" DECIMAL(10,8),
  "longitude" DECIMAL(11,8),
  "erf_number" VARCHAR(100),
  "sectional_title" BOOLEAN DEFAULT FALSE,
  "sectional_title_unit" VARCHAR(100),
  "bedrooms" INTEGER DEFAULT 0,
  "bathrooms" INTEGER DEFAULT 0,
  "en_suite_bathrooms" INTEGER DEFAULT 0,
  "parking_spaces" INTEGER DEFAULT 0,
  "garages" INTEGER DEFAULT 0,
  "square_meters" INTEGER,
  "square_meters_under_roof" INTEGER,
  "land_size" INTEGER,
  "year_built" INTEGER,
  "condition" VARCHAR(50) CHECK (condition IN ('excellent', 'good', 'fair', 'needs_renovation', 'dilapidated')),
  "furnished" VARCHAR(50) CHECK (furnished IN ('fully', 'semi', 'unfurnished')),
  "pet_friendly" BOOLEAN DEFAULT FALSE,
  "pool" VARCHAR(50) CHECK (pool IN ('none', 'private', 'communal')),
  "security" TEXT,
  "features" TEXT,
  "amenities" TEXT,
  "rates_taxes" DECIMAL(10,2),
  "levy" DECIMAL(10,2),
  "listing_agent_id" BIGINT,
  "listing_date" DATE,
  "expiry_date" DATE,
  "status" VARCHAR(50) DEFAULT 'available' CHECK (status IN ('available', 'sold', 'rented', 'pending', 'withdrawn', 'expired')),
  "virtual_tour_url" VARCHAR(500),
  "video_url" VARCHAR(500),
  "photos_count" INTEGER DEFAULT 0,
  "featured" BOOLEAN DEFAULT FALSE,
  "hot_deal" BOOLEAN DEFAULT FALSE,
  "new_listing" BOOLEAN DEFAULT FALSE,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. CRM Deals Collection (Sales opportunities)
CREATE TABLE IF NOT EXISTS "crm_deals" (
  "id" BIGSERIAL PRIMARY KEY,
  "deal_ref" VARCHAR(100) UNIQUE NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "description" TEXT,
  "deal_type" VARCHAR(50) DEFAULT 'sale' CHECK (deal_type IN ('sale', 'rent', 'lease')),
  "value" DECIMAL(15,2),
  "currency" VARCHAR(3) DEFAULT 'ZAR',
  "stage" VARCHAR(50) DEFAULT 'prospecting' CHECK (stage IN ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost')),
  "probability" INTEGER DEFAULT 0 CHECK (probability >= 0 AND probability <= 100),
  "expected_close_date" DATE,
  "actual_close_date" DATE,
  "lead_id" BIGINT,
  "contact_id" BIGINT,
  "property_id" BIGINT,
  "assigned_to" BIGINT,
  "commission_percentage" DECIMAL(5,2),
  "commission_amount" DECIMAL(15,2),
  "deal_source" VARCHAR(100),
  "competitor" VARCHAR(255),
  "lost_reason" VARCHAR(255),
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. CRM Suburbs Collection (Location data)
CREATE TABLE IF NOT EXISTS "crm_suburbs" (
  "id" BIGSERIAL PRIMARY KEY,
  "suburb_name" VARCHAR(255) NOT NULL,
  "city" VARCHAR(255) NOT NULL,
  "province" VARCHAR(2) NOT NULL,
  "postal_code" VARCHAR(20),
  "area_code" VARCHAR(20),
  "region" VARCHAR(255),
  "suburb_type" VARCHAR(50) CHECK (suburb_type IN ('residential', 'commercial', 'industrial', 'mixed')),
  "average_price" DECIMAL(15,2),
  "median_price" DECIMAL(15,2),
  "price_range_min" DECIMAL(15,2),
  "price_range_max" DECIMAL(15,2),
  "property_count" INTEGER DEFAULT 0,
  "active_listings" INTEGER DEFAULT 0,
  "sold_last_30_days" INTEGER DEFAULT 0,
  "days_on_market_avg" INTEGER,
  "population" INTEGER,
  "demographics" TEXT,
  "amenities" TEXT,
  "schools" TEXT,
  "transport" TEXT,
  "safety_rating" INTEGER CHECK (safety_rating >= 1 AND safety_rating <= 10),
  "growth_potential" VARCHAR(50) CHECK (growth_potential IN ('excellent', 'good', 'stable', 'declining')),
  "latitude" DECIMAL(10,8),
  "longitude" DECIMAL(11,8),
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. FICA Documents Collection (Compliance documents)
CREATE TABLE IF NOT EXISTS "crm_fica_documents" (
  "id" BIGSERIAL PRIMARY KEY,
  "document_type" VARCHAR(100) CHECK (document_type IN ('id_document', 'proof_of_address', 'proof_of_income', 'bank_statement', 'tax_clearance', 'company_registration')),
  "document_number" VARCHAR(255),
  "file_name" VARCHAR(255),
  "file_path" VARCHAR(500),
  "file_size" BIGINT,
  "mime_type" VARCHAR(100),
  "original_name" VARCHAR(255),
  "status" VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected', 'expired')),
  "verified_by" BIGINT,
  "verified_at" TIMESTAMP,
  "expiry_date" DATE,
  "lead_id" BIGINT,
  "contact_id" BIGINT,
  "property_id" BIGINT,
  "deal_id" BIGINT,
  "notes" TEXT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. CRM Activities Collection (Interactions and tasks)
CREATE TABLE IF NOT EXISTS "crm_activities" (
  "id" BIGSERIAL PRIMARY KEY,
  "activity_type" VARCHAR(50) CHECK (activity_type IN ('call', 'email', 'meeting', 'sms', 'whatsapp', 'note', 'task', 'reminder')),
  "subject" VARCHAR(255),
  "description" TEXT,
  "status" VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'cancelled', 'overdue')),
  "priority" VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP,
  "duration_minutes" INTEGER,
  "assigned_to" BIGINT,
  "lead_id" BIGINT,
  "contact_id" BIGINT,
  "property_id" BIGINT,
  "deal_id" BIGINT,
  "outcome" VARCHAR(255),
  "next_action" TEXT,
  "follow_up_date" DATE,
  "location" VARCHAR(255),
  "participants" TEXT,
  "attachments" TEXT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. CRM Email Templates Collection
CREATE TABLE IF NOT EXISTS "crm_email_templates" (
  "id" BIGSERIAL PRIMARY KEY,
  "template_name" VARCHAR(255) NOT NULL,
  "template_type" VARCHAR(50) CHECK (template_type IN ('welcome', 'follow_up', 'proposal', 'reminder', 'marketing', 'notification')),
  "subject" VARCHAR(500) NOT NULL,
  "body_html" TEXT,
  "body_text" TEXT,
  "from_name" VARCHAR(255),
  "from_email" VARCHAR(255),
  "cc_emails" TEXT,
  "bcc_emails" TEXT,
  "attachments" TEXT,
  "variables" TEXT,
  "is_active" BOOLEAN DEFAULT TRUE,
  "usage_count" INTEGER DEFAULT 0,
  "last_used" TIMESTAMP,
  "created_by" BIGINT,
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- NOCOBASE METADATA REGISTRATION
-- =====================================================

-- Register collections in NocoBase
INSERT INTO "collections" ("name", "title", "inherits", "model", "filterTargetKey", "createdAt", "updatedAt") VALUES
('crm_leads', 'CRM Leads', NULL, 'Model', 'id', NOW(), NOW()),
('crm_contacts', 'CRM Contacts', NULL, 'Model', 'id', NOW(), NOW()),
('crm_properties', 'CRM Properties', NULL, 'Model', 'id', NOW(), NOW()),
('crm_deals', 'CRM Deals', NULL, 'Model', 'id', NOW(), NOW()),
('crm_suburbs', 'CRM Suburbs', NULL, 'Model', 'id', NOW(), NOW()),
('crm_fica_documents', 'FICA Documents', NULL, 'Model', 'id', NOW(), NOW()),
('crm_activities', 'CRM Activities', NULL, 'Model', 'id', NOW(), NOW()),
('crm_email_templates', 'Email Templates', NULL, 'Model', 'id', NOW(), NOW());

-- =====================================================
-- FIELD DEFINITIONS FOR NOCOBASE
-- =====================================================

-- CRM Leads Fields
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('crm_leads', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_leads', 'first_name', 'string', 'input', '{"title":"First Name","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_leads', 'last_name', 'string', 'input', '{"title":"Last Name","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_leads', 'email', 'string', 'email', '{"title":"Email","type":"string","x-component":"Input","x-validator":"email"}', NOW(), NOW()),
('crm_leads', 'phone', 'string', 'phone', '{"title":"Phone","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'mobile', 'string', 'phone', '{"title":"Mobile","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'company', 'string', 'input', '{"title":"Company","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'job_title', 'string', 'input', '{"title":"Job Title","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"new","label":"New"},{"value":"contacted","label":"Contacted"},{"value":"qualified","label":"Qualified"},{"value":"lost","label":"Lost"},{"value":"converted","label":"Converted"}]}', NOW(), NOW()),
('crm_leads', 'source', 'string', 'select', '{"title":"Source","type":"string","x-component":"Select","enum":[{"value":"website","label":"Website"},{"value":"referral","label":"Referral"},{"value":"social","label":"Social Media"},{"value":"advertisement","label":"Advertisement"},{"value":"cold_call","label":"Cold Call"},{"value":"walk_in","label":"Walk In"}]}', NOW(), NOW()),
('crm_leads', 'priority', 'string', 'select', '{"title":"Priority","type":"string","x-component":"Select","enum":[{"value":"low","label":"Low"},{"value":"medium","label":"Medium"},{"value":"high","label":"High"},{"value":"urgent","label":"Urgent"}]}', NOW(), NOW()),
('crm_leads', 'budget_min', 'decimal', 'number', '{"title":"Budget Min","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_leads', 'budget_max', 'decimal', 'number', '{"title":"Budget Max","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_leads', 'preferred_location', 'string', 'input', '{"title":"Preferred Location","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'property_type_interest', 'string', 'input', '{"title":"Property Type Interest","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_leads', 'rsa_id', 'string', 'input', '{"title":"RSA ID Number","type":"string","x-component":"Input","pattern":"^[0-9]{13}$"}', NOW(), NOW()),
('crm_leads', 'fica_status', 'string', 'select', '{"title":"FICA Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"verified","label":"Verified"},{"value":"rejected","label":"Rejected"},{"value":"expired","label":"Expired"}]}', NOW(), NOW()),
('crm_leads', 'notes', 'text', 'textarea', '{"title":"Notes","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_leads', 'last_contact_date', 'date', 'date', '{"title":"Last Contact Date","type":"string","x-component":"DatePicker"}', NOW(), NOW()),
('crm_leads', 'next_follow_up', 'date', 'date', '{"title":"Next Follow Up","type":"string","x-component":"DatePicker"}', NOW(), NOW()),
('crm_leads', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_leads', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- CRM Contacts Fields
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('crm_contacts', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_contacts', 'first_name', 'string', 'input', '{"title":"First Name","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_contacts', 'last_name', 'string', 'input', '{"title":"Last Name","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_contacts', 'email', 'string', 'email', '{"title":"Email","type":"string","x-component":"Input","x-validator":"email"}', NOW(), NOW()),
('crm_contacts', 'phone', 'string', 'phone', '{"title":"Phone","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'mobile', 'string', 'phone', '{"title":"Mobile","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'company', 'string', 'input', '{"title":"Company","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'job_title', 'string', 'input', '{"title":"Job Title","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'department', 'string', 'input', '{"title":"Department","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'contact_type', 'string', 'select', '{"title":"Contact Type","type":"string","x-component":"Select","enum":[{"value":"individual","label":"Individual"},{"value":"company","label":"Company"},{"value":"investor","label":"Investor"},{"value":"developer","label":"Developer"}]}', NOW(), NOW()),
('crm_contacts', 'category', 'string', 'select', '{"title":"Category","type":"string","x-component":"Select","enum":[{"value":"client","label":"Client"},{"value":"prospect","label":"Prospect"},{"value":"partner","label":"Partner"},{"value":"vendor","label":"Vendor"},{"value":"other","label":"Other"}]}', NOW(), NOW()),
('crm_contacts', 'rsa_id', 'string', 'input', '{"title":"RSA ID Number","type":"string","x-component":"Input","pattern":"^[0-9]{13}$"}', NOW(), NOW()),
('crm_contacts', 'fica_status', 'string', 'select', '{"title":"FICA Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"verified","label":"Verified"},{"value":"rejected","label":"Rejected"},{"value":"expired","label":"Expired"}]}', NOW(), NOW()),
('crm_contacts', 'date_of_birth', 'date', 'date', '{"title":"Date of Birth","type":"string","x-component":"DatePicker"}', NOW(), NOW()),
('crm_contacts', 'preferred_contact_method', 'string', 'select', '{"title":"Preferred Contact Method","type":"string","x-component":"Select","enum":[{"value":"email","label":"Email"},{"value":"phone","label":"Phone"},{"value":"sms","label":"SMS"},{"value":"whatsapp","label":"WhatsApp"}]}', NOW(), NOW()),
('crm_contacts', 'address_line1', 'string', 'input', '{"title":"Address Line 1","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'city', 'string', 'input', '{"title":"City","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'province', 'string', 'select', '{"title":"Province","type":"string","x-component":"Select","enum":[{"value":"EC","label":"Eastern Cape"},{"value":"FS","label":"Free State"},{"value":"GP","label":"Gauteng"},{"value":"KZN","label":"KwaZulu-Natal"},{"value":"L","label":"Limpopo"},{"value":"MP","label":"Mpumalanga"},{"value":"NC","label":"Northern Cape"},{"value":"NW","label":"North West"},{"value":"WC","label":"Western Cape"}]}', NOW(), NOW()),
('crm_contacts', 'postal_code', 'string', 'input', '{"title":"Postal Code","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_contacts', 'tags', 'text', 'textarea', '{"title":"Tags","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_contacts', 'notes', 'text', 'textarea', '{"title":"Notes","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_contacts', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_contacts', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- CRM Properties Fields (abbreviated for brevity - include all fields)
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('crm_properties', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_properties', 'property_ref', 'string', 'input', '{"title":"Property Reference","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_properties', 'title', 'string', 'input', '{"title":"Property Title","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_properties', 'property_type', 'string', 'select', '{"title":"Property Type","type":"string","x-component":"Select","enum":[{"value":"house","label":"House"},{"value":"apartment","label":"Apartment"},{"value":"townhouse","label":"Townhouse"},{"value":"commercial","label":"Commercial"},{"value":"land","label":"Land"}]}', NOW(), NOW()),
('crm_properties', 'price', 'decimal', 'number', '{"title":"Price","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_properties', 'address', 'text', 'textarea', '{"title":"Address","type":"string","x-component":"Input.TextArea","required":true}', NOW(), NOW()),
('crm_properties', 'suburb', 'string', 'input', '{"title":"Suburb","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_properties', 'city', 'string', 'input', '{"title":"City","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_properties', 'province', 'string', 'select', '{"title":"Province","type":"string","x-component":"Select","enum":[{"value":"EC","label":"Eastern Cape"},{"value":"FS","label":"Free State"},{"value":"GP","label":"Gauteng"},{"value":"KZN","label":"KwaZulu-Natal"},{"value":"L","label":"Limpopo"},{"value":"MP","label":"Mpumalanga"},{"value":"NC","label":"Northern Cape"},{"value":"NW","label":"North West"},{"value":"WC","label":"Western Cape"}]}', NOW(), NOW()),
('crm_properties', 'bedrooms', 'integer', 'integer', '{"title":"Bedrooms","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'bathrooms', 'integer', 'integer', '{"title":"Bathrooms","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'parking_spaces', 'integer', 'integer', '{"title":"Parking Spaces","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'square_meters', 'integer', 'integer', '{"title":"Square Meters","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"available","label":"Available"},{"value":"sold","label":"Sold"},{"value":"pending","label":"Pending"},{"value":"withdrawn","label":"Withdrawn"}]}', NOW(), NOW()),
('crm_properties', 'listing_agent_id', 'bigInt', 'integer', '{"title":"Listing Agent","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_properties', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_properties', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- CRM Deals Fields (abbreviated)
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('crm_deals', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_deals', 'deal_ref', 'string', 'input', '{"title":"Deal Reference","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_deals', 'title', 'string', 'input', '{"title":"Deal Title","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_deals', 'value', 'decimal', 'number', '{"title":"Deal Value","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_deals', 'stage', 'string', 'select', '{"title":"Stage","type":"string","x-component":"Select","enum":[{"value":"prospecting","label":"Prospecting"},{"value":"qualification","label":"Qualification"},{"value":"proposal","label":"Proposal"},{"value":"negotiation","label":"Negotiation"},{"value":"closed_won","label":"Closed Won"},{"value":"closed_lost","label":"Closed Lost"}]}', NOW(), NOW()),
('crm_deals', 'probability', 'integer', 'integer', '{"title":"Probability (%)","type":"number","x-component":"InputNumber","x-min":0,"x-max":100}', NOW(), NOW()),
('crm_deals', 'expected_close_date', 'date', 'date', '{"title":"Expected Close Date","type":"string","x-component":"DatePicker"}', NOW(), NOW()),
('crm_deals', 'lead_id', 'bigInt', 'integer', '{"title":"Lead","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_deals', 'contact_id', 'bigInt', 'integer', '{"title":"Contact","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_deals', 'property_id', 'bigInt', 'integer', '{"title":"Property","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('crm_deals', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_deals', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- CRM Suburbs Fields (abbreviated)
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('crm_suburbs', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_suburbs', 'suburb_name', 'string', 'input', '{"title":"Suburb Name","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_suburbs', 'city', 'string', 'input', '{"title":"City","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('crm_suburbs', 'province', 'string', 'select', '{"title":"Province","type":"string","x-component":"Select","enum":[{"value":"EC","label":"Eastern Cape"},{"value":"FS","label":"Free State"},{"value":"GP","label":"Gauteng"},{"value":"KZN","label":"KwaZulu-Natal"},{"value":"L","label":"Limpopo"},{"value":"MP","label":"Mpumalanga"},{"value":"NC","label":"Northern Cape"},{"value":"NW","label":"North West"},{"value":"WC","label":"Western Cape"}]}', NOW(), NOW()),
('crm_suburbs', 'average_price', 'decimal', 'number', '{"title":"Average Price","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('crm_suburbs', 'property_count', 'integer', 'integer', '{"title":"Property Count","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_suburbs', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_suburbs', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- CRM Activities Fields (abbreviated)
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('crm_activities', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('crm_activities', 'activity_type', 'string', 'select', '{"title":"Activity Type","type":"string","x-component":"Select","enum":[{"value":"call","label":"Call"},{"value":"email","label":"Email"},{"value":"meeting","label":"Meeting"},{"value":"note","label":"Note"}]}', NOW(), NOW()),
('crm_activities', 'subject', 'string', 'input', '{"title":"Subject","type":"string","x-component":"Input"}', NOW(), NOW()),
('crm_activities', 'description', 'text', 'textarea', '{"title":"Description","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('crm_activities', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"completed","label":"Completed"}]}', NOW(), NOW()),
('crm_activities', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('crm_activities', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- =====================================================
-- UI SCHEMAS FOR MENU INTEGRATION
-- =====================================================

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
}', 'crm-fica-menu', NOW(), NOW()),

-- Activities Menu Item
('crm_activities_menu', '{
  "type": "void",
  "title": "Activities",
  "name": "crm_activities_menu",
  "icon": "CalendarOutlined",
  "x-uid": "crm-activities-menu",
  "x-async": false,
  "x-index": 8,
  "parent": "crm-menu-group"
}', 'crm-activities-menu', NOW(), NOW()),

-- Email Templates Menu Item
('crm_email_templates_menu', '{
  "type": "void",
  "title": "Email Templates",
  "name": "crm_email_templates_menu",
  "icon": "MailOutlined",
  "x-uid": "crm-email-templates-menu",
  "x-async": false,
  "x-index": 9,
  "parent": "crm-menu-group"
}', 'crm-email-templates-menu', NOW(), NOW());

-- =====================================================
-- SAMPLE DATA FOR TESTING
-- =====================================================

-- Sample Suburbs
INSERT INTO "crm_suburbs" ("suburb_name", "city", "province", "postal_code", "average_price", "property_count") VALUES
('Sandton', 'Johannesburg', 'GP', '2196', 2500000, 45),
('Rosebank', 'Johannesburg', 'GP', '2196', 1800000, 32),
('Fourways', 'Johannesburg', 'GP', '2055', 1500000, 28),
('Randburg', 'Johannesburg', 'GP', '2194', 1200000, 56),
('Bryanston', 'Johannesburg', 'GP', '2191', 3200000, 38),
('Midrand', 'Johannesburg', 'GP', '1685', 1400000, 42),
('Centurion', 'Pretoria', 'GP', '0157', 1300000, 35),
('Pretoria East', 'Pretoria', 'GP', '0081', 1100000, 48);

-- Sample Leads
INSERT INTO "crm_leads" ("first_name", "last_name", "email", "phone", "company", "status", "source", "priority", "budget_min", "budget_max", "rsa_id", "fica_status") VALUES
('John', 'Smith', 'john.smith@email.com', '0821234567', 'ABC Corporation', 'new', 'website', 'high', 2000000, 3000000, '8001015009087', 'pending'),
('Sarah', 'Johnson', 'sarah.j@company.co.za', '0832345678', 'XYZ Industries', 'contacted', 'referral', 'medium', 1500000, 2500000, '8502150090876', 'verified'),
('Michael', 'Brown', 'm.brown@email.com', '0843456789', 'Brown Properties', 'qualified', 'social', 'urgent', 3000000, 5000000, '7503305009081', 'pending'),
('Emma', 'Davis', 'emma.davis@webmail.com', '0854567890', 'Davis Consulting', 'new', 'advertisement', 'low', 800000, 1500000, '9005150090872', 'pending'),
('James', 'Wilson', 'j.wilson@corp.co.za', '0865678901', 'Wilson Holdings', 'contacted', 'cold_call', 'medium', 1800000, 2800000, '8807205009083', 'verified');

-- Sample Contacts
INSERT INTO "crm_contacts" ("first_name", "last_name", "email", "phone", "company", "job_title", "contact_type", "category", "rsa_id", "fica_status", "city", "province") VALUES
('Peter', 'Anderson', 'p.anderson@email.com', '0711234567', 'Anderson Realty', 'CEO', 'company', 'client', '7001015009084', 'verified', 'Sandton', 'GP'),
('Lisa', 'Thompson', 'lisa.t@company.co.za', '0722345678', 'Thompson Properties', 'Sales Manager', 'individual', 'client', '8002150090875', 'pending', 'Rosebank', 'GP'),
('David', 'Martinez', 'd.martinez@webmail.com', '0733456789', 'Martinez Investments', 'Property Consultant', 'investor', 'partner', '8503305009086', 'verified', 'Fourways', 'GP'),
('Jennifer', 'White', 'j.white@corp.co.za', '0744567890', 'White Real Estate', 'Director', 'company', 'client', '9005150090877', 'pending', 'Randburg', 'GP'),
('Robert', 'Lee', 'r.lee@email.com', '0755678901', 'Lee Property Group', 'Managing Director', 'developer', 'partner', '7807205009088', 'verified', 'Bryanston', 'GP');

-- Sample Properties
INSERT INTO "crm_properties" ("property_ref", "title", "description", "property_type", "listing_type", "price", "address", "suburb", "city", "province", "bedrooms", "bathrooms", "parking_spaces", "square_meters", "status", "listing_date") VALUES
('PROP001', 'Modern Family Home in Sandton', 'Beautiful 4-bedroom family home with garden and pool', 'house', 'sale', 2850000, '123 Oak Street, Sandton', 'Sandton', 'Johannesburg', 'GP', 4, 3, 2, 450, 'available', '2024-01-15'),
('PROP002', 'Luxury Apartment in Rosebank', 'Stunning 2-bedroom apartment in secure complex', 'apartment', 'sale', 1650000, '456 Pine Avenue, Rosebank', 'Rosebank', 'Johannesburg', 'GP', 2, 2, 1, 120, 'available', '2024-02-01'),
('PROP003', 'Townhouse Complex Unit', 'Modern 3-bedroom townhouse with private garden', 'townhouse', 'sale', 1350000, '789 Elm Road, Fourways', 'Fourways', 'Johannesburg', 'GP', 3, 2, 1, 180, 'sold', '2024-01-20'),
('PROP004', 'Prime Retail Space', 'Commercial property in busy shopping center', 'commercial', 'rent', 25000, '321 Main Street, Randburg', 'Randburg', 'Johannesburg', 'GP', 0, 2, 15, 850, 'available', '2024-01-10'),
('PROP005', 'Development Land', 'Large plot perfect for development', 'land', 'sale', 850000, '654 Valley View, Bryanston', 'Bryanston', 'Johannesburg', 'GP', 0, 0, 0, 1200, 'available', '2024-02-05');

-- Sample Deals
INSERT INTO "crm_deals" ("deal_ref", "title", "description", "deal_type", "value", "stage", "probability", "expected_close_date", "lead_id", "contact_id", "property_id") VALUES
('DEAL001', 'Sandton House Sale', 'Family home in prime location', 'sale', 2850000, 'negotiation', 85, '2024-04-15', 1, 1, 1),
('DEAL002', 'Rosebank Apartment', 'Luxury apartment for young professional', 'sale', 1650000, 'proposal', 70, '2024-03-30', 2, 2, 2),
('DEAL003', 'Fourways Townhouse', 'Modern townhouse complex unit', 'sale', 1350000, 'closed_won', 100, '2024-02-28', 3, 3, 3),
('DEAL004', 'Randburg Commercial', 'Retail space investment opportunity', 'rent', 300000, 'qualification', 45, '2024-05-20', 4, 4, 4),
('DEAL005', 'Bryanston Land Deal', 'Development land acquisition', 'sale', 850000, 'prospecting', 25, '2024-06-30', 5, 5, 5);

-- =====================================================
-- PERMISSIONS AND INDEXES
-- =====================================================

-- Grant permissions for NocoBase access
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;

-- Create indexes for better performance
CREATE INDEX idx_crm_leads_status ON crm_leads(status);
CREATE INDEX idx_crm_leads_email ON crm_leads(email);
CREATE INDEX idx_crm_leads_source ON crm_leads(source);
CREATE INDEX idx_crm_leads_priority ON crm_leads(priority);
CREATE INDEX idx_crm_leads_assigned ON crm_leads(assigned_to);
CREATE INDEX idx_crm_leads_next_follow_up ON crm_leads(next_follow_up);

CREATE INDEX idx_crm_contacts_email ON crm_contacts(email);
CREATE INDEX idx_crm_contacts_company ON crm_contacts(company);
CREATE INDEX idx_crm_contacts_contact_type ON crm_contacts(contact_type);
CREATE INDEX idx_crm_contacts_category ON crm_contacts(category);

CREATE INDEX idx_crm_properties_status ON crm_properties(status);
CREATE INDEX idx_crm_properties_property_type ON crm_properties(property_type);
CREATE INDEX idx_crm_properties_suburb ON crm_properties(suburb);
CREATE INDEX idx_crm_properties_price ON crm_properties(price);
CREATE INDEX idx_crm_properties_listing_agent ON crm_properties(listing_agent_id);

CREATE INDEX idx_crm_deals_stage ON crm_deals(stage);
CREATE INDEX idx_crm_deals_probability ON crm_deals(probability);
CREATE INDEX idx_crm_deals_expected_close ON crm_deals(expected_close_date);
CREATE INDEX idx_crm_deals_assigned ON crm_deals(assigned_to);

CREATE INDEX idx_crm_suburbs_name ON crm_suburbs(suburb_name);
CREATE INDEX idx_crm_suburbs_city ON crm_suburbs(city);
CREATE INDEX idx_crm_suburbs_province ON crm_suburbs(province);

CREATE INDEX idx_crm_fica_documents_status ON crm_fica_documents(status);
CREATE INDEX idx_crm_fica_documents_type ON crm_fica_documents(document_type);
CREATE INDEX idx_crm_fica_documents_expiry ON crm_fica_documents(expiry_date);

CREATE INDEX idx_crm_activities_type ON crm_activities(activity_type);
CREATE INDEX idx_crm_activities_status ON crm_activities(status);
CREATE INDEX idx_crm_activities_start_date ON crm_activities(start_date);
CREATE INDEX idx_crm_activities_assigned ON crm_activities(assigned_to);

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
CREATE TRIGGER update_crm_activities_updated_at BEFORE UPDATE ON crm_activities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_email_templates_updated_at BEFORE UPDATE ON crm_email_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();