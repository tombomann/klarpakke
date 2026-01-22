"""Phase 1: Signal Ingestion Pipeline - MVP"""
import os
import json
import logging
import requests

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

API_KEY = os.getenv("PERPLEXITY_API_KEY", "")
ENDPOINT = "https://api.perplexity.ai/chat/completions"

def get_signal(symbol):
    """Fetch one signal from Perplexity"""
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "sonar-pro",
        "messages": [{"role": "user", "content": f"Analyze {symbol} price trend today"}],
        "temperature": 0.2
    }
    
    try:
        resp = requests.post(ENDPOINT, headers=headers, json=payload, timeout=30)
        if resp.status_code == 200:
            logger.info(f"✅ {symbol}: API responded")
            return True
        else:
            logger.error(f"❌ {symbol}: HTTP {resp.status_code}")
            return False
    except Exception as e:
        logger.error(f"❌ {symbol}: {e}")
        return False

if __name__ == "__main__":
    logger.info("🚀 Phase 1 Signal Ingestion Pipeline")
    if not API_KEY:
        logger.error("No PERPLEXITY_API_KEY set")
    else:
        for symbol in ["BTC", "ETH"]:
            get_signal(symbol)
        logger.info("✅ Pipeline complete")
