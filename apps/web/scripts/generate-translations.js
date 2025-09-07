/**
 * Script to generate JSON translation files from TypeScript objects
 * Run with: node scripts/generate-translations.js
 */

const fs = require('fs')
const path = require('path')

// Import the translations
const { translations, translationsDE } = require('../src/lib/translations/index.ts')

// Create messages directory
const messagesDir = path.join(__dirname, '..', 'messages')
if (!fs.existsSync(messagesDir)) {
  fs.mkdirSync(messagesDir, { recursive: true })
}

// Write English translations
fs.writeFileSync(
  path.join(messagesDir, 'en.json'),
  JSON.stringify(translations, null, 2)
)

// Write German translations
fs.writeFileSync(
  path.join(messagesDir, 'de.json'),
  JSON.stringify(translationsDE, null, 2)
)

console.log('✅ Translation files generated successfully!')
console.log('📁 Files created:')
console.log('  - messages/en.json')
console.log('  - messages/de.json')
