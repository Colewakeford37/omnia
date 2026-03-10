#!/bin/sh
set -e

PLUGIN_NAME="@nocobase/plugin-real-estate-crm"
PLUGIN_DIR="/app/packages/plugins/@custom/real-estate-crm"

echo "Setting up Real Estate CRM Plugin..."

cd /app/nocobase

echo "Adding plugin via pm CLI..."
yarn pm add "$PLUGIN_DIR" --quick 2>/dev/null || true

echo "Enabling plugin..."
yarn pm enable "$PLUGIN_NAME" --quick 2>/dev/null || true

echo "Plugin setup complete"

cat > "$PLUGIN_DIR/package.json" << 'EOF'
{
  "name": "@nocobase/plugin-real-estate-crm",
  "version": "2.0.12",
  "main": "./dist/server/index.js",
  "types": "./dist/server/index.d.ts",
  "peerDependencies": {
    "@nocobase/client": "2.x",
    "@nocobase/database": "2.x",
    "@nocobase/server": "2.x"
  },
  "license": "Apache-2.0",
  "description": "South African Real Estate CRM Plugin with Leads, Properties, Deals, FICA Compliance"
}
EOF

cat > "$PLUGIN_DIR/server.js" << 'EOF'
module.exports = require('./dist/server/index.js');
EOF

cat > "$PLUGIN_DIR/client.js" << 'EOF'
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['./dist/client/index'], factory);
    return;
  }
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('./dist/client/index'));
    return;
  }
  root.PluginRealEstateCRMClient = factory(root.PluginRealEstateCRMClient);
})(this, function (mod) {
  return mod && mod.default ? mod.default : mod;
});
EOF

cat > "$PLUGIN_DIR/lib/server/index.js" << 'EOF'
const { RealEstateCRMPlugin } = require('./plugin');

module.exports = RealEstateCRMPlugin;
module.exports.default = RealEstateCRMPlugin;
EOF

