BEGIN;
UPDATE "uiSchemas"
SET schema = jsonb_set(COALESCE(schema::jsonb, '{}'::jsonb), '{x-async}', 'true'::jsonb, true)::json
WHERE "x-uid" = 'crm-leads-menu';
COMMIT;
