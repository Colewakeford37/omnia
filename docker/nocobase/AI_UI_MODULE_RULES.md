# AI UI Rules for NocoBase Module Planning and Delivery

## Purpose
This guide defines a repeatable AI-first process for planning and building NocoBase UI modules so future modules are predictable, testable, and production-safe.

Use this together with:
- `AI_SQL_MODULE_RULES.md` for data-layer and collection design
- this file for page UX, schema architecture, route wiring, and validation

## Outcomes This Guide Enforces
- Every module has explicit page goals, not just tables
- Route and schema IDs are planned before implementation
- UI schema trees are verifiable through API before release
- Permissions, performance, and failure recovery are planned up front

## Delivery Model
Every module should be delivered in four lanes:
1. **Data lane**: physical tables + collection metadata
2. **Navigation lane**: desktop routes, route hierarchy, permissions
3. **UI schema lane**: page schemas + schema tree graph
4. **Validation lane**: API checks + user workflow checks

No lane should be skipped.

## Canonical Planning Template
For each new module, produce this planning block first.

### 1) Module Definition
- Module name
- Business objective
- Primary roles
- Success events

### 2) Page Inventory
- Dashboard page
- List page(s)
- Details page(s)
- Create/Edit forms
- Supporting utility pages

### 3) Route Map
- Group route UID
- Child page route UIDs
- Parent-child structure
- Sidebar order
- Required path conventions

### 4) UI Blocks per Page
- Data source collection(s)
- Primary block type
- Expected key fields shown
- Required actions
- Empty-state behavior

### 5) Validation Matrix
- API endpoint checks
- UI render checks
- Role-based visibility checks
- Error-path checks

## Naming Conventions
Use stable, machine-friendly naming from day one.

### Route and Schema IDs
- Route menu UID: kebab-case for menus
- Tab/schema UID used by page loader: snake_case
- Keep deterministic mapping between route and schema

Recommended mapping:
- menu UID: `module-leads-menu`
- page/schema UID: `module_leads_menu`

### Collection Names
- snake_case with module prefix
- examples: `crm_leads`, `crm_properties`

### Component Node IDs
- root: `module_leads_menu`
- block: `module_leads_menu_block`
- table: `module_leads_menu_table`
- column: `module_leads_menu_col_1`

Do not use random IDs for core module pages unless strictly needed.

## UI Architecture Pattern
Use one clear baseline pattern for list pages.

### Standard List Page Tree
- Root page: `Grid`
- Data provider block: `DataBlockProvider`
- Visual container: `CardItem`
- Main data view: `TableV2`
- Child nodes: `TableV2.Column`

### Minimum Root Schema Contract
Root schema should always include:
- `type`
- `x-uid`
- `title`
- `x-component`
- `properties`

If root schema is missing or malformed, pages can render blank even with valid data.

## Route Architecture Pattern
For sidebar modules:
- one group route
- multiple child page routes
- child routes must point to valid schema IDs expected by admin page loader

### Route Integrity Checklist
- group route is `type=group`
- child routes are `type=page`
- child routes have valid parent relationship
- child routes are not hidden
- route paths resolve to valid admin page targets

## Permissions and Access Planning
Before UI rollout define:
- which roles can see module group
- which roles can open each page
- which roles can create/update/delete records

Minimum checks:
- role-route mapping exists for all module routes
- role can access page schema endpoint
- role can query required collections

## Action Endpoint Strategy
When using API actions for schema updates:
- prefer official schema actions first
- validate request/response per action
- inspect logs for repository-level failures
- maintain a fallback path if endpoint behavior is unstable

### Recommended Action Flow
1. `get` current schema
2. apply small patch via action endpoint
3. verify `getJsonSchema` output is non-empty
4. repeat for all module pages

### Endpoint Failure Protocol
If action endpoints return server errors:
- capture endpoint, payload shape, and error signature
- capture server stack evidence
- mark action path blocked for that environment/version
- switch to validated fallback (SQL/path rebuild/manual admin editor), then re-test

