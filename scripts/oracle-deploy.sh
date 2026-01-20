#!/bin/bash
#
# KLARPAKKE BACKEND - AUTOMATED ORACLE LINUX DEPLOYMENT
# Run this DIRECTLY in Oracle Serial Console
# No dependencies, no manual steps after paste
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}"
echo "════════════════════════════════════════════════"
echo "🚀 KLARPAKKE BACKEND DEPLOY"
echo "════════════════════════════════════════════════"
echo -e "${NC}"
echo "Started: $(date)"
echo ""

# =============================================================================
# 1. SYSTEM UPDATE & NODE.JS 20
# =============================================================================
echo -e "${YELLOW}[1/9] System update & Node.js 20...${NC}"
sudo dnf update -y > /dev/null 2>&1
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - > /dev/null 2>&1
sudo dnf install -y nodejs npm git gcc-c++ make htop curl wget > /dev/null 2>&1

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo -e "${GREEN}✓ Node ${NODE_VERSION} | npm ${NPM_VERSION}${NC}"

# =============================================================================
# 2. POSTGRESQL & REDIS
# =============================================================================
echo -e "${YELLOW}[2/9] PostgreSQL + Redis...${NC}"
sudo dnf install -y postgresql-server postgresql-contrib redis > /dev/null 2>&1
sudo postgresql-setup --initdb > /dev/null 2>&1
sudo systemctl enable --now postgresql redis

echo -e "${GREEN}✓ PostgreSQL + Redis started${NC}"

# =============================================================================
# 3. KLARPAKKE DATABASE & USER
# =============================================================================
echo -e "${YELLOW}[3/9] Klarpakke database setup...${NC}"
sudo -u postgres psql -c "CREATE USER klarpakke WITH PASSWORD 'klarpakke123';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE klarpakke OWNER klarpakke;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE klarpakke TO klarpakke;" 2>/dev/null || true

echo -e "${GREEN}✓ Database configured${NC}"

# =============================================================================
# 4. CLONE REPOSITORY
# =============================================================================
echo -e "${YELLOW}[4/9] Cloning github.com/tombomann/klarpakke...${NC}"
cd /home/opc
rm -rf klarpakke 2>/dev/null || true
git clone https://github.com/tombomann/klarpakke.git > /dev/null 2>&1
cd klarpakke

REPO_COMMIT=$(git rev-parse --short HEAD)
echo -e "${GREEN}✓ Repository cloned (${REPO_COMMIT})${NC}"

# =============================================================================
# 5. NPM INSTALL
# =============================================================================
echo -e "${YELLOW}[5/9] Installing dependencies...${NC}"
npm install --package-lock-only > /dev/null 2>&1
npm ci > /dev/null 2>&1

echo -e "${GREEN}✓ Dependencies installed${NC}"

# =============================================================================
# 6. ENVIRONMENT CONFIGURATION
# =============================================================================
echo -e "${YELLOW}[6/9] Environment configuration...${NC}"
cat > .env << 'ENVEOF'
NODE_ENV=staging
PORT=3000
DATABASE_URL=postgresql://klarpakke:klarpakke123@localhost:5432/klarpakke
REDIS_URL=redis://localhost:6379
PPLX_API_KEY=sk-pplx-9rGF
COINGECKO_API_KEY=demo
LOG_LEVEL=info
CORS_ORIGIN=*
ENVEOF

echo -e "${GREEN}✓ .env created${NC}"

# =============================================================================
# 7. HEALTH CHECK TEST (30 seconds)
# =============================================================================
echo -e "${YELLOW}[7/9] Testing server (30 seconds)...${NC}"

npm run dev > /tmp/server.log 2>&1 &
SERVER_PID=$!
sleep 30

HEALTH_OK=false
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ BACKEND HEALTH CHECK PASSED!${NC}"
    HEALTH_OK=true
else
    echo -e "${YELLOW}⚠️  Health check timeout - logs:${NC}"
    tail -20 /tmp/server.log || true
fi

kill $SERVER_PID 2>/dev/null || true
sleep 2

# =============================================================================
# 8. PM2 PRODUCTION SETUP
# =============================================================================
echo -e "${YELLOW}[8/9] PM2 production setup...${NC}"
sudo npm install -g pm2 > /dev/null 2>&1
pm2 delete klarpakke 2>/dev/null || true
pm2 start npm --name klarpakke -- run dev
pm2 save > /dev/null 2>&1
sudo pm2 startup > /dev/null 2>&1

echo -e "${GREEN}✓ PM2 configured${NC}"

# =============================================================================
# 9. FIREWALL CONFIGURATION
# =============================================================================
echo -e "${YELLOW}[9/9] Opening port 3000 in firewall...${NC}"
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-port=3000/tcp > /dev/null 2>&1
sudo firewall-cmd --reload > /dev/null 2>&1

echo -e "${GREEN}✓ Firewall configured${NC}"

# =============================================================================
# COMPLETION & VERIFICATION
# =============================================================================
echo ""
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE - $(date)${NC}"
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo ""

echo "📊 PM2 Status:"
pm2 status
echo ""

echo "🔍 Internal test:"
echo "   curl http://localhost:3000/health"
echo ""

echo "🌐 External test (from your Mac):"
echo "   curl http://79.76.63.189:3000/health"
echo ""

echo "📝 View logs:"
echo "   pm2 logs klarpakke --lines 50"
echo ""

echo "🔄 Restart if needed:"
echo "   pm2 restart klarpakke"
echo ""

if [ "$HEALTH_OK" = true ]; then
    echo -e "${GREEN}🎉 Backend is ready for integration!${NC}"
else
    echo -e "${YELLOW}⚠️  Check logs if health check failed${NC}"
fi

echo ""
echo "Next steps:"
echo "1. Test: curl http://localhost:3000/health"
echo "2. Bubble.io API connector setup"
echo "3. Perplexity integration test"
echo "4. Paper trading validation"
