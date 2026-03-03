# Vercel Deployment Guide for Real Estate CRM

## ⚠️ Important Notice

**NocoBase is a complex full-stack application** designed primarily for Docker deployment. Deploying to Vercel requires significant customization.

---

## Recommended Deployment Options

### Option 1: NocoBase Cloud (Recommended for Demo)
Use the official NocoBase cloud - fastest way to get a working demo:
- URL: https://demo.nocobase.com/new
- Install plugins from the store
- Configure your custom CRM plugin

### Option 2: Docker Deployment (Production)
Deploy using Docker to any cloud provider:
```bash
# Quick start with Docker
docker run -d --name nocobase \
  -p 13000:13000 \
  -e DB_DIALECT=postgres \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=nocobase \
  -e DB_USER=postgres \
  -e DB_PASSWORD=your-password \
  nocobase/nocobase:latest
```

### Option 3: Custom Vercel Deployment (Advanced)
Requires significant setup - see below.

---

## Vercel Deployment Steps (If Proceeding)

### Prerequisites
1. Vercel account connected to GitHub
2. Supabase or NeonDB for database
3. Environment variables configured

### Environment Variables Required
```
DB_DIALECT=postgres
DB_HOST=your-database-host
DB_PORT=5432
DB_DATABASE=your-db
DB_USER=your-user
DB_PASSWORD=your-password
APP_ENV=production
APP_KEY=your-app-key
```

### Deployment Limitations
- ❌ No WebSocket support
- ❌ No background job processing
- ❌ Limited to serverless functions
- ❌ Requires external database (Supabase/NeonDB)

---

## Quick Demo Alternative

For your Wednesday presentation, I recommend:

1. **Use demo.nocobase.com** - Upload/install the CRM plugin there
2. **Or use Docker locally** - Run locally for demo

---

## Next Steps

What would you prefer?
1. Help setting up Docker for local presentation
2. Guide to using NocoBase Cloud with your plugin
3. Attempt Vercel deployment with limitations