## Validation Protocol
Validation is mandatory and must include both API and UI.

### API Validation
- `desktopRoutes:listAccessible` returns full module tree
- `uiSchemas:getJsonSchema/{page_uid}` returns non-empty object
- collection metadata endpoint confirms key fields exist
- role checks confirm access mappings

### UI Validation
- sidebar group visible
- child pages visible
- opening page renders non-empty container
- table or primary component visible
- actions present where required

### Release Gate
A module is not done if any page returns empty schema payload or blank render.

## Blank Page Prevention Rules
Most blank page incidents in this stack come from one or more of:
- route points to wrong schema UID format
- schema root exists but tree graph is incomplete
- schema update action fails silently or throws internal error
- `x-uid` chain inconsistencies between root and descendants

Preventive controls:
- predefine UID map
- predefine full schema tree
- run API smoke checks per page
- include server log scan in rollout checklist

## AI Prompting Standard for New Modules
When asking AI to scaffold a new module, include:
- business domain and user roles
- required pages and actions
- expected route tree
- collection list and key fields
- default filters and statuses
- acceptance tests

### Example Prompt Structure
- Goal
- Entities
- Pages
- Route tree
- UI blocks per page
- Validation requirements
- Performance constraints
- Security constraints

## Performance Planning
Plan for scale early:
- define default pagination
- define sorting defaults
- avoid loading excessive fields in first paint
- define filtered indexes for top query paths

For high-volume modules:
- use concise list views first
- defer heavy details to drill-down pages

## Security and Compliance Planning
For regulated modules:
- classify sensitive fields
- define read-only fields at UI level
- define audit expectations
- ensure role checks are part of acceptance criteria

Never expose secrets in schema configs, logs, or example payloads.

## Migration and Change Management
For module evolution:
- version route/schema contracts
- avoid destructive UID renames after production adoption
- add compatibility mapping for legacy routes when needed

If renaming is unavoidable:
- migrate route references and schema references in one release window
- validate all old deep links

## Pre-Deployment Checklist
- data lane complete
- navigation lane complete
- schema lane complete
- role mapping complete
- API smoke tests pass
- UI smoke tests pass
- rollback plan prepared

## Post-Deployment Checklist
- verify page open success on real roles
- verify no server errors for schema endpoints
- verify no blank pages
- verify action buttons and forms behave as expected
- capture baseline metrics for load and error rate

## Rollback Strategy
Keep rollback artifacts ready:
- route rollback SQL
- schema rollback SQL
- permission rollback SQL
- endpoint-based rollback script if available

Rollback trigger examples:
- repeated schema endpoint 500 errors
- page schema resolves empty for critical pages
- major role visibility regressions

## Standard Module Handoff Artifacts
Every completed module should include:
- module requirements file
- route map file
- UI schema map file
- verification log output
- known limitations and future enhancements

## AI-Assisted Build Sequence
Recommended sequence for reliable outcomes:
1. Plan routes and page UID map
2. Plan data collections and fields
3. Create route records and role mappings
4. Create root page schemas and schema tree
5. Add table/form/action child nodes
6. Validate `getJsonSchema` for every page
7. Validate UI rendering for every page
8. Package verification artifacts

## Non-Negotiable Guardrails
- Do not ship module pages that return empty schema payloads
- Do not rely on sidebar visibility as proof page rendering works
- Do not skip API-level validation when UI appears partially correct
- Do not introduce UID format drift between route and schema references

## Quick Build Checklist for Future Modules
- Define UIDs (group, child routes, page schemas)
- Define collections and key fields
- Define page-level blocks
- Wire routes to page schema IDs
- Build schema tree and descendants
- Validate API schema responses
- Validate page rendering
- Validate permissions
- Publish with rollback assets

This file is the UI execution contract for AI-assisted module delivery in this repository.
