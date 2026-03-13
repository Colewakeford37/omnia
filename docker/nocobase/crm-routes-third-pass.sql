BEGIN;
UPDATE "desktopRoutes"
SET "type" = CASE
               WHEN "menuSchemaUid" = 'crm-menu-group' THEN 'group'
               ELSE 'page'
             END,
    "hideInMenu" = FALSE,
    "hidden" = FALSE,
    "updatedAt" = NOW()
WHERE "menuSchemaUid" LIKE 'crm-%'
   OR "menuSchemaUid" = 'crm-menu-group';
COMMIT;
