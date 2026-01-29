/**
 * Webflow MCP API Wrapper
 * 
 * A Model Context Protocol (MCP) style wrapper for Webflow API v2
 * Provides clean interface for programmatic Webflow site management
 * 
 * @author Klarpakke Team
 * @version 1.0.0
 */

const axios = require('axios');

class WebflowMCP {
  constructor(apiToken, siteId) {
    if (!apiToken) throw new Error('WEBFLOW_API_TOKEN required');
    if (!siteId) throw new Error('WEBFLOW_SITE_ID required');

    this.apiToken = apiToken;
    this.siteId = siteId;
    this.baseUrl = 'https://api.webflow.com/v2';
    
    this.client = axios.create({
      baseURL: this.baseUrl,
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
      const response = await this.client.get(`/sites/${this.siteId}`);
      return {
        success: true,
        data: response.data
      };
    } catch (error) {
      return this._handleError(error, 'getSiteInfo');
    }
  }

  /**
   * List all pages in site
   */
  async listPages() {
    try {
      const response = await this.client.get(`/sites/${this.siteId}/pages`);
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
   * Create new page
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
      const payload = {
        slug: data.slug,
        name: data.name,
        title: data.title,
        seo: {
          title: data.title,
          description: data.description || '',
          ...(data.openGraph || {})
        }
      };

      const response = await this.client.post(
        `/sites/${this.siteId}/pages`,
        payload
      );

      return {
        success: true,
        page: response.data,
        pageId: response.data.id
      };
    } catch (error) {
      return this._handleError(error, 'createPage');
    }
  }

  /**
   * Update page metadata
   */
  async updatePageMetadata(pageId, metadata) {
    try {
      const response = await this.client.patch(
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
   * List all CMS collections
   */
  async listCollections() {
    try {
      const response = await this.client.get(`/sites/${this.siteId}/collections`);
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

      const response = await this.client.get(
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
      const response = await this.client.post(
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
      const response = await this.client.patch(
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
      const response = await this.client.post(
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
