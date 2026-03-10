#!/bin/sh
set -e

echo "=========================================="
echo "Building and Activating Real Estate CRM Plugin"
echo "=========================================="

cd /app/packages/plugins/@custom/real-estate-crm

echo "Building plugin..."
yarn build 2>/dev/null || npm run build 2>/dev/null || true

cd /app/nocobase

echo "Adding plugin to NocoBase..."
yarn pm add "/app/packages/plugins/@custom/real-estate-crm" --quick 2>/dev/null || true

echo "Enabling plugin..."
yarn pm enable "@nocobase/plugin-real-estate-crm" --quick 2>/dev/null || true

echo "Plugin activation complete!"
echo ""
echo "CRM collections should now appear in your sidebar menu."
echo "If they don't appear immediately, refresh your browser."
echo ""
echo "Available collections: Leads, Properties, Deals, Contacts"

exit 0
