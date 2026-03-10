# AI SQL Rules for NocoBase Module Creation

## Overview
This document provides comprehensive rules and patterns for creating new modules in NocoBase using direct SQL database operations (Method 2). This approach works with all NocoBase versions including Community Edition.

## Core Principles

### 1. Database-First Approach
- Create tables first, then register in NocoBase metadata
- Use proper PostgreSQL conventions
- Maintain referential integrity through application logic
- Follow NocoBase naming conventions

### 2. NocoBase Integration Pattern
Every module requires three components:
1. **Physical Tables** - Actual PostgreSQL tables
2. **Collection Registration** - Entries in `collections` table
3. **Field Definitions** - Entries in `fields` table
4. **UI Schemas** - Menu structure in `uiSchemas` table

## Standard Module Creation Pattern

### Step 1: Create Physical Table
```sql
CREATE TABLE IF NOT EXISTS "module_name" (
  "id" BIGSERIAL PRIMARY KEY,
  "field1" VARCHAR(255),
  "field2" TEXT,
  "field3" INTEGER,
  "status" VARCHAR(50) DEFAULT 'active',
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Step 2: Register Collection
```sql
INSERT INTO "collections" ("name", "title", "inherits", "model", "filterTargetKey", "createdAt", "updatedAt") 
VALUES ('module_name', 'Module Title', NULL, 'Model', 'id', NOW(), NOW());
```

### Step 3: Define Fields
```sql
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('module_name', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('module_name', 'field1', 'string', 'input', '{"title":"Field 1","type":"string","x-component":"Input"}', NOW(), NOW()),
('module_name', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"active","label":"Active"},{"value":"inactive","label":"Inactive"}]}', NOW(), NOW()),
('module_name', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('module_name', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());
```

### Step 4: Create Menu Structure
```sql
INSERT INTO "uiSchemas" ("name", "uiSchema", "xUid", "createdAt", "updatedAt") VALUES
-- Main Menu Group
('module_menu_group', '{
  "type": "void",
  "title": "Module Name",
  "name": "module",
  "icon": "AppstoreOutlined",
  "x-designer": {"placement": "sidebar"},
  "x-uid": "module-menu-group",
  "x-async": false,
  "x-index": 10
}', 'module-menu-group', NOW(), NOW()),

-- Sub Menu Item
('module_list', '{
  "type": "void",
  "title": "Module List",
  "name": "module_list",
  "icon": "UnorderedListOutlined",
  "x-uid": "module-list",
  "x-async": false,
  "x-index": 1,
  "parent": "module-menu-group"
}', 'module-list', NOW(), NOW());
```

## Field Type Mapping Guide

### String Fields
```sql
-- Basic string
('collection', 'field_name', 'string', 'input', '{"title":"Field Name","type":"string","x-component":"Input"}', NOW(), NOW())

-- Email
('collection', 'email', 'string', 'email', '{"title":"Email","type":"string","x-component":"Input","x-validator":"email"}', NOW(), NOW())

-- Phone
('collection', 'phone', 'string', 'phone', '{"title":"Phone","type":"string","x-component":"Input"}', NOW(), NOW())

-- Select dropdown
('collection', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"active","label":"Active"},{"value":"inactive","label":"Inactive"}]}', NOW(), NOW())

-- Textarea
('collection', 'description', 'text', 'textarea', '{"title":"Description","type":"string","x-component":"Input.TextArea"}', NOW(), NOW())
```

### Number Fields
```sql
-- Integer
('collection', 'quantity', 'integer', 'integer', '{"title":"Quantity","type":"number","x-component":"InputNumber"}', NOW(), NOW())

