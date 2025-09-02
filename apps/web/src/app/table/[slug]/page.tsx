'use client'

import { useEffect, useState } from 'react'
import { useParams, useSearchParams } from 'next/navigation'

interface Column {
  idx: number
  header: string | null
  width: number | null
  today_hint: boolean
}

interface TableData {
  id: string
  slug: string
  title: string | null
  description: string | null
  cols: number
  rows: number
  columns: Column[]
}

export default function TablePage() {
  const params = useParams()
  const searchParams = useSearchParams()
  const [tableData, setTableData] = useState<TableData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const slug = params.slug as string
  const token = searchParams.get('t')

  useEffect(() => {
    if (!token) {
      setError('Token required')
      setLoading(false)
      return
    }

    const fetchTable = async () => {
      try {
        const response = await fetch(
          `${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'}/api/table/${slug}`,
          {
            headers: {
              t: token,
            },
          }
        )

        if (!response.ok) {
          throw new Error(`Failed to fetch table: ${response.status}`)
        }

        const data = await response.json()
        setTableData(data)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to load table')
      } finally {
        setLoading(false)
      }
    }

    fetchTable()
  }, [slug, token])

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-gray-600">Loading...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-red-600">Error: {error}</div>
      </div>
    )
  }

  if (!tableData) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-gray-600">Table not found</div>
      </div>
    )
  }

  return (
    <main className="min-h-screen bg-gray-50 p-4">
      <div className="max-w-full mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            {tableData.title || `Table ${tableData.slug}`}
          </h1>
          {tableData.description && <p className="text-gray-600">{tableData.description}</p>}
        </div>

        <div className="bg-white rounded-lg shadow overflow-x-auto">
          <div
            className="grid gap-0 min-w-full"
            style={{ gridTemplateColumns: `repeat(${tableData.cols}, 1fr)` }}
          >
            {tableData.columns.map(column => (
              <div
                key={column.idx}
                className="border border-gray-200 p-3 bg-gray-50 font-medium text-gray-900"
                style={{ width: column.width ? `${column.width}px` : 'auto' }}
              >
                {column.header || `Column ${column.idx + 1}`}
                {column.today_hint && <span className="ml-2 text-xs text-blue-600">📅</span>}
              </div>
            ))}
          </div>

          {Array.from({ length: tableData.rows }).map((_, rowIndex) => (
            <div
              key={rowIndex}
              className="grid gap-0"
              style={{ gridTemplateColumns: `repeat(${tableData.cols}, 1fr)` }}
            >
              {tableData.columns.map(column => (
                <div
                  key={column.idx}
                  className="border border-gray-200 p-3 min-h-[48px] bg-white"
                  style={{ width: column.width ? `${column.width}px` : 'auto' }}
                >
                  {/* Empty cells for now - Phase 2 will add data */}
                </div>
              ))}
            </div>
          ))}
        </div>
      </div>
    </main>
  )
}
