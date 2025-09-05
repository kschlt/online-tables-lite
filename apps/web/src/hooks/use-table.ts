/**
 * Custom hook for managing table data and state.
 */

import { useState, useEffect } from 'react'
import { api } from '@/lib/api'
import type { TableData, LoadingState } from '@/types'

interface UseTableOptions {
  slug: string
  token: string | null
}

interface UseTableReturn extends LoadingState {
  tableData: TableData | null
  refetch: () => Promise<void>
}

export function useTable({ slug, token }: UseTableOptions): UseTableReturn {
  const [tableData, setTableData] = useState<TableData | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchTable = async () => {
      if (!token) {
        setError('Token required')
        setIsLoading(false)
        return
      }

      try {
        setError(null)
        setIsLoading(true)
        const data = await api.getTable(slug, token)
        setTableData(data)
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to load table'
        setError(errorMessage)
        setTableData(null)
      } finally {
        setIsLoading(false)
      }
    }

    fetchTable()
  }, [slug, token])

  const refetch = async () => {
    if (!token) {
      setError('Token required')
      setIsLoading(false)
      return
    }

    try {
      setError(null)
      setIsLoading(true)
      const data = await api.getTable(slug, token)
      setTableData(data)
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to load table'
      setError(errorMessage)
      setTableData(null)
    } finally {
      setIsLoading(false)
    }
  }

  return {
    tableData,
    isLoading,
    error,
    refetch,
  }
}
