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
INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_leads'), 1, 11),
       'crm_leads',
       'crm_leads',
       FALSE,
       FALSE,
       '{"tableName":"crm_leads","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       4
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_leads');

INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_contacts'), 1, 11),
       'crm_contacts',
       'crm_contacts',
       FALSE,
       FALSE,
       '{"tableName":"crm_contacts","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       5
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_contacts');

INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_properties'), 1, 11),
       'crm_properties',
       'crm_properties',
       FALSE,
       FALSE,
       '{"tableName":"crm_properties","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       6
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_properties');

INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_deals'), 1, 11),
       'crm_deals',
       'crm_deals',
       FALSE,
       FALSE,
       '{"tableName":"crm_deals","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       7
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_deals');

INSERT INTO "collections" ("key", "name", "title", "inherit", "hidden", "options", "description", "sort")
SELECT substr(md5('crm_suburbs'), 1, 11),
       'crm_suburbs',
       'crm_suburbs',
       FALSE,
       FALSE,
       '{"tableName":"crm_suburbs","timestamps":false,"autoGenId":false,"filterTargetKey":"id","underscored":false,"schema":"public","unavailableActions":[]}'::json,
       NULL,
       3
WHERE NOT EXISTS (SELECT 1 FROM "collections" WHERE "name" = 'crm_suburbs');

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

-- Add collection fields to NocoBase fields table
-- This defines the schema for each collection
SELECT 1;

-- Create UI Schemas for Menu Integration
-- This creates the sidebar menu structure following NocoBase patterns
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
$$::json)
ON CONFLICT ("x-uid") DO NOTHING;

-- Insert sample data for testing
INSERT INTO "crm_suburbs" ("id","createdAt","updatedAt","name","city","province","postal_code","average_price","median_price","price_trend","days_on_market","inventory_count") VALUES
(7000000000001, NOW(), NOW(), 'Sandton', 'Johannesburg', 'GP', '2196', 2500000, 2400000, 'up', 18, 45),
(7000000000002, NOW(), NOW(), 'Rosebank', 'Johannesburg', 'GP', '2196', 1800000, 1750000, 'stable', 22, 32),
(7000000000003, NOW(), NOW(), 'Fourways', 'Johannesburg', 'GP', '2055', 1500000, 1450000, 'down', 28, 28),
(7000000000004, NOW(), NOW(), 'Randburg', 'Johannesburg', 'GP', '2194', 1200000, 1180000, 'stable', 35, 56),
(7000000000005, NOW(), NOW(), 'Bryanston', 'Johannesburg', 'GP', '2191', 3200000, 3100000, 'up', 16, 38)
ON CONFLICT DO NOTHING;

INSERT INTO "crm_leads" ("id","createdAt","updatedAt","full_name","first_name","last_name","email","phone","mobile","company","status","source","id_number","fica_completed","fica_documents") VALUES
(7000000000101, NOW(), NOW(), 'John Smith', 'John', 'Smith', 'john.smith@email.com', '0821234567', '0821234567', 'ABC Corporation', 'new', 'website', '8001015009087', FALSE, '{}'::jsonb),
(7000000000102, NOW(), NOW(), 'Sarah Johnson', 'Sarah', 'Johnson', 'sarah.j@company.co.za', '0832345678', '0832345678', 'XYZ Industries', 'contacted', 'referral', '8502150090876', TRUE, '{}'::jsonb),
(7000000000103, NOW(), NOW(), 'Michael Brown', 'Michael', 'Brown', 'm.brown@email.com', '0843456789', '0843456789', 'Brown Properties', 'qualified', 'social', '7503305009081', FALSE, '{}'::jsonb),
(7000000000104, NOW(), NOW(), 'Emma Davis', 'Emma', 'Davis', 'emma.davis@webmail.com', '0854567890', '0854567890', 'Davis Consulting', 'new', 'advertisement', '9005150090872', FALSE, '{}'::jsonb),
(7000000000105, NOW(), NOW(), 'James Wilson', 'James', 'Wilson', 'j.wilson@corp.co.za', '0865678901', '0865678901', 'Wilson Holdings', 'contacted', 'website', '8807205009083', TRUE, '{}'::jsonb)
ON CONFLICT DO NOTHING;

INSERT INTO "crm_contacts" ("id","createdAt","updatedAt","full_name","first_name","last_name","email","phone","mobile","company","job_title","id_number","fica_completed","fica_documents","city","suburb","province","postal_code") VALUES
(7000000000201, NOW(), NOW(), 'Peter Anderson', 'Peter', 'Anderson', 'p.anderson@email.com', '0711234567', '0711234567', 'Anderson Realty', 'CEO', '7001015009084', TRUE, '{}'::jsonb, 'Johannesburg', 'Sandton', 'GP', '2196'),
(7000000000202, NOW(), NOW(), 'Lisa Thompson', 'Lisa', 'Thompson', 'lisa.t@company.co.za', '0722345678', '0722345678', 'Thompson Properties', 'Sales Manager', '8002150090875', FALSE, '{}'::jsonb, 'Johannesburg', 'Rosebank', 'GP', '2196'),
(7000000000203, NOW(), NOW(), 'David Martinez', 'David', 'Martinez', 'd.martinez@webmail.com', '0733456789', '0733456789', 'Martinez Investments', 'Property Consultant', '8503305009086', TRUE, '{}'::jsonb, 'Johannesburg', 'Fourways', 'GP', '2055'),
(7000000000204, NOW(), NOW(), 'Jennifer White', 'Jennifer', 'White', 'j.white@corp.co.za', '0744567890', '0744567890', 'White Real Estate', 'Director', '9005150090877', FALSE, '{}'::jsonb, 'Johannesburg', 'Randburg', 'GP', '2194'),
(7000000000205, NOW(), NOW(), 'Robert Lee', 'Robert', 'Lee', 'r.lee@email.com', '0755678901', '0755678901', 'Lee Property Group', 'Managing Director', '7807205009088', TRUE, '{}'::jsonb, 'Johannesburg', 'Bryanston', 'GP', '2191')
ON CONFLICT DO NOTHING;

