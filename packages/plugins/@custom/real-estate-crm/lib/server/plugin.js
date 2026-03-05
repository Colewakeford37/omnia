const { Plugin } = require('@nocobase/server');

class RealEstateCRMPlugin extends Plugin {
  async afterAdd() {}

  async beforeLoad() {}

  async load() {
    const db = this.app.db;
    await this.defineCollections(db);
  }

  async defineCollections(db) {
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
        {
          name: 'status',
          type: 'string',
          title: 'Status',
          defaultValue: 'new',
          interface: 'select',
          uiSchema: {
            enum: [
              { label: 'New', value: 'new', color: '#1890ff' },
              { label: 'Contacted', value: 'contacted', color: '#52c41a' },
              { label: 'Qualified', value: 'qualified', color: '#faad14' },
              { label: 'Proposal', value: 'proposal', color: '#722ed1' },
              { label: 'Negotiation', value: 'negotiation', color: '#eb2f96' },
              { label: 'Won', value: 'won', color: '#52c41a' },
              { label: 'Lost', value: 'lost', color: '#ff4d4f' }
            ]
          }
        },
        { name: 'source', type: 'string', title: 'Lead Source' },
        { name: 'source_detail', type: 'string', title: 'Source Detail' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'budget_min', type: 'decimal', title: 'Budget Min' },
        { name: 'budget_max', type: 'decimal', title: 'Budget Max' },
        { name: 'preferred_location', type: 'string', title: 'Preferred Location' },
        { name: 'property_type', type: 'string', title: 'Property Type' },
        { name: 'bedrooms_required', type: 'integer', title: 'Bedrooms Required' },
        { name: 'timeline', type: 'string', title: 'Timeline' },
        { name: 'rating', type: 'integer', title: 'Rating' },
        { name: 'last_contacted', type: 'datetime', title: 'Last Contacted' },
        { name: 'next_follow_up', type: 'datetime', title: 'Next Follow Up' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
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
        { name: 'address', type: 'string', title: 'Address' },
        { name: 'city', type: 'string', title: 'City' },
        { name: 'suburb', type: 'string', title: 'Suburb' },
        { name: 'province', type: 'string', title: 'Province' },
        { name: 'postal_code', type: 'string', title: 'Postal Code' },
        { name: 'country', type: 'string', title: 'Country' },
        { name: 'birthday', type: 'date', title: 'Birthday' },
        { name: 'anniversary', type: 'date', title: 'Purchase Anniversary' },
        {
          name: 'type',
          type: 'string',
          title: 'Contact Type',
          defaultValue: 'prospect',
          interface: 'select'
        },
        { name: 'company', type: 'string', title: 'Company' },
        { name: 'job_title', type: 'string', title: 'Job Title' },
        { name: 'source', type: 'string', title: 'Source' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'engagement_score', type: 'integer', title: 'Engagement Score', defaultValue: 0 },
        { name: 'last_contacted', type: 'datetime', title: 'Last Contacted' },
        { name: 'next_follow_up', type: 'datetime', title: 'Next Follow Up' },
        { name: 'preferred_contact_method', type: 'string', title: 'Preferred Contact Method' },
        { name: 'preferred_contact_time', type: 'string', title: 'Preferred Contact Time' },
        { name: 'do_not_call', type: 'boolean', title: 'Do Not Call', defaultValue: false },
        { name: 'do_not_email', type: 'boolean', title: 'Do Not Email', defaultValue: false },
        { name: 'tags', type: 'string', title: 'Tags' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
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
        { name: 'city', type: 'string', title: 'City' },
        { name: 'province', type: 'string', title: 'Province' },
        { name: 'postal_code', type: 'string', title: 'Postal Code' },
        { name: 'country', type: 'string', title: 'Country' },
        {
          name: 'property_type',
          type: 'string',
          title: 'Property Type',
          interface: 'select'
        },
        { name: 'listing_type', type: 'string', title: 'Listing Type' },
        { name: 'price', type: 'decimal', title: 'Price' },
        { name: 'price_display', type: 'string', title: 'Price Display' },
        { name: 'negotiable', type: 'boolean', title: 'Negotiable', defaultValue: true },
        { name: 'bedrooms', type: 'integer', title: 'Bedrooms' },
        { name: 'bathrooms', type: 'integer', title: 'Bathrooms' },
        { name: 'garage', type: 'integer', title: 'Garage' },
        { name: 'parking', type: 'integer', title: 'Parking' },
        { name: 'floor_area', type: 'decimal', title: 'Floor Area (m²)' },
        { name: 'land_size', type: 'decimal', title: 'Land Size (m²)' },
        { name: 'year_built', type: 'integer', title: 'Year Built' },
        { name: 'floors', type: 'integer', title: 'Floors' },
        { name: 'living_areas', type: 'integer', title: 'Living Areas' },
        {
          name: 'status',
          type: 'string',
          title: 'Status',
          defaultValue: 'active',
          interface: 'select'
        },
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
        { name: 'source', type: 'string', title: 'Source' },
        { name: 'viewings_count', type: 'integer', title: 'Viewings', defaultValue: 0 },
        { name: 'inquiries_count', type: 'integer', title: 'Inquiries', defaultValue: 0 },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
      ]
    });

