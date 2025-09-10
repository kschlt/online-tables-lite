#!/bin/bash

# Quick start script for development
# This provides a convenient entry point for developers

echo "🚀 Online Tables Lite - Quick Start"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "apps" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Run setup if needed
if [ ! -d "apps/web/node_modules" ] || [ ! -d "apps/api/venv" ]; then
    echo "📦 Setting up development environment..."
    ./scripts/dev/setup-dev.sh
fi

# Start development servers
echo "🎯 Starting development servers..."
./scripts/dev/start-dev.sh
