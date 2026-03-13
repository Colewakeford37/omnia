SELECT
  COUNT(*) AS orphan_count
FROM "uiSchemaTreePath" p
LEFT JOIN "uiSchemas" s ON s."x-uid" = p."descendant"
WHERE s."x-uid" IS NULL;

SELECT
  p."ancestor",
  p."descendant",
  p."depth"
FROM "uiSchemaTreePath" p
LEFT JOIN "uiSchemas" s ON s."x-uid" = p."descendant"
WHERE s."x-uid" IS NULL
ORDER BY p."ancestor", p."depth"
LIMIT 100;
