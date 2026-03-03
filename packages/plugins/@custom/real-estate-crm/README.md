# Real Estate CRM Plugin

A comprehensive Real Estate CRM plugin built for NocoBase, providing lead management, property tracking, contact management, and enterprise action plans with AI integration.

## Features

### Core CRM Features
- **Lead Management** - Track and manage leads from various sources
- **Contact Management** - Full contact database with engagement tracking
- **Property Listings** - Manage property listings with detailed information
- **Deal Pipeline** - Track deals through various stages
- **Activity Tracking** - Log all customer interactions

### Cold Calling Features (22 Working Principles)
1. Birthday Wish
2. Anniversary of Purchase  
3. New Property in Street
4. Price Reduced
5. Property Just Listed
6. Market Update
7. Expired Listing
8. New Development Nearby
9. School Zones Changed
10. Infrastructure Updates
11. Interest Rate Changes
12. Similar Property Sold
13. Open House Invitation
14. Free Valuation Offer
15. Property Management Services
16. Investment Opportunity
17. Downsizing/Upsizing Options
18. Relocation Services
19. First-Time Buyer Info
20. Seasonal Greetings
21. Follow-up After Viewing
22. Feedback Request

### Enterprise Action Plans
- Create multi-step action plans
- Task management with dependencies
- Checklist templates
- Progress tracking
- Due date management
- Assignment workflows

### AI Integration
- Lead Qualifier AI
- Property Matcher AI
- Market Analyst AI
- CRM Insights AI
- Analysis templates for dashboards
- Knowledge base integration

### Data Source Integrations
- **Scraper Data** - Property24, Private Property, Rent Guru, Facebook Groups
- **Supabase Suburb Data** - Demographics, sales history, sectional titles
- **Local Database** - Previous sellers, property history, communications

## Installation

1. Copy this plugin to your NocoBase plugins directory
2. Add to your package.json dependencies
3. Run database migrations
4. Enable the plugin in NocoBase admin panel

## Configuration

### Enable Custom Branding
After installing the plugin, configure branding in:
- System Settings → General → Application Name
- Custom Brand plugin settings

### Configure AI Employees
1. Go to AI Employees in admin panel
2. Create new employees using the configurations in `src/config/ai-config.ts`
3. Set up LLM provider (OpenAI, Anthropic, etc.)

### Set Up Data Sources
Configure in `src/config/datasource-config.ts`:
- Scraper API endpoints
- Supabase connection
- Local database connection

## Collections

### Core CRM Collections
- `crm_leads` - Lead information and status
- `crm_contacts` - Contact database
- `crm_properties` - Property listings
- `crm_deals` - Deal/opportunity tracking
- `crm_activities` - Activity history

### Cold Calling Collections
- `crm_contact_reasons` - 22 working principles
- `crm_call_logs` - Call history
- `crm_follow_ups` - Scheduled follow-ups

### Action Plan Collections
- `crm_action_plans` - Enterprise action plans
- `crm_tasks` - Task management
- `crm_checklist_templates` - Checklist templates
- `crm_checklist_items` - Individual checklist items

### Data Collections
- `crm_suburbs` - Suburb information
- `crm_suburb_reports` - Market reports
- `crm_sectional_titles` - Sectional title data
- `crm_scraped_leads` - Imported lead data

## Test Data

Generate test data for presentation:

```typescript
import { generateTestData } from './scripts/generate-test-data';
import { Database } from '@nocobase/database';

const db = new Database({...});
await generateTestData(db);
```

Generates:
- 60 Leads
- 120 Contacts  
- 45 Properties
- 30 Deals
- 15 Action Plans
- 50 Tasks
- 80 Call Logs
- 40 Follow-ups
- 10 Suburbs
- 35 Scraped Leads

## Customization

### Adding Custom Contact Reasons
Edit `src/config/datasource-config.ts` → `COLD_CALLING_PRINCIPLES`

### Modifying AI Prompts
Edit `src/config/ai-config.ts` → `AI_EMPLOYEES`

### Brand Customization
Edit `src/config/branding-config.ts` → `BRAND_CONFIG`

## License

Apache-2.0

## Author

YourBrand Development Team
