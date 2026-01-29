#!/usr/bin/env node
/**
 * AI Content Generator
 * Uses Perplexity Pro to generate Webflow-optimized content
 */

const axios = require('axios');

class AIContentGenerator {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.baseURL = 'https://api.perplexity.ai';
  }

  /**
   * Generate page content based on requirements
   */
  async generatePageContent(pageType, requirements) {
    const prompt = this._buildPrompt(pageType, requirements);
    
    try {
      const response = await axios.post(
        `${this.baseURL}/chat/completions`,
        {
          model: 'llama-3.1-sonar-large-128k-online',
          messages: [
            {
              role: 'system',
              content: 'You are an expert Webflow developer and UX writer. Generate production-ready, SEO-optimized content.'
            },
            {
              role: 'user',
              content: prompt
            }
          ],
          temperature: 0.7,
          max_tokens: 2000
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const content = response.data.choices[0].message.content;
      return this._parseContent(content, pageType);
    } catch (error) {
      console.error('❌ AI Content Generation failed:', error.message);
      return this._getFallbackContent(pageType);
    }
  }

  /**
   * Generate element IDs based on page structure
   */
  async generateElementIDs(pageStructure) {
    const prompt = `
Generate semantic HTML element IDs for a Webflow page with this structure:
${JSON.stringify(pageStructure, null, 2)}

Requirements:
- Use kebab-case
- Prefix with page name
- Be descriptive but concise
- Follow Webflow conventions

Return as JSON array: [{"element": "hero section", "id": "landing-hero-section"}]
`;

    try {
      const response = await axios.post(
        `${this.baseURL}/chat/completions`,
        {
          model: 'llama-3.1-sonar-small-128k-online',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.3
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const content = response.data.choices[0].message.content;
      return this._parseJSON(content);
    } catch (error) {
      console.error('❌ Element ID generation failed:', error.message);
      return [];
    }
  }

  /**
   * Optimize content for SEO
   */
  async optimizeForSEO(content, keywords) {
    const prompt = `
Optimize this content for SEO:

${content}

Target keywords: ${keywords.join(', ')}

Requirements:
- Natural keyword integration
- Improved readability
- Meta description
- Title tag
- Header hierarchy

Return as JSON with keys: title, description, optimizedContent, headers
`;

    try {
      const response = await axios.post(
        `${this.baseURL}/chat/completions`,
        {
          model: 'llama-3.1-sonar-large-128k-online',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.5
        },
        {
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const result = response.data.choices[0].message.content;
      return this._parseJSON(result);
    } catch (error) {
      console.error('❌ SEO optimization failed:', error.message);
      return { title: '', description: '', optimizedContent: content, headers: [] };
    }
  }

  /**
   * Build prompt based on page type
   */
  _buildPrompt(pageType, requirements) {
    const basePrompt = `Generate professional content for a ${pageType} page.`;
    const reqText = requirements ? `\n\nRequirements:\n${JSON.stringify(requirements, null, 2)}` : '';
    
    return `${basePrompt}${reqText}\n\nReturn as JSON with keys: headline, subheadline, body, cta, benefits (array)`;
  }

  /**
   * Parse AI response
   */
  _parseContent(content, pageType) {
    try {
      // Try to extract JSON from markdown code blocks
      const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[1]);
      }
      return JSON.parse(content);
    } catch (error) {
      console.warn('⚠️  Failed to parse AI content, using fallback');
      return this._getFallbackContent(pageType);
    }
  }

  /**
   * Parse JSON from AI response
   */
  _parseJSON(content) {
    try {
      const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[1]);
      }
      return JSON.parse(content);
    } catch (error) {
      console.warn('⚠️  Failed to parse JSON response');
      return [];
    }
  }

  /**
   * Fallback content
   */
  _getFallbackContent(pageType) {
    const fallbacks = {
      landing: {
        headline: 'Trygg Krypto-Trading for Nordmenn',
        subheadline: 'AI-drevet risikoreduksjon med fokus på læring',
        body: 'Klarpakke hjelper småsparere å trade krypto trygt med AI-analyse.',
        cta: 'Kom i gang gratis',
        benefits: ['Risikoreduksjon', 'AI-analyse', 'Norsk support']
      },
      pricing: {
        headline: 'Velg din plan',
        subheadline: 'Start gratis, oppgrader når du er klar',
        plans: ['Paper', 'Safe', 'Pro', 'Extrem']
      },
      dashboard: {
        headline: 'Dine Trading Signaler',
        description: 'Se alle AI-genererte signaler'
      }
    };

    return fallbacks[pageType] || { headline: 'Welcome', body: 'Content goes here' };
  }
}

module.exports = AIContentGenerator;
