/**
 * Table-related TypeScript types.
 */

export type ColumnFormat = 'text' | 'date'

export interface TableColumn {
  idx: number
  header: string | null
  width: number | null
  format: ColumnFormat
}

export interface CellData {
  row: number
  col: number
  value: string | null
}

export interface TableData {
  id: string
  slug: string
  title: string | null
  description: string | null
  cols: number
  rows: number
  fixed_rows: boolean
  columns: TableColumn[]
  cells: CellData[]
}

export interface CreateTableRequest {
  title?: string
  description?: string
  cols?: number
  rows?: number
}

export interface CreateTableResponse {
  slug: string
  admin_token: string
  edit_token: string
}

export interface CellUpdateRequest {
  row: number
  col: number
  value: string | null
}

export interface CellBatchUpdateRequest {
  cells: CellUpdateRequest[]
}

export type UserRole = 'admin' | 'editor'

export interface LoadingState {
  isLoading: boolean
  error: string | null
}

export interface ColumnConfigUpdate {
  idx: number
  header?: string | null
  width?: number | null
  format?: ColumnFormat | null
}

export interface TableConfigRequest {
  title?: string | null
  description?: string | null
  rows?: number | null
  fixed_rows?: boolean | null
  columns?: ColumnConfigUpdate[] | null
}

export interface TableConfigResponse {
  success: boolean
  message: string
  limits: {
    max_rows: number
    max_cols: number
  }
}

export interface AddRowRequest {
  count?: number
}

export interface RemoveRowRequest {
  count?: number
}

export interface AddColumnRequest {
  count?: number
  header?: string
}

export interface RemoveColumnRequest {
  count?: number
}

export interface RowColumnResponse {
  success: boolean
  message: string
  new_rows?: number | null
  new_cols?: number | null
}
