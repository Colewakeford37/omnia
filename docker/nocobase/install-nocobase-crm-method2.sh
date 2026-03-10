#!/bin/bash

# NocoBase CRM Installation Script - Method 2: Universal SQL Import
# This follows the official NocoBase CRM tutorial for Community Edition compatibility
# Source: https://www.nocobase.com/en/tutorials/nocobase-crm-demo-deployment-guide

set -e

echo "🚀 Starting NocoBase CRM installation using Method 2: Universal SQL Import"
echo "This method works with all NocoBase versions including Community Edition"

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c '\q' 2>/dev/null; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

echo "✅ PostgreSQL is ready!"

# Check if CRM tables already exist
echo "🔍 Checking for existing CRM data..."
CRM_EXISTS=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'crm_leads');" | xargs)

if [ "$CRM_EXISTS" = "t" ]; then
    echo "⚠️  CRM data already exists. Skipping installation to avoid duplicates."
    exit 0
fi

# Execute the SQL script
echo "📊 Installing CRM database schema and sample data..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -f /app/docker/nocobase/nocobase-crm.sql

if [ $? -eq 0 ]; then
    echo "✅ CRM database schema installed successfully!"
else
    echo "❌ Failed to install CRM database schema"
    exit 1
fi

# Verify installation
echo "🔍 Verifying CRM installation..."
TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'crm_%';" | xargs)
COLLECTION_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -t -c "SELECT COUNT(*) FROM collections WHERE name LIKE 'crm_%';" | xargs)
UI_SCHEMA_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -t -c "SELECT COUNT(*) FROM uiSchemas WHERE name LIKE 'crm_%';" | xargs)

echo "📈 Installation Summary:"
echo "  - CRM Tables: $TABLE_COUNT"
echo "  - Collections: $COLLECTION_COUNT" 
echo "  - UI Schemas: $UI_SCHEMA_COUNT"

if [ "$TABLE_COUNT" -ge 6 ] && [ "$COLLECTION_COUNT" -ge 6 ] && [ "$UI_SCHEMA_COUNT" -ge 7 ]; then
    echo "🎉 NocoBase CRM installation completed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Access your NocoBase admin panel"
    echo "  2. Go to Settings → Data Source Manager → Main Database → Collections"
    echo "  3. Click 'Configure UI' on each CRM collection to add them to the sidebar"
    echo "  4. The CRM menu items will appear in the sidebar after configuration"
    echo ""
    echo "🔧 Collections created:"
    echo "  - CRM Leads (with RSA ID validation)"
    echo "  - CRM Contacts (with FICA status)"
    echo "  - CRM Properties (with full property details)"
    echo "  - CRM Deals (with sales pipeline)"
    echo "  - CRM Suburbs (with area information)"
    echo "  - FICA Documents (for compliance)"
    echo ""
    echo "📊 Sample data has been loaded for testing"
    echo "✅ Ready to use! The CRM is now available in your NocoBase instance."
else
    echo "❌ Installation verification failed. Please check the logs."
    exit 1
fi