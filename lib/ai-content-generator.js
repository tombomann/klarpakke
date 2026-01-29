/**
 * AI Content Generator
 * 
 * Uses Perplexity Sonar Pro for intelligent content generation
 * Includes fallback templates when AI is unavailable
 * 
 * @author Klarpakke Team
 * @version 1.1.0 - Fixed API resilience
 */

const axios = require('axios');

class AIContentGenerator {
  constructor(apiKey = null) {
    this.apiKey = apiKey;
    this.baseUrl = 'https://api.perplexity.ai';
    this.model = 'llama-3.1-sonar-large-128k-online';
    this.enabled = !!apiKey;
    this.retries = 3;
    this.retryDelay = 1000; // ms

    if (this.enabled) {
      this.client = axios.create({
        baseURL: this.baseUrl,
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json'
        },
        timeout: 30000 // 30 second timeout
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
      return this._getFallbackContent(pageType, requirements);
    }

    try {
      const prompt = this._buildPrompt(pageType, requirements);
      const content = await this._callAIWithRetry(prompt);
      return this._parseAIResponse(content, pageType);

    } catch (error) {
      console.warn(`⚠️  AI generation failed (${error.message}), using fallback`);
      return this._getFallbackContent(pageType, requirements);
    }
  }

  /**
   * Call AI API with automatic retry logic
   */
  async _callAIWithRetry(prompt, attempt = 0) {
    try {
      const response = await this.client.post('/chat/completions', {
        model: this.model,
        messages: [
          {
            role: 'system',
            content: 'You are a professional Norwegian copywriter specializing in fintech and trading platforms. Generate compelling, trustworthy content. Always respond in valid JSON format when asked.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      });

      // Validate response structure
      if (!response?.data?.choices?.[0]?.message?.content) {
        throw new Error('Invalid API response structure');
      }

      return response.data.choices[0].message.content;

    } catch (error) {
      const status = error.response?.status;
      const message = error.response?.data?.message || error.message;

      // Handle specific errors
      if (status === 400 && message.includes('JSON')) {
        // Retry with simpler prompt
        if (attempt < 1) {
          const simplePrompt = `Generate brief content for a ${prompt.split('for ')[1]?.split('.')[0] || 'Klarpakke page'}. Response must be valid JSON with keys: headline, subheadline.`;
          return this._callAIWithRetry(simplePrompt, attempt + 1);
        }
        throw new Error('JSON format error after retry');
      }

      // Retry on network errors, timeouts
      if (status === 429 || status === 503 || error.code === 'ECONNABORTED') {
        if (attempt < this.retries) {
          const delay = this.retryDelay * Math.pow(2, attempt);
          await new Promise(resolve => setTimeout(resolve, delay));
          return this._callAIWithRetry(prompt, attempt + 1);
        }
        throw new Error(`API rate limited or unavailable (attempt ${attempt + 1}/${this.retries + 1})`);
      }

      // Non-recoverable errors
      if (status === 401) {
        throw new Error('Invalid API key');
      }
      if (status === 403) {
        throw new Error('Access forbidden');
      }

      throw error;
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
   * Generate SEO metadata with fallback
   */
  async optimizeForSEO(content, keywords = []) {
    const keywordString = keywords.join(', ');

    if (!this.enabled) {
      return this._getBasicSEO(content, keywords);
    }

    try {
      const prompt = `Generate SEO metadata for Norwegian crypto trading platform. Content headline: "${content.headline}". Keywords: ${keywordString}. Respond in JSON format with keys: title (max 60 chars), description (max 160 chars), keywords (array of 3-5 strings).`;

      const response = await this._callAIWithRetry(prompt);
      return this._parseSEOResponse(response);

    } catch (error) {
      console.warn(`⚠️  SEO optimization failed (${error.message}), using basic`);
      return this._getBasicSEO(content, keywords);
    }
  }

  /**
   * Build AI prompt for page type
   */
  _buildPrompt(pageType, requirements) {
    const basePrompts = {
      landing: `Generate landing page content for Klarpakke, a Norwegian crypto trading platform. Tone: ${requirements.tone || 'professional yet friendly'}. Audience: ${requirements.targetAudience || 'Norwegian retail investors'}. Respond in JSON format with keys: headline (max 10 words), subheadline (max 20 words), cta (max 3 words), features (array of 3 strings).`,

      pricing: `Generate pricing page content for Klarpakke trading platform. Plans: ${requirements.plans?.join(', ') || 'Paper, Safe, Pro, Extrem'}. Respond in JSON format with keys: headline, subheadline, planDescriptions (object with plan names as keys).`,

      dashboard: `Generate dashboard UI text for Klarpakke trading app. Respond in JSON format with keys: welcome, emptyState, loading, errorNetwork, errorAuth.`,

      calculator: `Generate calculator UI text for Klarpakke risk calculator. Respond in JSON format with keys: title, inputLabel, resultText, warningHighRisk, warningLowBalance.`,

      login: `Generate login page content for Klarpakke. Respond in JSON format with keys: headline, subheadline, buttonText, forgotPassword.`,

      signup: `Generate signup page content for Klarpakke. Respond in JSON format with keys: headline, subheadline, buttonText, termsText.`,

      settings: `Generate settings page content for Klarpakke. Respond in JSON format with keys: headline, apiKeyLabel, notificationLabel, saveButton, logoutButton.`
    };

    return basePrompts[pageType] || `Generate content for ${pageType} page in Norwegian. Respond in valid JSON format.`;
  }

  /**
   * Parse AI response with robustness
   */
  _parseAIResponse(aiContent, pageType) {
    try {
      // Try to extract JSON from response
      const jsonMatch = aiContent.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        if (Object.keys(parsed).length > 0) {
          return parsed;
        }
      }
    } catch (e) {
      // Parsing failed, fall back to templates
    }

    // Return fallback templates
    return this._getFallbackContent(pageType, {});
  }

  /**
   * Parse SEO response
   */
  _parseSEOResponse(content) {
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        if (parsed.title && parsed.description) {
          return {
            title: parsed.title.slice(0, 60),
            description: parsed.description.slice(0, 160),
            keywords: Array.isArray(parsed.keywords) ? parsed.keywords : []
          };
        }
      }
    } catch (e) {
      // Fall through to basic SEO
    }

    return this._getBasicSEO({ headline: 'Klarpakke' }, []);
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
        planDescriptions: {
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
        errorNetwork: 'Nettverksfeil. Prøv igjen.',
        errorAuth: 'Vennligst logg inn på nytt'
      },

      calculator: {
        title: 'Risiko-Kalkulator',
        inputLabel: 'Startbeløp (NOK)',
        resultText: 'Beregnet risiko og forventet avkastning',
        warningHighRisk: '⚠️ Høy risiko - vurder lavere leverage',
        warningLowBalance: '⚠️ For lavt beløp for valgt strategi'
      },

      login: {
        headline: 'Logg Inn',
        subheadline: 'Få tilgang til dine trading-signaler',
        buttonText: 'Logg Inn',
        forgotPassword: 'Glemt passord?'
      },

      signup: {
        headline: 'Registrer Deg',
        subheadline: 'Bli part av Klarpakke-samfunnet',
        buttonText: 'Registrer',
        termsText: 'Jeg godtar vilkårene for bruk'
      },

      settings: {
        headline: 'Innstillinger',
        apiKeyLabel: 'API-nøkkel',
        notificationLabel: 'E-postvarslinger',
        saveButton: 'Lagre',
        logoutButton: 'Logg ut'
      }
    };

    return fallbacks[pageType] || { headline: `${pageType} Page`, content: 'Default content' };
  }

  /**
   * Get basic SEO without AI
   */
  _getBasicSEO(content, keywords) {
    return {
      title: (content.headline || 'Klarpakke').slice(0, 60),
      description: (content.subheadline || 'AI-drevet trading for småsparere i Norge').slice(0, 160),
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
