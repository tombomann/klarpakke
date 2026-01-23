#!/usr/bin/env python3
"""
Aggregate sentiment from Reddit and Twitter for crypto signals
Boost or reduce AI confidence based on community sentiment
"""
import os
import sys
import json
import argparse
from typing import Dict, List
from datetime import datetime, timedelta, timezone

print("="*70)
print("💬 SENTIMENT AGGREGATION")
print("="*70)
print()

def parse_args():
    parser = argparse.ArgumentParser(description='Aggregate crypto sentiment')
    parser.add_argument('--symbol', required=True, help='Crypto symbol (e.g., BTC, ETH)')
    parser.add_argument('--base-confidence', type=float, required=True, help='AI base confidence (0.0-1.0)')
    parser.add_argument('--output', help='Output JSON file (optional)')
    return parser.parse_args()

def get_reddit_sentiment(symbol: str) -> Dict:
    """
    Fetch sentiment from r/CryptoCurrency
    
    NOTE: Requires REDDIT_CLIENT_ID and REDDIT_CLIENT_SECRET environment variables
    For production, use praw library: pip install praw
    """
    print(f"🐳 Fetching Reddit sentiment for {symbol}...")
    
    # Check for Reddit API credentials
    reddit_id = os.environ.get('REDDIT_CLIENT_ID')
    reddit_secret = os.environ.get('REDDIT_CLIENT_SECRET')
    
    if not reddit_id or not reddit_secret:
        print("  ⚠️  Reddit API credentials not set (REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET)")
        print("  🔮 Using mock data for demonstration")
        
        # Mock sentiment data
        return {
            "source": "reddit",
            "symbol": symbol,
            "posts_analyzed": 50,
            "positive": 32,
            "negative": 18,
            "sentiment_score": 0.64,  # 64% positive
            "confidence": "mock"
        }
    
    # TODO: Implement real Reddit API call using praw
    # import praw
    # reddit = praw.Reddit(
    #     client_id=reddit_id,
    #     client_secret=reddit_secret,
    #     user_agent='klarpakke:v1.0'
    # )
    # 
    # subreddit = reddit.subreddit('CryptoCurrency')
    # posts = subreddit.search(symbol, time_filter='day', limit=100)
    # 
    # # Use sentiment analysis model
    # from transformers import pipeline
    # sentiment_analyzer = pipeline('sentiment-analysis')
    # 
    # sentiments = []
    # for post in posts:
    #     text = post.title + " " + post.selftext
    #     result = sentiment_analyzer(text[:512])  # Max length
    #     sentiments.append(result[0]['label'] == 'POSITIVE')
    
    return {
        "source": "reddit",
        "symbol": symbol,
        "posts_analyzed": 0,
        "positive": 0,
        "negative": 0,
        "sentiment_score": 0.5,
        "confidence": "placeholder"
    }

def get_twitter_sentiment(symbol: str) -> Dict:
    """
    Fetch sentiment from Twitter/X
    
    NOTE: Requires TWITTER_API_KEY and TWITTER_API_SECRET environment variables
    For production, use tweepy library: pip install tweepy
    """
    print(f"🐦 Fetching Twitter sentiment for {symbol}...")
    
    # Check for Twitter API credentials
    twitter_key = os.environ.get('TWITTER_API_KEY')
    twitter_secret = os.environ.get('TWITTER_API_SECRET')
    
    if not twitter_key or not twitter_secret:
        print("  ⚠️  Twitter API credentials not set (TWITTER_API_KEY, TWITTER_API_SECRET)")
        print("  🔮 Using mock data for demonstration")
        
        # Mock sentiment data
        return {
            "source": "twitter",
            "symbol": symbol,
            "tweets_analyzed": 100,
            "positive": 68,
            "negative": 32,
            "sentiment_score": 0.68,  # 68% positive
            "confidence": "mock"
        }
    
    # TODO: Implement real Twitter API call using tweepy
    # import tweepy
    # auth = tweepy.OAuthHandler(twitter_key, twitter_secret)
    # api = tweepy.API(auth)
    # 
    # tweets = api.search_tweets(q=f"${symbol}", count=100, lang='en')
    # 
    # sentiments = []
    # for tweet in tweets:
    #     result = sentiment_analyzer(tweet.text)
    #     sentiments.append(result[0]['label'] == 'POSITIVE')
    
    return {
        "source": "twitter",
        "symbol": symbol,
        "tweets_analyzed": 0,
        "positive": 0,
        "negative": 0,
        "sentiment_score": 0.5,
        "confidence": "placeholder"
    }

