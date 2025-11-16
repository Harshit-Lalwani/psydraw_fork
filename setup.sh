#!/bin/bash

# PsyDraw Docker Setup Script
# This script helps set up the Docker environment for PsyDraw

set -e

# Check if running in non-interactive mode
NON_INTERACTIVE=${1:-""}

echo "🚀 PsyDraw Docker Setup"
echo "======================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo ""
    echo "Please install Docker Desktop:"
    echo "  macOS: https://docs.docker.com/desktop/install/mac-install/"
    echo "  Linux: https://docs.docker.com/engine/install/"
    echo "  Windows: https://docs.docker.com/desktop/install/windows-install/"
    echo ""
    echo "Or install via Homebrew (macOS):"
    echo "  brew install --cask docker"
    exit 1
fi

echo "✅ Docker is installed: $(docker --version)"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running!"
    echo ""
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker daemon is running"

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available!"
    echo "Please update Docker Desktop to the latest version."
    exit 1
fi

echo "✅ Docker Compose is available: $(docker compose version)"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created"
    echo ""
    
    if [ "$NON_INTERACTIVE" != "--non-interactive" ]; then
        echo "⚠️  IMPORTANT: Edit .env and add your GOOGLE_API_KEY"
        echo "   Get your key from: https://makersuite.google.com/app/apikey"
        echo ""
        read -p "Press Enter after you've added your API key to .env..."
    else
        echo "⚠️  IMPORTANT: Make sure to add your GOOGLE_API_KEY to .env"
        echo "   Get your key from: https://makersuite.google.com/app/apikey"
        echo ""
    fi
else
    echo "✅ .env file already exists"
    
    # Check if GOOGLE_API_KEY is set
    if grep -q "GOOGLE_API_KEY=your_google_api_key_here" .env || grep -q "GOOGLE_API_KEY=$" .env || grep -q "GOOGLE_API_KEY=\"\"" .env; then
        echo ""
        echo "⚠️  WARNING: GOOGLE_API_KEY appears to be empty or placeholder"
        echo "   Edit .env and add your actual API key"
        echo "   Get your key from: https://makersuite.google.com/app/apikey"
        echo ""
        
        if [ "$NON_INTERACTIVE" != "--non-interactive" ]; then
            read -p "Press Enter after you've added your API key to .env..."
        fi
    fi
fi

echo ""
echo "🏗️  Building Docker images (this may take a few minutes)..."
docker compose build

echo ""
echo "✅ Setup complete!"
echo ""

if [ "$NON_INTERACTIVE" != "--non-interactive" ]; then
    echo "To start the services, run:"
    echo "  make up"
    echo ""
    echo "Or manually:"
    echo "  docker compose up -d"
    echo ""
    echo "Access the application at:"
    echo "  - Web UI:  http://localhost:8501"
    echo "  - API:     http://localhost:9557"
    echo "  - API Docs: http://localhost:9557/docs"
fi
