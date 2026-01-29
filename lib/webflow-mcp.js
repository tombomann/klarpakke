#!/usr/bin/env node
/**
 * Webflow MCP (Model Context Protocol) Wrapper
 * Provides intelligent Webflow API access with AI-powered features
 */

const axios = require('axios');

class WebflowMCP {
  constructor(apiToken, siteId) {
    this.apiToken = apiToken;
    this.siteId = siteId;
    this.baseURL = 'https://api.webflow.com/v2';
    
    this.client = axios.create({
      baseURL: this.baseURL,
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'accept-version': '1.0.0'
      }
    });
  }

  /**
   * MCP Tool: List all pages
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
      return this._handleError('listPages', error);
    }
  }

  /**
   * MCP Tool: Get page by slug
   */
  async getPage(slug) {
    try {
      const pages = await this.listPages();
      if (!pages.success) return pages;
      
      const page = pages.pages.find(p => p.slug === slug);
      return {
        success: !!page,
        page: page || null
      };
    } catch (error) {
      return this._handleError('getPage', error);
    }
  }

  /**
   * MCP Tool: Create page with AI template
   */
  async createPage({ slug, name, title, template = 'default' }) {
    try {
      const response = await this.client.post(`/sites/${this.siteId}/pages`, {
        slug,
        name,
        title,
        parentId: null,
        isHomePage: slug === 'index',
        isHidden: false
      });
      
      return {
        success: true,
        page: response.data,
        pageId: response.data.id
      };
    } catch (error) {
      return this._handleError('createPage', error);
    }
  }

  /**
   * MCP Tool: Update page metadata
   */
  async updatePageMetadata(pageId, metadata) {
    try {
      const response = await this.client.patch(`/pages/${pageId}`, metadata);
      return {
        success: true,
        page: response.data
      };
    } catch (error) {
      return this._handleError('updatePageMetadata', error);
    }
  }

  /**
   * MCP Tool: List collections
   */
  async listCollections() {
    try {
      const response = await this.client.get(`/sites/${this.siteId}/collections`);
      return {
        success: true,
        collections: response.data.collections || []
      };
    } catch (error) {
      return this._handleError('listCollections', error);
    }
  }

  /**
   * MCP Tool: Get collection items
   */
  async getCollectionItems(collectionId, { limit = 100, offset = 0 } = {}) {
    try {
      const response = await this.client.get(
        `/collections/${collectionId}/items`,
        { params: { limit, offset } }
      );
      return {
        success: true,
        items: response.data.items || [],
        count: response.data.count,
        limit: response.data.limit,
        offset: response.data.offset,
        total: response.data.total
      };
    } catch (error) {
      return this._handleError('getCollectionItems', error);
    }
  }

  /**
   * MCP Tool: Create collection item
   */
  async createCollectionItem(collectionId, fields) {
    try {
      const response = await this.client.post(
        `/collections/${collectionId}/items`,
        { fields }
      );
      return {
        success: true,
        item: response.data
      };
    } catch (error) {
      return this._handleError('createCollectionItem', error);
    }
  }

  /**
   * MCP Tool: Publish site
   */
  async publishSite(domains = []) {
    try {
      const response = await this.client.post(
        `/sites/${this.siteId}/publish`,
        { domains }
      );
      return {
        success: true,
        publishedAt: new Date().toISOString()
      };
    } catch (error) {
      return this._handleError('publishSite', error);
    }
  }

  /**
   * MCP Tool: Get site info
   */
  async getSiteInfo() {
    try {
      const response = await this.client.get(`/sites/${this.siteId}`);
      return {
        success: true,
        site: response.data
      };
    } catch (error) {
      return this._handleError('getSiteInfo', error);
    }
  }

  /**
   * Error handler
   */
  _handleError(method, error) {
    const message = error.response?.data?.message || error.message;
    console.error(`❌ Webflow MCP [${method}]:`, message);
    return {
      success: false,
      error: message,
      statusCode: error.response?.status
    };
  }
}

module.exports = WebflowMCP;
