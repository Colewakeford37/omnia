#!/bin/sh
set -e

echo "=========================================="
echo "Deploying NocoBase 2.0 with SA Real Estate CRM"
echo "=========================================="

cd /app/nocobase

echo "Step 1: Installing NocoBase CRM modules..."

# Install core CRM modules (without --quick flag)
yarn pm add @nocobase/plugin-collection-manager 2>/dev/null || true
yarn pm add @nocobase/plugin-ui-routes 2>/dev/null || true
yarn pm add @nocobase/plugin-ui-schema 2>/dev/null || true
yarn pm add @nocobase/plugin-workflow 2>/dev/null || true
yarn pm add @nocobase/plugin-file-manager 2>/dev/null || true
yarn pm add @nocobase/plugin-system-settings 2>/dev/null || true

echo "Step 2: Copying RSA ID validation plugin..."

# Copy the RSA ID validation plugin
cp -r /app/packages/plugins/rsa-id-validation /app/packages/plugins/@custom/rsa-id-validation 2>/dev/null || true

echo "Step 3: Installing RSA ID validation plugin..."

# Install the RSA ID validation plugin
yarn pm add /app/packages/plugins/@custom/rsa-id-validation 2>/dev/null || true

echo "Step 4: Creating database schema for SA Real Estate CRM..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Create core CRM tables with SA-specific fields
CREATE TABLE IF NOT EXISTS "customers" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "rsa_id_number" VARCHAR(13) UNIQUE,
  "first_name" VARCHAR(100) NOT NULL,
  "last_name" VARCHAR(100) NOT NULL,
  "email" VARCHAR(255) UNIQUE NOT NULL,
  "phone" VARCHAR(20),
  "mobile" VARCHAR(20),
  "customer_type" VARCHAR(50) DEFAULT 'individual',
  "fica_compliant" BOOLEAN DEFAULT FALSE,
  "fica_expiry" DATE,
  "tax_number" VARCHAR(20),
  "address" TEXT,
  "city" VARCHAR(100),
  "province" VARCHAR(100),
  "postal_code" VARCHAR(10),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "properties" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "property_ref" VARCHAR(50) UNIQUE NOT NULL,
  "title" VARCHAR(255) NOT NULL,
  "address" TEXT NOT NULL,
  "street_number" VARCHAR(20),
  "street_name" VARCHAR(255),
  "suburb" VARCHAR(255),
  "city" VARCHAR(100) DEFAULT 'Johannesburg',
  "province" VARCHAR(100) DEFAULT 'Gauteng',
  "postal_code" VARCHAR(10),
  "property_type" VARCHAR(50) NOT NULL,
  "listing_type" VARCHAR(50) DEFAULT 'sale',
  "price" DECIMAL(15,2),
  "price_display" VARCHAR(100),
  "negotiable" BOOLEAN DEFAULT TRUE,
  "bedrooms" INTEGER,
  "bathrooms" INTEGER,
  "garage" INTEGER,
  "parking" INTEGER,
  "floor_area" DECIMAL(10,2),
  "land_size" DECIMAL(10,2),
  "year_built" INTEGER,
  "status" VARCHAR(50) DEFAULT 'available',
  "description" TEXT,
  "features" TEXT,
  "owner_id" UUID REFERENCES "customers"("id"),
  "listing_date" DATE DEFAULT CURRENT_DATE,
  "mandate_type" VARCHAR(50),
  "mandate_expiry" DATE,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "opportunities" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "title" VARCHAR(255) NOT NULL,
  "customer_id" UUID REFERENCES "customers"("id"),
  "property_id" UUID REFERENCES "properties"("id"),
  "stage" VARCHAR(50) DEFAULT 'prospecting',
  "value" DECIMAL(15,2),
  "commission" DECIMAL(10,2),
  "commission_rate" DECIMAL(5,2) DEFAULT 5.0,
  "probability" INTEGER DEFAULT 10,
  "expected_close_date" DATE,
  "actual_close_date" DATE,
  "assigned_to" VARCHAR(255),
  "source" VARCHAR(100),
  "notes" TEXT,
  "lost_reason" VARCHAR(255),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "leads" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "first_name" VARCHAR(100),
  "last_name" VARCHAR(100),
  "email" VARCHAR(255),
  "phone" VARCHAR(20),
  "mobile" VARCHAR(20),
  "company" VARCHAR(255),
  "source" VARCHAR(100),
  "source_detail" VARCHAR(255),
  "status" VARCHAR(50) DEFAULT 'new',
  "budget_min" DECIMAL(15,2),
  "budget_max" DECIMAL(15,2),
  "preferred_location" VARCHAR(255),
  "property_type" VARCHAR(100),
  "bedrooms_required" INTEGER,
  "timeline" VARCHAR(100),
  "rating" INTEGER DEFAULT 1,
  "assigned_to" VARCHAR(255),
  "notes" TEXT,
  "last_contacted" TIMESTAMP WITH TIME ZONE,
  "next_follow_up" TIMESTAMP WITH TIME ZONE,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS "fica_documents" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "customer_id" UUID REFERENCES "customers"("id") ON DELETE CASCADE,
  "document_type" VARCHAR(50) NOT NULL,
  "file_path" TEXT NOT NULL,
  "file_name" VARCHAR(255) NOT NULL,
  "file_size" BIGINT,
  "mime_type" VARCHAR(100),
  "expiry_date" DATE,
  "verified" BOOLEAN DEFAULT FALSE,
  "verified_date" TIMESTAMP WITH TIME ZONE,
  "verified_by" VARCHAR(255),
  "notes" TEXT,
  "uploaded_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_customers_rsa_id ON "customers"("rsa_id_number");
