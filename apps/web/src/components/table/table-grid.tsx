/**
 * Table grid component for displaying table data.
 */

import { useState } from 'react'
import { useSearchParams } from 'next/navigation'
import { useCellEditor } from '@/hooks/use-cell-editor'
import { AdminDrawer } from '@/components/ui'
import { TableCell } from './table-cell'
import { api } from '@/lib/api'
import type { TableData } from '@/types'

interface TableGridProps {
  tableData: TableData
}

export function TableGrid({ tableData }: TableGridProps) {
  const searchParams = useSearchParams()
  const token = searchParams.get('t')
  const [isAdminDrawerOpen, setIsAdminDrawerOpen] = useState(false)
  const [isAdmin, setIsAdmin] = useState<boolean | null>(null)
  const [isUpdatingStructure, setIsUpdatingStructure] = useState(false)
  const [structureError, setStructureError] = useState<string | null>(null)

  const { getCellValue, updateCell, isUpdating, error, hasPendingUpdates, isConnected } =
    useCellEditor({
      tableId: tableData.id,
      tableSlug: tableData.slug,
      token: token || '',
      initialCells: tableData.cells || [],
    })

  if (!token) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-red-700">No access token provided</p>
      </div>
    )
  }

  // Check if user is admin by trying to access config (simplified approach)
  const checkAdminStatus = async () => {
    if (!token || isAdmin !== null) {
      return
    }

    try {
      const { updateTableConfig } = await import('@/lib/api')
      await updateTableConfig(tableData.slug, token, {}) // Empty request to test permissions
      setIsAdmin(true)
    } catch (err) {
      setIsAdmin(false)
    }
  }

  // Check admin status on mount
  if (token && isAdmin === null) {
    checkAdminStatus()
  }

  // Admin actions for row/column management
  const addRow = async () => {
    if (!isAdmin || !token || tableData.fixed_rows) return
    
    setIsUpdatingStructure(true)
    setStructureError(null)
    
    try {
      const response = await api.addRows(tableData.slug, token, { count: 1 })
      if (response.success) {
        window.location.reload() // Refresh to show new row
      } else {
        setStructureError(response.message)
      }
    } catch (err) {
      setStructureError(err instanceof Error ? err.message : 'Failed to add row')
    } finally {
      setIsUpdatingStructure(false)
    }
  }

  const addColumn = async () => {
    if (!isAdmin || !token) return
    
    setIsUpdatingStructure(true)
    setStructureError(null)
    
    try {
      const response = await api.addColumns(tableData.slug, token, { count: 1 })
      if (response.success) {
        window.location.reload() // Refresh to show new column
      } else {
        setStructureError(response.message)
      }
    } catch (err) {
      setStructureError(err instanceof Error ? err.message : 'Failed to add column')
    } finally {
      setIsUpdatingStructure(false)
    }
  }

  // Generate dynamic grid template based on column widths
  const gridTemplateColumns = tableData.columns
    .map(column => column.width ? `${column.width}px` : '1fr')
    .join(' ')

  return (
    <div className="relative">
      <div className="bg-white rounded-lg shadow overflow-x-auto">
        {/* Status indicator */}
        {(isUpdating || hasPendingUpdates || !isConnected || isUpdatingStructure) && (
          <div
            className={`border-b p-2 text-sm ${
              !isConnected
                ? 'bg-yellow-50 border-yellow-200 text-yellow-700'
                : 'bg-blue-50 border-blue-200 text-blue-700'
            }`}
          >
            {!isConnected && '⚠️ Disconnected - '}
            {isUpdatingStructure ? 'Updating table structure...' : 
             isUpdating ? 'Saving...' : hasPendingUpdates ? 'Unsaved changes' : ''}
            {!isConnected && !isUpdating && !hasPendingUpdates && !isUpdatingStructure && 'Attempting to reconnect...'}
          </div>
        )}

        {(error || structureError) && (
          <div className="bg-red-50 border-b border-red-200 p-2 text-sm text-red-700">
            Error: {error || structureError}
          </div>
        )}

        {/* Headers */}
        <div
          className="grid gap-0 min-w-full"
          style={{ gridTemplateColumns }}
        >
          {tableData.columns.map(column => (
            <div
              key={column.idx}
              className="border border-gray-200 p-3 bg-gray-50 font-medium text-gray-900"
            >
              {column.header || `Column ${column.idx + 1}`}
              {column.format === 'date' && (
                <span className="ml-2 text-xs text-blue-600" aria-label="Date format">
                  📅
                </span>
              )}
            </div>
          ))}
        </div>

        {/* Data rows */}
        {Array.from({ length: tableData.rows }).map((_, rowIndex) => (
          <div
            key={rowIndex}
            className="grid gap-0"
            style={{ gridTemplateColumns }}
          >
            {tableData.columns.map(column => (
              <TableCell
                key={`${rowIndex}-${column.idx}`}
                row={rowIndex}
                col={column.idx}
                value={getCellValue(rowIndex, column.idx)}
                onCellChange={updateCell}
                format={column.format}
              />
            ))}
          </div>
        ))}
      </div>

      {/* Elegant Admin Controls */}
      {isAdmin && (
        <div className="fixed bottom-6 left-6 space-y-3 z-40">
          {/* Add Row Button */}
          {!tableData.fixed_rows && (
            <div className="bg-white border-2 border-dashed border-gray-300 rounded-lg p-3 shadow-sm hover:border-gray-400 transition-colors">
              <button
                onClick={addRow}
                disabled={isUpdatingStructure}
                className="flex items-center space-x-2 text-gray-600 hover:text-gray-800 disabled:opacity-50 disabled:cursor-not-allowed"
                title="Add Row"
              >
                <div className="w-6 h-6 bg-gray-100 rounded-full flex items-center justify-center">
                  <span className="text-sm font-medium">+</span>
                </div>
                <span className="text-sm font-medium">Add Row</span>
              </button>
            </div>
          )}

          {/* Add Column Button */}
          <div className="bg-white border-2 border-dashed border-gray-300 rounded-lg p-3 shadow-sm hover:border-gray-400 transition-colors">
            <button
              onClick={addColumn}
              disabled={isUpdatingStructure}
              className="flex items-center space-x-2 text-gray-600 hover:text-gray-800 disabled:opacity-50 disabled:cursor-not-allowed"
              title="Add Column"
            >
              <div className="w-6 h-6 bg-gray-100 rounded-full flex items-center justify-center">
                <span className="text-sm font-medium">+</span>
              </div>
              <span className="text-sm font-medium">Add Column</span>
            </button>
          </div>
        </div>
      )}

      {/* Admin Settings Button */}
      {isAdmin && (
        <button
          onClick={() => setIsAdminDrawerOpen(true)}
          className="fixed bottom-6 right-6 bg-blue-600 text-white rounded-full w-14 h-14 shadow-lg hover:bg-blue-700 flex items-center justify-center z-40"
          title="Admin Settings"
        >
          ⚙️
        </button>
      )}

      {/* Admin drawer */}
      {isAdmin && token && (
        <AdminDrawer
          tableData={tableData}
          token={token}
          isOpen={isAdminDrawerOpen}
          onClose={() => setIsAdminDrawerOpen(false)}
          onUpdate={() => {
            // Table data will be refreshed by the drawer
          }}
        />
      )}
    </div>
  )
}
