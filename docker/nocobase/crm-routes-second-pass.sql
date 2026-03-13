BEGIN;
UPDATE "desktopRoutes"
SET "parentId" = NULL,
    "type" = 'menu',
    "hideInMenu" = FALSE,
    "hidden" = FALSE,
    "enableHeader" = TRUE,
    "displayTitle" = TRUE,
    "updatedAt" = NOW()
WHERE "menuSchemaUid" = 'crm-menu-group';

UPDATE "desktopRoutes"
SET "parentId" = NULL,
    "type" = 'menu',
    "options" = json_build_object('path', '/admin/' || replace("menuSchemaUid", '-', '/')),
    "hideInMenu" = FALSE,
    "hidden" = FALSE,
    "enableHeader" = TRUE,
    "displayTitle" = TRUE,
    "updatedAt" = NOW()
WHERE "menuSchemaUid" LIKE 'crm-%'
  AND "menuSchemaUid" <> 'crm-menu-group';
COMMIT;
