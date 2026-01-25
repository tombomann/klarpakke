#!/bin/bash
set -euo pipefail

PROJECT_REF="swfyuwkptusceiouqlks"
ENV_FILE=".env.migration"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 FULLY AUTOMATED KEY FIX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Function to check if supabase CLI is installed
check_supabase_cli() {
    if ! command -v supabase &> /dev/null; then
        echo "📦 Installing Supabase CLI..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install supabase/tap/supabase
        else
            echo "❌ Please install Supabase CLI manually:"
            echo "   https://supabase.com/docs/guides/cli/getting-started"
            exit 1
        fi
    fi
    echo "✅ Supabase CLI installed"
}

# Function to login to Supabase
login_supabase() {
    echo ""
    echo "🔐 Logging in to Supabase..."
    echo "   → This will open your browser for authentication"
    echo ""
    
    if supabase login; then
        echo "✅ Logged in successfully"
    else
        echo "❌ Login failed"
        exit 1
    fi
}

# Function to link project
link_project() {
    echo ""
    echo "🔗 Linking project ${PROJECT_REF}..."
    
    # Create temp directory for supabase config
    mkdir -p /tmp/klarpakke-fix
    cd /tmp/klarpakke-fix
    
    # Initialize supabase if not already
    if [ ! -f "supabase/config.toml" ]; then
        supabase init --workdir .
    fi
    
    # Link project
    if supabase link --project-ref "${PROJECT_REF}" --password "Skotthyll160973???"; then
        echo "✅ Project linked"
    else
        echo "⚠️  Link failed, trying without password..."
        supabase link --project-ref "${PROJECT_REF}" || {
            echo "❌ Could not link project"
            exit 1
        }
    fi
}

# Function to extract keys from supabase status
get_keys_from_cli() {
    echo ""
    echo "📡 Fetching API keys..."
    
    # Get project status which includes API URL
    STATUS_OUTPUT=$(supabase status 2>&1 || echo "")
    
    # Try to get keys from supabase projects api-keys command
    if supabase projects api-keys --project-ref "${PROJECT_REF}" &> /dev/null; then
        KEYS_OUTPUT=$(supabase projects api-keys --project-ref "${PROJECT_REF}")
        
        # Extract anon key
        ANON_KEY=$(echo "$KEYS_OUTPUT" | grep -i "anon" | awk '{print $NF}' | head -1)
        
        # Extract service_role key
        SERVICE_KEY=$(echo "$KEYS_OUTPUT" | grep -i "service" | awk '{print $NF}' | head -1)
    else
        echo "⚠️  CLI command not available, opening dashboard..."
        open "https://supabase.com/dashboard/project/${PROJECT_REF}/settings/api"
        echo ""
        echo "Please copy keys from dashboard:"
        read -p "📝 Paste ANON key: " ANON_KEY
        read -sp "📝 Paste SERVICE_ROLE key: " SERVICE_KEY
        echo ""
    fi
    
    # Validate keys
    if [[ ! "$ANON_KEY" =~ ^eyJ ]]; then
        echo "❌ Invalid ANON_KEY format"
        exit 1
    fi
    
    if [[ ! "$SERVICE_KEY" =~ ^eyJ ]]; then
        echo "❌ Invalid SERVICE_ROLE_KEY format"
        exit 1
    fi
    
    echo "✅ Keys extracted"
}

# Function to test keys
test_keys() {
    echo ""
    echo "🧪 Testing keys..."
    
    # Test service_role key
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
        "https://${PROJECT_REF}.supabase.co/rest/v1/" \
        -H "apikey: ${SERVICE_KEY}" \
        -H "Authorization: Bearer ${SERVICE_KEY}")
    
    if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "404" ]; then
        echo "✅ Keys are valid"
    else
        echo "❌ Keys test failed (HTTP $HTTP_CODE)"
        exit 1
    fi
}

# Function to update env file
update_env_file() {
    echo ""
    echo "📝 Updating $ENV_FILE..."
    
    # Backup old env
    if [ -f "$ENV_FILE" ]; then
        cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "   📦 Backed up old file"
    fi
    
    # Write new env file
    cat > "$ENV_FILE" << EOF
# Supabase Connection (Auto-updated: $(date))
SUPABASE_PROJECT_ID=${PROJECT_REF}
SUPABASE_ANON_KEY=${ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SERVICE_KEY}
SUPABASE_DB_URL="postgresql://postgres.${PROJECT_REF}:Skotthyll160973???@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"

# Make.com
MAKE_TEAM_ID=219598
MAKE_API_TOKEN=your_make_token_here
EOF
    
    echo "   ✅ File updated"
}

# Function to test local script
test_local_script() {
    echo ""
    echo "🧪 Testing local analysis script..."
    
    cd ~/klarpakke
    source "$ENV_FILE"
    export SUPABASE_PROJECT_ID
    export SUPABASE_SERVICE_ROLE_KEY
    
    if python3 scripts/analyze_signals.py 2>&1 | head -20 | grep -q "AUTOMATED ANALYSIS"; then
        echo "✅ Local script works!"
    else
        echo "⚠️  Script ran but verify output manually"
    fi
}

# Function to show next steps
show_next_steps() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ AUTOMATION COMPLETE!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 NEXT: Update GitHub Secrets"
    echo ""
    echo "Run this to open GitHub Secrets page:"
    echo "  open https://github.com/tombomann/klarpakke/settings/secrets/actions"
    echo ""
    echo "Update these secrets:"
    echo "  SUPABASE_PROJECT_ID = ${PROJECT_REF}"
    echo "  SUPABASE_SERVICE_ROLE_KEY = <paste from .env.migration>"
    echo ""
    echo "Or run this command to auto-open and copy key:"
    echo "  echo \"Copy this key:\""
    echo "  grep SUPABASE_SERVICE_ROLE_KEY .env.migration | cut -d'=' -f2"
    echo "  open https://github.com/tombomann/klarpakke/settings/secrets/actions"
    echo ""
    echo "Then test workflow:"
    echo "  open https://github.com/tombomann/klarpakke/actions/workflows/trading-analysis.yml"
    echo ""
}

# Main execution
main() {
    cd ~/klarpakke
    
    check_supabase_cli
    login_supabase
    link_project
    get_keys_from_cli
    test_keys
    update_env_file
    test_local_script
    show_next_steps
    
    # Cleanup temp dir
    rm -rf /tmp/klarpakke-fix
}

# Run main function
main
