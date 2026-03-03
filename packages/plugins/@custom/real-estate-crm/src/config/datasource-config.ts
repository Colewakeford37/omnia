/**
 * Data Source Integration Configuration
 * 
 * This file provides configurations for integrating multiple data sources:
 * 1. Scraper Data (NeonDB) - Property24, Private Property, Rent Guru, Facebook Groups
 * 2. Supabase Suburb Data - Age demographics, sales history, sectional titles
 * 3. Local Database - Previous sellers, property history, communications
 */

// ========================================
// 1. SCRAPER DATA SOURCE (NEONDB)
// ========================================

export const SCRAPER_SOURCES = {
  property24: {
    name: 'Property24',
    code: 'p24',
    enabled: true,
    url: 'https://www.property24.com',
    scrape_types: ['sole_mandate', 'private_seller'],
    fields_mapping: {
      title: 'property_title',
      address: 'address',
      price: 'price',
      bedrooms: 'bedrooms',
      bathrooms: 'bathrooms',
      property_type: 'property_type',
      description: 'description',
      features: 'features',
      images: 'images',
      seller_name: 'seller_name',
      seller_phone: 'seller_phone',
      seller_email: 'seller_email',
      listing_date: 'listing_date',
      mandate_type: 'mandate_type'
    },
    sync_interval: '1h',
    import_to_collection: 'crm_scraped_leads'
  },
  
  private_property: {
    name: 'Private Property',
    code: 'pp',
    enabled: true,
    url: 'https://www.privateproperty.co.za',
    scrape_types: ['private_seller', 'sole_mandate'],
    fields_mapping: {
      title: 'title',
      address: 'address',
      price: 'asking_price',
      bedrooms: 'beds',
      bathrooms: 'baths',
      property_type: 'type',
      description: 'description',
      features: 'amenities',
      images: 'gallery',
      seller: 'owner_name',
      contact: 'owner_contact',
      listed: 'date_listed'
    },
    sync_interval: '2h',
    import_to_collection: 'crm_scraped_leads'
  },
  
  rent_guru: {
    name: 'Rent Guru',
    code: 'rg',
    enabled: true,
    url: 'https://www.rentguru.co.za',
    scrape_types: ['rental', 'to_let'],
    fields_mapping: {
      title: 'rental_title',
      address: 'location',
      price: 'monthly_rent',
      bedrooms: 'bedrooms',
      bathrooms: 'bathrooms',
      property_type: 'property_type',
      description: 'details',
      available_from: 'available_date',
      landlord: 'landlord_name',
      contact: 'landlord_phone'
    },
    sync_interval: '3h',
    import_to_collection: 'crm_scraped_leads'
  },
  
  facebook_groups: {
    name: 'Facebook Groups',
    code: 'fb',
    enabled: true,
    groups: [
      'Property for Sale - South Africa',
      'Private Property Listings SA',
      'Sole Mandate Properties SA',
      'South Africa Real Estate'
    ],
    fields_mapping: {
      post_title: 'listing_title',
      post_content: 'description',
      location: 'area',
      price: 'asking_price',
      contact_name: 'seller_name',
      contact_phone: 'seller_phone',
      post_date: 'posted_date',
      group_name: 'source_group'
    },
    sync_interval: '30m',
    import_to_collection: 'crm_scraped_leads'
  }
};

// ========================================
// 2. SUPABASE SUBURB DATA SOURCE
// ========================================

