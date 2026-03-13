# Fresh Start: Seeding, Localization, and “Types”

## Seeding Goals
Seeding must support three distinct modes:
- Demo seed: realistic, consistent data for presentations.
- Dev seed: small data for fast local development.
- Load/perf seed: larger data for performance and workflow testing.

Requirements:
- Idempotent seeding (safe to re-run).
- Deterministic “seed version” recorded in DB for traceability.
- Tenant + branch aware: seed can create N tenants and M branches each.

## Data Seeding Strategy
### Layer 1: Core reference data
Seed once per tenant:
- lead statuses, deal stages, activity types
- cold-calling reasons (22 principles)
- CRM pipeline defaults
- default roles + permissions baseline

### Layer 2: Sample operational data
Seed per tenant/branch:
- leads, contacts, properties, deals, activities
- tasks/action plans

### Layer 3: Integration fixtures
Optional:
- imported “scraped leads” with stable external IDs
- suburb reports/demographics snapshots

## Implementation Notes (Current Repo Artifacts)
There is already a demo generator script for CRM:
- [generate-test-data.ts](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/packages/plugins/@custom/real-estate-crm/scripts/generate-test-data.ts)

It generates:
- leads, contacts, properties, deals, action plans, tasks, call logs, follow-ups, suburbs, scraped leads

In a fresh start, keep this approach but enforce:
- tenant_id + branch_id on every inserted row
- external_id + source on all imported/scraped records

## Localization Requirements
Localization must cover:
- Language (UI strings + system messages)
- Currency formatting and symbol
- Date/time formatting and timezone
- Number formatting (thousands separators, decimals)
- Address formats by country/region

### Language strategy
- Per tenant default language (e.g., en-ZA).
- Per user override language.

Reference:
- Current plugin includes en-US locale JSON:
  - [en-US.json](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/packages/plugins/@custom/real-estate-crm/src/locale/en-US.json)

### “Types” to standardize across modules
Define stable enums/lookup tables rather than ad-hoc strings:
- LeadStatus: new/contacted/qualified/proposal/negotiation/won/lost
- DealStage: prospecting/qualification/proposal/negotiation/closed_won/closed_lost
- PropertyStatus: active/under_offer/sold/withdrawn/expired
- ActivityType: call/email/meeting/viewing/note/system
- Priority: low/medium/high
- ContactMethod: phone/email/whatsapp

Persist these as reference tables or enums with:
- key (stable)
- label (localized)
- sort
- active flag

## Tenant Defaults (Localization)
Per tenant store:
- default_locale (e.g., en-ZA)
- default_timezone (e.g., Africa/Johannesburg)
- currency_code (e.g., ZAR)
- date_format preference

Per branch store:
- branch_timezone override (optional)

## Seeding for “100 branches” provisioning
Provision flow per tenant:
1) Create tenant + branches.
2) Create roles and role bindings.
3) Seed reference tables (localized labels).
4) Seed demo data (optional toggle).
5) Register workflow templates and enable them.
6) Create vector ingestion jobs (optional toggle).

## Quality Gates
After seeding, automated checks must pass:
- Auth works for seeded admin user.
- CRM list endpoints return 200.
- No missing required reference data.
- UI strings for default locale present.
