/**
 * South African Real Estate CRM Plugin for NocoBase
 * 
 * This plugin provides a complete CRM solution for South African real estate businesses
 * with FICA compliance, RSA ID validation, and property management.
 */

import { Plugin } from '@nocobase/server';
import { Database } from '@nocobase/database';

export class SARealEstateCRMPlugin extends Plugin {
  async load() {
    const db = this.app.db as Database;
    
    // Create collections
    await this.createCollections(db);
    
    // Add menu items
    await this.addMenuItems();
    
    // Add RSA ID validation
    await this.addRSAIDValidation(db);
    
    console.log('✅ SA Real Estate CRM Plugin loaded successfully');
  }

  private async createCollections(db: Database) {
    // Create customers collection
    db.collection({
      name: 'customers',
      fields: [
        { type: 'uuid', name: 'id', primaryKey: true },
        { type: 'string', name: 'rsa_id_number', unique: true },
        { type: 'string', name: 'first_name', required: true },
        { type: 'string', name: 'last_name', required: true },
        { type: 'string', name: 'email', unique: true, required: true },
        { type: 'string', name: 'phone' },
        { type: 'string', name: 'mobile' },
        { type: 'string', name: 'customer_type', defaultValue: 'individual' },
        { type: 'boolean', name: 'fica_compliant', defaultValue: false },
        { type: 'date', name: 'fica_expiry' },
        { type: 'string', name: 'tax_number' },
        { type: 'text', name: 'address' },
        { type: 'string', name: 'city' },
        { type: 'string', name: 'province' },
        { type: 'string', name: 'postal_code' },
        { type: 'boolean', name: 'rsa_id_valid', defaultValue: false },
        { type: 'date', name: 'date_of_birth' },
        { type: 'string', name: 'gender' },
        { type: 'string', name: 'citizenship' },
        { type: 'integer', name: 'age' },
        { type: 'date', name: 'created_at' },
        { type: 'date', name: 'updated_at' }
      ]
    });

    // Create properties collection
    db.collection({
      name: 'properties',
      fields: [
        { type: 'uuid', name: 'id', primaryKey: true },
        { type: 'string', name: 'property_ref', unique: true, required: true },
        { type: 'string', name: 'title', required: true },
        { type: 'text', name: 'address', required: true },
        { type: 'string', name: 'street_number' },
        { type: 'string', name: 'street_name' },
        { type: 'string', name: 'suburb' },
        { type: 'string', name: 'city', defaultValue: 'Johannesburg' },
        { type: 'string', name: 'province', defaultValue: 'Gauteng' },
        { type: 'string', name: 'postal_code' },
        { type: 'string', name: 'property_type', required: true },
        { type: 'string', name: 'listing_type', defaultValue: 'sale' },
        { type: 'decimal', name: 'price' },
        { type: 'string', name: 'price_display' },
        { type: 'boolean', name: 'negotiable', defaultValue: true },
        { type: 'integer', name: 'bedrooms' },
        { type: 'integer', name: 'bathrooms' },
        { type: 'integer', name: 'garage' },
        { type: 'integer', name: 'parking' },
        { type: 'decimal', name: 'floor_area' },
        { type: 'decimal', name: 'land_size' },
        { type: 'integer', name: 'year_built' },
        { type: 'string', name: 'status', defaultValue: 'available' },
        { type: 'text', name: 'description' },
        { type: 'text', name: 'features' },
        { type: 'belongsTo', name: 'owner', target: 'customers' },
        { type: 'date', name: 'listing_date' },
        { type: 'string', name: 'mandate_type' },
        { type: 'date', name: 'mandate_expiry' },
        { type: 'date', name: 'created_at' },
        { type: 'date', name: 'updated_at' }
      ]
    });

    // Create opportunities collection
    db.collection({
      name: 'opportunities',
      fields: [
        { type: 'uuid', name: 'id', primaryKey: true },
        { type: 'string', name: 'title', required: true },
        { type: 'belongsTo', name: 'customer', target: 'customers' },
        { type: 'belongsTo', name: 'property', target: 'properties' },
        { type: 'string', name: 'stage', defaultValue: 'prospecting' },
        { type: 'decimal', name: 'value' },
        { type: 'decimal', name: 'commission' },
        { type: 'decimal', name: 'commission_rate', defaultValue: 5.0 },
        { type: 'integer', name: 'probability', defaultValue: 10 },
        { type: 'date', name: 'expected_close_date' },
        { type: 'date', name: 'actual_close_date' },
        { type: 'string', name: 'assigned_to' },
        { type: 'string', name: 'source' },
        { type: 'text', name: 'notes' },
        { type: 'string', name: 'lost_reason' },
        { type: 'date', name: 'created_at' },
        { type: 'date', name: 'updated_at' }
      ]
    });

    // Create leads collection
    db.collection({
      name: 'leads',
      fields: [
        { type: 'uuid', name: 'id', primaryKey: true },
        { type: 'string', name: 'first_name' },
        { type: 'string', name: 'last_name' },
        { type: 'string', name: 'email' },
        { type: 'string', name: 'phone' },
        { type: 'string', name: 'mobile' },
        { type: 'string', name: 'company' },
        { type: 'string', name: 'source' },
        { type: 'string', name: 'source_detail' },
        { type: 'string', name: 'status', defaultValue: 'new' },
        { type: 'decimal', name: 'budget_min' },
        { type: 'decimal', name: 'budget_max' },
        { type: 'string', name: 'preferred_location' },
        { type: 'string', name: 'property_type' },
        { type: 'integer', name: 'bedrooms_required' },
        { type: 'string', name: 'timeline' },
        { type: 'integer', name: 'rating', defaultValue: 1 },
        { type: 'string', name: 'assigned_to' },
        { type: 'text', name: 'notes' },
        { type: 'date', name: 'last_contacted' },
        { type: 'date', name: 'next_follow_up' },
        { type: 'date', name: 'created_at' },
        { type: 'date', name: 'updated_at' }
      ]
    });

    // Create fica_documents collection
    db.collection({
      name: 'fica_documents',
      fields: [
        { type: 'uuid', name: 'id', primaryKey: true },
        { type: 'belongsTo', name: 'customer', target: 'customers' },
        { type: 'string', name: 'document_type', required: true },
        { type: 'text', name: 'file_path', required: true },
        { type: 'string', name: 'file_name', required: true },
        { type: 'integer', name: 'file_size' },
        { type: 'string', name: 'mime_type' },
        { type: 'date', name: 'expiry_date' },
        { type: 'boolean', name: 'verified', defaultValue: false },
        { type: 'date', name: 'verified_date' },
        { type: 'string', name: 'verified_by' },
        { type: 'text', name: 'notes' },
        { type: 'date', name: 'uploaded_at' },
        { type: 'date', name: 'created_at' },
        { type: 'date', name: 'updated_at' }
      ]
    });

    // Create fica_document_types collection
    db.collection({
      name: 'fica_document_types',
      fields: [
        { type: 'uuid', name: 'id', primaryKey: true },
        { type: 'string', name: 'name', required: true },
        { type: 'string', name: 'code', unique: true, required: true },
        { type: 'text', name: 'description' },
        { type: 'boolean', name: 'required', defaultValue: true },
        { type: 'integer', name: 'expiry_days' },
        { type: 'date', name: 'created_at' }
      ]
    });
  }

