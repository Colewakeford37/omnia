BEGIN;
UPDATE "applicationPlugins"
SET enabled = FALSE,
    installed = FALSE,
    "updatedAt" = NOW()
WHERE "packageName" = 'plugin-real-estate-crm'
   OR name = 'plugin-real-estate-crm';
COMMIT;
