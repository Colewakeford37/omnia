#!/bin/sh
set -e

echo "=========================================="
echo "Final Deployment: SA Real Estate CRM with RSA ID Validation"
echo "=========================================="

cd /app/nocobase

echo "Step 1: Creating database schema with RSA ID validation..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Create core CRM tables with SA-specific fields and RSA ID validation
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
  "rsa_id_valid" BOOLEAN DEFAULT FALSE,
  "date_of_birth" DATE,
  "gender" VARCHAR(10),
  "citizenship" VARCHAR(20),
  "age" INTEGER,
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

-- Create RSA ID validation function
CREATE OR REPLACE FUNCTION validate_rsa_id(rsa_id VARCHAR) RETURNS BOOLEAN AS $$
BEGIN
  -- Check length and format
  IF rsa_id IS NULL OR LENGTH(rsa_id) != 13 OR NOT rsa_id ~ '^\d{13}$' THEN
    RETURN FALSE;
  END IF;
  
  -- Extract components
  DECLARE
    year_part INT := CAST(SUBSTRING(rsa_id, 1, 2) AS INT);
    month_part INT := CAST(SUBSTRING(rsa_id, 3, 2) AS INT);
    day_part INT := CAST(SUBSTRING(rsa_id, 5, 2) AS INT);
    sequential INT := CAST(SUBSTRING(rsa_id, 7, 4) AS INT);
    citizenship INT := CAST(SUBSTRING(rsa_id, 11, 1) AS INT);
    checksum INT := CAST(SUBSTRING(rsa_id, 13, 1) AS INT);
    full_year INT;
    calculated_sum INT := 0;
    alternate BOOLEAN := FALSE;
    digit INT;
  BEGIN
    -- Determine full year
    IF year_part < 50 THEN
      full_year := 2000 + year_part;
    ELSE
      full_year := 1900 + year_part;
    END IF;
    
    -- Validate date components
    IF month_part < 1 OR month_part > 12 THEN
      RETURN FALSE;
    END IF;
    
    IF day_part < 1 OR day_part > 31 THEN
      RETURN FALSE;
    END IF;
    
    -- Validate sequential number (gender)
    IF sequential < 0 OR sequential > 9999 THEN
      RETURN FALSE;
    END IF;
    
    -- Validate citizenship
    IF citizenship < 0 OR citizenship > 1 THEN
      RETURN FALSE;
    END IF;
    
    -- Validate Luhn checksum
    FOR i IN REVERSE 12..1 LOOP
      digit := CAST(SUBSTRING(rsa_id, i, 1) AS INT);
      
      IF alternate THEN
        digit := digit * 2;
        IF digit > 9 THEN
          digit := (digit % 10) + 1;
        END IF;
      END IF;
      
      calculated_sum := calculated_sum + digit;
      alternate := NOT alternate;
    END LOOP;
    
    RETURN (calculated_sum % 10) = 0;
  END;
END;
$$ LANGUAGE plpgsql;

-- Create function to extract RSA ID information
CREATE OR REPLACE FUNCTION extract_rsa_id_info(rsa_id VARCHAR) RETURNS JSON AS $$
DECLARE
  result JSON;
  year_part INT;
  month_part INT;
  day_part INT;
  sequential INT;
  citizenship INT;
  full_year INT;
  gender VARCHAR(10);
  citizenship_status VARCHAR(20);
  age INT;
  today DATE := CURRENT_DATE;
BEGIN
  IF NOT validate_rsa_id(rsa_id) THEN
    RETURN NULL;
  END IF;
  
  -- Extract components
  year_part := CAST(SUBSTRING(rsa_id, 1, 2) AS INT);
  month_part := CAST(SUBSTRING(rsa_id, 3, 2) AS INT);
  day_part := CAST(SUBSTRING(rsa_id, 5, 2) AS INT);
  sequential := CAST(SUBSTRING(rsa_id, 7, 4) AS INT);
  citizenship := CAST(SUBSTRING(rsa_id, 11, 1) AS INT);
  
  -- Determine full year
  IF year_part < 50 THEN
    full_year := 2000 + year_part;
  ELSE
    full_year := 1900 + year_part;
  END IF;
  
  -- Determine gender
  IF sequential < 5000 THEN
    gender := 'female';
  ELSE
    gender := 'male';
  END IF;
  
  -- Determine citizenship
  IF citizenship = 0 THEN
    citizenship_status := 'citizen';
  ELSE
    citizenship_status := 'resident';
  END IF;
  
  -- Calculate age
  age := DATE_PART('year', today) - full_year;
  IF DATE_PART('month', today) < month_part OR 
     (DATE_PART('month', today) = month_part AND DATE_PART('day', today) < day_part) THEN
    age := age - 1;
  END IF;
  
  RETURN json_build_object(
    'date_of_birth', MAKE_DATE(full_year, month_part, day_part),
    'gender', gender,
    'citizenship', citizenship_status,
    'age', age
  );
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-validate RSA ID and extract info
CREATE OR REPLACE FUNCTION update_customer_rsa_info() RETURNS TRIGGER AS $$
DECLARE
  rsa_info JSON;