export const SUPABASE_CONFIG = {
  enabled: true,
  connection: {
    url: process.env.SUPABASE_URL || 'https://your-project.supabase.co',
    key: process.env.SUPABASE_ANON_KEY || 'your-anon-key'
  },
  tables: {
    suburbs: {
      table_name: 'suburbs',
      sync_interval: '24h',
      fields: [
        { source: 'id', target: 'id' },
        { source: 'name', target: 'name' },
        { source: 'city', target: 'city' },
        { source: 'province', target: 'province' },
        { source: 'region', target: 'region' },
        { source: 'postal_code', target: 'postal_code' },
        { source: 'latitude', target: 'latitude' },
        { source: 'longitude', target: 'longitude' },
        { source: 'average_price', target: 'average_price' },
        { source: 'median_price', target: 'median_price' },
        { source: 'price_trend', target: 'price_trend' },
        { source: 'days_on_market', target: 'days_on_market' },
        { source: 'inventory_count', target: 'inventory_count' }
      ]
    },
    suburb_demographics: {
      table_name: 'suburb_demographics',
      sync_interval: '168h', // weekly
      fields: [
        { source: 'suburb_id', target: 'suburb_id' },
        { source: 'median_age', target: 'median_age' },
        { source: 'population', target: 'population' },
        { source: 'household_income', target: 'household_income' },
        { source: 'employment_rate', target: 'employment_rate' },
        { source: 'owner_occupied_pct', target: 'owner_occupied_pct' },
        { source: 'rental_pct', target: 'rental_pct' },
        { source: 'family_households', target: 'family_households' },
        { source: 'single_person_households', target: 'single_person_households' }
      ]
    },
    sales_history: {
      table_name: 'sales_history',
      sync_interval: '24h',
      fields: [
        { source: 'suburb_id', target: 'suburb_id' },
        { source: 'sale_date', target: 'sale_date' },
        { source: 'property_type', target: 'property_type' },
        { source: 'sale_price', target: 'sale_price' },
        { source: 'bedrooms', target: 'bedrooms' },
        { source: 'bathrooms', target: 'bathrooms' },
        { source: 'floor_area', target: 'floor_area' },
        { source: 'erf_size', target: 'erf_size' }
      ]
    },
    sectional_titles: {
      table_name: 'sectional_titles',
      sync_interval: '168h',
      fields: [
        { source: 'scheme_name', target: 'scheme_name' },
        { source: 'unit_number', target: 'unit_number' },
        { source: 'address', target: 'address' },
        { source: 'suburb', target: 'suburb' },
        { source: 'body_corp', target: 'body_corp' },
        { source: 'monthly_levy', target: 'levy' },
        { source: 'monthly_rates', target: 'rates' },
        { source: 'parking', target: 'parking' },
        { source: 'bedrooms', target: 'bedrooms' },
        { source: 'bathrooms', target: 'bathrooms' },
        { source: 'floor_area', target: 'floor_area' }
      ]
    },
    estate_reports: {
      table_name: 'estate_reports',
      sync_interval: '720h', // monthly
      fields: [
        { source: 'estate_name', target: 'estate_name' },
        { source: 'suburb', target: 'suburb' },
        { source: 'total_units', target: 'total_units' },
        { source: 'sold_units', target: 'sold_units' },
        { source: 'available_units', target: 'available_units' },
        { source: 'average_price', target: 'average_price' },
        { source: 'facilities', target: 'facilities' },
        { source: 'security_features', target: 'security_features' }
      ]
    }
  }
};

// ========================================
// 3. LOCAL DATABASE CONFIGURATION
// ========================================

