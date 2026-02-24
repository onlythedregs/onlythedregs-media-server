#!/bin/bash
# Pi Media Server Deployment Script

set -e

echo "🥧 Raspberry Pi Media Server Setup"
echo "=================================="

# Check if running on Pi
if [[ $(uname -m) != "aarch64" ]] && [[ $(uname -m) != "armv7l" ]]; then
    echo "⚠️  Warning: This script is designed for Raspberry Pi (ARM architecture)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check for required files
echo "📋 Checking configuration..."
if [[ ! -f ".env" ]]; then
    echo "❌ .env file not found. Please create it first!"
    echo "   Copy from .env.example and update your values."
    exit 1
fi

if [[ ! -d "certs" ]] || [[ ! -f "certs/fullchain.pem" ]] || [[ ! -f "certs/privkey.pem" ]]; then
    echo "❌ TLS certificates not found in ./certs/"
    echo "   Please generate certificates first (see PI_DEPLOYMENT.md)"
    exit 1
fi

# Source environment variables
source .env

echo "✅ Configuration found"
echo "   Public IP: ${PUBLIC_IP}"
echo "   Domain: ${PUBLIC_DOMAIN}"

# Check Docker
echo "🐳 Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Installing..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-v2
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    echo "⚠️  Please log out and log back in, then run this script again"
    exit 1
fi

if ! docker ps &> /dev/null; then
    echo "❌ Cannot connect to Docker. Please ensure you're in the docker group:"
    echo "   sudo usermod -aG docker $USER"
    echo "   Then log out and log back in."
    exit 1
fi

echo "✅ Docker ready"

# Choose compose file
COMPOSE_FILE="docker-compose.yml"
if [[ -f "docker-compose.pi.yml" ]]; then
    echo "🎯 Pi-optimized compose file found"
    read -p "Use Pi-optimized configuration? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        COMPOSE_FILE="docker-compose.yml"
    else
        COMPOSE_FILE="docker-compose.pi.yml"
    fi
fi

echo "📦 Building containers..."
docker-compose -f $COMPOSE_FILE build --parallel

echo "🚀 Starting services..."
docker-compose -f $COMPOSE_FILE up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "🔍 Checking service status..."
docker-compose -f $COMPOSE_FILE ps

# Test connectivity
echo "🧪 Testing connectivity..."
if curl -k --connect-timeout 5 https://localhost:443 &> /dev/null; then
    echo "✅ WSS endpoint responding"
else
    echo "⚠️  WSS endpoint not responding (may not be accessible from localhost)"
fi

# Show useful information
echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📊 Useful commands:"
echo "   View logs:     docker-compose -f $COMPOSE_FILE logs -f"
echo "   Stop services: docker-compose -f $COMPOSE_FILE down"
echo "   Service status: docker-compose -f $COMPOSE_FILE ps"
echo "   Resource usage: docker stats"
echo ""
echo "🔗 Access your media server:"
echo "   External: wss://${PUBLIC_DOMAIN}:443"
echo "   Local: wss://${INTERNAL_IP}:443"
echo ""
echo "📚 See PI_DEPLOYMENT.md for detailed configuration and troubleshooting"
echo ""
echo "🔥 To monitor Pi temperature: watch vcgencmd measure_temp"