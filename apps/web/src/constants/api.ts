/**
 * API configuration constants.
 */

export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
export const API_VERSION = 'v1';
export const API_ENDPOINTS = {
  HEALTH: '/healthz',
  TABLES: `/api/${API_VERSION}/tables`,
} as const;