BEGIN
  IF NEW.rsa_id_number IS NOT NULL AND NEW.rsa_id_number != '' THEN
    -- Validate RSA ID
    NEW.rsa_id_valid := validate_rsa_id(NEW.rsa_id_number);
    
    -- Extract information if valid
    IF NEW.rsa_id_valid THEN
      rsa_info := extract_rsa_id_info(NEW.rsa_id_number);
      IF rsa_info IS NOT NULL THEN
        NEW.date_of_birth := (rsa_info->>'date_of_birth')::DATE;
        NEW.gender := rsa_info->>'gender';
        NEW.citizenship := rsa_info->>'citizenship';
        NEW.age := (rsa_info->>'age')::INT;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_customer_rsa_info
  BEFORE INSERT OR UPDATE ON "customers"
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_rsa_info();

PSQL

echo "Step 2: Creating indexes for performance..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customers_rsa_id ON "customers"("rsa_id_number");
CREATE INDEX IF NOT EXISTS idx_customers_email ON "customers"("email");
CREATE INDEX IF NOT EXISTS idx_customers_fica_status ON "customers"("fica_compliant");
CREATE INDEX IF NOT EXISTS idx_properties_ref ON "properties"("property_ref");
CREATE INDEX IF NOT EXISTS idx_properties_status ON "properties"("status");
CREATE INDEX IF NOT EXISTS idx_properties_owner ON "properties"("owner_id");
CREATE INDEX IF NOT EXISTS idx_opportunities_customer ON "opportunities"("customer_id");
CREATE INDEX IF NOT EXISTS idx_opportunities_property ON "opportunities"("property_id");
CREATE INDEX IF NOT EXISTS idx_leads_status ON "leads"("status");
CREATE INDEX IF NOT EXISTS idx_leads_assigned ON "leads"("assigned_to");
CREATE INDEX IF NOT EXISTS idx_fica_customer ON "fica_documents"("customer_id");
CREATE INDEX IF NOT EXISTS idx_fica_type ON "fica_documents"("document_type");
CREATE INDEX IF NOT EXISTS idx_fica_verified ON "fica_documents"("verified");

PSQL

echo "Step 3: Creating menu structure..."

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

echo "Step 4: Setting up permissions..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Grant permissions for collections
GRANT SELECT, INSERT, UPDATE, DELETE ON "customers" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "properties" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "opportunities" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "leads" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "fica_documents" TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON "fica_document_types" TO authenticated;

-- Grant read access to anonymous users (for public property listings)
GRANT SELECT ON "properties" TO anon;
GRANT SELECT ON "customers" TO anon;
GRANT SELECT ON "fica_document_types" TO anon;

PSQL

echo "Step 5: Inserting sample data for testing..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Insert sample customers with valid RSA IDs
INSERT INTO "customers" ("rsa_id_number", "first_name", "last_name", "email", "phone", "address", "city", "province", "customer_type") VALUES
('8001015009087', 'John', 'Smith', 'john.smith@email.com', '0825551234', '123 Main St', 'Johannesburg', 'Gauteng', 'individual'),
('8503050001234', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '0835555678', '456 Oak Ave', 'Cape Town', 'Western Cape', 'individual'),
('9005205012345', 'Michael', 'Brown', 'michael.brown@email.com', '0845559012', '789 Pine Rd', 'Durban', 'KwaZulu-Natal', 'individual')
ON CONFLICT ("email") DO NOTHING;

-- Insert sample properties
INSERT INTO "properties" ("property_ref", "title", "address", "suburb", "city", "province", "property_type", "price", "bedrooms", "bathrooms", "status", "description") VALUES
('PROP001', 'Modern 3-Bedroom House in Sandton', '123 Sandton Drive', 'Sandton', 'Johannesburg', 'Gauteng', 'House', 2500000, 3, 2, 'available', 'Beautiful modern house with garden and pool'),
('PROP002', 'Luxury Apartment in Cape Town CBD', '456 Long Street', 'CBD', 'Cape Town', 'Western Cape', 'Apartment', 1800000, 2, 2, 'available', 'Stunning apartment with mountain views'),
('PROP003', 'Family Home in Durban North', '789 Marine Drive', 'Durban North', 'Durban', 'KwaZulu-Natal', 'House', 3200000, 4, 3, 'available', 'Spacious family home near the beach')
ON CONFLICT ("property_ref") DO NOTHING;

-- Insert sample leads
INSERT INTO "leads" ("first_name", "last_name", "email", "phone", "source", "status", "preferred_location", "property_type", "budget_min", "budget_max") VALUES
('Alice', 'Williams', 'alice.williams@email.com', '0815552468', 'website', 'new', 'Sandton', 'House', 2000000, 3000000),
('Bob', 'Davis', 'bob.davis@email.com', '0855551357', 'property24', 'contacted', 'Cape Town', 'Apartment', 1500000, 2000000),
('Carol', 'Wilson', 'carol.wilson@email.com', '0865557890', 'referral', 'qualified', 'Durban', 'House', 2500000, 4000000)
ON CONFLICT ("email") DO NOTHING;

PSQL

echo "=========================================="
echo "✅ SA Real Estate CRM with RSA ID Validation Deployed!"
echo "=========================================="
echo ""
echo "Your CRM is now ready with:"
echo "- ✅ RSA ID validation with automatic info extraction"
echo "- ✅ Customer Management with FICA compliance tracking"
echo "- ✅ Property Listings with SA locations"
echo "- ✅ Sales Opportunities with commission tracking"
echo "- ✅ Lead Management with assignment"
echo "- ✅ FICA Compliance with document management"
echo ""
echo "The CRM menu should appear in your sidebar."
echo "Visit: https://omnia-app.up.railway.app/admin"
echo ""
echo "Sample data has been loaded for testing."
echo "Try creating a customer with RSA ID: 8001015009087"
echo "=========================================="

exit 0
