#!/bin/bash
set -euo pipefail

REPO="tombomann/klarpakke"
ENV_FILE=".env.migration"

echo ""
echo "🔄 GITHUB SECRETS SYNC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if gh CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo "📦 Installing GitHub CLI..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install gh
        else
            echo "❌ Please install GitHub CLI manually:"
            echo "   https://cli.github.com/manual/installation"
            exit 1
        fi
    fi
    echo "✅ GitHub CLI installed"
}

# Login to GitHub CLI
login_gh() {
    echo ""
    echo "🔐 Checking GitHub CLI authentication..."
    
    if gh auth status &> /dev/null; then
        echo "✅ Already logged in"
    else
        echo "🔐 Logging in to GitHub..."
        gh auth login
    fi
}

# Push secrets from .env.migration to GitHub
push_secrets() {
    echo ""
    echo "📤 PUSHING secrets from .env.migration → GitHub..."
    echo ""
    
    if [ ! -f "$ENV_FILE" ]; then
        echo "❌ $ENV_FILE not found. Run auto-fix-keys.sh first."
        exit 1
    fi
    
    # Extract values from .env.migration
    PROJECT_ID=$(grep "^SUPABASE_PROJECT_ID=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d ' ')
    ANON_KEY=$(grep "^SUPABASE_ANON_KEY=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d ' ')
    SERVICE_KEY=$(grep "^SUPABASE_SERVICE_ROLE_KEY=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d ' ')
    DB_URL=$(grep "^SUPABASE_DB_URL=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"')
    MAKE_TEAM_ID=$(grep "^MAKE_TEAM_ID=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d ' ')
    MAKE_TOKEN=$(grep "^MAKE_API_TOKEN=" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d ' ')
    
    # Validate required keys
    if [ -z "$PROJECT_ID" ] || [ -z "$SERVICE_KEY" ]; then
        echo "❌ Missing required keys in $ENV_FILE"
        exit 1
    fi
    
    # Set secrets in GitHub
    echo "Setting SUPABASE_PROJECT_ID..."
    echo "$PROJECT_ID" | gh secret set SUPABASE_PROJECT_ID -R "$REPO"
    
    if [ -n "$ANON_KEY" ]; then
        echo "Setting SUPABASE_ANON_KEY..."
        echo "$ANON_KEY" | gh secret set SUPABASE_ANON_KEY -R "$REPO"
    fi
    
    echo "Setting SUPABASE_SERVICE_ROLE_KEY..."
    echo "$SERVICE_KEY" | gh secret set SUPABASE_SERVICE_ROLE_KEY -R "$REPO"
    
    if [ -n "$DB_URL" ]; then
        echo "Setting SUPABASE_DB_URL..."
        echo "$DB_URL" | gh secret set SUPABASE_DB_URL -R "$REPO"
    fi
    
    if [ -n "$MAKE_TEAM_ID" ] && [ "$MAKE_TEAM_ID" != "your_make_token_here" ]; then
        echo "Setting MAKE_TEAM_ID..."
        echo "$MAKE_TEAM_ID" | gh secret set MAKE_TEAM_ID -R "$REPO"
    fi
    
    if [ -n "$MAKE_TOKEN" ] && [ "$MAKE_TOKEN" != "your_make_token_here" ]; then
        echo "Setting MAKE_API_TOKEN..."
        echo "$MAKE_TOKEN" | gh secret set MAKE_API_TOKEN -R "$REPO"
    fi
    
    echo ""
    echo "✅ All secrets pushed to GitHub!"
    echo ""
    echo "Verify at: https://github.com/$REPO/settings/secrets/actions"
}

# Pull secrets from GitHub to .env.migration (Note: GitHub doesn't allow reading secret values)
pull_secrets() {
    echo ""
    echo "⚠️  LIMITATION: GitHub Secrets cannot be read back"
    echo ""
    echo "GitHub API does not expose secret values for security reasons."
    echo "You can only:"
    echo "  1. List secret names: gh secret list -R $REPO"
    echo "  2. Delete secrets: gh secret delete SECRET_NAME -R $REPO"
    echo "  3. Set new values: gh secret set SECRET_NAME -R $REPO"
    echo ""
    echo "To sync FROM GitHub → Local:"
    echo "  - You must manually copy values from original source (Supabase Dashboard)"
    echo "  - Or re-run: bash scripts/auto-fix-keys.sh"
    echo ""
}

# List current GitHub secrets
list_secrets() {
    echo ""
    echo "📋 Current GitHub Secrets for $REPO:"
    echo ""
    gh secret list -R "$REPO"
    echo ""
}

# Show usage
usage() {
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  push     Push secrets from .env.migration to GitHub (DEFAULT)"
    echo "  pull     Show info about pulling (GitHub doesn't allow reading secrets)"
    echo "  list     List current GitHub secret names"
    echo "  help     Show this help"
    echo ""
    echo "Examples:"
    echo "  $0           # Push secrets to GitHub"
    echo "  $0 push      # Same as above"
    echo "  $0 list      # List secret names"
    echo ""
}

# Main execution
main() {
    cd ~/klarpakke
    
    COMMAND="${1:-push}"
    
    case "$COMMAND" in
        push)
            check_gh_cli
            login_gh
            push_secrets
            list_secrets
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "✅ SYNC COMPLETE!"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Next: Test GitHub Actions workflow"
            echo "  open https://github.com/$REPO/actions/workflows/trading-analysis.yml"
            echo ""
            ;;
        pull)
            pull_secrets
            ;;
        list)
            check_gh_cli
            login_gh
            list_secrets
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo "❌ Unknown command: $COMMAND"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
