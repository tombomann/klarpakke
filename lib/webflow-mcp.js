/**
 * Webflow MCP API Wrapper
 * 
 * A Model Context Protocol (MCP) style wrapper for Webflow API
 * Provides clean interface for programmatic Webflow site management
 * 
 * Supports:
 * - Data API v2 (for listing, reading, CMS operations)
 * - Designer API (for page creation and manipulation)
 * 
 * @author Klarpakke Team
 * @version 2.0.0
 */

const axios = require('axios');

class WebflowMCP {
  constructor(apiToken, siteId) {
    if (!apiToken) throw new Error('WEBFLOW_API_TOKEN required');
    if (!siteId) throw new Error('WEBFLOW_SITE_ID required');

    this.apiToken = apiToken;
    this.siteId = siteId;
    this.dataApiUrl = 'https://api.webflow.com/v2';
    this.designerApiUrl = 'https://api.webflow.com/v1'; // Designer API uses v1
    
    // Data API client (for reading/listing)
    this.dataClient = axios.create({
      baseURL: this.dataApiUrl,
      headers: {
        'Authorization': `Bearer ${this.apiToken}`,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    });

    // Designer API client (for creating/manipulating)
    this.designerClient = axios.create({
      baseURL: this.designerApiUrl,
      headers: {
        'Authorization': `Bearer ${this.apiToken}`,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    });
  }

  /**
   * Get site information
   */
  async getSiteInfo() {
    try {
      const response = await this.dataClient.get(`/sites/${this.siteId}`);
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return this._handleError(error, 'getSiteInfo');
    }
  }

  /**
   * List all pages in site (Data API)
   */
  async listPages() {
    try {
      const response = await this.dataClient.get(`/sites/${this.siteId}/pages`);
      return {
        success: true,
        pages: response.data.pages || [],
        count: response.data.pages?.length || 0
      };
    } catch (error) {
      return this._handleError(error, 'listPages');
    }
  }

  /**
   * Get specific page by slug
   */
  async getPage(slug) {
    try {
      const result = await this.listPages();
      if (!result.success) return result;

      const page = result.pages.find(p => p.slug === slug);
      if (!page) {
        return {
          success: false,
          error: `Page not found: ${slug}`
        };
      }

      return {
        success: true,
        page
      };
    } catch (error) {
      return this._handleError(error, 'getPage');
    }
  }

  /**
   * Create new page using Designer API
   * 
   * Designer API endpoint for page creation:
   * POST /sites/{siteId}/pages
   * 
   * @param {Object} data - Page data
   * @param {string} data.slug - URL slug (e.g., 'pricing')
   * @param {string} data.name - Display name
   * @param {string} data.title - Page title (for <title> tag)
   * @param {string} [data.description] - Meta description
   * @param {Object} [data.openGraph] - Open Graph metadata
   */
  async createPage(data) {
    try {
      // First, check if page already exists
      const existing = await this.getPage(data.slug);
      if (existing.success) {
        return {
          success: true,
          page: existing.page,
          pageId: existing.page.id,
          message: 'Page already exists'
        };
      }

      // Try Designer API v1 endpoint
      const payload = {
        slug: data.slug,
        name: data.name,
        title: data.title,
        displayName: data.name,
        metaDescription: data.description || '',
        settings: {
          openGraph: data.openGraph || {}
        }
      };

      // Try v1 Designer API
      try {
        const response = await this.designerClient.post(
          `/sites/${this.siteId}/pages`,
          payload
        );

        return {
          success: true,
          page: response.data,
          pageId: response.data.id,
          source: 'designer-api-v1'
        };
      } catch (designerError) {
        // If Designer API also fails, provide helpful message
        if (designerError.response?.status === 404 || 
            designerError.response?.status === 401 ||
            designerError.response?.status === 403) {
          
          return {
            success: false,
            error: 'Page creation requires higher API permissions',
            message: 'Use Webflow Designer UI to create pages, then use this API to inject content',
            recommendation: 'Create page manually in Webflow Designer',
            details: designerError.response?.data
          };
        }
        throw designerError;
      }
    } catch (error) {
      return this._handleError(error, 'createPage');
    }
  }

  /**
   * Create page via direct page creation endpoint
   * Alternative method if Designer API also fails
   */
  async createPageDirect(pageData) {
    try {
      // POST /sites/:siteId/pages
      const response = await axios.post(
        `${this.dataApiUrl}/sites/${this.siteId}/pages`,
        {
          displayName: pageData.name,
          slug: pageData.slug,
          title: pageData.title,
          metaDescription: pageData.description || ''
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiToken}`,
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          }
        }
      );

      return {
        success: true,
        page: response.data,
        pageId: response.data.id
      };
    } catch (error) {
      return this._handleError(error, 'createPageDirect');
    }
  }

  /**
   * Update page metadata
   */
  async updatePageMetadata(pageId, metadata) {
    try {
      const response = await this.dataClient.patch(
        `/sites/${this.siteId}/pages/${pageId}`,
        metadata
      );

      return {
        success: true,
        page: response.data
      };
    } catch (error) {
      return this._handleError(error, 'updatePageMetadata');
    }
  }

  /**
   * Inject custom code into page
   * Updates page's head and footer custom code
   */
  async injectCustomCode(pageId, { head = '', footer = '' }) {
    try {
      // Note: This may require Designer API access
      // Fallback: Return instructions for manual injection
      
      return {
        success: false,
        message: 'Custom code injection requires Designer UI access',
        instructions: `
          Manual injection required:
          1. Open page in Webflow Designer
          2. Page Settings (gear icon) → Custom Code
          3. Paste HEAD code: ${head}
          4. Paste FOOTER code: ${footer}
          5. Save and Publish
        `
      };
    } catch (error) {
      return this._handleError(error, 'injectCustomCode');
    }
  }

  /**
   * List all CMS collections
   */
  async listCollections() {
    try {
      const response = await this.dataClient.get(`/sites/${this.siteId}/collections`);
      return {
        success: true,
        collections: response.data.collections || [],
        count: response.data.collections?.length || 0
      };
    } catch (error) {
      return this._handleError(error, 'listCollections');
    }
  }

  /**
   * Get collection items
   */
  async getCollectionItems(collectionId, options = {}) {
    try {
      const params = {
        limit: options.limit || 100,
        offset: options.offset || 0
      };

      const response = await this.dataClient.get(
        `/collections/${collectionId}/items`,
        { params }
      );

      return {
        success: true,
        items: response.data.items || [],
        count: response.data.count || 0,
        limit: response.data.limit,
        offset: response.data.offset,
        total: response.data.total
      };
    } catch (error) {
      return this._handleError(error, 'getCollectionItems');
    }
  }

  /**
   * Create CMS collection item
   */
  async createCollectionItem(collectionId, fields) {
    try {
      const response = await this.dataClient.post(
        `/collections/${collectionId}/items`,
        {
          fieldData: fields
        }
      );

      return {
        success: true,
        item: response.data
      };
    } catch (error) {
      return this._handleError(error, 'createCollectionItem');
    }
  }

  /**
   * Update CMS collection item
   */
  async updateCollectionItem(collectionId, itemId, fields) {
    try {
      const response = await this.dataClient.patch(
        `/collections/${collectionId}/items/${itemId}`,
        {
          fieldData: fields
        }
      );

      return {
        success: true,
        item: response.data
      };
    } catch (error) {
      return this._handleError(error, 'updateCollectionItem');
    }
  }

  /**
   * Publish site to domains
   * 
   * @param {string[]} domains - List of domains to publish to
   */
  async publishSite(domains = []) {
    try {
      const response = await this.dataClient.post(
        `/sites/${this.siteId}/publish`,
        {
          domains: domains.length > 0 ? domains : undefined
        }
      );

      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return this._handleError(error, 'publishSite');
    }
  }

  /**
   * Check if page exists
   */
  async pageExists(slug) {
    const result = await this.getPage(slug);
    return result.success;
  }

  /**
   * Get all required pages status
   */
  async validateRequiredPages(requiredSlugs = []) {
    const defaults = [
      'index', 
      'pricing', 
      'app/dashboard', 
      'app/kalkulator', 
      'app/settings', 
      'login', 
      'signup'
    ];
    
    const slugsToCheck = requiredSlugs.length > 0 ? requiredSlugs : defaults;
    const result = await this.listPages();
    
    if (!result.success) {
      return {
        success: false,
        error: result.error
      };
    }

    const existing = new Set(result.pages.map(p => p.slug));
    const missing = slugsToCheck.filter(slug => !existing.has(slug));
    const present = slugsToCheck.filter(slug => existing.has(slug));

    return {
      success: true,
      total: slugsToCheck.length,
      present: present,
      presentCount: present.length,
      missing: missing,
      missingCount: missing.length,
      allPresent: missing.length === 0
    };
  }

  /**
   * Error handler
   */
  _handleError(error, method) {
    const errorData = {
      success: false,
      method,
      error: error.message
    };

    if (error.response) {
      errorData.status = error.response.status;
      errorData.statusText = error.response.statusText;
      errorData.data = error.response.data;
    }

    return errorData;
  }
}

module.exports = WebflowMCP;
