/**
 * API client utilities following CLAUDE.md guidelines.
 * Uses native fetch() only as per project requirements.
 */

import { API_BASE_URL, API_ENDPOINTS } from '@/constants'
import type {
  TableData,
  CreateTableRequest,
  CreateTableResponse,
  CellBatchUpdateRequest,
  TableConfigRequest,
  TableConfigResponse,
  AddRowRequest,
  RemoveRowRequest,
  AddColumnRequest,
  RemoveColumnRequest,
  RowColumnResponse,
} from '@/types'

class ApiError extends Error {
  public readonly status: number
  public readonly response?: Response

  constructor(message: string, status: number, response?: Response) {
    super(message)
    this.name = 'ApiError'
    this.status = status
    this.response = response
  }
}

interface ApiRequestOptions extends RequestInit {
  token?: string
}

async function apiRequest<T>(endpoint: string, options: ApiRequestOptions = {}): Promise<T> {
  const { token, ...fetchOptions } = options

  const headers = new Headers(fetchOptions.headers)

  if (token) {
    headers.set('t', token)
  }

  if (!headers.has('Content-Type') && fetchOptions.method !== 'GET') {
    headers.set('Content-Type', 'application/json')
  }

  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...fetchOptions,
    headers,
  })

  if (!response.ok) {
    throw new ApiError(`API request failed: ${response.status}`, response.status, response)
  }

  return response.json()
}

export const api = {
  async createTable(request: CreateTableRequest): Promise<CreateTableResponse> {
    return apiRequest<CreateTableResponse>(API_ENDPOINTS.TABLES, {
      method: 'POST',
      body: JSON.stringify(request),
    })
  },

  async getTable(slug: string, token: string): Promise<TableData> {
    return apiRequest<TableData>(`${API_ENDPOINTS.TABLES}/${slug}`, {
      token,
    })
  },

  async updateCells(
    slug: string,
    token: string,
    request: CellBatchUpdateRequest
  ): Promise<{ success: boolean; updated_cells: number }> {
    return apiRequest<{ success: boolean; updated_cells: number }>(
      `${API_ENDPOINTS.TABLES}/${slug}/cells`,
      {
        method: 'POST',
        token,
        body: JSON.stringify(request),
      }
    )
  },

  async updateTableConfig(
    slug: string,
    token: string,
    request: TableConfigRequest
  ): Promise<TableConfigResponse> {
    return apiRequest<TableConfigResponse>(`${API_ENDPOINTS.TABLES}/${slug}/config`, {
      method: 'PUT',
      token,
      body: JSON.stringify(request),
    })
  },

  async healthCheck(): Promise<{ status: string }> {
    return apiRequest<{ status: string }>(API_ENDPOINTS.HEALTH)
  },

  async addRows(
    slug: string,
    token: string,
    request: AddRowRequest = { count: 1 }
  ): Promise<RowColumnResponse> {
    return apiRequest<RowColumnResponse>(`${API_ENDPOINTS.TABLES}/${slug}/rows`, {
      method: 'POST',
      token,
      body: JSON.stringify(request),
    })
  },

  async removeRows(
    slug: string,
    token: string,
    request: RemoveRowRequest = { count: 1 }
  ): Promise<RowColumnResponse> {
    return apiRequest<RowColumnResponse>(`${API_ENDPOINTS.TABLES}/${slug}/rows`, {
      method: 'DELETE',
      token,
      body: JSON.stringify(request),
    })
  },

  async addColumns(
    slug: string,
    token: string,
    request: AddColumnRequest = { count: 1 }
  ): Promise<RowColumnResponse> {
    return apiRequest<RowColumnResponse>(`${API_ENDPOINTS.TABLES}/${slug}/columns`, {
      method: 'POST',
      token,
      body: JSON.stringify(request),
    })
  },

  async removeColumns(
    slug: string,
    token: string,
    request: RemoveColumnRequest = { count: 1 }
  ): Promise<RowColumnResponse> {
    return apiRequest<RowColumnResponse>(`${API_ENDPOINTS.TABLES}/${slug}/columns`, {
      method: 'DELETE',
      token,
      body: JSON.stringify(request),
    })
  },
}

export { ApiError }

// Convenience exports
export const createTable = api.createTable
export const updateCells = api.updateCells
export const updateTableConfig = api.updateTableConfig
