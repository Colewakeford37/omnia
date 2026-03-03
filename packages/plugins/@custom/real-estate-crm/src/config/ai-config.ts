/**
 * AI Employees Configuration for Real Estate CRM
 * 
 * This file provides configuration for AI employees that can be integrated
 * into the Real Estate CRM system using NocoBase's AI plugin.
 * 
 * AI Employees are powered by the @nocobase/plugin-ai
 */

export const AI_EMPLOYEES = {
  // Lead Qualification AI
  lead_qualifier: {
    name: 'Lead Qualifier',
    role: 'Sales Assistant',
    description: 'Analyzes and qualifies incoming leads based on budget, timeline, and requirements',
    capabilities: [
      'Lead scoring and qualification',
      'Budget analysis',
      'Timeline assessment',
      'Property matching suggestions'
    ],
    prompt: `You are a Lead Qualifier for a Real Estate CRM. Your role is to:
1. Analyze incoming lead information
2. Assess lead quality based on budget, timeline, and property requirements
3. Provide lead scoring (1-10)
4. Suggest next best actions
5. Identify urgent leads that need immediate attention

Always be professional and helpful. Ask clarifying questions when needed.`,
    tools: [
      'analyze_lead',
      'calculate_budget_match',
      'assess_timeline',
      'recommend_properties'
    ],
    knowledge_base: 'product_catalog',
    default_settings: {
      auto_qualify_threshold: 7,
      notify_on_high_priority: true,
      max_leads_per_day: 50
    }
  },

  // Property Matcher AI
  property_matcher: {
    name: 'Property Matcher',
    role: 'Property Consultant',
    description: 'Matches properties with client requirements and preferences',
    capabilities: [
      'Property requirement analysis',
      'Smart property recommendations',
      'Price range matching',
      'Location preference matching'
    ],
    prompt: `You are a Property Matcher for a Real Estate CRM. Your role is to:
1. Understand client requirements and preferences
2. Match properties from the database with client needs
3. Rank properties by relevance score
4. Provide reasoning for each recommendation
5. Consider factors like price, location, size, and features`,
    tools: [
      'match_properties',
      'analyze_requirements',
      'calculate_match_score',
      'get_similar_properties'
    ],
    knowledge_base: 'property_listings',
    default_settings: {
      max_recommendations: 10,
      min_match_score: 60,
      include_sold_properties: false
    }
  },

  // Market Analyst AI
  market_analyst: {
    name: 'Market Analyst',
    role: 'Real Estate Analyst',
    description: 'Provides market insights, trends, and property valuations',
    capabilities: [
      'Market trend analysis',
      'Property valuation estimates',
      'Price trend predictions',
      'Investment opportunity identification'
    ],
    prompt: `You are a Market Analyst for a Real Estate CRM. Your role is to:
1. Analyze current market conditions
2. Provide price trends and predictions
3. Compare similar properties
4. Identify investment opportunities
5. Generate market reports

Use data from the suburb reports and historical sales data.`,
    tools: [
      'analyze_market_trends',
      'estimate_property_value',
      'compare_properties',
      'generate_market_report'
    ],
    knowledge_base: 'market_data',
    default_settings: {
      report_frequency: 'weekly',
      include_comparables: true,
      market_areas: ['all']
    }
  },

  // CRM Insights AI (similar to Viz in CRM demo)
  crm_insights: {
    name: 'CRM Insights',
    role: 'Business Intelligence Analyst',
    description: 'Provides insights and analytics for CRM data',
    capabilities: [
      'Lead pipeline analysis',
      'Conversion rate optimization',
      'Performance reporting',
      'Trend detection'
    ],
    prompt: `You are a CRM Insights Analyst. Your role is to:
1. Analyze the CRM data to identify trends
2. Generate insights about sales performance
3. Create visualizations and charts
4. Identify areas for improvement
5. Provide actionable recommendations

Use the Overall Analytics workflow for templated analysis.`,
    tools: [
      'get_collection_data',
      'aggregate_statistics',
      'generate_chart',
      'overall_analytics'
    ],
    knowledge_base: 'crm_data',
    default_settings: {
      dashboard_refresh: 'realtime',
      chart_types: ['line', 'bar', 'pie', 'funnel'],
      kpi_tracking: true
    }
  }
};

