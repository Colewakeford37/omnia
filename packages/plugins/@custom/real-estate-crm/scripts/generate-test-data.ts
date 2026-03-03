/**
 * Test Data Generator for Real Estate CRM
 * 
 * This script generates realistic test data for the CRM presentation.
 * Run this after installing the plugin to populate the database.
 */

import { Database } from '@nocobase/database';

const FIRST_NAMES = [
  'John', 'Jane', 'Michael', 'Sarah', 'David', 'Emily', 'Robert', 'Jennifer',
  'William', 'Lisa', 'James', 'Mary', 'Richard', 'Patricia', 'Thomas', 'Linda',
  'Daniel', 'Barbara', 'Matthew', 'Susan', 'Anthony', 'Jessica', 'Mark', 'Karen',
  'Paul', 'Nancy', 'Steven', 'Betty', 'Andrew', 'Margaret', 'Joshua', 'Sandra'
];

const LAST_NAMES = [
  'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
  'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
  'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
  'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker'
];

const SUBURBS = [
  { name: 'Sandton', city: 'Johannesburg', province: 'Gauteng', avgPrice: 2500000 },
  { name: 'Rosebank', city: 'Johannesburg', province: 'Gauteng', avgPrice: 1800000 },
  { name: 'Waterkloof', city: 'Pretoria', province: 'Gauteng', avgPrice: 2100000 },
  { name: 'Milnerton', city: 'Cape Town', province: 'Western Cape', avgPrice: 1950000 },
  { name: 'Stellenbosch', city: 'Stellenbosch', province: 'Western Cape', avgPrice: 2200000 },
  { name: 'Durban North', city: 'Durban', province: 'KwaZulu-Natal', avgPrice: 1400000 },
  { name: 'Umhlanga', city: 'Durban', province: 'KwaZulu-Natal', avgPrice: 1650000 },
  { name: 'Bedfordview', city: 'Johannesburg', province: 'Gauteng', avgPrice: 1500000 },
  { name: 'Fourways', city: 'Johannesburg', province: 'Gauteng', avgPrice: 1750000 },
  { name: 'Centurion', city: 'Pretoria', province: 'Gauteng', avgPrice: 1350000 }
];

const PROPERTY_TYPES = ['House', 'Apartment', 'Townhouse', 'Condo', 'Villa', 'Plot', 'Farm'];
const LEAD_SOURCES = ['Property24', 'Private Property', 'Referral', 'Facebook', 'Website', 'Cold Call', 'Walk-in'];
const LEAD_STATUSES = ['new', 'contacted', 'qualified', 'proposal', 'negotiation', 'won', 'lost'];
const DEAL_STAGES = ['prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost'];
const PROPERTY_STATUSES = ['active', 'under_offer', 'sold', 'withdrawn', 'expired'];

function randomElement(arr: any[]) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function generatePhone() {
  return `+27${randomInt(61, 82)}${randomInt(1000000, 9999999)}`;
}

function generateEmail(firstName: string, lastName: string) {
  return `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${randomElement(['gmail.com', 'yahoo.com', 'outlook.com', 'icloud.com'])}`;
}

function generateBirthday() {
  const start = new Date(1960, 0, 1);
  const end = new Date(1995, 11, 31);
  const date = new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  return date.toISOString().split('T')[0];
}

function generateAnniversary() {
  const start = new Date(2015, 0, 1);
  const end = new Date(2023, 11, 31);
  const date = new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  return date.toISOString().split('T')[0];
}

