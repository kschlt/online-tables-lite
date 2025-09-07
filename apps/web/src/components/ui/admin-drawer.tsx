'use client'

/**
 * Admin drawer component for table configuration.
 */

import { useState } from 'react'
import { useTranslations } from '@/hooks/use-translations'
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
  const { t } = useTranslations()
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
      // 1. Handle column additions/removals first
      const currentColumnIdxs = new Set(tableData.columns.map(col => col.idx))
      const newColumnIdxs = new Set(columnConfigs.map(col => col.idx))

      // Columns to add
      const columnsToAdd = columnConfigs.filter(col => !currentColumnIdxs.has(col.idx))
      if (columnsToAdd.length > 0) {
        const response = await api.addColumns(tableData.slug, token, { count: columnsToAdd.length })
        if (!response.success) {
          setError(response.message)
          return
        }
      }

      // Columns to remove (only if not fixed rows)
      const columnsToRemove = tableData.columns.filter(col => !newColumnIdxs.has(col.idx))
      if (columnsToRemove.length > 0) {
        const response = await api.removeColumns(tableData.slug, token, { count: columnsToRemove.length })
        if (!response.success) {
          setError(response.message)
          return
        }
      }

      // 2. Then update table configuration (title, description, rows, fixed_rows, and column properties)
      const request: TableConfigRequest = {
        title: title || null,
        description: description || null,
        rows: fixedRows ? rows : null,
        fixed_rows: fixedRows,
        columns: columnConfigs, // Send all column properties
      }

      const response = await updateTableConfig(tableData.slug, token, request)

      if (response.success) {
        window.location.reload() // Refresh to get latest data from backend
      } else {
        setError(response.message)
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : t('admin.failedToUpdateConfig'))
    } finally {
      setIsUpdating(false)
    }
  }

  const addColumn = () => {
    if (columnConfigs.length >= 64) {
      setError(t('admin.maxColumnsReached'))
      return
    }
    
    const newIdx = Math.max(...columnConfigs.map(c => c.idx), -1) + 1
    setColumnConfigs(prev => [
      ...prev,
      {
        idx: newIdx,
        header: t('table.columnNumber', { number: newIdx + 1 }),
        width: null,
        format: 'text' as ColumnFormat,
      }
    ])
  }

  const removeColumn = (idx: number) => {
    if (columnConfigs.length <= 1) {
      setError(t('admin.minColumnsReached'))
      return
    }
    
    setColumnConfigs(prev => prev.filter(col => col.idx !== idx))
  }

  const updateColumnConfig = (idx: number, updates: Partial<ColumnConfigUpdate>) => {
    setColumnConfigs(prev => 
      prev.map(col => 
        col.idx === idx ? { ...col, ...updates } : col
      )
    )
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-end sm:items-center justify-center">
      <div className="bg-white rounded-t-lg sm:rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] overflow-hidden">
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">{t('admin.tableSettings')}</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="overflow-y-auto max-h-[calc(90vh-140px)]">
          <div className="p-6 space-y-6">
            {/* Error message */}
            {error && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <p className="text-red-700">{error}</p>
              </div>
            )}

            {/* Table Settings */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium text-gray-900">{t('admin.tableSettings')}</h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
                    {t('table.title')}
                  </label>
                  <input
                    type="text"
                    id="title"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder={t('table.title')}
                  />
                </div>
                
                <div>
                  <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
                    {t('table.description')}
                  </label>
                  <input
                    type="text"
                    id="description"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    placeholder={t('table.description')}
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      checked={fixedRows}
                      onChange={(e) => setFixedRows(e.target.checked)}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="text-sm font-medium text-gray-700">{t('table.fixedRows')}</span>
                  </label>
                </div>
                
                {fixedRows && (
                  <div>
                    <label htmlFor="rows" className="block text-sm font-medium text-gray-700 mb-2">
                      {t('table.rows')}
                    </label>
                    <input
                      type="number"
                      id="rows"
                      min="1"
                      max="500"
                      value={rows}
                      onChange={(e) => setRows(parseInt(e.target.value) || 1)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                )}
              </div>
            </div>

            {/* Column Settings */}
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium text-gray-900">{t('admin.columnSettings')}</h3>
                <button
                  type="button"
                  onClick={addColumn}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
                >
                  {t('admin.addColumn')}
                </button>
              </div>

              <div className="space-y-4">
                {columnConfigs.map((column, index) => (
                  <div key={column.idx} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex items-center justify-between mb-4">
                      <h4 className="font-medium text-gray-900">
                        {t('table.columnNumber', { number: index + 1 })}
                      </h4>
                      {columnConfigs.length > 1 && (
                        <button
                          type="button"
                          onClick={() => removeColumn(column.idx)}
                          className="text-red-600 hover:text-red-800 transition-colors"
                        >
                          {t('admin.removeColumn')}
                        </button>
                      )}
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          {t('table.header')}
                        </label>
                        <input
                          type="text"
                          value={column.header || ''}
                          onChange={(e) => updateColumnConfig(column.idx, { header: e.target.value })}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                          placeholder={t('table.header')}
                        />
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          {t('table.width')}
                        </label>
                        <input
                          type="number"
                          min="50"
                          max="800"
                          value={column.width || ''}
                          onChange={(e) => updateColumnConfig(column.idx, { width: e.target.value ? parseInt(e.target.value) : null })}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                          placeholder="auto"
                        />
                        <p className="text-xs text-gray-500 mt-1">{t('admin.columnWidthHelp')}</p>
                      </div>

                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          {t('table.format')}
                        </label>
                        <select
                          value={column.format || "text"}
                          onChange={(e) => updateColumnConfig(column.idx, { format: e.target.value as ColumnFormat })}
                          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        >
                          <option value="text">{t('table.text')}</option>
                          <option value="date">{t('table.date')}</option>
                        </select>
                        <p className="text-xs text-gray-500 mt-1">{t('admin.columnFormatHelp')}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Footer */}
          <div className="border-t border-gray-200 px-6 py-4 bg-gray-50 flex items-center justify-end space-x-3">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
            >
              {t('common.cancel')}
            </button>
            <button
              type="submit"
              disabled={isUpdating}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {isUpdating ? t('admin.updating') : t('admin.updateConfiguration')}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
