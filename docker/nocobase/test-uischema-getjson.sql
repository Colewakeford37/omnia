BEGIN;
INSERT INTO "uiSchemas" ("x-uid", "name", "schema")
VALUES ('test-jsonschema-probe', 'test_jsonschema_probe', '{"probe":true,"x-uid":"test-jsonschema-probe","type":"void"}'::json)
ON CONFLICT ("x-uid")
DO UPDATE SET schema = EXCLUDED.schema, name = EXCLUDED.name;
COMMIT;
