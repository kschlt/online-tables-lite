/**
 * Table-related TypeScript types.
 */

export interface TableColumn {
  idx: number;
  header: string | null;
  width: number | null;
  today_hint: boolean;
}

export interface CellData {
  row: number;
  col: number;
  value: string | null;
}

export interface TableData {
  id: string;
  slug: string;
  title: string | null;
  description: string | null;
  cols: number;
  rows: number;
  columns: TableColumn[];
  cells: CellData[];
}

export interface CreateTableRequest {
  title?: string;
  description?: string;
  cols?: number;
  rows?: number;
}

export interface CreateTableResponse {
  slug: string;
  admin_token: string;
  edit_token: string;
}

export interface CellUpdateRequest {
  row: number;
  col: number;
  value: string | null;
}

export interface CellBatchUpdateRequest {
  cells: CellUpdateRequest[];
}

export type UserRole = 'admin' | 'editor';

export interface LoadingState {
  isLoading: boolean;
  error: string | null;
}

export interface ColumnConfigUpdate {
  idx: number;
  header?: string | null;
  width?: number | null;
  today_hint?: boolean | null;
}

export interface TableConfigRequest {
  title?: string | null;
  description?: string | null;
  rows?: number | null;
  cols?: number | null;
  columns?: ColumnConfigUpdate[] | null;
}

export interface TableConfigResponse {
  success: boolean;
  message: string;
  limits: {
    max_rows: number;
    max_cols: number;
  };
}