-- Decimal
('collection', 'price', 'decimal', 'number', '{"title":"Price","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW())

-- BigInt (for IDs)
('collection', 'related_id', 'bigInt', 'integer', '{"title":"Related ID","type":"number","x-component":"InputNumber"}', NOW(), NOW())
```

### Date Fields
```sql
-- Date only
('collection', 'due_date', 'date', 'date', '{"title":"Due Date","type":"string","x-component":"DatePicker"}', NOW(), NOW())

-- DateTime
('collection', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW())
```

## Advanced Patterns

### 1. South African Specific Fields
```sql
-- RSA ID with validation
('crm_leads', 'rsa_id', 'string', 'input', '{"title":"RSA ID Number","type":"string","x-component":"Input","pattern":"^[0-9]{13}$"}', NOW(), NOW())

-- Province selection
('crm_properties', 'province', 'string', 'select', '{"title":"Province","type":"string","x-component":"Select","enum":[{"value":"EC","label":"Eastern Cape"},{"value":"GP","label":"Gauteng"},{"value":"WC","label":"Western Cape"}]}', NOW(), NOW())

-- FICA Status
('crm_contacts', 'fica_status', 'string', 'select', '{"title":"FICA Status","type":"string","x-component":"Select","enum":[{"value":"pending","label":"Pending"},{"value":"verified","label":"Verified"},{"value":"rejected","label":"Rejected"}]}', NOW(), NOW())
```

### 2. File Upload Fields
```sql
-- Document storage
('crm_fica_documents', 'file_name', 'string', 'input', '{"title":"File Name","type":"string","x-component":"Input","x-read-pretty":true}', NOW(), NOW())
('crm_fica_documents', 'file_path', 'string', 'input', '{"title":"File Path","type":"string","x-component":"Input","x-read-pretty":true}', NOW(), NOW())
('crm_fica_documents', 'file_size', 'bigInt', 'integer', '{"title":"File Size","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW())
('crm_fica_documents', 'mime_type', 'string', 'input', '{"title":"MIME Type","type":"string","x-component":"Input","x-read-pretty":true}', NOW(), NOW())
```

### 3. Relationship Fields
```sql
-- Foreign key references (logical, not physical)
('crm_deals', 'lead_id', 'bigInt', 'integer', '{"title":"Lead","type":"number","x-component":"InputNumber"}', NOW(), NOW())
('crm_deals', 'contact_id', 'bigInt', 'integer', '{"title":"Contact","type":"number","x-component":"InputNumber"}', NOW(), NOW())
('crm_deals', 'property_id', 'bigInt', 'integer', '{"title":"Property","type":"number","x-component":"InputNumber"}', NOW(), NOW())
```

## Menu Icon Reference

### Common Icons for CRM Modules
- `UserOutlined` - Leads, Contacts, Customers
- `TeamOutlined` - Contacts, Teams
- `HomeOutlined` - Properties, Real Estate
- `DollarOutlined` - Deals, Sales, Finance
- `ShopOutlined` - CRM, Business
- `DashboardOutlined` - Dashboard, Analytics
- `EnvironmentOutlined` - Locations, Suburbs
- `SafetyOutlined` - Compliance, FICA
- `FileTextOutlined` - Documents, Files
- `CalendarOutlined` - Appointments, Events
- `PhoneOutlined` - Calls, Communications
- `MailOutlined` - Emails, Messages

## Permission Management

### Basic Permissions
```sql
-- Grant full access to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;

-- Grant read access to anonymous users
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
```

### Collection-Specific Permissions
```sql
-- Grant permissions for specific collections
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE module_name TO authenticated;
GRANT SELECT ON TABLE module_name TO anon;
```

## Performance Optimization

### Index Creation
```sql
-- Status fields (frequently filtered)
CREATE INDEX idx_module_status ON module_name(status);

-- Email fields (unique identifiers)
CREATE INDEX idx_module_email ON module_name(email);

-- Date fields (frequently sorted)
CREATE INDEX idx_module_created_at ON module_name(created_at);

-- Foreign key fields
CREATE INDEX idx_module_related_id ON module_name(related_id);
```

### Auto-update Triggers
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_module_updated_at BEFORE UPDATE ON module_name FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Validation Patterns

### Email Validation
```sql
'{"title":"Email","type":"string","x-component":"Input","x-validator":"email"}'
```

### Phone Number Validation
```sql
'{"title":"Phone","type":"string","x-component":"Input","pattern":"^[0-9]{10,15}$"}'
```

### RSA ID Validation
```sql
'{"title":"RSA ID","type":"string","x-component":"Input","pattern":"^[0-9]{13}$"}'
```

### Required Fields
```sql
'{"title":"Required Field","type":"string","x-component":"Input","required":true}'
```

## Complete Module Example: Inventory Management

```sql
-- 1. Create table
CREATE TABLE IF NOT EXISTS "inventory_items" (
  "id" BIGSERIAL PRIMARY KEY,
  "sku" VARCHAR(100) UNIQUE,
  "name" VARCHAR(255),
  "description" TEXT,
  "category" VARCHAR(100),
  "quantity" INTEGER DEFAULT 0,
  "unit_price" DECIMAL(10,2),
  "supplier" VARCHAR(255),
  "location" VARCHAR(100),
  "min_quantity" INTEGER DEFAULT 0,
  "status" VARCHAR(50) DEFAULT 'active',
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Register collection
INSERT INTO "collections" ("name", "title", "inherits", "model", "filterTargetKey", "createdAt", "updatedAt") 
VALUES ('inventory_items', 'Inventory Items', NULL, 'Model', 'id', NOW(), NOW());

-- 3. Define fields
INSERT INTO "fields" ("collectionName", "name", "type", "interface", "uiSchema", "createdAt", "updatedAt") VALUES
('inventory_items', 'id', 'bigInt', 'integer', '{"title":"ID","type":"number","x-component":"InputNumber","x-read-pretty":true}', NOW(), NOW()),
('inventory_items', 'sku', 'string', 'input', '{"title":"SKU","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('inventory_items', 'name', 'string', 'input', '{"title":"Item Name","type":"string","x-component":"Input","required":true}', NOW(), NOW()),
('inventory_items', 'description', 'text', 'textarea', '{"title":"Description","type":"string","x-component":"Input.TextArea"}', NOW(), NOW()),
('inventory_items', 'category', 'string', 'select', '{"title":"Category","type":"string","x-component":"Select","enum":[{"value":"electronics","label":"Electronics"},{"value":"furniture","label":"Furniture"},{"value":"supplies","label":"Supplies"}]}', NOW(), NOW()),
('inventory_items', 'quantity', 'integer', 'integer', '{"title":"Quantity","type":"number","x-component":"InputNumber"}', NOW(), NOW()),
('inventory_items', 'unit_price', 'decimal', 'number', '{"title":"Unit Price","type":"number","x-component":"InputNumber","x-precision":2}', NOW(), NOW()),
('inventory_items', 'status', 'string', 'select', '{"title":"Status","type":"string","x-component":"Select","enum":[{"value":"active","label":"Active"},{"value":"discontinued","label":"Discontinued"},{"value":"out_of_stock","label":"Out of Stock"}]}', NOW(), NOW()),
('inventory_items', 'created_at', 'date', 'datetime', '{"title":"Created At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW()),
('inventory_items', 'updated_at', 'date', 'datetime', '{"title":"Updated At","type":"string","x-component":"DatePicker","x-read-pretty":true}', NOW(), NOW());

-- 4. Create menu
INSERT INTO "uiSchemas" ("name", "uiSchema", "xUid", "createdAt", "updatedAt") VALUES
('inventory_menu', '{
  "type": "void",
  "title": "Inventory Management",
  "name": "inventory",
  "icon": "InboxOutlined",
  "x-designer": {"placement": "sidebar"},
  "x-uid": "inventory-menu",
  "x-async": false,
  "x-index": 15
}', 'inventory-menu', NOW(), NOW()),

('inventory_items', '{
  "type": "void",
  "title": "Items",
  "name": "inventory_items",
  "icon": "UnorderedListOutlined",
  "x-uid": "inventory-items",
  "x-async": false,
  "x-index": 1,
  "parent": "inventory-menu"
}', 'inventory-items', NOW(), NOW());

-- 5. Permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON inventory_items TO authenticated;
GRANT SELECT ON inventory_items TO anon;

-- 6. Indexes
CREATE INDEX idx_inventory_sku ON inventory_items(sku);
CREATE INDEX idx_inventory_category ON inventory_items(category);
CREATE INDEX idx_inventory_status ON inventory_items(status);
CREATE INDEX idx_inventory_quantity ON inventory_items(quantity);

-- 7. Auto-update trigger
CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Testing Your Module

### 1. Verify Table Creation
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'your_module';
```

### 2. Check Collection Registration
```sql
SELECT * FROM collections WHERE name = 'your_module';
```

### 3. Validate Field Definitions
```sql
SELECT * FROM fields WHERE "collectionName" = 'your_module' ORDER BY name;
```

### 4. Test Menu Integration
```sql
SELECT * FROM uiSchemas WHERE name LIKE '%your_module%';
```

### 5. Verify Permissions
```sql
SELECT grantee, table_name, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_schema = 'public' AND table_name = 'your_module' 
AND grantee IN ('anon', 'authenticated');
```

## Common Issues and Solutions

### Issue: Collection not appearing in Data Source Manager
**Solution**: Ensure collection is registered in `collections` table with correct naming convention.

### Issue: Fields not showing correct interface
**Solution**: Check `uiSchema` JSON format and `interface` type mapping.

### Issue: Menu items not appearing in sidebar
**Solution**: Verify `uiSchemas` entries have correct parent-child relationships and proper `x-uid` values.

### Issue: Permission denied errors
**Solution**: Grant appropriate permissions to `authenticated` and `anon` roles.

### Issue: Auto-update not working
**Solution**: Ensure trigger function exists and is properly attached to table.

## Best Practices

1. **Naming Conventions**
   - Use snake_case for table names: `crm_leads`, not `CrmLeads`
   - Use consistent prefixes: `crm_`, `inventory_`, `project_`
   - Keep names descriptive but concise

2. **Field Design**
   - Always include `id`, `created_at`, `updated_at`
   - Use appropriate data types (BIGSERIAL for IDs, DECIMAL for money)
   - Add sensible defaults where applicable

3. **Performance**
   - Create indexes on frequently filtered fields
   - Use triggers for automatic timestamp updates
   - Consider partitioning for large datasets

4. **Security**
   - Grant minimal necessary permissions
   - Use RLS (Row Level Security) for multi-tenant apps
   - Validate inputs at database level when possible

5. **Maintainability**
   - Document complex business logic
   - Use consistent patterns across modules
   - Version your SQL scripts

This guide provides the foundation for creating any type of module in NocoBase using direct SQL operations. Follow these patterns and adapt them to your specific requirements.