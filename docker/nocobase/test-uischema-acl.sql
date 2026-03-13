BEGIN;
UPDATE "uiSchemas"
SET schema = '{
  "x-uid": "test-jsonschema-probe",
  "type": "void",
  "x-acl-action": "ui:*",
  "properties": {
    "hello": {
      "type": "void",
      "title": "Hello probe"
    }
  }
}'::json
WHERE "x-uid" = 'test-jsonschema-probe';
COMMIT;
