'use client'

import { useState } from 'react'
import { useTranslations } from 'next-intl'
import { TableData, TableConfigRequest, ColumnConfigUpdate, ColumnFormat } from '@/types'
import { updateTableConfig, api } from '@/lib/api'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Label } from '@/components/ui/label'

import { Alert, AlertDescription } from '@/components/ui/alert'
import { AlertCircle, Plus, Trash2, Settings } from 'lucide-react'

interface AdminDialogProps {
  tableData: TableData
  token: string
  isOpen: boolean
  onClose: () => void
  onUpdate: () => void
}

export function AdminDialog({ tableData, token, isOpen, onClose }: AdminDialogProps) {
  const t = useTranslations()
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
        const response = await api.removeColumns(tableData.slug, token, {
          count: columnsToRemove.length,
        })
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
      },
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
    setColumnConfigs(prev => prev.map(col => (col.idx === idx ? { ...col, ...updates } : col)))
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-[95vw] sm:max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-heading-3 pr-8">
            <Settings className="h-5 w-5 flex-shrink-0" />
            <span className="truncate">{t('admin.tableSettings')}</span>
          </DialogTitle>
          <DialogDescription className="text-body text-muted-foreground">
            {t('admin.tableSettingsDescription')}
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit} className="space-y-6 mt-6">
          {/* Error message */}
          {error && (
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          {/* Table Settings */}
          <div className="space-y-4">
            <h3 className="text-heading-3">{t('admin.basicSettings')}</h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="title" className="text-body font-medium">
                  {t('admin.tableTitle')}
                </Label>
                <Input
                  id="title"
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                  placeholder={t('admin.tableTitlePlaceholder')}
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="description" className="text-body font-medium">
                  {t('admin.tableDescription')}
                </Label>
                <Textarea
                  id="description"
                  value={description}
                  onChange={e => setDescription(e.target.value)}
                  placeholder={t('admin.tableDescriptionPlaceholder')}
                  rows={3}
                  className="max-h-40 resize-y"
                />
              </div>
            </div>

            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="fixedRows"
                  checked={fixedRows}
                  onChange={e => setFixedRows(e.target.checked)}
                  className="rounded border-border"
                />
                <Label htmlFor="fixedRows" className="text-body font-medium">
                  {t('admin.fixedRows')}
                </Label>
              </div>

              <div className="flex items-center space-x-2">
                <Label htmlFor="rows" className={`text-body ${fixedRows ? '' : 'text-muted-foreground'}`}>
                  {t('admin.numberOfRows')}
                </Label>
                <Input
                  id="rows"
                  type="number"
                  min="1"
                  max="1000"
                  value={rows}
                  onChange={e => setRows(parseInt(e.target.value) || 1)}
                  disabled={!fixedRows}
                  className="w-20"
                  aria-describedby={fixedRows ? undefined : "rows-disabled-description"}
                />
                <span id="rows-disabled-description" className="sr-only">
                  {!fixedRows ? "Input is disabled when Fixed Rows is not checked" : ""}
                </span>
              </div>
            </div>
          </div>

          {/* Column Management */}
          <div className="space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
              <h3 className="text-heading-3 truncate">{t('admin.columnManagement')}</h3>
              <Button
                type="button"
                onClick={addColumn}
                size="sm"
                variant="secondary"
                className="flex items-center gap-2 flex-shrink-0"
              >
                <Plus className="h-4 w-4" />
                <span className="whitespace-nowrap">{t('admin.addColumn')}</span>
              </Button>
            </div>

            <div className="space-y-3">
              {columnConfigs.map(column => (
                <div
                  key={column.idx}
                  className="flex items-center space-x-3 p-3 border border-border rounded-lg card-flat relative"
                >
                  <span className="absolute top-2 right-2 text-xs text-muted-foreground font-medium">
                    {column.idx + 1}
                  </span>
                  <div className="flex-1 grid grid-cols-1 md:grid-cols-3 gap-3 pr-12">
                    <div>
                      <Label htmlFor={`header-${column.idx}`} className="text-body font-medium">
                        {t('admin.columnHeader')}
                      </Label>
                      <Input
                        id={`header-${column.idx}`}
                        value={column.header || ''}
                        onChange={e => updateColumnConfig(column.idx, { header: e.target.value })}
                        placeholder={t('table.columnNumber', { number: column.idx + 1 })}
                      />
                    </div>

                    <div>
                      <Label htmlFor={`width-${column.idx}`} className="text-body font-medium">
                        {t('admin.columnWidth')}
                      </Label>
                      <Input
                        id={`width-${column.idx}`}
                        type="number"
                        min="80"
                        max="500"
                        value={column.width || ''}
                        onChange={e =>
                          updateColumnConfig(column.idx, {
                            width: e.target.value ? parseInt(e.target.value) : null,
                          })
                        }
                        placeholder="120"
                      />
                    </div>

                    <div>
                      <Label htmlFor={`format-${column.idx}`} className="text-body font-medium">
                        {t('admin.columnFormat')}
                      </Label>
                      <select
                        id={`format-${column.idx}`}
                        value={column.format || 'text'}
                        onChange={e =>
                          updateColumnConfig(column.idx, {
                            format: e.target.value as ColumnFormat,
                          })
                        }
                        className="w-full px-3 py-2 border border-border rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                      >
                        <option value="text">{t('admin.formatText')}</option>
                        <option value="date">{t('admin.formatDate')}</option>
                        <option value="timerange">{t('admin.formatTimeRange')}</option>
                      </select>
                    </div>
                  </div>

                  <Button
                    type="button"
                    variant="secondary"
                    size="sm"
                    onClick={() => removeColumn(column.idx)}
                    disabled={columnConfigs.length <= 1}
                    className="flex items-center gap-1 text-destructive hover:text-destructive"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              ))}
            </div>
          </div>

          {/* Action Buttons */}
        </form>

        <DialogFooter className="flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 gap-3 sm:gap-0">
          <Button type="button" variant="secondary" onClick={onClose} className="w-full sm:w-auto">
            {t('common.cancel')}
          </Button>
          <Button
            type="button"
            onClick={e => {
              e.preventDefault()
              handleSubmit(e as any)
            }}
            disabled={isUpdating}
            className="w-full sm:w-auto"
          >
            {isUpdating ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2" />
                {t('common.saving')}
              </>
            ) : (
              t('common.save')
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