export const LOCAL_DB_CONFIG = {
  enabled: true,
  connection: {
    type: 'postgres',
    host: process.env.LOCAL_DB_HOST || 'localhost',
    port: parseInt(process.env.LOCAL_DB_PORT || '5432'),
    database: process.env.LOCAL_DB_NAME || 'realestate',
    user: process.env.LOCAL_DB_USER || 'postgres',
    password: process.env.LOCAL_DB_PASSWORD || 'password'
  },
  tables: {
    previous_sellers: {
      table_name: 'previous_sellers',
      sync_interval: '24h',
      fields: [
        { source: 'id', target: 'id' },
        { source: 'name', target: 'full_name' },
        { source: 'email', target: 'email' },
        { source: 'phone', target: 'phone' },
        { source: 'mobile', target: 'mobile' },
        { source: 'address', target: 'address' },
        { source: 'suburb', target: 'suburb' },
        { source: 'property_sold', target: 'property_sold' },
        { source: 'sale_date', target: 'sale_date' },
        { source: 'sale_price', target: 'sale_price' },
        { source: 'birthday', target: 'birthday' },
        { source: 'anniversary', target: 'anniversary' },
        { source: 'last_contact', target: 'last_contacted' },
        { source: 'engagement_score', target: 'engagement_score' }
      ],
      // Cold calling links - 20+ working principles applied
      engagement_triggers: [
        {
          trigger: 'birthday',
          days_before: 0,
          reason_code: 'BIRTHDAY',
          contact_method: 'phone'
        },
        {
          trigger: 'anniversary',
          days_before: 0,
          reason_code: 'PURCHASE_ANNIV',
          contact_method: 'phone'
        },
        {
          trigger: '6_months_since_sale',
          days_after: 180,
          reason_code: 'MARKET_UPDATE',
          contact_method: 'email'
        },
        {
          trigger: '12_months_since_sale',
          days_after: 365,
          reason_code: 'VALUATION',
          contact_method: 'phone'
        },
        {
          trigger: 'new_neighbor',
          days_after: 30,
          reason_code: 'NEW_NEIGHBOR',
          contact_method: 'phone'
        }
      ]
    },
    property_history: {
      table_name: 'property_history',
      sync_interval: '24h',
      fields: [
        { source: 'id', target: 'id' },
        { source: 'address', target: 'address' },
        { source: 'suburb', target: 'suburb' },
        { source: 'owner', target: 'owner_name' },
        { source: 'owner_contact', target: 'owner_phone' },
        { source: 'previous_sale_date', target: 'last_sale_date' },
        { source: 'previous_sale_price', target: 'last_sale_price' },
        { source: 'previous_owner', target: 'previous_owner' },
        { source: 'listed_date', target: 'listing_date' },
        { source: 'listed_price', target: 'listing_price' },
        { source: 'status', target: 'status' }
      ],
      // Property-level triggers
      triggers: [
        {
          event: 'new_listing_street',
          reason_code: 'NEW_LISTING_STREET',
          notify_radius_km: 0.5
        },
        {
          event: 'price_reduction',
          reason_code: 'PRICE_REDUCED',
          notify_previous_interested: true
        },
        {
          event: 'listing_expired',
          reason_code: 'EXPIRED_LISTING',
          notify_owner: true
        }
      ]
    },
    communications: {
      table_name: 'communications',
      sync_interval: '1h',
      fields: [
        { source: 'id', target: 'id' },
        { source: 'contact_id', target: 'contact_id' },
        { source: 'type', target: 'type' },
        { source: 'direction', target: 'direction' },
        { source: 'outcome', target: 'outcome' },
        { source: 'notes', target: 'notes' },
        { source: 'recorded_at', target: 'recorded_at' },
        { source: 'agent', target: 'created_by' }
      ]
    }
  }
};

// ========================================
// COLD CALLING - 20+ WORKING PRINCIPLES
// ========================================

