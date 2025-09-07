/**
 * Table grid component for displaying table data.
 */

import { useState, useEffect } from 'react'
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
  
  // Local state for table data to enable immediate updates
  const [localTableData, setLocalTableData] = useState<TableData>(tableData)

  const { getCellValue, updateCell, isUpdating, error, hasPendingUpdates, isConnected } =
    useCellEditor({
      tableId: localTableData.id,
      tableSlug: localTableData.slug,
      token: token || '',
      initialCells: localTableData.cells || [],
    })

  // Update local state when props change
  useEffect(() => {
    setLocalTableData(tableData)
  }, [tableData])

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
      await updateTableConfig(localTableData.slug, token, {}) // Empty request to test permissions
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
    if (!isAdmin || !token || localTableData.fixed_rows) return
    
    setIsUpdatingStructure(true)
    setStructureError(null)
    
    try {
      const response = await api.addRows(localTableData.slug, token, { count: 1 })
      if (response.success) {
        // Update local state immediately for instant UI feedback
        setLocalTableData(prev => ({
          ...prev,
          rows: prev.rows + 1
        }))
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
      const response = await api.addColumns(localTableData.slug, token, { count: 1 })
      if (response.success) {
        // Update local state immediately for instant UI feedback
        setLocalTableData(prev => ({
          ...prev,
          columns: [
            ...prev.columns,
            {
              idx: prev.columns.length,
              header: `Column ${prev.columns.length + 1}`,
              width: null,
              format: 'text'
            }
          ]
        }))
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
  const gridTemplateColumns = localTableData.columns
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
          {localTableData.columns.map(column => (
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
        {Array.from({ length: localTableData.rows }).map((_, rowIndex) => (
          <div
            key={rowIndex}
            className="grid gap-0"
            style={{ gridTemplateColumns }}
          >
            {localTableData.columns.map(column => (
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

        {/* Add Row Button - Inline at bottom of table */}
        {isAdmin && !localTableData.fixed_rows && (
          <div
            className="border-2 border-dashed border-gray-300 rounded-lg p-6 m-4 hover:border-gray-400 transition-colors cursor-pointer"
            onClick={addRow}
          >
            <div className="flex flex-col items-center justify-center text-gray-500 hover:text-gray-700">
              <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center mb-2">
                <span className="text-blue-600 font-medium text-lg">+</span>
              </div>
              <span className="text-sm font-medium">Add new row</span>
            </div>
          </div>
        )}
      </div>

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
          tableData={localTableData}
          token={token}
          isOpen={isAdminDrawerOpen}
          onClose={() => setIsAdminDrawerOpen(false)}
          onUpdate={() => {
            // Refresh local table data when admin drawer updates
            setLocalTableData(tableData)
          }}
        />
      )}
    </div>
  )
}
