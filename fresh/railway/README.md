# Railway Deployment Scaffolding (Hybrid Platform)

## Target Topology
- Service: nocobase-core
- Service: web-ui
- Service: worker
- Service: postgres (with pgvector capability)
- Optional: redis

## Pinned Versions
Do not deploy `latest` images in production.
- Pin NocoBase image tag.
- Pin Postgres major version.
- Pin Node major version for worker/web-ui.

## Required Variables (nocobase-core)
- APP_KEY
- DB_DIALECT=postgres
- DB_HOST
- DB_PORT
- DB_DATABASE
- DB_USER
- DB_PASSWORD
- API_BASE_PATH=/api/
- INIT_ROOT_USERNAME
- INIT_ROOT_PASSWORD
- INIT_LANG

## Branch/Tenant Provisioning
Provisioning should be driven by an API-first “provisioner” job that:
1) Creates tenant and branches.
2) Applies baseline RBAC.
3) Installs/updates required modules with pinned module versions.
4) Seeds reference data (localized labels) and optional demo data.
5) Creates ingestion jobs and connects external sources.

## Importer Requirements (Idempotent)
All imports must include:
- source_key
- external_id
- tenant_id
- branch_id

And must enforce:
- deterministic upserts (no duplicates)
- replay-safe processing (idempotency keys)

## Suggested Railway Template Layout
Store template assets and environment variable manifests in this directory.
This repository currently provides the local compose as the canonical “contract” and mirrors it in Railway services.
