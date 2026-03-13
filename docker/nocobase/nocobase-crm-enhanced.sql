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
INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_fica_documents'), 1, 11),
       'crm_fica_documents',
       'crm_fica_documents',
       FALSE,
       FALSE,
       '{"tableName":"crm_fica_documents","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       8
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_fica_documents');

INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_activities'), 1, 11),
       'crm_activities',
       'crm_activities',
       FALSE,
       FALSE,
       '{"tableName":"crm_activities","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       9
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_activities');

INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_email_templates'), 1, 11),
       'crm_email_templates',
       'crm_email_templates',
       FALSE,
       FALSE,
       '{"tableName":"crm_email_templates","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       10
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_email_templates');

-- =====================================================
-- UI SCHEMAS FOR MENU INTEGRATION
-- =====================================================

INSERT INTO "uiSchemas" ("x-uid", "name", "schema") VALUES
('crm-menu-group', 'crm_menu_group', $$
{
  "type": "void",
  "title": "Real Estate CRM",
  "name": "crm",
  "icon": "ShopOutlined",
  "x-designer": {"placement": "sidebar"},
  "x-uid": "crm-menu-group",
  "x-async": false,
  "x-index": 10
}
$$::json),
('crm-dashboard', 'crm_dashboard', $$
{
  "type": "void",
  "title": "Dashboard",
  "name": "crm_dashboard",
  "icon": "DashboardOutlined",
  "x-uid": "crm-dashboard",
  "x-async": false,
  "x-index": 1,
  "parent": "crm-menu-group"
}
$$::json),
('crm-leads-menu', 'crm_leads_menu', $$
{
  "type": "void",
  "title": "Leads",
  "name": "crm_leads_menu",
  "icon": "UserOutlined",
  "x-uid": "crm-leads-menu",
  "x-async": false,
  "x-index": 2,
  "parent": "crm-menu-group"
}
$$::json),
('crm-contacts-menu', 'crm_contacts_menu', $$
{
  "type": "void",
  "title": "Contacts",
  "name": "crm_contacts_menu",
  "icon": "TeamOutlined",
  "x-uid": "crm-contacts-menu",
  "x-async": false,
  "x-index": 3,
  "parent": "crm-menu-group"
}
$$::json),
('crm-properties-menu', 'crm_properties_menu', $$
{
  "type": "void",
  "title": "Properties",
  "name": "crm_properties_menu",
  "icon": "HomeOutlined",
  "x-uid": "crm-properties-menu",
  "x-async": false,
  "x-index": 4,
  "parent": "crm-menu-group"
}
$$::json),
('crm-deals-menu', 'crm_deals_menu', $$
{
  "type": "void",
  "title": "Deals",
  "name": "crm_deals_menu",
  "icon": "DollarOutlined",
  "x-uid": "crm-deals-menu",
  "x-async": false,
  "x-index": 5,
  "parent": "crm-menu-group"
}
$$::json),
('crm-suburbs-menu', 'crm_suburbs_menu', $$
{
  "type": "void",
  "title": "Suburbs",
  "name": "crm_suburbs_menu",
  "icon": "EnvironmentOutlined",
  "x-uid": "crm-suburbs-menu",
  "x-async": false,
  "x-index": 6,
  "parent": "crm-menu-group"
}
$$::json),
('crm-fica-menu', 'crm_fica_menu', $$
{
  "type": "void",
  "title": "FICA Compliance",
  "name": "crm_fica_menu",
  "icon": "SafetyOutlined",
  "x-uid": "crm-fica-menu",
  "x-async": false,
  "x-index": 7,
  "parent": "crm-menu-group"
}
$$::json),
('crm-activities-menu', 'crm_activities_menu', $$
{
  "type": "void",
  "title": "Activities",
  "name": "crm_activities_menu",
  "icon": "CalendarOutlined",
  "x-uid": "crm-activities-menu",
  "x-async": false,
  "x-index": 8,
  "parent": "crm-menu-group"
}
$$::json),
('crm-email-templates-menu', 'crm_email_templates_menu', $$
{
  "type": "void",
  "title": "Email Templates",
  "name": "crm_email_templates_menu",
  "icon": "MailOutlined",
  "x-uid": "crm-email-templates-menu",
  "x-async": false,
  "x-index": 9,
  "parent": "crm-menu-group"
}
$$::json)
ON CONFLICT ("x-uid") DO NOTHING;
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
