# Railway Deployment Guide for Real Estate CRM

## Prerequisites

1. **Railway Account** - Sign up at https://railway.app
2. **NeonDB Database** - Create a PostgreSQL database at https://neon.tech
3. **GitHub Repository** - Push your code to GitHub

---

## Step 1: Create NeonDB Database

1. Go to https://neon.tech
2. Create a new project
3. Get your connection string (will look like: `postgresql://user:pass@ep-xxx.us-east-1.aws.neon.tech/neon_db`)

---

## Step 2: Deploy to Railway

### Option A: Via Railway Dashboard

1. Go to https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your repository
5. Add the following Environment Variables:

### Environment Variables

```env
# Required
APP_ENV=production
NODE_ENV=production
APP_KEY=generate-a-random-string-here

# Database (NeonDB)
DB_DIALECT=postgres
DB_HOST=your-neon-host.us-east-1.aws.neon.tech
DB_PORT=5432
DB_DATABASE=neon_db
DB_USER=your-user
DB_PASSWORD=your-password

# Cache
CACHE_DEFAULT_STORE=memory
CACHE_MEMORY_MAX=2000

# Security
ENCRYPTION_FIELD_KEY=your-encryption-key

# Application
INIT_LANG=en-US
INIT_ROOT_EMAIL=admin@yourdomain.com
INIT_ROOT_PASSWORD=admin123
INIT_ROOT_NICKNAME=Admin
INIT_ROOT_USERNAME=admin
```

### Option B: Via Railway CLI

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Create project
railway init

# Add database
railway add postgresql

# Add environment variables
railway variables set APP_KEY=your-random-key
railway variables set DB_DIALECT=postgres
# ... add other variables

# Deploy
railway up
```

---

## Step 3: Configure Custom Domain

1. Go to Railway project settings
2. Click "Domains"
3. Add your custom domain: `lifestyle.vercel.app` (or connect to Vercel)
4. Or use Railway's free domain: `your-project.railway.app`

---

## Step 4: Install CRM Plugin

After deployment:

1. Access your Railway app URL
2. Login with admin credentials
3. Go to Plugin Manager
4. Install your custom CRM plugin (`@custom/real-estate-crm`)
5. Enable the plugin

---

## Step 5: Generate Test Data

1. Go to the admin panel
2. Navigate to Settings or use the API to generate test data
3. Or manually add sample records

---

## Files Created

- `railway.json` - Railway configuration
- `Dockerfile` - Container build instructions

---

## Troubleshooting

### Build Fails
- Check that all dependencies are in package.json
- Ensure Node version is 18+

### Database Connection Error
- Verify NeonDB credentials
- Check that NeonDB allows external connections
- Ensure DB_HOST is correct

### App Won't Start
- Check Railway logs: `railway logs`
- Verify all required env vars are set
- Ensure port 13000 is exposed

---

## Quick Commands

```bash
# View logs
railway logs

# Open shell
railway run bash

# Check status
railway status

# Add variables
railway variables set KEY=value
```

---

## Next Steps After Deployment

1. Configure Custom Branding in admin panel
2. Set up AI employees
3. Import test data
4. Present your CRM!
