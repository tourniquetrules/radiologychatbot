// RadAI Chat Configuration
// This file contains configuration settings for different deployment environments

window.RadAIConfig = {
    // Configuration for local access
    development: {
        apiBaseUrl: '/api',
        description: 'Local development server',
        useProxy: false
    },
    
    // Configuration for Cloudflare tunnel access
    cloudflare: {
        apiBaseUrl: '/api',
        description: 'Cloudflare tunnel to local server',
        useProxy: false
    },
    
    // Fallback configuration for other external access
    external: {
        apiBaseUrl: '/api.php?path=',
        description: 'External access via PHP proxy',
        useProxy: true
    },
    
    // Auto-detect current environment
    getCurrentConfig: function() {
        const hostname = window.location.hostname;
        const protocol = window.location.protocol;
        
        // Check if we're accessing locally
        if (hostname === 'localhost' || 
            hostname === '127.0.0.1' || 
            hostname.startsWith('192.168.') || 
            hostname.startsWith('10.') || 
            hostname.startsWith('172.')) {
            return this.development;
        } 
        // Check if accessing via Cloudflare tunnel (haydd.com domain)
        else if (hostname.includes('haydd.com')) {
            return this.cloudflare;
        }
        // Any other external access
        else {
            return this.external;
        }
    }
};
