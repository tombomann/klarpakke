/**
 * AI Content Generator
 * 
 * Uses Perplexity Sonar Pro for intelligent content generation
 * Includes fallback templates when AI is unavailable
 * 
 * @author Klarpakke Team
 * @version 1.0.0
 */

const axios = require('axios');

class AIContentGenerator {
  constructor(apiKey = null) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.perplexity.ai';
    this.model = 'llama-3.1-sonar-large-128k-online';
    this.enabled = !!apiKey;

    if (this.enabled) {
      this.client = axios.create({
        baseURL: this.baseUrl,
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json'
        }
      });
    }
  }

  /**
   * Generate page content with AI or fallback
   * 
   * @param {string} pageType - Type of page (landing, pricing, dashboard, etc.)
   * @param {Object} requirements - Content requirements
   */
  async generatePageContent(pageType, requirements = {}) {
    if (!this.enabled) {
      console.log('ℹ️  AI disabled, using fallback content');
      return this._getFallbackContent(pageType, requirements);
    }

    try {
      const prompt = this._buildPrompt(pageType, requirements);
      
      const response = await this.client.post('/chat/completions', {
        model: this.model,
        messages: [
          {
            role: 'system',
            content: 'You are a professional Norwegian copywriter specializing in fintech and trading platforms. Generate compelling, trustworthy content.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      });

      const aiContent = response.data.choices[0].message.content;
      return this._parseAIResponse(aiContent, pageType);

    } catch (error) {
      console.warn('⚠️  AI generation failed, using fallback:', error.message);
      return this._getFallbackContent(pageType, requirements);
    }
  }

  /**
   * Generate semantic element IDs for Webflow
   */
  async generateElementIDs(pageStructure) {
    const ids = {};

    for (const section of pageStructure.sections) {
      const sectionId = this._toKebabCase(section.name);
      ids[section.name] = `#${sectionId}`;

      if (section.elements) {
        for (const element of section.elements) {
          const elementId = `${sectionId}-${this._toKebabCase(element)}`;
          ids[`${section.name}.${element}`] = `#${elementId}`;
        }
      }
    }

    return ids;
  }

  /**
   * Generate SEO metadata
   */
  async optimizeForSEO(content, keywords = []) {
    const keywordString = keywords.join(', ');

    if (!this.enabled) {
      return this._getBasicSEO(content, keywords);
    }

    try {
      const prompt = `Generate SEO metadata for Norwegian crypto trading platform:\n\nContent: ${content.headline}\nKeywords: ${keywordString}\n\nGenerate:\n1. Meta title (max 60 chars)\n2. Meta description (max 160 chars)\n3. 3 relevant keywords`;

      const response = await this.client.post('/chat/completions', {
        model: this.model,
        messages: [
          { role: 'system', content: 'You are an SEO expert.' },
          { role: 'user', content: prompt }
        ],
        temperature: 0.5,
        max_tokens: 300
      });

      return this._parseSEOResponse(response.data.choices[0].message.content);

    } catch (error) {
      console.warn('⚠️  SEO optimization failed, using basic:', error.message);
      return this._getBasicSEO(content, keywords);
    }
  }

  /**
   * Build AI prompt for page type
   */
  _buildPrompt(pageType, requirements) {
    const basePrompts = {
      landing: `Generate landing page content for Klarpakke, a Norwegian crypto trading platform.\n\nTone: ${requirements.tone || 'professional yet friendly'}\nAudience: ${requirements.targetAudience || 'Norwegian retail investors'}\nSections: ${requirements.sections?.join(', ') || 'hero, features, cta'}\n\nGenerate:\n1. Hero headline (max 10 words)\n2. Hero subheadline (max 20 words)\n3. CTA button text (max 3 words)\n4. 3 key features (each 5-10 words)\n\nFormat as JSON.`,

      pricing: `Generate pricing page content for Klarpakke.\n\nPlans: ${requirements.plans?.join(', ') || 'Paper, Safe, Pro, Extrem'}\n\nGenerate:\n1. Page headline\n2. Subheadline\n3. Description for each plan (15-20 words each)\n\nFormat as JSON.`,

      dashboard: `Generate dashboard UI text for Klarpakke trading app.\n\nGenerate:\n1. Welcome message\n2. Empty state text\n3. Loading text\n4. Error messages\n\nFormat as JSON.`,

      calculator: `Generate calculator UI text for Klarpakke risk calculator.\n\nGenerate:\n1. Page title\n2. Input labels\n3. Result descriptions\n4. Warning messages\n\nFormat as JSON.`
    };

    return basePrompts[pageType] || `Generate content for ${pageType} page in Norwegian.`;
  }

  /**
   * Parse AI response
   */
  _parseAIResponse(aiContent, pageType) {
    try {
      // Try to extract JSON from response
      const jsonMatch = aiContent.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[0]);
      }
    } catch (e) {
      // If JSON parsing fails, fall back
    }

    // Return structured fallback
    return this._getFallbackContent(pageType, {});
  }

  /**
   * Parse SEO response
   */
  _parseSEOResponse(content) {
    // Simple parsing - extract title, description, keywords
    const lines = content.split('\n').filter(l => l.trim());
    
    return {
      title: lines[0]?.replace(/^\d+\.\s*/, '').slice(0, 60) || 'Klarpakke - Trygg Krypto-Trading',
      description: lines[1]?.replace(/^\d+\.\s*/, '').slice(0, 160) || 'AI-drevet trading for småsparere',
      keywords: lines.slice(2).map(l => l.replace(/^\d+\.\s*/, '').trim()).filter(k => k)
    };
  }

  /**
   * Get fallback content templates
   */
  _getFallbackContent(pageType, requirements) {
    const fallbacks = {
      landing: {
        headline: 'Trygg Krypto-Trading med AI',
        subheadline: 'Klarpakke hjelper småsparere med intelligente trading-signaler',
        cta: 'Start Gratis',
        features: [
          'AI-drevne trading-signaler',
          'Risikostyring automatisk',
          'Norsk støtte og veiledning'
        ]
      },

      pricing: {
        headline: 'Velg Din Plan',
        subheadline: 'Start med Paper Trading, oppgrader når du er klar',
        plans: {
          paper: 'Øv med virtuelt kapital uten risiko',
          safe: 'Konservativ trading med lav risiko',
          pro: 'Balansert strategi for erfarne traders',
          extrem: 'Aggressiv trading for maksimal avkastning'
        }
      },

      dashboard: {
        welcome: 'Velkommen til Klarpakke',
        emptyState: 'Ingen aktive signaler akkurat nå',
        loading: 'Laster data...',
        errors: {
          network: 'Nettverksfeil. Prøv igjen.',
          auth: 'Vennligst logg inn på nytt'
        }
      },

      calculator: {
        title: 'Risiko-Kalkulator',
        labels: {
          amount: 'Startbeløp (NOK)',
          leverage: 'Leverage',
          plan: 'Velg plan'
        },
        result: 'Beregnet risiko og forventet avkastning',
        warnings: {
          highRisk: '⚠️ Høy risiko - vurder lavere leverage',
          lowBalance: '⚠️ For lavt beløp for valgt strategi'
        }
      }
    };

    return fallbacks[pageType] || { headline: `${pageType} Page` };
  }

  /**
   * Get basic SEO without AI
   */
  _getBasicSEO(content, keywords) {
    return {
      title: content.headline?.slice(0, 60) || 'Klarpakke - Trygg Krypto-Trading',
      description: content.subheadline?.slice(0, 160) || 'AI-drevet trading for småsparere i Norge',
      keywords: keywords.length > 0 ? keywords : ['krypto', 'trading', 'norge', 'AI']
    };
  }

  /**
   * Convert string to kebab-case for element IDs
   */
  _toKebabCase(str) {
    return str
      .replace(/([a-z])([A-Z])/g, '$1-$2')
      .replace(/[\s_]+/g, '-')
      .replace(/[æÆ]/g, 'ae')
      .replace(/[øØ]/g, 'o')
      .replace(/[åÅ]/g, 'aa')
      .toLowerCase();
  }
}

module.exports = AIContentGenerator;
