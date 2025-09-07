'use client'

/**
 * Admin drawer component for table configuration.
 */

import { useState } from 'react'
import { TableData, TableConfigRequest, ColumnConfigUpdate, ColumnFormat } from '@/types'
import { updateTableConfig, api } from '@/lib/api'

interface AdminDrawerProps {
  tableData: TableData
  token: string
  isOpen: boolean
  onClose: () => void
  onUpdate: (updatedTable: TableData) => void
}

export function AdminDrawer({ tableData, token, isOpen, onClose, onUpdate }: AdminDrawerProps) {
  const [isUpdating, setIsUpdating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [title, setTitle] = useState(tableData.title || '')
  const [description, setDescription] = useState(tableData.description || '')
  const [fixedRows, setFixedRows] = useState(tableData.fixed_rows || false)
  const [rows, setRows] = useState(tableData.rows)
  const [columnConfigs, setColumnConfigs] = useState<ColumnConfigUpdate[]>(
    tableData.columns.map(col => ({
      idx: col.idx,
      header: col.header,
      width: col.width,
      format: col.format,
    }))
  )

  if (!isOpen) {
    return null
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsUpdating(true)
    setError(null)

    try {
      const request: TableConfigRequest = {
        title: title || null,
        description: description || null,
        rows: fixedRows ? rows : null,
        fixed_rows: fixedRows,
        columns: columnConfigs,
      }

      const response = await updateTableConfig(tableData.slug, token, request)

      if (response.success) {
        // Refresh table data - simplified approach
        window.location.reload()
      } else {
        setError(response.message)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update configuration')
    } finally {
      setIsUpdating(false)
    }
  }

  // Helper functions for column configuration
  const updateColumnHeader = (idx: number, header: string) => {
    setColumnConfigs(prev =>
      prev.map(col => (col.idx === idx ? { ...col, header: header || null } : col))
    )
  }

  const updateColumnWidth = (idx: number, width: string) => {
    const numWidth = width ? parseInt(width, 10) : null
    if (numWidth !== null && (isNaN(numWidth) || numWidth < 50 || numWidth > 800)) {
      return // Invalid width range
    }
    setColumnConfigs(prev =>
      prev.map(col => (col.idx === idx ? { ...col, width: numWidth } : col))
    )
  }

  const updateColumnFormat = (idx: number, format: ColumnFormat) => {
    setColumnConfigs(prev =>
      prev.map(col => (col.idx === idx ? { ...col, format } : col))
    )
  }

  // Fixed API-based column management
  const addColumn = async () => {
    if (columnConfigs.length >= 64) {
      setError('Cannot add more columns. Maximum is 64.')
      return
    }
    
    setIsUpdating(true)
    setError(null)

    try {
      const response = await api.addColumns(tableData.slug, token, { count: 1 })
      if (response.success) {
        // Refresh to show new column
        window.location.reload()
      } else {
        setError(response.message)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add column')
    } finally {
      setIsUpdating(false)
    }
  }

  const removeColumn = async (idx: number) => {
    if (columnConfigs.length <= 1) {
      setError('Cannot remove the last column. Tables must have at least one column.')
      return
    }
    
    setIsUpdating(true)
    setError(null)

    try {
      const response = await api.removeColumns(tableData.slug, token, { count: 1 })
      if (response.success) {
        // Refresh to show removed column
        window.location.reload()
      } else {
        setError(response.message)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to remove column')
    } finally {
      setIsUpdating(false)
    }
  }

  // Row management functions
  const addRow = async () => {
    if (rows >= 500) {
      setError('Cannot add more rows. Maximum is 500.')
      return
    }
    
    setIsUpdating(true)
    setError(null)

    try {
      const response = await api.addRows(tableData.slug, token, { count: 1 })
      if (response.success && response.new_rows) {
        setRows(response.new_rows)
      } else {
        setError(response.message)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add row')
    } finally {
      setIsUpdating(false)
    }
  }

  const removeRow = async () => {
    if (rows <= 1) {
      setError('Cannot remove rows. Tables must have at least one row.')
      return
    }
    
    setIsUpdating(true)
    setError(null)

    try {
      const response = await api.removeRows(tableData.slug, token, { count: 1 })
      if (response.success && response.new_rows) {
        setRows(response.new_rows)
      } else {
        setError(response.message)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to remove row')
    } finally {
      setIsUpdating(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold text-gray-900">Table Configuration</h2>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 text-2xl"
              aria-label="Close"
            >
              ×
            </button>
          </div>

          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded text-red-700 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Title and Description */}
            <div className="space-y-4">
              <div>
                <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
                  Table Title
                </label>
                <input
                  type="text"
                  id="title"
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                  className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter table title"
                />
              </div>

              <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                <textarea
                  id="description"
                  value={description}
                  onChange={e => setDescription(e.target.value)}
                  rows={3}
                  className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter table description"
                />
              </div>
            </div>

            {/* Column Configuration Section */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-lg font-medium text-gray-900">Column Configuration</h3>
                <div className="space-x-2">
                  <button
                    type="button"
                    onClick={addColumn}
                    disabled={isUpdating || columnConfigs.length >= 64}
                    className="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700 disabled:opacity-50"
                  >
                    + Add Column
                  </button>
                </div>
              </div>
              
              <div className="space-y-4">
                {columnConfigs.map((column, index) => (
                  <div key={column.idx} className="border border-gray-200 rounded-lg p-4 space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="font-medium text-gray-700">
                        Column {index + 1}
                      </span>
                      {columnConfigs.length > 1 && (
                        <button
                          type="button"
                          onClick={() => removeColumn(column.idx)}
                          disabled={isUpdating}
                          className="text-red-600 hover:text-red-800 text-sm disabled:opacity-50"
                        >
                          Remove
                        </button>
                      )}
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      {/* Header */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Header
                        </label>
                        <input
                          type="text"
                          value={column.header || ''}
                          onChange={e => updateColumnHeader(column.idx, e.target.value)}
                          className="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder={`Column ${index + 1}`}
                        />
                      </div>

                      {/* Width */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Width (px)
                        </label>
                        <input
                          type="number"
                          min="50"
                          max="800"
                          value={column.width || ''}
                          onChange={e => updateColumnWidth(column.idx, e.target.value)}
                          className="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                          placeholder="Auto"
                        />
                        <div className="text-xs text-gray-500 mt-1">50-800px or leave empty for auto</div>
                      </div>

                      {/* Format */}
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">
                          Format
                        </label>
                        <select
                          value={column.format || 'text'}
                          onChange={e => updateColumnFormat(column.idx, e.target.value as ColumnFormat)}
                          className="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                          <option value="text">Text</option>
                          <option value="date">Date</option>
                        </select>
                        <div className="text-xs text-gray-500 mt-1">How values should be formatted</div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Row Configuration Section */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-lg font-medium text-gray-900">Row Management</h3>
                <div className="space-x-2">
                  <button
                    type="button"
                    onClick={addRow}
                    disabled={isUpdating || rows >= 500 || fixedRows}
                    className="px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700 disabled:opacity-50"
                  >
                    + Add Row
                  </button>
                  <button
                    type="button"
                    onClick={removeRow}
                    disabled={isUpdating || rows <= 1 || fixedRows}
                    className="px-3 py-1 bg-red-600 text-white rounded text-sm hover:bg-red-700 disabled:opacity-50"
                  >
                    - Remove Row
                  </button>
                </div>
              </div>
              
              <div className="space-y-4">
                <div className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    id="fixedRows"
                    checked={fixedRows}
                    onChange={e => setFixedRows(e.target.checked)}
                    className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500"
                  />
                  <label htmlFor="fixedRows" className="text-sm text-gray-700">
                    Set fixed number of rows
                  </label>
                </div>

                {fixedRows && (
                  <div className="ml-6">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Number of rows
                    </label>
                    <input
                      type="number"
                      min="1"
                      max="500"
                      value={rows}
                      onChange={e => setRows(parseInt(e.target.value, 10) || 1)}
                      className="w-32 border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    />
                    <div className="text-xs text-gray-500 mt-1">Max: 500 rows</div>
                  </div>
                )}

                {!fixedRows && (
                  <div className="ml-6 text-sm text-gray-600">
                    <p>Auto rows is enabled. Current rows: {rows}. Use the buttons above to add/remove rows.</p>
                  </div>
                )}
              </div>
            </div>

            <div className="flex justify-end space-x-3 pt-4 border-t">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-gray-600 hover:text-gray-800"
                disabled={isUpdating}
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={isUpdating}
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
              >
                {isUpdating ? 'Updating...' : 'Update Configuration'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}
