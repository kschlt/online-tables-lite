import { FlatCompat } from '@eslint/eslintrc'
import js from '@eslint/js'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import typescriptEslint from '@typescript-eslint/eslint-plugin'
import typescriptParser from '@typescript-eslint/parser'
import nextPlugin from '@next/eslint-plugin-next'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
})

const eslintConfig = [
  // Ignore patterns for build and config files
  {
    ignores: [
      '.next/**/*',
      'node_modules/**/*',
      'out/**/*',
      '*.config.js',
      '*.config.mjs',
      '*.config.ts',
    ],
  },
  ...compat.extends('next/core-web-vitals'),
  {
    files: ['**/*.{js,jsx,ts,tsx}'],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
    plugins: {
      '@typescript-eslint': typescriptEslint,
      '@next/next': nextPlugin,
    },
    rules: {
      // Next.js specific rules
      ...nextPlugin.configs.recommended.rules,
      ...nextPlugin.configs['core-web-vitals'].rules,

      // Code quality rules
      'react/no-unescaped-entities': 'warn',
      'react-hooks/exhaustive-deps': 'warn',
      'prefer-const': 'warn',
      'no-var': 'warn',
      'no-console': 'warn',
      eqeqeq: ['warn', 'always'],
      curly: ['warn', 'all'],

      // Enforce CLAUDE.md architecture decisions
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            // HTTP clients
            {
              group: ['axios', 'swr', '@tanstack/react-query'],
              message: 'Use native fetch() only - per CLAUDE.md guidelines',
            },
            // UI component libraries
            {
              group: ['@mui/*', 'antd', '@chakra-ui/*', 'react-bootstrap'],
              message: 'Use Tailwind CSS + native HTML only - per CLAUDE.md guidelines',
            },
            // State management
            {
              group: ['redux', '@reduxjs/toolkit', 'zustand', 'jotai', 'valtio'],
              message: 'Use React hooks only - discuss complex state management first',
            },
            // CSS-in-JS
            {
              group: ['styled-components', '@emotion/*', 'stitches'],
              message: 'Use Tailwind CSS only - no CSS-in-JS per CLAUDE.md guidelines',
            },
            // Database access
            {
              group: ['prisma', 'drizzle-orm', 'typeorm'],
              message: 'Use Supabase client only - per CLAUDE.md guidelines',
            },
          ],
        },
      ],

      // Enforce component naming patterns
      'react/display-name': 'warn',

      // Disable problematic unicorn rules for now - ESLint v9 compatibility issues

      // TypeScript-specific patterns
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': 'warn',
    },
  },
]

export default eslintConfig