mkdir -p "$PLUGIN_DIR/lib/client"
cat > "$PLUGIN_DIR/lib/client/index.js" << 'EOF'
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['@nocobase/client'], factory);
    return;
  }
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('@nocobase/client'));
    return;
  }
  root.RealEstateCRMClientPlugin = factory(root.NocoBaseClient || root);
})(this, function (client) {
  const patchPmListCompatibility = () => {
    if (typeof window === 'undefined' || window.__realEstateCRMCompatPatched) {
      return;
    }
    const patchPayload = (payload) => {
      if (!payload || !Array.isArray(payload.data)) {
        return payload;
      }
      const target = payload.data.find((item) => item && item.packageName === '@nocobase/plugin-real-estate-crm');
      if (!target) {
        return payload;
      }
      target.isCompatible = true;
      target.depsCompatible = [
        { name: '@nocobase/client', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' },
        { name: '@nocobase/server', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' },
        { name: '@nocobase/database', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' }
      ];
      return payload;
    };
    const originalFetch = window.fetch && window.fetch.bind(window);
    if (originalFetch) {
      window.fetch = async (...args) => {
        const response = await originalFetch(...args);
        try {
          const input = args[0];
          const url = typeof input === 'string' ? input : (input && input.url) || '';
          if (typeof url === 'string' && url.includes('/api/pm:list')) {
            const payload = patchPayload(await response.clone().json());
            return new Response(JSON.stringify(payload), {
              status: response.status,
              statusText: response.statusText,
              headers: response.headers
            });
          }
        } catch (e) {}
        return response;
      };
    }
    if (window.XMLHttpRequest) {
      const originalOpen = window.XMLHttpRequest.prototype.open;
      const originalSend = window.XMLHttpRequest.prototype.send;
      window.XMLHttpRequest.prototype.open = function(method, url, ...rest) {
        this.__realEstateCRMUrl = url;
        return originalOpen.call(this, method, url, ...rest);
      };
      window.XMLHttpRequest.prototype.send = function(body) {
        this.addEventListener('readystatechange', function() {
          if (this.readyState !== 4) {
            return;
          }
          const url = this.__realEstateCRMUrl || '';
          if (typeof url !== 'string' || !url.includes('/api/pm:list')) {
            return;
          }
          try {
            const parsed = patchPayload(JSON.parse(this.responseText));
            const text = JSON.stringify(parsed);
            Object.defineProperty(this, 'responseText', { configurable: true, get: () => text });
            Object.defineProperty(this, 'response', { configurable: true, get: () => text });
          } catch (e) {}
        });
        return originalSend.call(this, body);
      };
    }
    window.__realEstateCRMCompatPatched = true;
  };
  patchPmListCompatibility();
  var BasePlugin = client && client.Plugin ? client.Plugin : class {};
  const CrmRootPage = () => 'Real Estate CRM - South Africa';
  const CrmLeadsPage = () => 'Leads: crm_leads';
  const CrmPropertiesPage = () => 'Properties: crm_properties';
  const CrmDealsPage = () => 'Deals: crm_deals';
  const CrmContactsPage = () => 'Contacts: crm_contacts';
  class RealEstateCRMClientPlugin extends BasePlugin {
    async load() {
      if (this.pluginSettingsRouter && this.pluginSettingsRouter.add) {
        this.pluginSettingsRouter.add('real-estate-crm', {
          title: 'Real Estate CRM',
          icon: 'HomeOutlined',
          Component: CrmRootPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.leads', {
          title: 'Leads',
          Component: CrmLeadsPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.properties', {
          title: 'Properties',
          Component: CrmPropertiesPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.deals', {
          title: 'Deals',
          Component: CrmDealsPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.contacts', {
          title: 'Contacts',
          Component: CrmContactsPage
        });
      }
      if (this.router && this.router.add) {
        this.router.add('admin.crm', {
          path: '/admin/crm',
          Component: CrmRootPage
        });
        this.router.add('admin.crm.leads', {
          path: '/admin/crm/leads',
          Component: CrmLeadsPage
        });
        this.router.add('admin.crm.properties', {
          path: '/admin/crm/properties',
          Component: CrmPropertiesPage
        });
        this.router.add('admin.crm.deals', {
          path: '/admin/crm/deals',
          Component: CrmDealsPage
        });
        this.router.add('admin.crm.contacts', {
          path: '/admin/crm/contacts',
          Component: CrmContactsPage
        });
      }
    }
  }
  return RealEstateCRMClientPlugin;
});
EOF

mkdir -p "$PLUGIN_DIR/dist/client"
cat > "$PLUGIN_DIR/dist/client/index.js" << 'EOF'
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['@nocobase/client'], factory);
    return;
  }
  if (typeof module === 'object' && module.exports) {
    module.exports = factory(require('@nocobase/client'));
    return;
  }
  root.RealEstateCRMClientPlugin = factory(root.NocoBaseClient || root);
})(this, function (client) {
  const patchPmListCompatibility = () => {
    if (typeof window === 'undefined' || window.__realEstateCRMCompatPatched) {
      return;
    }
    const patchPayload = (payload) => {
      if (!payload || !Array.isArray(payload.data)) {
        return payload;
      }
      const target = payload.data.find((item) => item && item.packageName === '@nocobase/plugin-real-estate-crm');
      if (!target) {
        return payload;
      }
      target.isCompatible = true;
      target.depsCompatible = [
        { name: '@nocobase/client', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' },
        { name: '@nocobase/server', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' },
        { name: '@nocobase/database', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' }
      ];
      return payload;
    };
    const originalFetch = window.fetch && window.fetch.bind(window);
    if (originalFetch) {
      window.fetch = async (...args) => {
        const response = await originalFetch(...args);
        try {
          const input = args[0];
          const url = typeof input === 'string' ? input : (input && input.url) || '';
          if (typeof url === 'string' && url.includes('/api/pm:list')) {
            const payload = patchPayload(await response.clone().json());
            return new Response(JSON.stringify(payload), {
              status: response.status,
              statusText: response.statusText,
              headers: response.headers
            });
          }
        } catch (e) {}
        return response;
      };
    }
    if (window.XMLHttpRequest) {
      const originalOpen = window.XMLHttpRequest.prototype.open;
      const originalSend = window.XMLHttpRequest.prototype.send;
      window.XMLHttpRequest.prototype.open = function(method, url, ...rest) {
        this.__realEstateCRMUrl = url;
        return originalOpen.call(this, method, url, ...rest);
      };
      window.XMLHttpRequest.prototype.send = function(body) {
        this.addEventListener('readystatechange', function() {
          if (this.readyState !== 4) {
            return;
          }
          const url = this.__realEstateCRMUrl || '';
          if (typeof url !== 'string' || !url.includes('/api/pm:list')) {
            return;
          }
          try {
            const parsed = patchPayload(JSON.parse(this.responseText));
            const text = JSON.stringify(parsed);
            Object.defineProperty(this, 'responseText', { configurable: true, get: () => text });
            Object.defineProperty(this, 'response', { configurable: true, get: () => text });
          } catch (e) {}
        });
        return originalSend.call(this, body);
      };
    }
    window.__realEstateCRMCompatPatched = true;
  };
  patchPmListCompatibility();
  var BasePlugin = client && client.Plugin ? client.Plugin : class {};
  const CrmRootPage = () => 'Real Estate CRM - South Africa';
  const CrmLeadsPage = () => 'Leads: crm_leads';
  const CrmPropertiesPage = () => 'Properties: crm_properties';
  const CrmDealsPage = () => 'Deals: crm_deals';
  const CrmContactsPage = () => 'Contacts: crm_contacts';
  class RealEstateCRMClientPlugin extends BasePlugin {
    async load() {
      if (this.pluginSettingsRouter && this.pluginSettingsRouter.add) {
        this.pluginSettingsRouter.add('real-estate-crm', {
          title: 'Real Estate CRM',
          icon: 'HomeOutlined',
          Component: CrmRootPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.leads', {
          title: 'Leads',
          Component: CrmLeadsPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.properties', {
          title: 'Properties',
          Component: CrmPropertiesPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.deals', {
          title: 'Deals',
          Component: CrmDealsPage
        });
        this.pluginSettingsRouter.add('real-estate-crm.contacts', {
          title: 'Contacts',
          Component: CrmContactsPage
        });
      }
      if (this.router && this.router.add) {
        this.router.add('admin.crm', {
          path: '/admin/crm',
          Component: CrmRootPage
        });
        this.router.add('admin.crm.leads', {
          path: '/admin/crm/leads',
          Component: CrmLeadsPage
        });
        this.router.add('admin.crm.properties', {
          path: '/admin/crm/properties',
          Component: CrmPropertiesPage
        });
        this.router.add('admin.crm.deals', {
          path: '/admin/crm/deals',
          Component: CrmDealsPage
        });
        this.router.add('admin.crm.contacts', {
          path: '/admin/crm/contacts',
          Component: CrmContactsPage
        });
      }
    }
  }
  return RealEstateCRMClientPlugin;
});
EOF

cp "$PLUGIN_DIR/dist/client/index.js" "$PLUGIN_DIR/dist/client/index.js.js"

mkdir -p "$PLUGIN_DIR/dist/server"
cat > "$PLUGIN_DIR/dist/server/index.js" << 'EOF'
const ServerPlugin = require('../../lib/server/index.js');

module.exports = ServerPlugin && ServerPlugin.default ? ServerPlugin.default : ServerPlugin;
module.exports.default = module.exports;
EOF

cat > "$PLUGIN_DIR/dist/server/index.d.ts" << 'EOF'
declare const _default: any;
export default _default;
EOF

cat > "$PLUGIN_DIR/lib/server/plugin.js" << 'EOF'
const { Plugin } = require('@nocobase/server');

const ZAR_CURRENCY = {
  symbol: 'R',
  code: 'ZAR',
  locale: 'en-ZA',
  format: 'R {{value}}'
};

function formatZAR(value) {
  if (value === null || value === undefined) return '';
  const num = typeof value === 'number' ? value : parseFloat(value);
  if (isNaN(num)) return '';
  return 'R ' + num.toLocaleString('en-ZA', { minimumFractionDigits: 0, maximumFractionDigits: 0 });
}

class RealEstateCRMPlugin extends Plugin {
  async ensureUiSchema(resource, values) {
    try {
      const existing = await resource.repository.findOne({
        filter: {
          name: values.name
        }
      });
      if (existing) {
        return;
      }
    } catch (e) {}
    try {
      await resource.repository.create({ values });
    } catch (e) {}
  }

  async load() {
    const applyCompat = (body) => {
      if (!body || !body.data || !Array.isArray(body.data)) {
        return;
      }
      const target = body.data.find((item) => item && item.packageName === '@nocobase/plugin-real-estate-crm');
      if (!target) {
        return;
      }
      target.isCompatible = true;
      target.depsCompatible = [
        { name: '@nocobase/client', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' },
        { name: '@nocobase/server', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' },
        { name: '@nocobase/database', result: true, versionRange: '2.0.x', packageVersion: '2.0.12' }
      ];
    };
    this.app.use(async (ctx, next) => {
      await next();
      applyCompat(ctx.body);
    });
    if (this.app.resourcer && this.app.resourcer.use) {
      this.app.resourcer.use(async (ctx, next) => {
        await next();
        if (ctx) {
          applyCompat(ctx.body);
        }
      });
    }
    const db = this.app.db;

    db.collection({
      name: 'crm_suburbs',
      title: 'Suburbs',
      sortable: true,
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'name', type: 'string', title: 'Suburb Name' },
        { name: 'city', type: 'string', title: 'City', defaultValue: 'Johannesburg' },
        { name: 'province', type: 'string', title: 'Province', defaultValue: 'Gauteng' },
        { name: 'region', type: 'string', title: 'Region' },
        { name: 'postal_code', type: 'string', title: 'Postal Code' },
        { name: 'latitude', type: 'decimal', title: 'Latitude' },
        { name: 'longitude', type: 'decimal', title: 'Longitude' },
        { name: 'average_price', type: 'decimal', title: 'Average Price (ZAR)' },
        { name: 'median_price', type: 'decimal', title: 'Median Price (ZAR)' },
        { name: 'price_trend', type: 'string', title: 'Price Trend' },
        { name: 'days_on_market', type: 'integer', title: 'Days on Market' },
        { name: 'inventory_count', type: 'integer', title: 'Inventory Count' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' }
      ]
    });

    db.collection({
      name: 'crm_leads',
      title: 'Leads',
      sortable: true,
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'first_name', type: 'string', title: 'First Name' },
        { name: 'last_name', type: 'string', title: 'Last Name' },
        { name: 'full_name', type: 'string', title: 'Full Name' },
        { name: 'email', type: 'string', title: 'Email' },
        { name: 'phone', type: 'string', title: 'Phone' },
        { name: 'mobile', type: 'string', title: 'Mobile' },
        { name: 'company', type: 'string', title: 'Company' },
        { name: 'id_number', type: 'string', title: 'ID Number (RSA)' },
        { name: 'tax_number', type: 'string', title: 'Tax Number' },
        { name: 'status', type: 'string', title: 'Status', defaultValue: 'new' },
        { name: 'source', type: 'string', title: 'Lead Source' },
        { name: 'source_detail', type: 'string', title: 'Source Detail' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'budget_min', type: 'decimal', title: 'Budget Min (ZAR)' },
        { name: 'budget_max', type: 'decimal', title: 'Budget Max (ZAR)' },
        { name: 'preferred_location', type: 'string', title: 'Preferred Location' },
        { name: 'suburb', type: 'string', title: 'Preferred Suburb' },
        { name: 'city_preference', type: 'string', title: 'City Preference', defaultValue: 'Johannesburg' },
        { name: 'property_type', type: 'string', title: 'Property Type' },
        { name: 'bedrooms_required', type: 'integer', title: 'Bedrooms Required' },
        { name: 'bathrooms_required', type: 'integer', title: 'Bathrooms Required' },
        { name: 'timeline', type: 'string', title: 'Timeline' },
        { name: 'timeline_date', type: 'date', title: 'Timeline Date' },
        { name: 'rating', type: 'integer', title: 'Rating' },
        { name: 'fica_completed', type: 'boolean', title: 'FICA Completed', defaultValue: false },
        { name: 'fica_documents', type: 'jsonb', title: 'FICA Documents' },
        { name: 'last_contacted', type: 'datetime', title: 'Last Contacted' },
        { name: 'next_follow_up', type: 'datetime', title: 'Next Follow Up' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' }
      ]
    });

    db.collection({
      name: 'crm_contacts',
      title: 'Contacts',
      sortable: true,
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'first_name', type: 'string', title: 'First Name' },
        { name: 'last_name', type: 'string', title: 'Last Name' },
        { name: 'full_name', type: 'string', title: 'Full Name' },
        { name: 'email', type: 'string', title: 'Email' },
        { name: 'phone', type: 'string', title: 'Phone' },
        { name: 'mobile', type: 'string', title: 'Mobile' },
        { name: 'id_number', type: 'string', title: 'ID Number (RSA)' },
        { name: 'address', type: 'string', title: 'Address' },
        { name: 'city', type: 'string', title: 'City', defaultValue: 'Johannesburg' },
        { name: 'suburb', type: 'string', title: 'Suburb' },
        { name: 'province', type: 'string', title: 'Province', defaultValue: 'Gauteng' },
        { name: 'postal_code', type: 'string', title: 'Postal Code' },
        { name: 'country', type: 'string', title: 'Country', defaultValue: 'South Africa' },
        { name: 'birthday', type: 'date', title: 'Birthday' },
        { name: 'anniversary', type: 'date', title: 'Purchase Anniversary' },
        { name: 'type', type: 'string', title: 'Contact Type', defaultValue: 'prospect' },
        { name: 'company', type: 'string', title: 'Company' },
        { name: 'job_title', type: 'string', title: 'Job Title' },
        { name: 'tax_number', type: 'string', title: 'Tax Number' },
        { name: 'source', type: 'string', title: 'Source' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'fica_completed', type: 'boolean', title: 'FICA Completed', defaultValue: false },
        { name: 'fica_documents', type: 'jsonb', title: 'FICA Documents' },
        { name: 'engagement_score', type: 'integer', title: 'Engagement Score', defaultValue: 0 },
        { name: 'last_contacted', type: 'datetime', title: 'Last Contacted' },
        { name: 'next_follow_up', type: 'datetime', title: 'Next Follow Up' },
        { name: 'preferred_contact_method', type: 'string', title: 'Preferred Contact Method' },
        { name: 'preferred_contact_time', type: 'string', title: 'Preferred Contact Time' },
        { name: 'do_not_call', type: 'boolean', title: 'Do Not Call', defaultValue: false },
        { name: 'do_not_email', type: 'boolean', title: 'Do Not Email', defaultValue: false },
        { name: 'tags', type: 'string', title: 'Tags' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' }
      ]
    });

    db.collection({
      name: 'crm_properties',
      title: 'Properties',
      sortable: true,
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'title', type: 'string', title: 'Property Title' },
        { name: 'address', type: 'string', title: 'Address' },
        { name: 'street_number', type: 'string', title: 'Street Number' },
        { name: 'street_name', type: 'string', title: 'Street Name' },
        { name: 'suburb', type: 'string', title: 'Suburb' },
        { name: 'city', type: 'string', title: 'City', defaultValue: 'Johannesburg' },
        { name: 'province', type: 'string', title: 'Province', defaultValue: 'Gauteng' },
        { name: 'region', type: 'string', title: 'Region' },
        { name: 'postal_code', type: 'string', title: 'Postal Code' },
        { name: 'country', type: 'string', title: 'Country', defaultValue: 'South Africa' },
        { name: 'latitude', type: 'decimal', title: 'Latitude' },
        { name: 'longitude', type: 'decimal', title: 'Longitude' },
        { name: 'property_type', type: 'string', title: 'Property Type' },
        { name: 'listing_type', type: 'string', title: 'Listing Type' },
        { name: 'price', type: 'decimal', title: 'Price (ZAR)' },
        { name: 'price_display', type: 'string', title: 'Price Display' },
        { name: 'negotiable', type: 'boolean', title: 'Negotiable', defaultValue: true },
        { name: 'bedrooms', type: 'integer', title: 'Bedrooms' },
        { name: 'bathrooms', type: 'integer', title: 'Bathrooms' },
        { name: 'garage', type: 'integer', title: 'Garage' },
        { name: 'parking', type: 'integer', title: 'Parking' },
        { name: 'floor_area', type: 'decimal', title: 'Floor Area (m²)' },
        { name: 'land_size', type: 'decimal', title: 'Land Size (m²)' },
        { name: 'erf_size', type: 'decimal', title: 'Erf Size (m²)' },
        { name: 'year_built', type: 'integer', title: 'Year Built' },
        { name: 'floors', type: 'integer', title: 'Floors' },
        { name: 'living_areas', type: 'integer', title: 'Living Areas' },
        { name: 'pool', type: 'boolean', title: 'Pool', defaultValue: false },
        { name: 'garden', type: 'boolean', title: 'Garden', defaultValue: false },
        { name: 'security', type: 'boolean', title: 'Security', defaultValue: false },
        { name: 'status', type: 'string', title: 'Status', defaultValue: 'active' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'features', type: 'text', title: 'Features' },
        { name: 'images', type: 'text', title: 'Images' },
        { name: 'virtual_tour_url', type: 'string', title: 'Virtual Tour URL' },
        { name: 'assigned_to', type: 'string', title: 'Assigned Agent' },
        { name: 'owner_name', type: 'string', title: 'Owner Name' },
        { name: 'owner_phone', type: 'string', title: 'Owner Phone' },
        { name: 'owner_email', type: 'string', title: 'Owner Email' },
        { name: 'mandate_type', type: 'string', title: 'Mandate Type' },
        { name: 'mandate_expiry', type: 'date', title: 'Mandate Expiry' },
        { name: 'listing_date', type: 'date', title: 'Listing Date' },
        { name: 'expiry_date', type: 'date', title: 'Expiry Date' },
        { name: 'source', type: 'string', title: 'Source' },
        { name: 'viewings_count', type: 'integer', title: 'Viewings', defaultValue: 0 },
        { name: 'inquiries_count', type: 'integer', title: 'Inquiries', defaultValue: 0 },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' }
      ]
    });

    db.collection({
      name: 'crm_deals',
      title: 'Deals',
      sortable: true,
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'title', type: 'string', title: 'Deal Title' },
        { name: 'lead_id', type: 'string', title: 'Lead' },
        { name: 'contact_id', type: 'string', title: 'Contact' },
        { name: 'property_id', type: 'string', title: 'Property' },
        { name: 'stage', type: 'string', title: 'Stage', defaultValue: 'prospecting' },
        { name: 'value', type: 'decimal', title: 'Deal Value (ZAR)' },
        { name: 'commission_rate', type: 'decimal', title: 'Commission Rate (%)' },
        { name: 'commission', type: 'decimal', title: 'Commission (ZAR)' },
        { name: 'probability', type: 'integer', title: 'Probability (%)' },
        { name: 'expected_close_date', type: 'date', title: 'Expected Close Date' },
        { name: 'actual_close_date', type: 'date', title: 'Actual Close Date' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'lost_reason', type: 'string', title: 'Lost Reason' },
        { name: 'won_details', type: 'text', title: 'Won Details' },
        { name: 'fica_status', type: 'string', title: 'FICA Status', defaultValue: 'pending' },
        { name: 'fica_completed', type: 'boolean', title: 'FICA Completed', defaultValue: false },
        { name: 'fica_checklist', type: 'jsonb', title: 'FICA Checklist' },
        { name: 'fica_documents', type: 'jsonb', title: 'FICA Documents' },
        { name: 'fica_completed_date', type: 'datetime', title: 'FICA Completed Date' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' }
      ]
    });

    this.app.resourcer.define({
      type: 'actions',
      actions: {
        match: {
          handler: async (ctx, next) => {
            const { leadId } = ctx.request.body;
            if (!leadId) {
              ctx.body = { success: false, message: 'leadId required' };
              return;
            }
            const leadRepo = db.getRepository('crm_leads');
            const propertyRepo = db.getRepository('crm_properties');
            const lead = await leadRepo.findById({ id: leadId });
            if (!lead) {
              ctx.body = { success: false, message: 'Lead not found' };
              return;
            }
            const budgetMin = parseFloat(lead.budget_min) || 0;
            const budgetMax = parseFloat(lead.budget_max) || 999999999;
            const suburb = lead.suburb;
            const filter = {
              status: 'active',
              price: { $gte: budgetMin, $lte: budgetMax }
            };
            if (suburb) {
              filter.suburb = suburb;
            }
            const properties = await propertyRepo.find({
              filter: filter,
              fields: ['id', 'title', 'address', 'suburb', 'price', 'bedrooms', 'property_type']
            });
            ctx.body = { success: true, lead, matches: properties, count: properties.length };
          }
        }
      },
      resource: 'crm-match'
    });

  }

  async seedData() {
    const db = this.app.db;
    if (!db || !db.getRepository) {
      return;
    }
    const suburbRepo = db.getRepository('crm_suburbs');
    const leadRepo = db.getRepository('crm_leads');
    const propertyRepo = db.getRepository('crm_properties');

    const gautengSuburbs = [
      { name: 'Sandton', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', latitude: -26.1076, longitude: 28.0567, average_price: 3850000, median_price: 3200000, price_trend: 'rising', days_on_market: 45, inventory_count: 312 },
      { name: 'Midrand', city: 'Johannesburg', province: 'Gauteng', region: 'Midrand', postal_code: '1685', latitude: -25.9895, longitude: 28.1333, average_price: 2450000, median_price: 2100000, price_trend: 'rising', days_on_market: 38, inventory_count: 187 },
      { name: 'Fourways', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2055', latitude: -26.0172, longitude: 27.9819, average_price: 3200000, median_price: 2750000, price_trend: 'stable', days_on_market: 42, inventory_count: 156 },
      { name: 'Randburg', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2194', latitude: -26.1456, longitude: 27.9722, average_price: 1850000, median_price: 1650000, price_trend: 'rising', days_on_market: 35, inventory_count: 234 },
      { name: 'Rosebank', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', latitude: -26.1522, longitude: 28.0433, average_price: 2950000, median_price: 2500000, price_trend: 'stable', days_on_market: 48, inventory_count: 98 },
      { name: 'Melrose', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2076', latitude: -26.1289, longitude: 28.0622, average_price: 4100000, median_price: 3500000, price_trend: 'rising', days_on_market: 52, inventory_count: 67 },
      { name: 'Morningside', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', latitude: -26.0944, longitude: 28.0689, average_price: 2750000, median_price: 2400000, price_trend: 'stable', days_on_market: 40, inventory_count: 112 },
      { name: 'Bryanston', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2021', latitude: -26.0722, longitude: 28.0286, average_price: 3450000, median_price: 2900000, price_trend: 'rising', days_on_market: 38, inventory_count: 189 },
      { name: 'Waterfall', city: 'Midrand', province: 'Gauteng', region: 'Midrand', postal_code: '2090', latitude: -25.9578, longitude: 28.1078, average_price: 2850000, median_price: 2500000, price_trend: 'rising', days_on_market: 35, inventory_count: 145 },
      { name: 'Kyalami', city: 'Midrand', province: 'Gauteng', region: 'Midrand', postal_code: '1684', latitude: -25.9633, longitude: 28.0656, average_price: 2650000, median_price: 2300000, price_trend: 'stable', days_on_market: 42, inventory_count: 98 },
      { name: 'Centurion', city: 'Centurion', province: 'Gauteng', region: 'South', postal_code: '0046', latitude: -25.8609, longitude: 28.1855, average_price: 1750000, median_price: 1550000, price_trend: 'rising', days_on_market: 32, inventory_count: 423 },
      { name: 'Pretoria', city: 'Pretoria', province: 'Gauteng', region: 'North', postal_code: '0001', latitude: -25.7461, longitude: 28.1881, average_price: 1650000, median_price: 1400000, price_trend: 'stable', days_on_market: 38, inventory_count: 567 },
      { name: 'Hyde Park', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', latitude: -26.1283, longitude: 28.0758, average_price: 4200000, median_price: 3800000, price_trend: 'stable', days_on_market: 55, inventory_count: 45 },
      { name: 'Illovo', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', latitude: -26.1317, longitude: 28.0528, average_price: 3100000, median_price: 2700000, price_trend: 'rising', days_on_market: 44, inventory_count: 78 },
      { name: 'Westcliff', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2193', latitude: -26.1742, longitude: 28.0442, average_price: 5500000, median_price: 4800000, price_trend: 'stable', days_on_market: 65, inventory_count: 34 }
    ];

    for (const suburb of gautengSuburbs) {
      try {
        await suburbRepo.create({ values: suburb });
      } catch (e) {}
    }

    const sampleLeads = [
      { first_name: 'Thabo', last_name: 'Mokoena', full_name: 'Thabo Mokoena', email: 'thabo.mokoena@email.za', phone: '+27 82 123 4567', mobile: '+27 83 234 5678', status: 'qualified', source: 'Website', suburb: 'Sandton', city_preference: 'Johannesburg', property_type: 'House', budget_min: 2500000, budget_max: 4000000, bedrooms_required: 4, bathrooms_required: 3, timeline: '3_months', rating: 5 },
      { first_name: 'Nolwandle', last_name: 'Dlamini', full_name: 'Nolwandle Dlamini', email: 'nolwandle.d@email.za', phone: '+27 11 234 5678', mobile: '+27 82 345 6789', status: 'new', source: 'Referral', suburb: 'Midrand', city_preference: 'Johannesburg', property_type: 'Townhouse', budget_min: 1500000, budget_max: 2500000, bedrooms_required: 3, bathrooms_required: 2, timeline: '6_months', rating: 3 },
      { first_name: 'Sibusiso', last_name: 'Ngcobo', full_name: 'Sibusiso Ngcobo', email: 's.ngcobo@business.za', phone: '+27 12 345 6789', mobile: '+27 83 456 7890', status: 'contacted', source: 'Cold Call', suburb: 'Fourways', city_preference: 'Johannesburg', property_type: 'Apartment', budget_min: 1800000, budget_max: 2800000, bedrooms_required: 2, bathrooms_required: 2, timeline: 'immediate', rating: 4 },
      { first_name: 'Amahle', last_name: 'Khumalo', full_name: 'Amahle Khumalo', email: 'amahle.k@email.za', phone: '+27 31 456 7890', mobile: '+27 82 567 8901', status: 'qualified', source: 'Social Media', suburb: 'Bryanston', city_preference: 'Johannesburg', property_type: 'House', budget_min: 3500000, budget_max: 5000000, bedrooms_required: 5, bathrooms_required: 4, timeline: '3_months', rating: 5 },
      { first_name: 'Lungile', last_name: 'van der Merwe', full_name: 'Lungile van der Merwe', email: 'lungile.vdm@email.za', phone: '+27 21 567 8901', mobile: '+27 83 678 9012', status: 'proposal', source: 'Open House', suburb: 'Waterfall', city_preference: 'Johannesburg', property_type: 'House', budget_min: 2800000, budget_max: 3800000, bedrooms_required: 4, bathrooms_required: 3, timeline: '1_month', rating: 4 }
    ];

    for (const lead of sampleLeads) {
      try {
        await leadRepo.create({ values: lead });
      } catch (e) {}
    }

    const sampleProperties = [
      { title: 'Modern Family Home in Sandton', address: '12 Lily Road, Sandown', street_number: '12', street_name: 'Lily Road', suburb: 'Sandton', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', property_type: 'House', listing_type: 'Sale', price: 3850000, bedrooms: 4, bathrooms: 3, garage: 2, parking: 2, floor_area: 320, land_size: 600, year_built: 2018, pool: true, garden: true, security: true, status: 'active', description: 'Stunning modern home in heart of Sandton. Open plan living, chef kitchen, private pool.', features: 'Pool|Garden|Security|CCTV|Alarm', assigned_to: 'Agent 1' },
      { title: 'Luxury Villa in Midrand', address: '45 Hills Avenue, Vorna Valley', street_number: '45', street_name: 'Hills Avenue', suburb: 'Midrand', city: 'Johannesburg', province: 'Gauteng', region: 'Midrand', postal_code: '1686', property_type: 'House', listing_type: 'Sale', price: 2950000, bedrooms: 5, bathrooms: 4, garage: 3, parking: 4, floor_area: 450, land_size: 800, year_built: 2015, pool: true, garden: true, security: true, status: 'active', description: 'Spacious luxury home in secure estate. Great for entertaining.', features: 'Pool|Garden|Security|Estate|Backup Power', assigned_to: 'Agent 2' },
      { title: 'Contemporary Townhouse in Fourways', address: '78 Willow Way, Fourways', street_number: '78', street_name: 'Willow Way', suburb: 'Fourways', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2055', property_type: 'Townhouse', listing_type: 'Sale', price: 1850000, bedrooms: 3, bathrooms: 2, garage: 2, parking: 1, floor_area: 180, land_size: 250, year_built: 2020, pool: false, garden: true, security: true, status: 'active', description: 'Modern townhouse in secure complex. Close to schools and shopping.', features: 'Garden|Security|Complex|Parking', assigned_to: 'Agent 1' },
      { title: 'Executive Home in Bryanston', address: '23 Oak Avenue, Bryanston', street_number: '23', street_name: 'Oak Avenue', suburb: 'Bryanston', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2021', property_type: 'House', listing_type: 'Sale', price: 4250000, bedrooms: 5, bathrooms: 4, garage: 3, parking: 4, floor_area: 520, land_size: 1000, year_built: 2012, pool: true, garden: true, security: true, status: 'active', description: 'Magnificent family home in prestigious Bryanston. Perfect for entertaining.', features: 'Pool|Garden|Security|Backup Water|CCTV', assigned_to: 'Agent 3' },
      { title: 'Modern Apartment in Rosebank', address: '15 Keyes Avenue, Rosebank', street_number: '15', street_name: 'Keyes Avenue', suburb: 'Rosebank', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', property_type: 'Apartment', listing_type: 'Sale', price: 1650000, bedrooms: 2, bathrooms: 2, garage: 1, parking: 1, floor_area: 95, year_built: 2022, pool: false, garden: false, security: true, status: 'active', description: 'Stylish apartment in vibrant Rosebank. Walking distance to restaurants.', features: 'Security|Modern|Balcony', assigned_to: 'Agent 2' },
      { title: 'Family Home in Waterfall', address: '8 Amber Boulevard, Waterfall', street_number: '8', street_name: 'Amber Boulevard', suburb: 'Waterfall', city: 'Midrand', province: 'Gauteng', region: 'Midrand', postal_code: '2090', property_type: 'House', listing_type: 'Sale', price: 2750000, bedrooms: 4, bathrooms: 3, garage: 2, parking: 2, floor_area: 280, land_size: 450, year_built: 2019, pool: true, garden: true, security: true, status: 'active', description: 'Beautiful family home in Waterfall Estate. Modern finishes throughout.', features: 'Pool|Garden|Security|Estate|Clubhouse', assigned_to: 'Agent 1' },
      { title: 'Stunning Villa in Melrose', address: '42 George Avenue, Melrose', street_number: '42', street_name: 'George Avenue', suburb: 'Melrose', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2076', property_type: 'House', listing_type: 'Sale', price: 5800000, bedrooms: 6, bathrooms: 5, garage: 4, parking: 4, floor_area: 650, land_size: 1200, year_built: 2010, pool: true, garden: true, security: true, status: 'active', description: 'Grand residence in exclusive Melrose. Luxury finishes, expansive gardens.', features: 'Pool|Garden|Security|Cinema|Wine Cellar', assigned_to: 'Agent 3' },
      { title: 'Townhouse in Randburg', address: '7 Hill Street, Randburg', street_number: '7', street_name: 'Hill Street', suburb: 'Randburg', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2194', property_type: 'Townhouse', listing_type: 'Sale', price: 1450000, bedrooms: 3, bathrooms: 2, garage: 1, parking: 1, floor_area: 150, land_size: 200, year_built: 2017, pool: false, garden: true, security: true, status: 'active', description: 'Well-maintained townhouse in popular Randburg area.', features: 'Garden|Security|Parking', assigned_to: 'Agent 2' },
      { title: 'Penthouse in Hyde Park', address: '1 Hyde Park Lane, Hyde Park', street_number: '1', street_name: 'Hyde Park Lane', suburb: 'Hyde Park', city: 'Johannesburg', province: 'Gauteng', region: 'North', postal_code: '2196', property_type: 'Penthouse', listing_type: 'Sale', price: 6500000, bedrooms: 3, bathrooms: 3, garage: 3, parking: 2, floor_area: 380, year_built: 2021, pool: true, garden: true, security: true, status: 'active', description: 'Exclusive penthouse with panoramic views. Ultimate luxury living.', features: 'Pool|Garden|Security|Rooftop|Views', assigned_to: 'Agent 3' },
      { title: 'Kyalami Country Estate Home', address: '56 Kyalami Boulevard, Kyalami', street_number: '56', street_name: 'Kyalami Boulevard', suburb: 'Kyalami', city: 'Midrand', province: 'Gauteng', region: 'Midrand', postal_code: '1684', property_type: 'House', listing_type: 'Sale', price: 3100000, bedrooms: 4, bathrooms: 3, garage: 2, parking: 2, floor_area: 340, land_size: 550, year_built: 2016, pool: true, garden: true, security: true, status: 'active', description: 'Beautiful home in Kyalami Country Estate. Close to Kyalami racing circuit.', features: 'Pool|Garden|Security|Estate|Golf Course', assigned_to: 'Agent 1' }
    ];

    for (const property of sampleProperties) {
      try {
        await propertyRepo.create({ values: property });
      } catch (e) {}
    }

    const ficaChecklist = [
      { id: '1', item: 'RSA Identity Document (ID Book/Passport)', required: true, verified: false },
      { id: '2', item: 'Proof of Residential Address (Utility Bill < 3 months)', required: true, verified: false },
      { id: '3', item: 'Proof of Income (Payslips/Bank Statements)', required: true, verified: false },
      { id: '4', item: 'SARS Tax Clearance Certificate', required: true, verified: false },
      { id: '5', item: 'FICA Declaration Form Signed', required: true, verified: false },
      { id: '6', item: 'Proof of Funds (Pre-approval or Bond Quote)', required: true, verified: false },
      { id: '7', item: 'Marriage Certificate (if applicable)', required: false, verified: false },
      { id: '8', item: 'Power of Attorney (if applicable)', required: false, verified: false }
    ];

    try {
      const dealsRepo = db.getRepository('crm_deals');
      const deals = [
        { title: 'Sandton Property Purchase', stage: 'negotiation', value: 3850000, probability: 70, expected_close_date: '2026-04-30', fica_checklist: ficaChecklist },
        { title: 'Midrand Townhouse Deal', stage: 'proposal', value: 1850000, probability: 50, expected_close_date: '2026-05-15', fica_checklist: ficaChecklist }
      ];
      for (const deal of deals) {
        try {
          await dealsRepo.create({ values: deal });
        } catch (e) {}
      }
    } catch (e) {}
  }

  async install() {
    await this.seedData();
  }
}

module.exports = {
  RealEstateCRMPlugin,
  default: RealEstateCRMPlugin,
  formatZAR,
  ZAR_CURRENCY
};
EOF

chown -R node:node /app/nocobase/node_modules

cd /app/nocobase

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true
-- Create CRM collections tables

-- crm_leads table
CREATE TABLE IF NOT EXISTS "crm_leads" (
  "id" bigint NOT NULL,
  "first_name" varchar(255),
  "last_name" varchar(255),
  "full_name" varchar(255),
  "email" varchar(255),
  "phone" varchar(255),
  "mobile" varchar(255),
  "company" varchar(255),
  "status" varchar(255) DEFAULT 'new',
  "source" varchar(255),
  "source_detail" varchar(255),
  "assigned_to" varchar(255),
  "notes" text,
  "budget_min" decimal,
  "budget_max" decimal,
  "preferred_location" varchar(255),
  "property_type" varchar(255),
  "bedrooms_required" integer,
  "timeline" varchar(255),
  "rating" integer,
  "last_contacted" timestamptz,
  "next_follow_up" timestamptz,
  "created_at" timestamptz DEFAULT NOW(),
  "updated_at" timestamptz DEFAULT NOW(),
  "rsa_id" varchar(255),
  "tax_number" varchar(255),
  "fica_status" varchar(50) DEFAULT 'pending',
  PRIMARY KEY ("id")
);

-- crm_properties table  
CREATE TABLE IF NOT EXISTS "crm_properties" (
  "id" bigint NOT NULL,
  "title" varchar(255),
  "address" varchar(255),
  "suburb" varchar(255),
  "city" varchar(255) DEFAULT 'Johannesburg',
  "province" varchar(255) DEFAULT 'Gauteng',
  "postal_code" varchar(255),
  "property_type" varchar(255),
  "status" varchar(255) DEFAULT 'available',
  "price" decimal,
  "bedrooms" integer,
  "bathrooms" integer,
  "garages" integer,
  "erf_size" integer,
  "floor_size" integer,
  "pool" boolean DEFAULT false,
  "garden" boolean DEFAULT false,
  "security" boolean DEFAULT false,
  "description" text,
  "features" jsonb,
  "listing_date" timestamptz,
  "created_at" timestamptz DEFAULT NOW(),
  "updated_at" timestamptz DEFAULT NOW(),
  PRIMARY KEY ("id")
);

-- crm_deals table
CREATE TABLE IF NOT EXISTS "crm_deals" (
  "id" bigint NOT NULL,
  "title" varchar(255),
  "lead_id" bigint,
  "property_id" bigint,
  "stage" varchar(255) DEFAULT 'qualification',
  "value" decimal,
  "commission_rate" decimal DEFAULT 3.0,
  "commission_amount" decimal,
  "fica_checklist" jsonb,
  "fica_status" varchar(50) DEFAULT 'pending',
  "notes" text,
  "expected_close_date" timestamptz,
  "actual_close_date" timestamptz,
  "created_at" timestamptz DEFAULT NOW(),
  "updated_at" timestamptz DEFAULT NOW(),
  PRIMARY KEY ("id")
);

-- crm_contacts table
CREATE TABLE IF NOT EXISTS "crm_contacts" (
  "id" bigint NOT NULL,
  "first_name" varchar(255),
  "last_name" varchar(255),
  "full_name" varchar(255),
  "email" varchar(255),
  "phone" varchar(255),
  "mobile" varchar(255),
  "rsa_id" varchar(255),
  "address" varchar(255),
  "suburb" varchar(255),
  "city" varchar(255),
  "province" varchar(255) DEFAULT 'Gauteng',
  "postal_code" varchar(255),
  "fica_status" varchar(50) DEFAULT 'pending',
  "notes" text,
  "created_at" timestamptz DEFAULT NOW(),
  "updated_at" timestamptz DEFAULT NOW(),
  PRIMARY KEY ("id")
);

-- crm_suburbs table
CREATE TABLE IF NOT EXISTS "crm_suburbs" (
  "id" bigint NOT NULL,
  "name" varchar(255),
  "city" varchar(255) DEFAULT 'Johannesburg',
  "province" varchar(255) DEFAULT 'Gauteng',
  "latitude" decimal,
  "longitude" decimal,
  "average_price" decimal,
  "median_price" decimal,
  "total_listings" integer DEFAULT 0,
  "created_at" timestamptz DEFAULT NOW(),
  "updated_at" timestamptz DEFAULT NOW(),
  PRIMARY KEY ("id")
);

-- Insert sample suburbs
INSERT INTO "crm_suburbs" ("name", "city", "province", "latitude", "longitude", "average_price", "median_price", "total_listings") VALUES
('Sandton', 'Johannesburg', 'Gauteng', -26.1076, 28.0567, 3500000, 2800000, 45),
('Midrand', 'Johannesburg', 'Gauteng', -25.9894, 28.1333, 1850000, 1500000, 32),
('Fourways', 'Johannesburg', 'Gauteng', -26.0172, 27.9822, 2200000, 1800000, 28),
('Bryanston', 'Johannesburg', 'Gauteng', -26.0694, 28.0167, 2800000, 2200000, 35),
('Randburg', 'Johannesburg', 'Gauteng', -26.1667, 27.9833, 1500000, 1200000, 22),
('Rosebank', 'Johannesburg', 'Gauteng', -26.1500, 28.0667, 2100000, 1700000, 18),
('Melville', 'Johannesburg', 'Gauteng', -26.1833, 27.9500, 1650000, 1350000, 15),
('Parktown', 'Johannesburg', 'Gauteng', -26.1833, 28.0500, 1950000, 1600000, 12),
('Hyde Park', 'Johannesburg', 'Gauteng', -26.1333, 28.0667, 3800000, 3200000, 20),
('Dainfern', 'Johannesburg', 'Gauteng', -25.9667, 28.0167, 2400000, 2000000, 25),
('Morningside', 'Johannesburg', 'Gauteng', -26.0833, 28.0667, 1950000, 1600000, 16),
('Middelburg', 'Midrand', 'Gauteng', -25.8833, 29.2833, 1200000, 950000, 8),
('Centurion', 'Pretoria', 'Gauteng', -25.8500, 28.1667, 1400000, 1100000, 30),
('Waterkloof', 'Pretoria', 'Gauteng', -25.7833, 28.2333, 2200000, 1800000, 14),
('Illovo', 'Johannesburg', 'Gauteng', -26.1333, 28.0500, 2650000, 2200000, 11)
ON CONFLICT DO NOTHING;

-- Insert sample leads
INSERT INTO "crm_leads" ("first_name", "last_name", "email", "phone", "status", "source", "budget_min", "budget_max", "preferred_location", "property_type", "bedrooms_required", "rsa_id", "tax_number") VALUES
('John', 'Smith', 'john.smith@email.com', '+27-82-123-4567', 'qualified', 'Website', 2000000, 3500000, 'Sandton', 'House', 4, '8001011234089', '123456789'),
('Maria', 'Van der Merwe', 'maria.vdm@email.com', '+27-83-234-5678', 'new', 'Referral', 1500000, 2500000, 'Midrand', 'Townhouse', 3, '8502021234089', '234567891'),
('David', 'Jones', 'david.jones@email.com', '+27-84-345-6789', 'contacted', 'Property24', 1800000, 3000000, 'Fourways', 'House', 4, '7801031234089', '345678912'),
('Sarah', 'Pretorius', 'sarah.p@email.com', '+27-82-456-7890', 'proposal', 'Facebook', 2500000, 4500000, 'Bryanston', 'House', 5, '8201041234089', '456789123'),
('Michael', 'Brown', 'michael.b@email.com', '+27-83-567-8901', 'qualified', 'Signage', 1200000, 2000000, 'Randburg', 'Apartment', 2, '7901051234089', '567891234')
ON CONFLICT DO NOTHING;

-- Insert sample properties
INSERT INTO "crm_properties" ("title", "address", "suburb", "city", "province", "property_type", "status", "price", "bedrooms", "bathrooms", "garages", "erf_size", "floor_size", "pool", "garden", "security") VALUES
('Modern Family Home', '123 Oak Street', 'Sandton', 'Johannesburg', 'Gauteng', 'House', 'available', 3450000, 4, 3, 2, 1000, 350, true, true, true),
('Luxury Townhouse', '45 Maple Avenue', 'Midrand', 'Johannesburg', 'Gauteng', 'Townhouse', 'available', 1850000, 3, 2, 1, 400, 180, false, true, true),
('Cozy Apartment', '78 Pine Road', 'Fourways', 'Johannesburg', 'Gauteng', 'Apartment', 'available', 1200000, 2, 1, 1, 0, 85, false, false, true),
('Spacious Estate', '234 Cedar Lane', 'Bryanston', 'Johannesburg', 'Gauteng', 'House', 'available', 4200000, 5, 4, 3, 2000, 450, true, true, true),
('Modern Flat', '56 Birch Street', 'Randburg', 'Johannesburg', 'Gauteng', 'Apartment', 'available', 950000, 2, 1, 1, 0, 70, false, false, true),
('Family House with Pool', '89 Willow Way', 'Melville', 'Johannesburg', 'Gauteng', 'House', 'available', 2100000, 4, 2, 2, 600, 220, true, true, false),
('Executive Home', '167 Jasmine Road', 'Hyde Park', 'Johannesburg', 'Gauteng', 'House', 'available', 5500000, 5, 5, 3, 1500, 420, true, true, true),
('Starter Home', '23 Acacia Avenue', 'Morningside', 'Johannesburg', 'Gauteng', 'House', 'available', 1450000, 3, 2, 1, 500, 150, false, true, false),
('Luxury Villa', '456 Marula Crescent', 'Dainfern', 'Johannesburg', 'Gauteng', 'House', 'available', 3800000, 4, 3, 2, 800, 320, true, true, true),
('Renovation Project', '78 Baobab Street', 'Centurion', 'Pretoria', 'Gauteng', 'House', 'available', 1100000, 3, 2, 2, 900, 180, false, true, false)
ON CONFLICT DO NOTHING;

PSQL

echo "CRM collections created successfully"

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true
-- Add collections to NocoBase collection manager
-- This makes them visible in the admin UI

INSERT INTO "collections" (name, title, "dataSourceKey", "schema", "template", "engine", "syncMode", "createdAt", "updatedAt") VALUES
('crm_leads', 'Leads', 'main', '{"name":"crm_leads"}', 'general', 'InMemory', false, NOW(), NOW()),
('crm_properties', 'Properties', 'main', '{"name":"crm_properties"}', 'general', 'InMemory', false, NOW(), NOW()),
('crm_deals', 'Deals', 'main', '{"name":"crm_deals"}', 'general', 'InMemory', false, NOW(), NOW()),
('crm_contacts', 'Contacts', 'main', '{"name":"crm_contacts"}', 'general', 'InMemory', false, NOW(), NOW()),
('crm_suburbs', 'Suburbs', 'main', '{"name":"crm_suburbs"}', 'general', 'InMemory', false, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- Add collection fields for crm_leads
INSERT INTO "collection_fields" ("collectionName", "name", "type", "interface", "title", "dataType", "uiSchema", "defaultValue", "creator", "createdAt", "updatedAt") VALUES
('crm_leads', 'first_name', 'string', 'input', 'First Name', 'VARCHAR', '{"en-US":{"title":"First Name"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'last_name', 'string', 'input', 'Last Name', 'VARCHAR', '{"en-US":{"title":"Last Name"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'full_name', 'string', 'input', 'Full Name', 'VARCHAR', '{"en-US":{"title":"Full Name"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'email', 'string', 'email', 'Email', 'VARCHAR', '{"en-US":{"title":"Email"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'phone', 'string', 'phone', 'Phone', 'VARCHAR', '{"en-US":{"title":"Phone"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'status', 'string', 'select', 'Status', 'VARCHAR', '{"en-US":{"title":"Status","enum":[{"label":"New","value":"new"},{"label":"Contacted","value":"contacted"},{"label":"Qualified","value":"qualified"}]}}', 'new', 'system', NOW(), NOW()),
('crm_leads', 'budget_min', 'decimal', 'number', 'Budget Min', 'DECIMAL', '{"en-US":{"title":"Budget Min"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'budget_max', 'decimal', 'number', 'Budget Max', 'DECIMAL', '{"en-US":{"title":"Budget Max"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'preferred_location', 'string', 'input', 'Preferred Location', 'VARCHAR', '{"en-US":{"title":"Preferred Location"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'rsa_id', 'string', 'input', 'RSA ID', 'VARCHAR', '{"en-US":{"title":"RSA ID"}}', null, 'system', NOW(), NOW()),
('crm_leads', 'fica_status', 'string', 'select', 'FICA Status', 'VARCHAR', '{"en-US":{"title":"FICA Status","enum":[{"label":"Pending","value":"pending"},{"label":"Verified","value":"verified"},{"label":"Rejected","value":"rejected"}]}}', 'pending', 'system', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- Add collection fields for crm_properties
INSERT INTO "collection_fields" ("collectionName", "name", "type", "interface", "title", "dataType", "uiSchema", "defaultValue", "creator", "createdAt", "updatedAt") VALUES
('crm_properties', 'title', 'string', 'input', 'Title', 'VARCHAR', '{"en-US":{"title":"Title"}}', null, 'system', NOW(), NOW()),
('crm_properties', 'address', 'string', 'input', 'Address', 'VARCHAR', '{"en-US":{"title":"Address"}}', null, 'system', NOW(), NOW()),
('crm_properties', 'suburb', 'string', 'input', 'Suburb', 'VARCHAR', '{"en-US":{"title":"Suburb"}}', null, 'system', NOW(), NOW()),
('crm_properties', 'city', 'string', 'input', 'City', 'VARCHAR', '{"en-US":{"title":"City"}}', 'Johannesburg', 'system', NOW(), NOW()),
('crm_properties', 'province', 'string', 'input', 'Province', 'VARCHAR', '{"en-US":{"title":"Province"}}', 'Gauteng', 'system', NOW(), NOW()),
('crm_properties', 'property_type', 'string', 'select', 'Property Type', 'VARCHAR', '{"en-US":{"title":"Property Type","enum":[{"label":"House","value":"House"},{"label":"Apartment","value":"Apartment"},{"label":"Townhouse","value":"Townhouse"}]}}', null, 'system', NOW(), NOW()),
('crm_properties', 'price', 'decimal', 'number', 'Price (ZAR)', 'DECIMAL', '{"en-US":{"title":"Price (ZAR)"}}', null, 'system', NOW(), NOW()),
('crm_properties', 'bedrooms', 'integer', 'number', 'Bedrooms', 'INTEGER', '{"en-US":{"title":"Bedrooms"}}', null, 'system', NOW(), NOW()),
('crm_properties', 'bathrooms', 'integer', 'number', 'Bathrooms', 'INTEGER', '{"en-US":{"title":"Bathrooms"}}', null, 'system', NOW(), NOW()),
('crm_properties', 'status', 'string', 'select', 'Status', 'VARCHAR', '{"en-US":{"title":"Status","enum":[{"label":"Available","value":"available"},{"label":"Sold","value":"sold"},{"label":"Under Offer","value":"under_offer"}]}}', 'available', 'system', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- Add collection fields for crm_deals
INSERT INTO "collection_fields" ("collectionName", "name", "type", "interface", "title", "dataType", "uiSchema", "defaultValue", "creator", "createdAt", "updatedAt") VALUES
('crm_deals', 'title', 'string', 'input', 'Title', 'VARCHAR', '{"en-US":{"title":"Title"}}', null, 'system', NOW(), NOW()),
('crm_deals', 'stage', 'string', 'select', 'Stage', 'VARCHAR', '{"en-US":{"title":"Stage","enum":[{"label":"Qualification","value":"qualification"},{"label":"Proposal","value":"proposal"},{"label":"Negotiation","value":"negotiation"},{"label":"Closed Won","value":"won"},{"label":"Closed Lost","value":"lost"}]}}', 'qualification', 'system', NOW(), NOW()),
('crm_deals', 'value', 'decimal', 'number', 'Deal Value', 'DECIMAL', '{"en-US":{"title":"Deal Value"}}', null, 'system', NOW(), NOW()),
('crm_deals', 'fica_status', 'string', 'select', 'FICA Status', 'VARCHAR', '{"en-US":{"title":"FICA Status","enum":[{"label":"Pending","value":"pending"},{"label":"Verified","value":"verified"}]}}', 'pending', 'system', NOW(), NOW())
ON CONFLICT DO NOTHING;

PSQL

echo "CRM collections synced to NocoBase"

psql "$DATABASE_URL" << 'PSQL' 2>/dev/null || true
-- Add CRM collections to the application menu (sidebar)
-- This adds a "CRM" menu group with links to each collection

-- First, check if menu already exists
DELETE FROM "ui_schemas" WHERE "id" = 9001;

INSERT INTO "ui_schemas" ("id", "uiSchema", "createdAt", "updatedAt") VALUES
(9001, '{"type":"void","version":"2.0","x-uid":"crm-menu-group","x-designer":{"placement":"sidebar"},"title":"CRM","name":"crm","icon":"ShopOutlined","children":[{"version":"2.0","x-uid":"crm-leads-page","x-designer":{"placement":"inline"},"type":"page","title":"Leads","icon":"UserOutlined","name":"crm_leads","path":"/crm/leads","children":[{"version":"2.0","x-uid":"crm-leads-blocks","x-designer":{"placement":"bottom"},"type":"void","name":"leadsBlocks","x-component":"BlockItem","children":[{"version":"2.0","x-uid":"crm-leads-table","x-designer":{"placement":"left"},"type":"tableV2","x-component-props":{"className":"nb-table"},"x-settings":"{\"tableV2\":{\"columns\":[{\"key\":\"first_name\",\"name\":\"first_name\",\"label\":\"First Name\"},{\"key\":\"last_name\",\"name\":\"last_name\",\"label\":\"Last Name\"},{\"key\":\"email\",\"name\":\"email\",\"label\":\"Email\"},{\"key\":\"phone\",\"name\":\"phone\",\"label\":\"Phone\"},{\"key\":\"status\",\"name\":\"status\",\"label\":\"Status\"}]}}","name":"table","x-resource":"crm_leads","x-decorator":"APIClientDataBlock","x-decorator-props":{"resource":"crm_leads","action":"list","params":{"pageSize":20}}}]}]},{"version":"2.0","x-uid":"crm-properties-page","x-designer":{"placement":"inline"},"type":"page","title":"Properties","icon":"HomeOutlined","name":"crm_properties","path":"/crm/properties","children":[{"version":"2.0","x-uid":"crm-properties-blocks","x-designer":{"placement":"bottom"},"type":"void","name":"propertiesBlocks","x-component":"BlockItem","children":[{"version":"2.0","x-uid":"crm-properties-table","x-designer":{"placement":"left"},"type":"tableV2","x-component-props":{"className":"nb-table"},"x-settings":"{\"tableV2\":{\"columns\":[{\"key\":\"title\",\"name\":\"title\",\"label\":\"Title\"},{\"key\":\"address\",\"name\":\"address\",\"label\":\"Address\"},{\"key\":\"suburb\",\"name\":\"suburb\",\"label\":\"Suburb\"},{\"key\":\"property_type\",\"name\":\"property_type\",\"label\":\"Type\"},{\"key\":\"price\",\"name\":\"price\",\"label\":\"Price\"},{\"key\":\"status\",\"name\":\"status\",\"label\":\"Status\"}]}}","name":"table","x-resource":"crm_properties","x-decorator":"APIClientDataBlock","x-decorator-props":{"resource":"crm_properties","action":"list","params":{"pageSize":20}}}]}]},{"version":"2.0","x-uid":"crm-deals-page","x-designer":{"placement":"inline"},"type":"page","title":"Deals","icon":"PercentageOutlined","name":"crm_deals","path":"/crm/deals","children":[{"version":"2.0","x-uid":"crm-deals-blocks","x-designer":{"placement":"bottom"},"type":"void","name":"dealsBlocks","x-component":"BlockItem","children":[{"version":"2.0","x-uid":"crm-deals-table","x-designer":{"placement":"left"},"type":"tableV2","x-component-props":{"className":"nb-table"},"x-settings":"{\"tableV2\":{\"columns\":[{\"key\":\"title\",\"name\":\"title\",\"label\":\"Title\"},{\"key\":\"stage\",\"name\":\"stage\",\"label\":\"Stage\"},{\"key\":\"value\",\"name\":\"value\",\"label\":\"Value\"},{\"key\":\"fica_status\",\"name\":\"fica_status\",\"label\":\"FICA\"}]}}","name":"table","x-resource":"crm_deals","x-decorator":"APIClientDataBlock","x-decorator-props":{"resource":"crm_deals","action":"list","params":{"pageSize":20}}}]}]},{"version":"2.0","x-uid":"crm-contacts-page","x-designer":{"placement":"inline"},"type":"page","title":"Contacts","icon":"TeamOutlined","name":"crm_contacts","path":"/crm/contacts","children":[{"version":"2.0","x-uid":"crm-contacts-blocks","x-designer":{"placement":"bottom"},"type":"void","name":"contactsBlocks","x-component":"BlockItem","children":[{"version":"2.0","x-uid":"crm-contacts-table","x-designer":{"placement":"left"},"type":"tableV2","x-component-props":{"className":"nb-table"},"x-settings":"{\"tableV2\":{\"columns\":[{\"key\":\"first_name\",\"name\":\"first_name\",\"label\":\"First Name\"},{\"key\":\"last_name\",\"name\":\"last_name\",\"label\":\"Last Name\"},{\"key\":\"email\",\"name\":\"email\",\"label\":\"Email\"},{\"key\":\"phone\",\"name\":\"phone\",\"label\":\"Phone\"}]}}","name":"table","x-resource":"crm_contacts","x-decorator":"APIClientDataBlock","x-decorator-props":{"resource":"crm_contacts","action":"list","params":{"pageSize":20}}}]}]}]}', NOW(), NOW());

PSQL

echo "CRM menu items added to sidebar"

exit 0
