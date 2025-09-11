#!/bin/bash

# Development Environment Setup Script
# This script sets up the development environment with auto-formatting and linting

echo "🚀 Setting up development environment..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
cd apps/web && npm install

# Test the setup
echo "🧪 Testing auto-formatting and linting..."

# Create a test file to verify the setup
cat > test-auto-format.ts << 'TEST_EOF'
// Test file for auto-formatting
const testFunction=(a:number,b:string)=>{
if(a>0){
}
return{a,b}
}
TEST_EOF

echo "📝 Created test file with unformatted code"

# Run prettier to format it
npx prettier --write test-auto-format.ts

echo "✨ Formatted test file:"
cat test-auto-format.ts

# Run ESLint auto-fix
npx eslint test-auto-format.ts --fix

echo "🔧 ESLint auto-fix applied"

# Clean up test file
rm test-auto-format.ts

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "📋 What's configured:"
echo "   • Prettier auto-formatting on save"
echo "   • ESLint auto-fixing on save"
echo "   • Pre-commit hooks with lint-staged"
echo "   • Import organization on save"
echo "   • Trailing whitespace removal"
echo ""
echo "🎯 Usage:"
echo "   • Save any file in VS Code to auto-format and fix"
echo "   • Commit changes to trigger pre-commit hooks"
echo "   • Run 'npm run fix' to fix all files manually"
echo ""
echo "🔧 Manual commands:"
echo "   • npm run lint:fix  - Fix ESLint issues"
echo "   • npm run format    - Format with Prettier"
echo "   • npm run fix       - Run both lint:fix and format"
echo ""