  private async addMenuItems() {
    // Add CRM menu group
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'crm_menu_group',
        uiSchema: {
          type: 'void',
          title: 'Real Estate CRM',
          name: 'crm',
          icon: 'ShopOutlined',
          'x-designer': { placement: 'sidebar' },
          'x-uid': 'crm-menu-group',
          'x-async': false,
          'x-index': 10
        }
      }
    });

    // Add Dashboard menu item
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'crm_dashboard',
        uiSchema: {
          type: 'page',
          title: 'Dashboard',
          name: 'crm_dashboard',
          icon: 'DashboardOutlined',
          path: '/admin/crm/dashboard',
          'x-uid': 'crm-dashboard',
          'x-async': false,
          'x-parent-uid': 'crm-menu-group'
        }
      }
    });

    // Add Customers menu item
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'customers_menu',
        uiSchema: {
          type: 'page',
          title: 'Customers',
          name: 'customers',
          icon: 'UserOutlined',
          path: '/admin/crm/customers',
          'x-resource': 'customers',
          'x-decorator': 'APIClientDataBlock',
          'x-decorator-props': {
            resource: 'customers',
            action: 'list',
            params: { pageSize: 20 }
          },
          'x-uid': 'customers-menu',
          'x-async': false,
          'x-parent-uid': 'crm-menu-group'
        }
      }
    });

    // Add Properties menu item
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'properties_menu',
        uiSchema: {
          type: 'page',
          title: 'Properties',
          name: 'properties',
          icon: 'HomeOutlined',
          path: '/admin/crm/properties',
          'x-resource': 'properties',
          'x-decorator': 'APIClientDataBlock',
          'x-decorator-props': {
            resource: 'properties',
            action: 'list',
            params: { pageSize: 20 }
          },
          'x-uid': 'properties-menu',
          'x-async': false,
          'x-parent-uid': 'crm-menu-group'
        }
      }
    });

    // Add Opportunities menu item
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'opportunities_menu',
        uiSchema: {
          type: 'page',
          title: 'Opportunities',
          name: 'opportunities',
          icon: 'PercentageOutlined',
          path: '/admin/crm/opportunities',
          'x-resource': 'opportunities',
          'x-decorator': 'APIClientDataBlock',
          'x-decorator-props': {
            resource: 'opportunities',
            action: 'list',
            params: { pageSize: 20 }
          },
          'x-uid': 'opportunities-menu',
          'x-async': false,
          'x-parent-uid': 'crm-menu-group'
        }
      }
    });

    // Add Leads menu item
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'leads_menu',
        uiSchema: {
          type: 'page',
          title: 'Leads',
          name: 'leads',
          icon: 'TeamOutlined',
          path: '/admin/crm/leads',
          'x-resource': 'leads',
          'x-decorator': 'APIClientDataBlock',
          'x-decorator-props': {
            resource: 'leads',
            action: 'list',
            params: { pageSize: 20 }
          },
          'x-uid': 'leads-menu',
          'x-async': false,
          'x-parent-uid': 'crm-menu-group'
        }
      }
    });

    // Add FICA Compliance menu item
    await this.app.db.getRepository('uiSchemas').create({
      values: {
        name: 'fica_compliance_menu',
        uiSchema: {
          type: 'page',
          title: 'FICA Compliance',
          name: 'fica_compliance',
          icon: 'SafetyOutlined',
          path: '/admin/crm/fica',
          'x-resource': 'fica_documents',
          'x-decorator': 'APIClientDataBlock',
          'x-decorator-props': {
            resource: 'fica_documents',
            action: 'list',
            params: { pageSize: 20 }
          },
          'x-uid': 'fica-compliance-menu',
          'x-async': false,
          'x-parent-uid': 'crm-menu-group'
        }
      }
    });
  }

  private async addRSAIDValidation(db: Database) {
    // Add RSA ID validation function
    const validateRSAID = (rsaId: string): boolean => {
      if (!rsaId || rsaId.length !== 13 || !/^\d{13}$/.test(rsaId)) {
        return false;
      }

      try {
        const year = parseInt(rsaId.substring(0, 2));
        const month = parseInt(rsaId.substring(2, 4));
        const day = parseInt(rsaId.substring(4, 6));
        const sequential = parseInt(rsaId.substring(6, 10));
        const citizenship = parseInt(rsaId.substring(10, 11));

        if (month < 1 || month > 12) return false;
        if (day < 1 || day > 31) return false;
        if (sequential < 0 || sequential > 9999) return false;
        if (citizenship < 0 || citizenship > 1) return false;

        // Luhn checksum validation
        let sum = 0;
        let alternate = false;
        for (let i = rsaId.length - 1; i >= 0; i--) {
          let n = parseInt(rsaId.charAt(i));
          if (alternate) {
            n *= 2;
            if (n > 9) n = (n % 10) + 1;
          }
          sum += n;
          alternate = !alternate;
        }
        return (sum % 10) === 0;
      } catch (error) {
        return false;
      }
    };

    // Add API endpoint for RSA ID validation
    this.app.resource({
      name: 'rsa-validation',
      actions: {
        validate: async (ctx) => {
          const { rsaId } = ctx.request.body;
          
          if (!rsaId) {
            ctx.throw(400, 'RSA ID number is required');
          }

          const isValid = validateRSAID(rsaId);
          let info = null;

          if (isValid) {
            const year = parseInt(rsaId.substring(0, 2));
            const month = parseInt(rsaId.substring(2, 4));
            const day = parseInt(rsaId.substring(4, 6));
            const sequential = parseInt(rsaId.substring(6, 10));
            const citizenship = parseInt(rsaId.substring(10, 11));

            const fullYear = year < 50 ? 2000 + year : 1900 + year;
            const today = new Date();
            let age = today.getFullYear() - fullYear;
            const monthDiff = today.getMonth() - (month - 1);
            if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < day)) {
              age--;
            }

            info = {
              dateOfBirth: new Date(fullYear, month - 1, day),
              gender: sequential < 5000 ? 'female' : 'male',
              citizenship: citizenship === 0 ? 'citizen' : 'resident',
              age: age
            };
          }

          ctx.body = {
            valid: isValid,
            info: info,
            message: isValid ? 'Valid RSA ID number' : 'Invalid RSA ID number format'
          };
        }
      }
    });
  }
}

export default SARealEstateCRMPlugin;