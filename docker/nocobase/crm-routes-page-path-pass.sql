BEGIN;
UPDATE "desktopRoutes"
SET "options" = json_build_object('path', '/admin/' || "tabSchemaName"),
    "updatedAt" = NOW()
WHERE "menuSchemaUid" LIKE 'crm-%'
  AND "menuSchemaUid" <> 'crm-menu-group';
COMMIT;
