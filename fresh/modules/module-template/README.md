# Module Template

This is a minimal, versioned module template intended as the baseline for plug-and-play modules.

## Contract
- Data model lives in the plugin (collections/fields).
- Seeding is deterministic and idempotent at the module boundary.
- Localization keys live beside the module.
- A module must ship smoke checks that validate API access and permissions.

## Included
- Collection: `mod_records`
- Seed helper: [seed.ts](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/fresh/modules/module-template/scripts/seed.ts)
- Locale: [en-US.json](file:///c:/Users/colew/Documents/trae_projects/omnia/omnia/fresh/modules/module-template/src/locale/en-US.json)
