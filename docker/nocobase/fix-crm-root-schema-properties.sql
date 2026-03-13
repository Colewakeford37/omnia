WITH page_routes AS (
  SELECT DISTINCT "menuSchemaUid" AS uid
  FROM "desktopRoutes"
  WHERE type = 'page'
    AND "menuSchemaUid" LIKE 'crm-%'
),
first_children AS (
  SELECT DISTINCT ON (p.ancestor)
    p.ancestor,
    p.descendant
  FROM "uiSchemaTreePath" p
  JOIN page_routes r ON r.uid = p.ancestor
  WHERE p.depth = 1
  ORDER BY p.ancestor, p.sort NULLS LAST, p.descendant
)
UPDATE "uiSchemas" u
SET schema = jsonb_set(
  jsonb_set(
    COALESCE(u.schema::jsonb, '{}'::jsonb),
    '{properties}',
    jsonb_build_object(fc.descendant, jsonb_build_object('x-uid', fc.descendant)),
    true
  ),
  '{x-async}',
  'true'::jsonb,
  true
)
FROM first_children fc
WHERE u."x-uid" = fc.ancestor;
