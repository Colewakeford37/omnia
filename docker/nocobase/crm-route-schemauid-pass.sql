BEGIN;
UPDATE "desktopRoutes"
SET "schemaUid" = "tabSchemaName",
    "updatedAt" = NOW()
WHERE "menuSchemaUid" LIKE 'crm-%'
   OR "menuSchemaUid" = 'crm-menu-group';
COMMIT;
