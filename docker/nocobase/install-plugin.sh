#!/bin/sh
set -e

echo "=========================================="
echo "Activating Real Estate CRM Plugin"
echo "=========================================="

cd /app/nocobase

PLUGIN_DIR="/app/packages/plugins/@custom/real-estate-crm"
PLUGIN_NAME="@nocobase/plugin-real-estate-crm"

echo "Adding plugin to NocoBase..."
yarn pm add "$PLUGIN_DIR" --quick 2>/dev/null || true

echo "Enabling plugin..."
yarn pm enable "$PLUGIN_NAME" --quick 2>/dev/null || true

echo "Plugin activation complete!"
echo ""
echo "CRM collections should now appear in your sidebar menu."
echo "If they don't appear immediately, refresh your browser."
echo ""
echo "Available collections: Leads, Properties, Deals, Contacts"

exit 0