def adjust_confidence(
    base_confidence: float,
    reddit_sentiment: float,
    twitter_sentiment: float,
    max_adjustment: float = 0.15
) -> Dict:
    """
    Adjust AI confidence based on community sentiment
    
    Logic:
    - If sentiment is strongly positive (>0.7): boost confidence
    - If sentiment is strongly negative (<0.3): reduce confidence
    - Max adjustment: ±15%
    """
    # Average sentiment across sources
    avg_sentiment = (reddit_sentiment + twitter_sentiment) / 2
    
    # Calculate adjustment
    # sentiment 0.5 = no change
    # sentiment 1.0 = +15% boost
    # sentiment 0.0 = -15% reduction
    adjustment = (avg_sentiment - 0.5) * 2 * max_adjustment
    
    # Apply adjustment
    adjusted_confidence = base_confidence + adjustment
    
    # Clamp to [0, 1]
    adjusted_confidence = max(0.0, min(1.0, adjusted_confidence))
    
    return {
        "base_confidence": round(base_confidence, 4),
        "avg_sentiment": round(avg_sentiment, 4),
        "adjustment": round(adjustment, 4),
        "adjusted_confidence": round(adjusted_confidence, 4),
        "recommendation": "BOOST" if adjustment > 0 else "REDUCE" if adjustment < 0 else "NEUTRAL"
    }

def main():
    args = parse_args()
    
    print(f"🎯 Symbol: {args.symbol}")
    print(f"🤖 Base AI Confidence: {args.base_confidence:.2%}")
    print()
    
    # Fetch sentiment from sources
    reddit = get_reddit_sentiment(args.symbol)
    twitter = get_twitter_sentiment(args.symbol)
    
    print()
    print("📊 Sentiment Results:")
    print(f"  Reddit: {reddit['sentiment_score']:.2%} positive ({reddit['posts_analyzed']} posts)")
    print(f"  Twitter: {twitter['sentiment_score']:.2%} positive ({twitter['tweets_analyzed']} tweets)")
    print()
    
    # Adjust confidence
    adjustment = adjust_confidence(
        args.base_confidence,
        reddit['sentiment_score'],
        twitter['sentiment_score']
    )
    
    print("⚙️  Confidence Adjustment:")
    print(f"  Base: {adjustment['base_confidence']:.2%}")
    print(f"  Avg Sentiment: {adjustment['avg_sentiment']:.2%}")
    print(f"  Adjustment: {adjustment['adjustment']:+.2%}")
    print(f"  Adjusted: {adjustment['adjusted_confidence']:.2%}")
    print(f"  Recommendation: {adjustment['recommendation']}")
    print()
    
    # Combine results
    result = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "symbol": args.symbol,
        "sentiment": {
            "reddit": reddit,
            "twitter": twitter
        },
        "confidence": adjustment
    }
    
    # Save to file if specified
    if args.output:
        with open(args.output, 'w') as f:
            json.dump(result, f, indent=2)
        print(f"💾 Results saved to: {args.output}")
    
    print("="*70)
    print("✅ SENTIMENT AGGREGATION COMPLETE")
    print("="*70)
    print()
    
    # Return exit code based on recommendation
    # 0 = neutral/boost, 1 = reduce (warning)
    return 1 if adjustment['recommendation'] == 'REDUCE' else 0

if __name__ == '__main__':
    sys.exit(main())
