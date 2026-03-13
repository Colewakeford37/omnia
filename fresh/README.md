# Fresh Platform (Hybrid Option B)

## Intent
This folder is a clean “platform skeleton” for a hybrid architecture:
- NocoBase runs as the control plane (multi-data-source federation, RBAC, workflows, AI employees where available).
- A separate TypeScript web UI is the product experience (stable UX, no UI-schema fragility in production UI).
- A worker service handles ingestion, normalization, embeddings, and near-real-time indexing.

The long-term goal is plug-and-play modules: each module is versioned, installable, and verified by smoke tests.

## Services
### 1) Control plane: NocoBase
Responsibilities:
- Multi-database connections (Data Source Manager).
- RBAC and audit.
- Workflow execution and approvals.
- Stable APIs for data and actions.

### 2) Product UI: TypeScript app
Responsibilities:
- UX for CRM, Ticketing, Stock, Accounting/Payroll, etc.
- Chat-style interface that calls approved actions via APIs.
- Role-aware UI built on API contracts, not database/UI-schema writes.

### 3) Worker
Responsibilities:
- Ingestion (webhooks/outbox/CDC).
- Normalization to a tenant-scoped operational model.
- Embedding generation and vector index updates.
- Background workflows and scheduled jobs.

## Versioning (Pinned)
The platform must pin:
- NocoBase version (docker image tag).
- Node runtime for UI/worker.
- Database engine versions (Postgres + optional vector extension).

## Local Dev
Use the compose file:
- [docker-compose.yml](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/fresh/docker-compose.yml)

## Modules
Each module must define:
- Data model (collections/fields + migrations).
- API contract (actions, workflows).
- Seed packs (demo/dev/load).
- Localization keys and enums.
- Smoke checks.

See docs:
- [fresh-start-system-requirements.md](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/.trae/documents/fresh-start-system-requirements.md)
- [fresh-start-crm-requirements.md](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/.trae/documents/fresh-start-crm-requirements.md)
- [fresh-start-seeding-localization.md](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/.trae/documents/fresh-start-seeding-localization.md)
