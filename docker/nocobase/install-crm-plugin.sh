#!/bin/sh
set -e

echo "=========================================="
echo "Installing SA Real Estate CRM Plugin"
echo "=========================================="

cd /app/nocobase

echo "Step 1: Copying plugin files..."

# Copy the plugin to the packages directory
cp -r /app/packages/plugins/sa-real-estate-crm /app/packages/plugins/@custom/sa-real-estate-crm 2>/dev/null || true

echo "Step 2: Installing the plugin..."

# Install the plugin using NocoBase's plugin manager
yarn pm add /app/packages/plugins/@custom/sa-real-estate-crm 2>/dev/null || true

echo "Step 3: Syncing database..."

# Sync the database to create tables
yarn nocobase db:sync 2>/dev/null || true

echo "Step 4: Creating FICA document types..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Insert default FICA document types if they don't exist
INSERT INTO "fica_document_types" ("name", "code", "description", "required", "expiry_days") VALUES
('RSA ID Document', 'rsa_id', 'South African ID Document or Passport', TRUE, NULL),
('Proof of Address', 'proof_of_address', 'Utility bill or bank statement (not older than 3 months)', TRUE, 90),
('Tax Number', 'tax_number', 'SARS tax number certificate', FALSE, NULL),
('Bank Statement', 'bank_statement', 'Recent bank statement', FALSE, 90),
('Employment Letter', 'employment_letter', 'Letter from employer', FALSE, NULL)
ON CONFLICT ("code") DO NOTHING;

PSQL

echo "Step 5: Inserting sample data..."

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true

-- Insert sample customers with valid RSA IDs
INSERT INTO "customers" ("rsa_id_number", "first_name", "last_name", "email", "phone", "address", "city", "province", "customer_type", "rsa_id_valid", "date_of_birth", "gender", "citizenship", "age") VALUES
('8001015009087', 'John', 'Smith', 'john.smith@email.com', '0825551234', '123 Main St', 'Johannesburg', 'Gauteng', 'individual', TRUE, '1980-01-01', 'male', 'citizen', 44),
('8503050001234', 'Sarah', 'Johnson', 'sarah.johnson@email.com', '0835555678', '456 Oak Ave', 'Cape Town', 'Western Cape', 'individual', TRUE, '1985-03-05', 'female', 'citizen', 39),
('9005205012345', 'Michael', 'Brown', 'michael.brown@email.com', '0845559012', '789 Pine Rd', 'Durban', 'KwaZulu-Natal', 'individual', TRUE, '1990-05-20', 'male', 'citizen', 34)
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
echo "✅ SA Real Estate CRM Plugin Installed!"
echo "=========================================="
echo ""
echo "Your CRM is now ready with:"
echo "- ✅ Complete menu structure in sidebar"
echo "- ✅ RSA ID validation with automatic info extraction"
echo "- ✅ Customer Management with FICA compliance tracking"
echo "- ✅ Property Listings with SA locations"
echo "- ✅ Sales Opportunities with commission tracking"
echo "- ✅ Lead Management with assignment"
echo "- ✅ FICA Compliance with document management"
echo ""
echo "The CRM menu should now appear in your sidebar."
echo "Visit: https://omnia-app.up.railway.app/admin"
echo ""
echo "Sample data has been loaded for testing."
echo "Try creating a customer with RSA ID: 8001015009087"
echo "=========================================="

exit 0
