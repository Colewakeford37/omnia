BEGIN;
UPDATE "desktopRoutes"
SET "parentId" = NULL,
    "updatedAt" = NOW()
WHERE "menuSchemaUid" = 'crm-menu-group';

UPDATE "desktopRoutes"
SET "parentId" = (
      SELECT id FROM "desktopRoutes" WHERE "menuSchemaUid" = 'crm-menu-group' LIMIT 1
    ),
    "updatedAt" = NOW()
WHERE "menuSchemaUid" LIKE 'crm-%'
  AND "menuSchemaUid" <> 'crm-menu-group';
COMMIT;