    db.collection({
      name: 'crm_deals',
      title: 'Deals',
      sortable: true,
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'title', type: 'string', title: 'Deal Title' },
        { name: 'contact_id', type: 'string', title: 'Contact' },
        { name: 'property_id', type: 'string', title: 'Property' },
        {
          name: 'stage',
          type: 'string',
          title: 'Stage',
          defaultValue: 'prospecting',
          interface: 'select'
        },
        { name: 'value', type: 'decimal', title: 'Deal Value' },
        { name: 'commission', type: 'decimal', title: 'Commission' },
        { name: 'probability', type: 'integer', title: 'Probability (%)' },
        { name: 'expected_close_date', type: 'date', title: 'Expected Close Date' },
        { name: 'actual_close_date', type: 'date', title: 'Actual Close Date' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'lost_reason', type: 'string', title: 'Lost Reason' },
        { name: 'won_details', type: 'text', title: 'Won Details' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
      ]
    });

    db.collection({
      name: 'crm_contact_reasons',
      title: 'Contact Reasons',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'name', type: 'string', title: 'Reason Name' },
        { name: 'code', type: 'string', title: 'Reason Code' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'category', type: 'string', title: 'Category' },
        { name: 'priority', type: 'integer', title: 'Priority' },
        { name: 'active', type: 'boolean', title: 'Active', defaultValue: true },
        { name: 'script', type: 'text', title: 'Call Script' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_call_logs',
      title: 'Call Logs',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'contact_id', type: 'string', title: 'Contact' },
        { name: 'lead_id', type: 'string', title: 'Lead' },
        { name: 'direction', type: 'string', title: 'Direction' },
        { name: 'status', type: 'string', title: 'Call Status' },
        { name: 'duration', type: 'integer', title: 'Duration (seconds)' },
        { name: 'reason_id', type: 'string', title: 'Contact Reason' },
        { name: 'outcome', type: 'string', title: 'Outcome' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'next_action', type: 'string', title: 'Next Action' },
        { name: 'next_follow_up', type: 'datetime', title: 'Next Follow Up' },
        { name: 'recorded_at', type: 'datetime', title: 'Recorded At' },
        { name: 'created_by', type: 'string', title: 'Created By' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_follow_ups',
      title: 'Follow-ups',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'contact_id', type: 'string', title: 'Contact' },
        { name: 'lead_id', type: 'string', title: 'Lead' },
        { name: 'type', type: 'string', title: 'Follow-up Type' },
        { name: 'reason', type: 'string', title: 'Reason' },
        { name: 'due_date', type: 'datetime', title: 'Due Date' },
        { name: 'completed', type: 'boolean', title: 'Completed', defaultValue: false },
        { name: 'completed_at', type: 'datetime', title: 'Completed At' },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_action_plans',
      title: 'Action Plans',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'name', type: 'string', title: 'Plan Name' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'type', type: 'string', title: 'Plan Type' },
        {
          name: 'status',
          type: 'string',
          title: 'Status',
          defaultValue: 'draft'
        },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'lead_id', type: 'string', title: 'Related Lead' },
        { name: 'contact_id', type: 'string', title: 'Related Contact' },
        { name: 'property_id', type: 'string', title: 'Related Property' },
        { name: 'deal_id', type: 'string', title: 'Related Deal' },
        { name: 'start_date', type: 'date', title: 'Start Date' },
        { name: 'due_date', type: 'date', title: 'Due Date' },
        { name: 'completion_percentage', type: 'integer', title: 'Completion %', defaultValue: 0 },
        { name: 'notes', type: 'text', title: 'Notes' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
      ]
    });

    db.collection({
      name: 'crm_tasks',
      title: 'Tasks',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'title', type: 'string', title: 'Task Title' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'action_plan_id', type: 'string', title: 'Action Plan' },
        { name: 'parent_task_id', type: 'string', title: 'Parent Task' },
        {
          name: 'status',
          type: 'string',
          title: 'Status',
          defaultValue: 'pending'
        },
        { name: 'priority', type: 'string', title: 'Priority' },
        { name: 'due_date', type: 'datetime', title: 'Due Date' },
        { name: 'start_date', type: 'datetime', title: 'Start Date' },
        { name: 'completed_at', type: 'datetime', title: 'Completed At' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'estimated_hours', type: 'decimal', title: 'Estimated Hours' },
        { name: 'actual_hours', type: 'decimal', title: 'Actual Hours' },
        { name: 'order', type: 'integer', title: 'Order' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
      ]
    });

    db.collection({
      name: 'crm_checklist_templates',
      title: 'Checklist Templates',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'name', type: 'string', title: 'Template Name' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'category', type: 'string', title: 'Category' },
        { name: 'active', type: 'boolean', title: 'Active', defaultValue: true },
        { name: 'items', type: 'text', title: 'Template Items (JSON)' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_checklist_items',
      title: 'Checklist Items',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'task_id', type: 'string', title: 'Task' },
        { name: 'template_id', type: 'string', title: 'Template' },
        { name: 'title', type: 'string', title: 'Item Title' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'completed', type: 'boolean', title: 'Completed', defaultValue: false },
        { name: 'completed_at', type: 'datetime', title: 'Completed At' },
        { name: 'completed_by', type: 'string', title: 'Completed By' },
        { name: 'order', type: 'integer', title: 'Order' },
        { name: 'due_date', type: 'datetime', title: 'Due Date' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_suburbs',
      title: 'Suburbs',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'name', type: 'string', title: 'Suburb Name' },
        { name: 'city', type: 'string', title: 'City' },
        { name: 'province', type: 'string', title: 'Province' },
        { name: 'region', type: 'string', title: 'Region' },
        { name: 'postal_code', type: 'string', title: 'Postal Code' },
        { name: 'latitude', type: 'decimal', title: 'Latitude' },
        { name: 'longitude', type: 'decimal', title: 'Longitude' },
        { name: 'average_price', type: 'decimal', title: 'Average Price' },
        { name: 'median_price', type: 'decimal', title: 'Median Price' },
        { name: 'price_trend', type: 'string', title: 'Price Trend' },
        { name: 'days_on_market', type: 'integer', title: 'Days on Market' },
        { name: 'inventory_count', type: 'integer', title: 'Inventory Count' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
        { name: 'updated_at', type: 'datetime', title: 'Updated At' },
      ]
    });

    db.collection({
      name: 'crm_suburb_reports',
      title: 'Suburb Reports',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'suburb_id', type: 'string', title: 'Suburb' },
        { name: 'report_type', type: 'string', title: 'Report Type' },
        { name: 'title', type: 'string', title: 'Report Title' },
        { name: 'data', type: 'jsonb', title: 'Report Data' },
        { name: 'report_date', type: 'date', title: 'Report Date' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_sectional_titles',
      title: 'Sectional Titles',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'scheme_name', type: 'string', title: 'Scheme Name' },
        { name: 'unit_number', type: 'string', title: 'Unit Number' },
        { name: 'address', type: 'string', title: 'Address' },
        { name: 'suburb', type: 'string', title: 'Suburb' },
        { name: 'body_corp', type: 'string', title: 'Body Corporate' },
        { name: 'levy', type: 'decimal', title: 'Monthly Levy' },
        { name: 'rates', type: 'decimal', title: 'Monthly Rates' },
        { name: 'parking', type: 'string', title: 'Parking' },
        { name: 'bedrooms', type: 'integer', title: 'Bedrooms' },
        { name: 'bathrooms', type: 'integer', title: 'Bathrooms' },
        { name: 'floor_area', type: 'decimal', title: 'Floor Area' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_scraped_leads',
      title: 'Scraped Leads',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'source', type: 'string', title: 'Source' },
        { name: 'source_url', type: 'string', title: 'Source URL' },
        { name: 'property_title', type: 'string', title: 'Property Title' },
        { name: 'address', type: 'string', title: 'Address' },
        { name: 'price', type: 'decimal', title: 'Price' },
        { name: 'property_type', type: 'string', title: 'Property Type' },
        { name: 'seller_name', type: 'string', title: 'Seller Name' },
        { name: 'seller_phone', type: 'string', title: 'Seller Phone' },
        { name: 'seller_email', type: 'string', title: 'Seller Email' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'features', type: 'text', title: 'Features' },
        { name: 'images', type: 'text', title: 'Images' },
        { name: 'listing_date', type: 'date', title: 'Listing Date' },
        { name: 'mandate_type', type: 'string', title: 'Mandate Type' },
        { name: 'imported', type: 'boolean', title: 'Imported to CRM', defaultValue: false },
        { name: 'imported_at', type: 'datetime', title: 'Imported At' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });

    db.collection({
      name: 'crm_activities',
      title: 'Activities',
      fields: [
        { name: 'id', type: 'snowflakeId', primaryKey: true },
        { name: 'type', type: 'string', title: 'Activity Type' },
        { name: 'subject', type: 'string', title: 'Subject' },
        { name: 'description', type: 'text', title: 'Description' },
        { name: 'contact_id', type: 'string', title: 'Contact' },
        { name: 'lead_id', type: 'string', title: 'Lead' },
        { name: 'property_id', type: 'string', title: 'Property' },
        { name: 'deal_id', type: 'string', title: 'Deal' },
        { name: 'assigned_to', type: 'string', title: 'Assigned To' },
        { name: 'due_date', type: 'datetime', title: 'Due Date' },
        { name: 'completed', type: 'boolean', title: 'Completed', defaultValue: false },
        { name: 'completed_at', type: 'datetime', title: 'Completed At' },
        { name: 'created_at', type: 'datetime', title: 'Created At' },
      ]
    });
  }

  async install() {
    const reasons = [
      { name: 'Birthday Wish', code: 'BIRTHDAY', category: 'Personal', priority: 1, description: 'Call to wish Happy Birthday', script: 'Hi [Name], just calling to wish you a very Happy Birthday! Hope you have a wonderful day ahead.' },
      { name: 'Anniversary of Purchase', code: 'PURCHASE_ANNIV', category: 'Personal', priority: 2, description: 'Call on anniversary of property purchase', script: 'Hi [Name], just calling to wish you Happy Anniversary on your property purchase! Time flies.' },
      { name: 'New Property in Street', code: 'NEW_LISTING_STREET', category: 'Property', priority: 1, description: 'Inform about new property listed in their street', script: 'Hi [Name], I just wanted to let you know that a new property has come up in your street. I thought you might be interested.' },
      { name: 'Price Reduced', code: 'PRICE_REDUCED', category: 'Property', priority: 1, description: 'Notify about price reduction on watched property', script: 'Hi [Name], great news! The property you were interested in has had a price reduction.' },
      { name: 'Property Just Listed', code: 'NEW_LISTING', category: 'Property', priority: 1, description: 'Inform about new property matching criteria', script: 'Hi [Name], I have a new listing that matches your requirements perfectly.' },
      { name: 'Market Update', code: 'MARKET_UPDATE', category: 'Value Add', priority: 3, description: 'Share market insights and trends', script: 'Hi [Name], I wanted to share some recent market updates in your area that might interest you.' },
      { name: 'Expired Listing', code: 'EXPIRED_LISTING', category: 'Opportunity', priority: 2, description: 'Contact owner of expired listing', script: 'Hi [Name], I noticed your property listing has expired. Would you be interested in a market appraisal?' },
      { name: 'New Development Nearby', code: 'NEW_DEVELOPMENT', category: 'Property', priority: 2, description: 'Inform about new developments in area', script: 'Hi [Name], there is a new development coming up in your area. Would you like more information?' },
      { name: 'School Zone Changed', code: 'SCHOOL_ZONE', category: 'Value Add', priority: 3, description: 'Notify about school zone changes', script: 'Hi [Name], I wanted to inform you about some changes in school zones that might affect your property value.' },
      { name: 'Infrastructure Updates', code: 'INFRASTRUCTURE', category: 'Value Add', priority: 3, description: 'Share infrastructure developments', script: 'Hi [Name], there are some exciting infrastructure developments in our area that could benefit you.' },
      { name: 'Interest Rate Changes', code: 'RATE_CHANGES', category: 'Value Add', priority: 2, description: 'Inform about interest rate changes', script: 'Hi [Name], I wanted to touch base about recent interest rate changes and how they might affect your property decisions.' },
      { name: 'Similar Property Sold', code: 'SIMILAR_SOLD', category: 'Property', priority: 2, description: 'Share information about similar properties sold', script: 'Hi [Name], a property similar to yours just sold. I wanted to share the details with you.' },
      { name: 'Open House Invitation', code: 'OPEN_HOUSE', category: 'Property', priority: 2, description: 'Invite to open house event', script: 'Hi [Name], we are having an open house this weekend. I would love to show you around.' },
      { name: 'Free Valuation Offer', code: 'VALUATION', category: 'Opportunity', priority: 1, description: 'Offer free property valuation', script: 'Hi [Name], I would like to offer you a free property valuation. No obligation.' },
      { name: 'Property Management Services', code: 'PM_SERVICES', category: 'Service', priority: 3, description: 'Promote property management services', script: 'Hi [Name], I wanted to tell you about our property management services if you are looking to rent out your property.' },
      { name: 'Investment Opportunity', code: 'INVESTMENT', category: 'Property', priority: 2, description: 'Share investment opportunities', script: 'Hi [Name], I have an investment opportunity that I think might interest you.' },
      { name: 'Downsizing/Upsizing Options', code: 'SIZE_OPTIONS', category: 'Property', priority: 3, description: 'Discuss property size options', script: 'Hi [Name], I wanted to check if you have considered upsizing/downsizing options in the current market.' },
      { name: 'Relocation Services', code: 'RELOCATION', category: 'Service', priority: 3, description: 'Offer relocation assistance', script: 'Hi [Name], if you are considering relocating, I can help you with the transition.' },
      { name: 'First-Time Buyer Info', code: 'FIRST_TIME_BUYER', category: 'Service', priority: 3, description: 'Provide first-time buyer information', script: 'Hi [Name], as a first-time buyer, there are some great programs and information I can share with you.' },
      { name: 'Seasonal Greetings', code: 'SEASONAL', category: 'Personal', priority: 4, description: 'Send seasonal holiday greetings', script: 'Hi [Name], wishing you and your family a wonderful [Season] from our team!' },
      { name: 'Follow-up After Viewing', code: 'FOLLOW_VIEWING', category: 'Follow-up', priority: 1, description: 'Follow up after property viewing', script: 'Hi [Name], thank you for viewing the property. What did you think? Any questions?' },
      { name: 'Feedback Request', code: 'FEEDBACK', category: 'Follow-up', priority: 2, description: 'Request feedback after service', script: 'Hi [Name], we value your feedback. How was your experience working with us?' },
    ];

    const db = this.app.db;
    const repo = db.getRepository('crm_contact_reasons');

    for (const reason of reasons) {
      try {
        await repo.create({ values: reason });
      } catch (e) {}
    }
  }

  async afterEnable() {}

  async afterDisable() {}

  async remove() {}
}

module.exports = {
  RealEstateCRMPlugin,
  default: RealEstateCRMPlugin,
};
