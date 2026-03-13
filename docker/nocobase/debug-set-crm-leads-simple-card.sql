UPDATE "uiSchemas"
SET schema = '{
  "type": "void",
  "x-component": "Grid",
  "title": "Leads (DEBUG)",
  "properties": {
    "debug_card": {
      "type": "void",
      "x-component": "CardItem",
      "title": "DEBUG CARD: schema rendering works"
    }
  }
}'::json
WHERE "x-uid" IN ('crm_leads_menu', 'crm-leads-menu');
