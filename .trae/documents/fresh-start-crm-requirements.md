# Fresh Start: Real Estate CRM Requirements

## CRM Goal
Provide a module that supports a real-estate sales organization with multiple branches, agents, and integrations with listing sources. The CRM must be:
- API-driven (all operations available via API).
- Workflow-enabled (automation for follow-ups, notifications, approvals).
- Secure (tenant + branch isolation, strong RBAC).
- Extensible (new pipelines, new lead sources, and custom fields per tenant).

## Core Entities
### Leads
Minimum fields:
- Identity: first_name, last_name, full_name, email, phone, mobile
- Source: source, source_detail, external_id
- Status/pipeline: status, rating, assigned_to, last_contacted, next_follow_up
- Preferences: budget_min, budget_max, property_type, preferred_location, bedrooms_required, timeline
- Notes and attachments

### Contacts
Minimum fields:
- Identity & address: full_name, email, phone/mobile, address, city, suburb, province, postal_code, country
- Relationship: type (prospect/customer/vendor/partner), engagement_score
- Preferences: preferred_contact_method/time, do_not_call, do_not_email
- Important dates: birthday, anniversary

### Properties (Listings)
Minimum fields:
- Location: address, suburb, city, province, postal_code, country
- Listing details: property_type, listing_type, status, listing_date, mandate_type, mandate_expiry
- Pricing: price, price_display, negotiable
- Attributes: bedrooms, bathrooms, garage, parking, floor_area, land_size, year_built
- Owner: owner_name, owner_phone, owner_email
- Performance: inquiries_count, viewings_count

### Deals (Pipeline)
Minimum fields:
- stage, value, probability, expected_close_date, commission, assigned_to
- link to lead/contact/property as applicable

### Activities
Minimum fields:
- activity_type, subject, notes, start_date/end_date, related entity references

## Cold Calling / Engagement (“22 Working Principles”)
Represent as a reference table (reasons) with:
- name, category (personal/property/value_add/opportunity/service/follow_up)
- templates for suggested script and follow-up actions

## Enterprise Action Plans
Support structured plans:
- action_plans (name, description, status, owner, due dates)
- tasks (dependencies, status, assignees, checklists)
- checklist templates and checklist items

## Integrations & Data Sources
### Lead sources
- Property portals (e.g. Property24, Private Property)
- Social feeds/groups (e.g. Facebook groups)
- Website forms, inbound email
- Imported lists (CSV/Excel)

### Suburb/market data
- Demographics, sales history, sectional title data
- Market reports

Design requirements:
- Each source record must have an external identifier and a source key.
- All imports must be idempotent (re-running does not duplicate).

## Workflows (MVP)
Examples:
- New lead intake → assign agent → create follow-up task.
- Follow-up due → notify agent → escalate if overdue.
- Deal stage change → send internal notification → update forecast.
- Listing expired → create “revival” action plan.

## Permissions Model (RBAC)
Minimum roles:
- Tenant Admin: manage configs, users, all data in tenant.
- Branch Manager: manage branch users and branch data.
- Agent: read assigned leads/contacts/deals, create activities, update statuses.
- Auditor: read-only + export with audit trail.

Scope rules:
- Enforce tenant_id always.
- Enforce branch_id unless role is tenant-wide.

## UX Requirements (Module UI)
If using a dedicated TS web UI:
- “List + detail + actions” patterns for leads/contacts/properties/deals.
- Fast search + filters + saved views per role.
- Bulk operations (assign, tag, status update).
- Chat surface: “create lead”, “schedule follow-up”, “summarize lead”, “run workflow”.

## Success Criteria (MVP)
- Leads/Contacts/Properties/Deals list views render reliably.
- API endpoints stable and permissioned.
- Workflows can be triggered via API and via UI.
- Seeding creates realistic demo data for sales demos.