export async function generateTestData(db: Database) {
  console.log('Starting test data generation...');

  // 1. Generate Leads
  console.log('Generating leads...');
  const leadsRepo = db.getRepository('crm_leads');
  for (let i = 0; i < 60; i++) {
    const firstName = randomElement(FIRST_NAMES);
    const lastName = randomElement(LAST_NAMES);
    await leadsRepo.create({
      values: {
        first_name: firstName,
        last_name: lastName,
        full_name: `${firstName} ${lastName}`,
        email: generateEmail(firstName, lastName),
        phone: generatePhone(),
        mobile: generatePhone(),
        company: Math.random() > 0.5 ? `${lastName} ${randomElement(['Properties', 'Investments', 'Holdings', 'Group'])}` : null,
        status: randomElement(LEAD_STATUSES),
        source: randomElement(LEAD_SOURCES),
        source_detail: randomElement(['Organic', 'Paid', 'Referral', 'Direct']),
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams', 'Agent Davis']),
        notes: randomElement([
          'Looking for a family home in a good school area',
          'Investment property - looking for rental yield',
          'Downsizing from larger property',
          'First-time buyer - needs guidance',
          'Relocating from another city',
          'Looking for commercial property'
        ]),
        budget_min: randomInt(500000, 1500000),
        budget_max: randomInt(2000000, 5000000),
        preferred_location: randomElement(SUBURBS).name,
        property_type: randomElement(PROPERTY_TYPES),
        bedrooms_required: randomInt(2, 5),
        timeline: randomElement(['Immediate', '1-3 months', '3-6 months', '6-12 months']),
        rating: randomInt(1, 5),
        last_contacted: new Date(Date.now() - randomInt(1, 30) * 24 * 60 * 60 * 1000).toISOString(),
        next_follow_up: new Date(Date.now() + randomInt(1, 14) * 24 * 60 * 60 * 1000).toISOString()
      }
    });
  }

  // 2. Generate Contacts
  console.log('Generating contacts...');
  const contactsRepo = db.getRepository('crm_contacts');
  for (let i = 0; i < 120; i++) {
    const firstName = randomElement(FIRST_NAMES);
    const lastName = randomElement(LAST_NAMES);
    const suburb = randomElement(SUBURBS);
    await contactsRepo.create({
      values: {
        first_name: firstName,
        last_name: lastName,
        full_name: `${firstName} ${lastName}`,
        email: generateEmail(firstName, lastName),
        phone: generatePhone(),
        mobile: generatePhone(),
        address: `${randomInt(1, 500)} ${randomElement(['Main', 'Oak', 'Pine', 'Maple', 'Cedar'])} ${randomElement(['Street', 'Road', 'Avenue', 'Drive'])}`,
        city: suburb.city,
        suburb: suburb.name,
        province: suburb.province,
        postal_code: `${randomInt(1000, 9999)}`,
        country: 'South Africa',
        birthday: generateBirthday(),
        anniversary: generateAnniversary(),
        type: randomElement(['prospect', 'customer', 'vendor', 'partner']),
        company: Math.random() > 0.6 ? `${lastName} ${randomElement(['Pty Ltd', 'Inc', 'Corp', 'Associates'])}` : null,
        job_title: randomElement(['CEO', 'Manager', 'Director', 'Employee', 'Entrepreneur', 'Retired']),
        source: randomElement(LEAD_SOURCES),
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams', 'Agent Davis']),
        notes: randomElement([
          'Very interested in Waterkloof area',
          'Has children - needs school nearby',
          'Investor - cash buyer',
          'Flexible on timing',
          'Looking for renovation opportunity'
        ]),
        engagement_score: randomInt(0, 100),
        last_contacted: new Date(Date.now() - randomInt(1, 60) * 24 * 60 * 60 * 1000).toISOString(),
        next_follow_up: new Date(Date.now() + randomInt(1, 30) * 24 * 60 * 60 * 1000).toISOString(),
        preferred_contact_method: randomElement(['phone', 'email', 'whatsapp']),
        preferred_contact_time: randomElement(['morning', 'afternoon', 'evening']),
        do_not_call: Math.random() > 0.95,
        do_not_email: Math.random() > 0.98
      }
    });
  }

  // 3. Generate Properties
  console.log('Generating properties...');
  const propertiesRepo = db.getRepository('crm_properties');
  for (let i = 0; i < 45; i++) {
    const suburb = randomElement(SUBURBS);
    const propertyType = randomElement(PROPERTY_TYPES);
    const basePrice = suburb.avgPrice * (randomInt(70, 150) / 100);
    await propertiesRepo.create({
      values: {
        title: `${propertyType} in ${suburb.name}`,
        address: `${randomInt(1, 500)} ${randomElement(['Main', 'Oak', 'Pine', 'Maple', 'Cedar', ' Elm', 'Willow'])} ${randomElement(['Street', 'Road', 'Avenue', 'Drive', 'Lane'])}`,
        street_number: String(randomInt(1, 500)),
        street_name: `${randomElement(['Main', 'Oak', 'Pine', 'Maple', 'Cedar'])} ${randomElement(['Street', 'Road', 'Avenue', 'Drive'])}`,
        suburb: suburb.name,
        city: suburb.city,
        province: suburb.province,
        postal_code: `${randomInt(1000, 9999)}`,
        country: 'South Africa',
        property_type: propertyType,
        listing_type: randomElement(['sale', 'rent', 'sole_mandate']),
        price: basePrice,
        price_display: `R${(basePrice / 1000000).toFixed(2)}M`,
        negotiable: Math.random() > 0.3,
        bedrooms: randomInt(1, 6),
        bathrooms: randomInt(1, 4),
        garage: randomInt(0, 3),
        parking: randomInt(0, 4),
        floor_area: randomInt(50, 500),
        land_size: randomInt(200, 2000),
        year_built: randomInt(1950, 2024),
        floors: randomInt(1, 3),
        living_areas: randomInt(1, 3),
        status: randomElement(PROPERTY_STATUSES),
        description: randomElement([
          'Beautiful family home in quiet suburb. Recently renovated with modern finishes.',
          'Spacious property with stunning views. Perfect for entertaining.',
          'Cozy home close to schools and amenities. Great investment opportunity.',
          'Luxurious property with pool and garden. Must see!',
          'Character home with original features. Lots of potential.'
        ]),
        features: randomElement([
          'Pool, Garden, Garage, Security',
          'Kitchen, Scullery, Patio, Borehole',
          'Home Office, WiFi, Garden, Parking',
          'Pool, Gym, Security, Garden',
          'Solar, Generator, Water Tank, Alarm'
        ]),
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams', 'Agent Davis']),
        owner_name: `${randomElement(FIRST_NAMES)} ${randomElement(LAST_NAMES)}`,
        owner_phone: generatePhone(),
        owner_email: generateEmail(randomElement(FIRST_NAMES), randomElement(LAST_NAMES)),
        mandate_type: randomElement(['sole', 'shared', 'open']),
        mandate_expiry: new Date(Date.now() + randomInt(30, 180) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        listing_date: new Date(Date.now() - randomInt(1, 90) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        source: randomElement(['Property24', 'Private Property', 'Direct', 'Referral']),
        viewings_count: randomInt(0, 50),
        inquiries_count: randomInt(0, 30)
      }
    });
  }

  // 4. Generate Deals
  console.log('Generating deals...');
  const dealsRepo = db.getRepository('crm_deals');
  for (let i = 0; i < 30; i++) {
    const suburb = randomElement(SUBURBS);
    const value = suburb.avgPrice * (randomInt(80, 120) / 100);
    await dealsRepo.create({
      values: {
        title: `Deal - ${suburb.name} Property`,
        stage: randomElement(DEAL_STAGES),
        value: value,
        commission: value * 0.025,
        probability: randomInt(10, 100),
        expected_close_date: new Date(Date.now() + randomInt(7, 90) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams', 'Agent Davis']),
        notes: randomElement([
          'Good potential client',
          'Needs financing',
          'Decision maker',
          'Ready to close'
        ])
      }
    });
  }

  // 5. Generate Action Plans
  console.log('Generating action plans...');
  const actionPlansRepo = db.getRepository('crm_action_plans');
  const actionPlanTemplates = [
    { name: 'New Lead Follow-up', description: 'Systematic follow-up for new leads' },
    { name: 'Property Listing Campaign', description: 'Marketing campaign for new listing' },
    { name: 'Buyer Journey', description: 'Guide buyer through purchase process' },
    { name: 'Seller Onboarding', description: 'Onboarding new seller clients' },
    { name: 'Expired Listing Revival', description: 'Revive expired listings' },
    { name: 'Referral Program', description: 'Follow up on referral opportunities' }
  ];
  
  for (let i = 0; i < 15; i++) {
    const template = randomElement(actionPlanTemplates);
    await actionPlansRepo.create({
      values: {
        name: template.name,
        description: template.description,
        type: randomElement(['sales', 'marketing', 'onboarding', 'followup']),
        status: randomElement(['draft', 'active', 'completed', 'cancelled']),
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams']),
        start_date: new Date(Date.now() - randomInt(1, 30) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        due_date: new Date(Date.now() + randomInt(7, 60) * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        completion_percentage: randomInt(0, 100),
        notes: template.description
      }
    });
  }

  // 6. Generate Tasks
  console.log('Generating tasks...');
  const tasksRepo = db.getRepository('crm_tasks');
  const taskTemplates = [
    'Make initial contact call',
    'Send property listings',
    'Schedule property viewing',
    'Follow up after viewing',
    'Prepare offer documentation',
    'Negotiate with seller',
    'Coordinate with attorney',
    'Arrange home inspection',
    'Finalize sale agreement',
    'Post-sale follow-up'
  ];
  
  for (let i = 0; i < 50; i++) {
    await tasksRepo.create({
      values: {
        title: randomElement(taskTemplates),
        description: randomElement(['High priority task', 'Standard follow-up', 'Documentation required']),
        status: randomElement(['pending', 'in_progress', 'completed', 'cancelled']),
        priority: randomElement(['high', 'medium', 'low']),
        due_date: new Date(Date.now() + randomInt(-7, 30) * 24 * 60 * 60 * 1000).toISOString(),
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams', 'Agent Davis']),
        estimated_hours: randomInt(1, 8),
        order: randomInt(1, 10)
      }
    });
  }

  // 7. Generate Checklist Templates
  console.log('Generating checklist templates...');
  const checklistTemplatesRepo = db.getRepository('crm_checklist_templates');
  const checklistData = [
    {
      name: 'Property Listing Checklist',
      description: 'Complete checklist for listing a property',
      category: 'Listing',
      items: JSON.stringify([
        'Conduct property valuation',
        'Take professional photos',
        'Write property description',
        'List property on portals',
        'Install signage',
        'Schedule open house',
        'Notify neighbors'
      ])
    },
    {
      name: 'Buyer Onboarding',
      description: 'Steps for new buyer clients',
      category: 'Sales',
      items: JSON.stringify([
        'Complete buyer profile',
        'Discuss budget and requirements',
        'Pre-qualify for finance',
        'Schedule property viewings',
        'Provide market analysis',
        'Make offer on property',
        'Coordinate conveyancer'
      ])
    },
    {
      name: 'Lead Qualification',
      description: 'Qualify new leads effectively',
      category: 'Sales',
      items: JSON.stringify([
        'Verify contact details',
        'Identify needs and wants',
        'Check budget compatibility',
        'Assess timeline',
        'Identify decision makers',
        'Schedule initial viewing',
        'Follow up within 24 hours'
      ])
    }
  ];
  
  for (const template of checklistData) {
    await checklistTemplatesRepo.create({ values: template });
  }

  // 8. Generate Call Logs
  console.log('Generating call logs...');
  const callLogsRepo = db.getRepository('crm_call_logs');
  const outcomes = ['Interested', 'Not Interested', 'No Answer', 'Callback Later', 'Wrong Number', 'Voicemail'];
  const directions = ['inbound', 'outbound'];
  
  for (let i = 0; i < 80; i++) {
    await callLogsRepo.create({
      values: {
        direction: randomElement(directions),
        status: 'completed',
        duration: randomInt(30, 1800),
        outcome: randomElement(outcomes),
        notes: randomElement([
          'Good conversation, scheduled viewing',
          'Not ready to buy yet',
          'Looking in different area',
          'Budget too low',
          'Already purchased',
          'Very interested, will call back'
        ]),
        next_action: randomElement(['Schedule viewing', 'Send listings', 'Follow up next week', 'Send market report']),
        next_follow_up: new Date(Date.now() + randomInt(1, 14) * 24 * 60 * 60 * 1000).toISOString(),
        recorded_at: new Date(Date.now() - randomInt(1, 30) * 24 * 60 * 60 * 1000).toISOString(),
        created_by: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams'])
      }
    });
  }

  // 9. Generate Follow-ups
  console.log('Generating follow-ups...');
  const followUpsRepo = db.getRepository('crm_follow_ups');
  const followUpTypes = ['call', 'email', 'meeting', 'viewing'];
  
  for (let i = 0; i < 40; i++) {
    await followUpsRepo.create({
      values: {
        type: randomElement(followUpTypes),
        reason: randomElement([
          'New listing in area',
          'Price reduction',
          'Market update',
          'Property viewing feedback',
          'General check-in'
        ]),
        due_date: new Date(Date.now() + randomInt(-5, 21) * 24 * 60 * 60 * 1000).toISOString(),
        completed: Math.random() > 0.4,
        completed_at: Math.random() > 0.6 ? new Date(Date.now() - randomInt(1, 10) * 24 * 60 * 60 * 1000).toISOString() : null,
        notes: randomElement(['Client happy', 'Needs more info', 'Call back next week']),
        assigned_to: randomElement(['Agent Smith', 'Agent Johnson', 'Agent Williams'])
      }
    });
  }

  // 10. Generate Suburbs
  console.log('Generating suburbs...');
  const suburbsRepo = db.getRepository('crm_suburbs');
  for (const suburb of SUBURBS) {
    await suburbsRepo.create({
      values: {
        name: suburb.name,
        city: suburb.city,
        province: suburb.province,
        region: suburb.province,
        postal_code: `${randomInt(1000, 9999)}`,
        latitude: -30 + Math.random() * 10,
        longitude: 20 + Math.random() * 10,
        average_price: suburb.avgPrice,
        median_price: suburb.avgPrice * 0.9,
        price_trend: randomElement(['increasing', 'stable', 'decreasing']),
        days_on_market: randomInt(30, 120),
        inventory_count: randomInt(10, 100)
      }
    });
  }

  // 11. Generate Scraped Leads
  console.log('Generating scraped leads...');
  const scrapedLeadsRepo = db.getRepository('crm_scraped_leads');
  const sources = ['Property24', 'Private Property', 'Rent Guru', 'Facebook'];
  
  for (let i = 0; i < 35; i++) {
    const suburb = randomElement(SUBURBS);
    await scrapedLeadsRepo.create({
      values: {
        source: randomElement(sources),
        source_url: randomElement(['https://property24.com/123', 'https://privateproperty.co.za/456', 'https://facebook.com/groups/789']),
        property_title: `${randomElement(PROPERTY_TYPES)} in ${suburb.name}`,
        address: `${randomInt(1, 500)} Test Street, ${suburb.name}`,
        price: suburb.avgPrice * (randomInt(70, 130) / 100),
        property_type: randomElement(PROPERTY_TYPES),
        seller_name: `${randomElement(FIRST_NAMES)} ${randomElement(LAST_NAMES)}`,
        seller_phone: generatePhone(),
        seller_email: generateEmail(randomElement(FIRST_NAMES), randomElement(LAST_NAMES)),
        description: randomElement(['Great property', 'Must sell', 'Reduced price', 'Sole mandate']),
        mandate_type: randomElement(['sole_mandate', 'shared_mandate', 'open_mandate']),
        imported: Math.random() > 0.5
      }
    });
  }

  console.log('Test data generation completed!');
  console.log('Generated:');
  console.log('- 60 Leads');
  console.log('- 120 Contacts');
  console.log('- 45 Properties');
  console.log('- 30 Deals');
  console.log('- 15 Action Plans');
  console.log('- 50 Tasks');
  console.log('- 3 Checklist Templates');
  console.log('- 80 Call Logs');
  console.log('- 40 Follow-ups');
  console.log('- 10 Suburbs');
  console.log('- 35 Scraped Leads');
}

export default generateTestData;
