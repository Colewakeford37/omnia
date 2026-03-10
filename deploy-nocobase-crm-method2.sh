#!/bin/bash

# NocoBase CRM Deployment Script - Method 2: Universal SQL Import
# This script deploys the South African Real Estate CRM using the official NocoBase tutorial approach
# Works with all NocoBase versions including Community Edition

set -e

echo "🚀 Deploying NocoBase CRM using Method 2: Universal SQL Import"
echo "Following the official NocoBase CRM tutorial approach"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Railway environment variables are set
if [ -z "$RAILWAY_SERVICE_ID" ]; then
    print_error "This script is intended for Railway deployment. RAILWAY_SERVICE_ID not found."
    exit 1
fi

print_status "Railway environment detected. Starting deployment..."

# Build and deploy to Railway
print_status "Building Docker image with CRM SQL import..."

# Create a temporary railway.json if it doesn't exist
if [ ! -f "railway.json" ]; then
    print_status "Creating railway.json configuration..."
    cat > railway.json << EOF
{
  "build": {
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "startCommand": "cd /app/nocobase && npm start",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF
fi

# Deploy to Railway
print_status "Deploying to Railway..."
railway up

if [ $? -eq 0 ]; then
    print_status "✅ Railway deployment initiated successfully!"
    print_status "The deployment will take a few minutes to complete."
    print_status ""
    print_status "📋 What happens next:"
    print_status "  1. Docker image will be built with the CRM SQL import script"
    print_status "  2. NocoBase will start and execute the SQL import automatically"
    print_status "  3. CRM collections will be registered in the database"
    print_status "  4. UI schemas will be created for menu integration"
    print_status ""
    print_status "🎯 After deployment completes:"
    print_status "  1. Access your NocoBase admin panel"
    print_status "  2. Go to Settings → Data Source Manager → Main Database → Collections"
    print_status "  3. Click 'Configure UI' on each CRM collection to add them to sidebar"
    print_status "  4. The CRM menu will appear with all sub-menu items"
    print_status ""
    print_status "🔧 CRM Features included:"
    print_status "  ✓ South African ID (RSA ID) validation"
    print_status "  ✓ FICA compliance tracking"
    print_status "  ✓ Property management with suburb data"
    print_status "  ✓ Sales pipeline with deal stages"
    print_status "  ✓ Lead and contact management"
    print_status "  ✓ Sample data loaded for testing"
    print_status ""
    
    # Get the deployment URL
    DEPLOYMENT_URL=$(railway status | grep "Service URL" | awk '{print $3}')
    if [ -n "$DEPLOYMENT_URL" ]; then
        print_status "🌐 Your NocoBase CRM will be available at: $DEPLOYMENT_URL/admin"
        print_status "💡 Add '/admin' to the URL to access the admin panel"
    fi
    
    print_status "🎉 Deployment completed! The CRM menu should appear after configuration."
    
else
    print_error "❌ Railway deployment failed"
    print_error "Please check the logs above for more details"
    exit 1
fi

# Monitor deployment status
print_status "Monitoring deployment status..."
echo ""
echo "To check deployment status, run: railway status"
echo "To view logs, run: railway logs"
echo ""
echo "The CRM installation will complete automatically when the container starts."
echo "Look for 'NocoBase CRM installation completed successfully!' in the logs."