INSERT INTO "crm_properties" ("id","createdAt","updatedAt","title","description","property_type","listing_type","price","address","suburb","city","province","postal_code","bedrooms","bathrooms","parking","floor_area","status","listing_date") VALUES
(7000000000301, NOW(), NOW(), 'Modern Family Home', 'Beautiful 4-bedroom family home with garden and pool', 'house', 'sale', 2850000, '123 Oak Street', 'Sandton', 'Johannesburg', 'GP', '2196', 4, 3, 2, 450, 'available', NOW()),
(7000000000302, NOW(), NOW(), 'Luxury Apartment', 'Stunning 2-bedroom apartment in secure complex', 'apartment', 'sale', 1650000, '456 Pine Avenue', 'Rosebank', 'Johannesburg', 'GP', '2196', 2, 2, 1, 120, 'available', NOW()),
(7000000000303, NOW(), NOW(), 'Townhouse Complex', 'Modern 3-bedroom townhouse with private garden', 'townhouse', 'sale', 1350000, '789 Elm Road', 'Fourways', 'Johannesburg', 'GP', '2055', 3, 2, 1, 180, 'sold', NOW()),
(7000000000304, NOW(), NOW(), 'Commercial Property', 'Prime retail space in busy shopping center', 'commercial', 'sale', 4200000, '321 Main Street', 'Randburg', 'Johannesburg', 'GP', '2194', 0, 2, 15, 850, 'available', NOW()),
(7000000000305, NOW(), NOW(), 'Vacant Land', 'Large plot perfect for development', 'land', 'sale', 850000, '654 Valley View', 'Bryanston', 'Johannesburg', 'GP', '2191', 0, 0, 0, 1200, 'available', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO "crm_deals" ("id","createdAt","updatedAt","title","stage","value","probability","expected_close_date","notes","fica_status","fica_completed","fica_checklist","fica_documents") VALUES
(7000000000401, NOW(), NOW(), 'Sandton House Sale', 'negotiation', 2850000, 85, '2024-04-15', 'Family home in prime location', 'pending', FALSE, '{}'::jsonb, '{}'::jsonb),
(7000000000402, NOW(), NOW(), 'Rosebank Apartment', 'proposal', 1650000, 70, '2024-03-30', 'Luxury apartment for young professional', 'pending', FALSE, '{}'::jsonb, '{}'::jsonb),
(7000000000403, NOW(), NOW(), 'Fourways Townhouse', 'closed_won', 1350000, 100, '2024-02-28', 'Modern townhouse complex unit', 'verified', TRUE, '{}'::jsonb, '{}'::jsonb),
(7000000000404, NOW(), NOW(), 'Randburg Commercial', 'qualification', 4200000, 45, '2024-05-20', 'Retail space investment opportunity', 'pending', FALSE, '{}'::jsonb, '{}'::jsonb),
(7000000000405, NOW(), NOW(), 'Bryanston Land Deal', 'prospecting', 850000, 25, '2024-06-30', 'Development land acquisition', 'pending', FALSE, '{}'::jsonb, '{}'::jsonb)
ON CONFLICT DO NOTHING;

-- Grant permissions for NocoBase access
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    EXECUTE 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon';
  END IF;
END
$$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_crm_leads_status ON crm_leads(status);
CREATE INDEX IF NOT EXISTS idx_crm_leads_email ON crm_leads(email);
CREATE INDEX IF NOT EXISTS idx_crm_contacts_email ON crm_contacts(email);
CREATE INDEX IF NOT EXISTS idx_crm_properties_status ON crm_properties(status);
CREATE INDEX IF NOT EXISTS idx_crm_properties_suburb ON crm_properties(suburb);
CREATE INDEX IF NOT EXISTS idx_crm_deals_stage ON crm_deals(stage);
CREATE INDEX IF NOT EXISTS idx_crm_suburbs_name ON crm_suburbs(name);
CREATE INDEX IF NOT EXISTS idx_crm_fica_documents_status ON crm_fica_documents(status);

-- Set up triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_crm_leads_updated_at') THEN
    CREATE TRIGGER update_crm_leads_updated_at BEFORE UPDATE ON crm_leads FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_crm_contacts_updated_at') THEN
    CREATE TRIGGER update_crm_contacts_updated_at BEFORE UPDATE ON crm_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_crm_properties_updated_at') THEN
    CREATE TRIGGER update_crm_properties_updated_at BEFORE UPDATE ON crm_properties FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_crm_deals_updated_at') THEN
    CREATE TRIGGER update_crm_deals_updated_at BEFORE UPDATE ON crm_deals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_crm_suburbs_updated_at') THEN
    CREATE TRIGGER update_crm_suburbs_updated_at BEFORE UPDATE ON crm_suburbs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_crm_fica_documents_updated_at') THEN
    CREATE TRIGGER update_crm_fica_documents_updated_at BEFORE UPDATE ON crm_fica_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
  END IF;
END
$$;
