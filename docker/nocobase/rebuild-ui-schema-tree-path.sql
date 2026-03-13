BEGIN;
TRUNCATE TABLE "uiSchemaTreePath";

INSERT INTO "uiSchemaTreePath" ("ancestor", "descendant", "depth", "async", "type", "sort")
SELECT
  "x-uid" AS ancestor,
  "x-uid" AS descendant,
  0 AS depth,
  COALESCE((schema::jsonb ->> 'x-async')::boolean, FALSE) AS async,
  COALESCE(schema::jsonb ->> 'type', 'void') AS type,
  NULL::int AS sort
FROM "uiSchemas";

COMMIT;