export const COLD_CALLING_PRINCIPLES = [
  {
    id: 1,
    name: 'Birthday Wish',
    code: 'BIRTHDAY',
    category: 'Personal',
    priority: 1,
    description: 'Call to wish Happy Birthday - strengthens relationship',
    script: 'Hi [Name], just calling to wish you a very Happy Birthday! Hope you have a wonderful day ahead.',
    best_time: 'morning',
    expected_outcome: 'Strengthened relationship'
  },
  {
    id: 2,
    name: 'Anniversary of Purchase',
    code: 'PURCHASE_ANNIV',
    category: 'Personal',
    priority: 2,
    description: 'Call on anniversary of property purchase',
    script: 'Hi [Name], just calling to wish you Happy Anniversary on your property purchase! Time flies.',
    best_time: 'afternoon',
    expected_outcome: 'Emotional connection, potential referral'
  },
  {
    id: 3,
    name: 'New Property in Street',
    code: 'NEW_LISTING_STREET',
    category: 'Property',
    priority: 1,
    description: 'Inform about new property listed in their street',
    script: 'Hi [Name], I just wanted to let you know that a new property has come up in your street. I thought you might be interested.',
    best_time: 'evening',
    expected_outcome: 'Generate interest, possible viewing'
  },
  {
    id: 4,
    name: 'Price Reduced',
    code: 'PRICE_REDUCED',
    category: 'Property',
    priority: 1,
    description: 'Notify about price reduction on watched property',
    script: 'Hi [Name], great news! The property you were interested in has had a price reduction.',
    best_time: 'morning',
    expected_outcome: 'Revive interest, schedule viewing'
  },
  {
    id: 5,
    name: 'Property Just Listed',
    code: 'NEW_LISTING',
    category: 'Property',
    priority: 1,
    description: 'Inform about new property matching criteria',
    script: 'Hi [Name], I have a new listing that matches your requirements perfectly.',
    best_time: 'any',
    expected_outcome: 'Schedule viewing, add to portfolio'
  },
  {
    id: 6,
    name: 'Market Update',
    code: 'MARKET_UPDATE',
    category: 'Value Add',
    priority: 3,
    description: 'Share market insights and trends',
    script: 'Hi [Name], I wanted to share some recent market updates in your area that might interest you.',
    best_time: 'weekday_morning',
    expected_outcome: 'Position as expert, build trust'
  },
  {
    id: 7,
    name: 'Expired Listing',
    code: 'EXPIRED_LISTING',
    category: 'Opportunity',
    priority: 2,
    description: 'Contact owner of expired listing',
    script: 'Hi [Name], I noticed your property listing has expired. Would you be interested in a market appraisal?',
    best_time: 'afternoon',
    expected_outcome: 'Get new listing mandate'
  },
  {
    id: 8,
    name: 'New Development Nearby',
    code: 'NEW_DEVELOPMENT',
    category: 'Property',
    priority: 2,
    description: 'Inform about new developments in area',
    script: 'Hi [Name], there is a new development coming up in your area. Would you like more information?',
    best_time: 'weekend_morning',
    expected_outcome: 'Generate leads, investment interest'
  },
  {
    id: 9,
    name: 'School Zones Changed',
    code: 'SCHOOL_ZONE',
    category: 'Value Add',
    priority: 3,
    description: 'Notify about school zone changes',
    script: 'Hi [Name], I wanted to inform you about some changes in school zones that might affect your property value.',
    best_time: 'evening',
    expected_outcome: 'Value-add call, position as expert'
  },
  {
    id: 10,
    name: 'Infrastructure Updates',
    code: 'INFRASTRUCTURE',
    category: 'Value Add',
    priority: 3,
    description: 'Share infrastructure developments',
    script: 'Hi [Name], there are some exciting infrastructure developments in our area that could benefit you.',
    best_time: 'weekday_afternoon',
    expected_outcome: 'Value-add call, market positioning'
  },
  {
    id: 11,
    name: 'Interest Rate Changes',
    code: 'RATE_CHANGES',
    category: 'Value Add',
    priority: 2,
    description: 'Inform about interest rate changes',
    script: 'Hi [Name], I wanted to touch base about recent interest rate changes and how they might affect your property decisions.',
    best_time: 'morning',
    expected_outcome: 'Timing opportunity, buyer/seller readiness'
  },
  {
    id: 12,
    name: 'Similar Property Sold',
    code: 'SIMILAR_SOLD',
    category: 'Property',
    priority: 2,
    description: 'Share information about similar properties sold',
    script: 'Hi [Name], a property similar to yours just sold. I wanted to share the details with you.',
    best_time: 'any',
    expected_outcome: 'Price validation, market confidence'
  },
  {
    id: 13,
    name: 'Open House Invitation',
    code: 'OPEN_HOUSE',
    category: 'Property',
    priority: 2,
    description: 'Invite to open house event',
    script: 'Hi [Name], we are having an open house this weekend. I would love to show you around.',
    best_time: 'weekday_evening',
    expected_outcome: 'Foot traffic, property exposure'
  },
  {
    id: 14,
    name: 'Free Valuation Offer',
    code: 'VALUATION',
    category: 'Opportunity',
    priority: 1,
    description: 'Offer free property valuation',
    script: 'Hi [Name], I would like to offer you a free property valuation. No obligation.',
    best_time: 'morning',
    expected_outcome: 'Lead generation, listing opportunity'
  },
  {
    id: 15,
    name: 'Property Management Services',
    code: 'PM_SERVICES',
    category: 'Service',
    priority: 3,
    description: 'Promote property management services',
    script: 'Hi [Name], I wanted to tell you about our property management services if you are looking to rent out your property.',
    best_time: 'afternoon',
    expected_outcome: 'Generate PM business'
  },
  {
    id: 16,
    name: 'Investment Opportunity',
    code: 'INVESTMENT',
    category: 'Property',
    priority: 2,
    description: 'Share investment opportunities',
    script: 'Hi [Name], I have an investment opportunity that I think might interest you.',
    best_time: 'weekday_morning',
    expected_outcome: 'Investment lead, portfolio expansion'
  },
  {
    id: 17,
    name: 'Downsizing/Upsizing Options',
    code: 'SIZE_OPTIONS',
    category: 'Property',
    priority: 3,
    description: 'Discuss property size options',
    script: 'Hi [Name], I wanted to check if you have considered upsizing/downsizing options in the current market.',
    best_time: 'evening',
    expected_outcome: 'Life stage transition opportunity'
  },
  {
    id: 18,
    name: 'Relocation Services',
    code: 'RELOCATION',
    category: 'Service',
    priority: 3,
    description: 'Offer relocation assistance',
    script: 'Hi [Name], if you are considering relocating, I can help you with the transition.',
    best_time: 'any',
    expected_outcome: 'Relocation referral, new market presence'
  },
  {
    id: 19,
    name: 'First-Time Buyer Info',
    code: 'FIRST_TIME_BUYER',
    category: 'Service',
    priority: 3,
    description: 'Provide first-time buyer information',
    script: 'Hi [Name], as a first-time buyer, there are some great programs and information I can share with you.',
    best_time: 'weekend',
    expected_outcome: 'Nurture future client'
  },
  {
    id: 20,
    name: 'Seasonal Greetings',
    code: 'SEASONAL',
    category: 'Personal',
    priority: 4,
    description: 'Send seasonal holiday greetings',
    script: 'Hi [Name], wishing you and your family a wonderful [Season] from our team!',
    best_time: 'holiday_season',
    expected_outcome: 'Relationship maintenance'
  },
  {
    id: 21,
    name: 'Follow-up After Viewing',
    code: 'FOLLOW_VIEWING',
    category: 'Follow-up',
    priority: 1,
    description: 'Follow up after property viewing',
    script: 'Hi [Name], thank you for viewing the property. What did you think? Any questions?',
    best_time: 'same_day',
    expected_outcome: 'Feedback, next steps'
  },
  {
    id: 22,
    name: 'Feedback Request',
    code: 'FEEDBACK',
    category: 'Follow-up',
    priority: 2,
    description: 'Request feedback after service',
    script: 'Hi [Name], we value your feedback. How was your experience working with us?',
    best_time: 'after_service',
    expected_outcome: 'Improve service, get referrals'
  }
];

// ========================================
// SYNC SCHEDULES
// ========================================

export const SYNC_SCHEDULES = {
  scraper_data: {
    property24: '0 * * * *', // Every hour
    private_property: '0 */2 * * *', // Every 2 hours
    rent_guru: '0 */3 * * *', // Every 3 hours
    facebook_groups: '0 */30 * * *' // Every 30 minutes
  },
  supabase_data: {
    suburbs: '0 1 * * *', // Daily at 1 AM
    demographics: '0 2 * * 0', // Weekly on Sunday
    sales_history: '0 2 * * *', // Daily at 2 AM
    sectional_titles: '0 3 * * 0', // Weekly on Sunday
    estate_reports: '0 4 1 * *' // Monthly on 1st
  },
  local_db: {
    previous_sellers: '0 3 * * *', // Daily at 3 AM
    property_history: '0 4 * * *', // Daily at 4 AM
    communications: '0 */1 * * *' // Every hour
  }
};

export default {
  SCRAPER_SOURCES,
  SUPABASE_CONFIG,
  LOCAL_DB_CONFIG,
  COLD_CALLING_PRINCIPLES,
  SYNC_SCHEDULES
};
