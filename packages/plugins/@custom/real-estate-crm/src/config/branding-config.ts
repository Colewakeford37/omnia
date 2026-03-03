/**
 * BRANDING CONFIGURATION
 * 
 * Use this file to customize the CRM branding.
 * Replace "YourBrand" with your actual brand name.
 */

export const BRAND_CONFIG = {
  // Company/Product Information
  company: {
    name: 'YourBrand',
    full_name: 'YourBrand Real Estate CRM',
    short_name: 'YourBrand',
    tagline: 'YourTagline - Real Estate Solutions',
    website: 'https://yourbrand.co.za',
    email: 'info@yourbrand.co.za',
    phone: '+27 12 345 6789',
    address: '123 Business Street, Sandton, Johannesburg'
  },
  
  // System Settings
  system: {
    app_name: 'YourBrand CRM',
    app_key: 'yourbrand-crm-key',
    admin_email: 'admin@yourbrand.co.za'
  },
  
  // Login Page Branding
  login: {
    title: 'Welcome to YourBrand CRM',
    subtitle: 'Sign in to your account',
    footer_text: '© 2026 YourBrand. All rights reserved.',
    logo_url: '/logo.png',
    background_image: '/login-bg.jpg',
    primary_color: '#1890ff',
    secondary_color: '#52c41a'
  },
  
  // Email Templates
  email: {
    from_name: 'YourBrand Real Estate',
    from_address: 'noreply@yourbrand.co.za',
    signature: `
      Best regards,
      YourBrand Team
      YourBrand Real Estate CRM
      www.yourbrand.co.za
    `
  },
  
  // Social Media
  social: {
    facebook: 'https://facebook.com/yourbrand',
    twitter: 'https://twitter.com/yourbrand',
    linkedin: 'https://linkedin.com/company/yourbrand',
    instagram: 'https://instagram.com/yourbrand'
  }
};

// Localization strings to override
export const LOCALE_OVERRIDES = {
  'en-US': {
    // Main navigation
    'Dashboard': 'Dashboard',
    'Settings': 'Settings',
    'Profile': 'Profile',
    'Logout': 'Logout',
    
    // System
    'NocoBase': 'YourBrand',
    'Welcome to NocoBase': 'Welcome to YourBrand CRM',
    'Sign in': 'Sign In',
    'Sign up': 'Sign Up',
    'Email': 'Email',
    'Password': 'Password',
    'Forgot password?': 'Forgot password?',
    
    // Footer
    'Powered by NocoBase': 'Powered by YourBrand',
    '© NocoBase': '© 2026 YourBrand',
    
    // About page
    'About NocoBase': 'About YourBrand',
    'NocoBase is an open source': 'YourBrand is a leading',
    'version': 'version'
  }
};

export default BRAND_CONFIG;
