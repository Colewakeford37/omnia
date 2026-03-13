#!/bin/bash

# NocoBase CRM Installation Script - Method 2: Universal SQL Import for MySQL
# This follows the official NocoBase CRM tutorial for Community Edition compatibility
# Source: https://www.nocobase.com/en/tutorials/nocobase-crm-demo-deployment-guide

set -e

echo "🚀 Starting NocoBase CRM installation using Method 2: Universal SQL Import (MySQL)"
echo "This method works with all NocoBase versions including Community Edition"

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
until mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SELECT 1;" $MYSQL_DATABASE 2>/dev/null; do
  echo "Waiting for MySQL..."
  sleep 2
done

echo "✅ MySQL is ready!"

# Check if CRM tables already exist
echo "🔍 Checking for existing CRM data..."
CRM_EXISTS=$(mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MYSQL_DATABASE' AND table_name = 'crm_leads';" -s -N 2>/dev/null || echo "0")

if [ "$CRM_EXISTS" -gt "0" ]; then
    echo "⚠️  CRM data already exists. Skipping installation to avoid duplicates."
    exit 0
fi

# Execute the MySQL SQL script
echo "📊 Installing enhanced CRM database schema and sample data..."
mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < /app/docker/nocobase/nocobase-crm-mysql-enhanced.sql

if [ $? -eq 0 ]; then
    echo "✅ CRM database schema installed successfully!"
else
    echo "❌ Failed to install CRM database schema"
    exit 1