// Analysis Templates for CRM Insights AI
export const ANALYSIS_TEMPLATES = [
  {
    name: 'Leads by Status',
    collection: 'crm_leads',
    sql: 'SELECT status, COUNT(*) as count FROM crm_leads GROUP BY status ORDER BY count DESC',
    description: 'Count of leads by their current status'
  },
  {
    name: 'Leads by Source',
    collection: 'crm_leads',
    sql: 'SELECT source, COUNT(*) as count FROM crm_leads GROUP BY source ORDER BY count DESC',
    description: 'Distribution of lead sources'
  },
  {
    name: 'Properties by Type',
    collection: 'crm_properties',
    sql: 'SELECT property_type, COUNT(*) as count, AVG(price) as avg_price FROM crm_properties GROUP BY property_type',
    description: 'Property count and average price by type'
  },
  {
    name: 'Properties by Status',
    collection: 'crm_properties',
    sql: 'SELECT status, COUNT(*) as count FROM crm_properties GROUP BY status',
    description: 'Property listings by status'
  },
  {
    name: 'Deals by Stage',
    collection: 'crm_deals',
    sql: 'SELECT stage, COUNT(*) as count, SUM(value) as total_value FROM crm_deals GROUP BY stage',
    description: 'Deal count and value by pipeline stage'
  },
  {
    name: 'Task Completion Rate',
    collection: 'crm_tasks',
    sql: "SELECT status, COUNT(*) as count FROM crm_tasks GROUP BY status",
    description: 'Task completion statistics'
  },
  {
    name: 'Contact Reasons Usage',
    collection: 'crm_call_logs',
    sql: 'SELECT reason_id, COUNT(*) as count FROM crm_call_logs GROUP BY reason_id',
    description: 'Most used contact reasons for calls'
  },
  {
    name: 'Lead Conversion Funnel',
    collection: 'crm_leads',
    sql: `SELECT 
      status,
      COUNT(*) as count,
      ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percentage
    FROM crm_leads 
    GROUP BY status`,
    description: 'Lead conversion funnel analysis'
  }
];

// AI Tools Configuration
export const AI_TOOLS = {
  analyze_lead: {
    name: 'Analyze Lead',
    description: 'Analyze lead information and provide qualification score',
    parameters: {
      lead_id: 'string',
      include_score: 'boolean'
    },
    returns: {
      score: 'number',
      strengths: 'array',
      concerns: 'array',
      recommendations: 'array'
    }
  },
  match_properties: {
    name: 'Match Properties',
    description: 'Match client requirements with available properties',
    parameters: {
      requirements: 'object',
      max_results: 'number'
    },
    returns: {
      matches: 'array',
      match_scores: 'array'
    }
  },
  analyze_market_trends: {
    name: 'Analyze Market Trends',
    description: 'Analyze market trends for a specific suburb or area',
    parameters: {
      suburb: 'string',
      period: 'string'
    },
    returns: {
      trends: 'object',
      predictions: 'array'
    }
  },
  get_crm_statistics: {
    name: 'Get CRM Statistics',
    description: 'Get aggregate statistics from CRM collections',
    parameters: {
      collection: 'string',
      metrics: 'array',
      filters: 'object'
    },
    returns: {
      statistics: 'object',
      charts: 'array'
    }
  }
};

// Knowledge Base Documents
export const KNOWLEDGE_BASE = {
  product_catalog: {
    name: 'Product Catalog',
    description: 'Information about property types, features, and pricing',
    documents: [
      { title: 'Property Types Guide', content: 'Detailed guide on different property types' },
      { title: 'Pricing Strategy', content: 'How to price properties for sale' },
      { title: 'Feature Categories', content: 'Common property features and amenities' }
    ]
  },
  market_data: {
    name: 'Market Data',
    description: 'Market trends, suburb reports, and historical data',
    documents: [
      { title: 'Market Trends 2024', content: 'Current market analysis' },
      { title: 'Suburb Comparison Guide', content: 'How to compare different suburbs' },
      { title: 'Investment Analysis', content: 'Property investment considerations' }
    ]
  },
  crm_data: {
    name: 'CRM Data',
    description: 'CRM-specific data and analytics',
    documents: [
      { title: 'Lead Management Best Practices', content: 'How to manage leads effectively' },
      { title: 'Conversion Strategies', content: 'Improving lead to deal conversion' },
      { title: 'Pipeline Management', content: 'Managing sales pipeline effectively' }
    ]
  }
};

export default {
  AI_EMPLOYEES,
  ANALYSIS_TEMPLATES,
  AI_TOOLS,
  KNOWLEDGE_BASE
};
