# Fresh Start: System Requirements & Scaling

## Product Goal
Build a multi-tenant, API-first business platform that aggregates many data sources, exposes all data via APIs, and supports:
- Fast creation of domain modules (CRM, Ticketing, Stock, Accounting, Payroll, etc.).
- Workflow automation and “agent” style assistants that can read data, propose actions, and execute approved actions.
- Strong RBAC, auditability, and security controls suitable for multi-branch operations.
- A modern, sleek web UI plus chat-based command surface.

This fresh start assumes a hybrid approach:
- NocoBase is the control plane (data source federation, workflow/orchestration, governance, RBAC).
- A dedicated TypeScript web app is the product UI (stable UX, reusable design system, no UI-schema fragility in production UI).

## Core Non-Functional Requirements
### Availability & Operations
- Zero-downtime deployments where possible (blue/green or rolling).
- Deterministic startup (no infinite “wait for DB” loops).
- Observability baseline: structured logs, request IDs, slow query logging, and error alerts.
- Automated smoke checks per module after deployment.

### Security
- Least-privilege RBAC by default with scoped permissions per tenant + per branch.
- Audit log for all write operations, workflow executions, and agent actions.
- Secrets never stored in UI schema or client code; all secrets in environment/secret store.
- Field-level encryption for sensitive PII where required.

### Data & API
- API-first: every entity and workflow action is accessible via an API contract.
- Backwards-compatible API versioning for module endpoints.
- Explicit schema evolution policy for fields/collections (migrations, compatibility notes).

## Data Aggregation Requirements
### Source Types
- Operational databases (Postgres/MySQL/MariaDB).
- External SaaS APIs (e.g. real estate listing feeds, email providers, accounting services).
- File stores (documents, images).
- Event streams (webhooks/CDC/outbox).

### Patterns
Use two layers:
1) Federated access (NocoBase data sources):
   - Read and write to source-of-truth systems where appropriate.
2) Materialized “AI/analytics” store:
   - A normalized, tenant-scoped database and/or search index for cross-source queries.
   - Optional vector index for RAG and agent context.

## “Real-time” Strategy (Practical)
Choose one:
- Outbox pattern per source (recommended for early stage): each source writes changes to an outbox table, a worker processes and updates central indexes.
- CDC pipeline (Debezium + stream) for near-real-time at higher scale.

Design invariants:
- Idempotent ingestion (replay-safe).
- Per-tenant routing keys.
- Deterministic upserts with stable external IDs.

## AI & Workflows Requirements
### AI/Vector Store
- Start with pgvector in the main Postgres if scale is moderate.
- Move to a dedicated vector DB (Qdrant/Weaviate/Milvus/Pinecone) when:
  - you need hybrid search/reranking at scale,
  - high-dimensional embeddings across many tenants,
  - specialized filtering and low-latency retrieval.

### Workflows
- All workflow triggers must be auditable and replayable.
- Agents can propose actions; execution requires policy-based approval (role-based).
- Workflow actions should be stable APIs, not UI schema mutations.

## Multi-tenancy & “100 branches”
### Tenant Model
- Tenant: company.
- Branch: operational unit under a tenant.

Isolation options:
- Single database with tenant_id + branch_id on every row (fastest to start).
- Separate schema or separate database per tenant at higher security/compliance requirements.

Branch provisioning must be automatic:
- Create tenant + branches.
- Provision roles/permissions baseline.
- Initialize module configs (CRM pipeline stages, default views).
- Trigger initial data import jobs.

## Module Packaging Standard
Every module must be:
- Versioned.
- Installable via one deterministic “install” procedure (migrations + permissions + templates).
- Testable via an automated smoke check.
- Upgradeable with explicit migration steps.

## Railway Deployment Requirements
- Use Railway templates for repeatable provisioning (app + DB + optional worker).
- Separate services:
  - web-ui (TypeScript app)
  - nocobase-core (control plane)
  - worker (ingestion + embeddings + automation)
  - postgres (main)
  - optional redis/queue

## Scaling Roadmap (Future-Proofing)
Phase 1:
- Single region, single Postgres, outbox worker, pgvector.
Phase 2:
- Queue-based ingestion, separate worker service, background jobs, caching.
Phase 3:
- CDC streaming, dedicated vector DB, multi-region read replicas for UI.
Phase 4:
- Tenant sharding, per-tenant isolation, compliance tooling, advanced rate limiting.