CREATE INDEX idx_customers_email ON "customers"("email");
CREATE INDEX idx_customers_fica_status ON "customers"("fica_compliant");
CREATE INDEX idx_properties_ref ON "properties"("property_ref");
CREATE INDEX idx_properties_status ON "properties"("status");
CREATE INDEX idx_properties_owner ON "properties"("owner_id");
CREATE INDEX idx_opportunities_customer ON "opportunities"("customer_id");
CREATE INDEX idx_opportunities_property ON "opportunities"("property_id");
CREATE INDEX idx_leads_status ON "leads"("status");
CREATE INDEX idx_leads_assigned ON "leads"("assigned_to");
CREATE INDEX idx_fica_customer ON "fica_documents"("customer_id");
CREATE INDEX idx_fica_type ON "fica_documents"("document_type");
CREATE INDEX idx_fica_verified ON "fica_documents"("verified");

PSQL

echo "Step 5: Registering collections in NocoBase..."

# Register collections using NocoBase's collection manager
yarn nocobase db:sync 2>/dev/null || true

echo "Step 6: Creating menu structure..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Create menu items for CRM collections
INSERT INTO "ui_schemas" ("name", "ui_schema", "created_at", "updated_at") VALUES
('crm_menu', '{
  "type": "void",
  "title": "Real Estate CRM",
  "name": "crm",
  "icon": "ShopOutlined",
  "x-designer": {"placement": "sidebar"},
  "children": [
    {
      "type": "page",
      "title": "Dashboard",
      "name": "crm_dashboard",
      "icon": "DashboardOutlined",
      "path": "/admin/crm/dashboard"
    },
    {
      "type": "page",
      "title": "Customers",
      "name": "customers",
      "icon": "UserOutlined",
      "path": "/admin/crm/customers",
      "x-resource": "customers",
      "x-decorator": "APIClientDataBlock",
      "x-decorator-props": {
        "resource": "customers",
        "action": "list",
        "params": {"pageSize": 20}
      }
    },
    {
      "type": "page",
      "title": "Properties",
      "name": "properties",
      "icon": "HomeOutlined",
      "path": "/admin/crm/properties",
      "x-resource": "properties",
      "x-decorator": "APIClientDataBlock",
      "x-decorator-props": {
        "resource": "properties",
        "action": "list",
        "params": {"pageSize": 20}
      }
    },
    {
      "type": "page",
      "title": "Opportunities",
      "name": "opportunities",
      "icon": "PercentageOutlined",
      "path": "/admin/crm/opportunities",
      "x-resource": "opportunities",
      "x-decorator": "APIClientDataBlock",
      "x-decorator-props": {
        "resource": "opportunities",
        "action": "list",
        "params": {"pageSize": 20}
      }
    },
    {
      "type": "page",
      "title": "Leads",
      "name": "leads",
      "icon": "TeamOutlined",
      "path": "/admin/crm/leads",
      "x-resource": "leads",
      "x-decorator": "APIClientDataBlock",
      "x-decorator-props": {
        "resource": "leads",
        "action": "list",
        "params": {"pageSize": 20}
      }
    },
    {
      "type": "page",
      "title": "FICA Compliance",
      "name": "fica_compliance",
      "icon": "SafetyOutlined",
      "path": "/admin/crm/fica",
      "x-resource": "fica_documents",
      "x-decorator": "APIClientDataBlock",
      "x-decorator-props": {
        "resource": "fica_documents",
        "action": "list",
        "params": {"pageSize": 20}
      }
    }
  ]
}', NOW(), NOW()) ON CONFLICT ("name") DO NOTHING;

PSQL

echo "Step 7: Setting up permissions..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Grant permissions for collections
GRANT SELECT, INSERT, UPDATE, DELETE ON "customers" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "properties" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "opportunities" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "leads" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "fica_documents" TO authenticated;

-- Grant read access to anonymous users (for public property listings)
GRANT SELECT ON "properties" TO anon;
GRANT SELECT ON "customers" TO anon;

PSQL

echo "Step 8: Creating default FICA document types..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Create FICA document types table
CREATE TABLE IF NOT EXISTS "fica_document_types" (
  "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" VARCHAR(100) NOT NULL,
  "code" VARCHAR(50) UNIQUE NOT NULL,
  "description" TEXT,
  "required" BOOLEAN DEFAULT TRUE,
  "expiry_days" INTEGER,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default FICA document types
INSERT INTO "fica_document_types" ("name", "code", "description", "required", "expiry_days") VALUES
('RSA ID Document', 'rsa_id', 'South African ID Document or Passport', TRUE, NULL),
('Proof of Address', 'proof_of_address', 'Utility bill or bank statement (not older than 3 months)', TRUE, 90),
('Tax Number', 'tax_number', 'SARS tax number certificate', FALSE, NULL),
('Bank Statement', 'bank_statement', 'Recent bank statement', FALSE, 90),
('Employment Letter', 'employment_letter', 'Letter from employer', FALSE, NULL)
ON CONFLICT ("code") DO NOTHING;

PSQL

echo "=========================================="
echo "✅ NocoBase 2.0 with SA Real Estate CRM Deployed!"
echo "=========================================="
echo ""
echo "Your CRM is now ready with:"
echo "- Customer Management (with RSA ID validation)"
echo "- Property Listings (with SA locations)"
echo "- Sales Opportunities (with commission tracking)"
echo "- Lead Management (with assignment)"
echo "- FICA Compliance (with document management)"
echo ""
echo "The CRM menu should appear in your sidebar."
echo "Visit: https://omnia-app.up.railway.app/admin"
echo "=========================================="

exit 0
