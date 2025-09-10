/**
 * Table grid component with FIXED corner issues
 */

import { useState, useEffect } from 'react'
import { useSearchParams } from 'next/navigation'
import { useTranslations } from 'next-intl'
import { useCellEditor } from '@/hooks/use-cell-editor'
import { AdminDialog } from '@/components/ui'
import { TableCell } from './table-cell'
import {
  Table,
  TableHeader,
  TableBody,
  TableHead,
  TableRow,
  TableCell as ShadcnTableCell,
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Plus, Settings } from 'lucide-react'
import { findNextUpcomingDate, isNextUpcomingDate } from '@/lib/date-utils'
import type { TableData } from '@/types'

interface TableGridProps {
  tableData: TableData
}

export function TableGrid({ tableData }: TableGridProps) {
  const t = useTranslations()
  const searchParams = useSearchParams()
  const token = searchParams.get('t')
  const [isAdminDialogOpen, setIsAdminDialogOpen] = useState(false)
  const [isAdmin, setIsAdmin] = useState<boolean | null>(null)

  const [structureError, setStructureError] = useState<string | null>(null)

  // Local state for table data to enable immediate updates
  const [localTableData, setLocalTableData] = useState<TableData>(tableData)

  const { getCellValue, updateCell, error } = useCellEditor({
    tableId: localTableData.id,
    tableSlug: localTableData.slug,
    token: token || '',
    initialCells: localTableData.cells || [],
  })

  // Update local state when props change
  useEffect(() => {
    setLocalTableData(tableData)
  }, [tableData])

  // Get all date/timerange values for next date highlighting
  const getDateColumnsAndValues = () => {
    const dateColumns = localTableData.columns.filter(
      col => col.format === 'date' || col.format === 'timerange'
    )

    const dateValues: string[] = []
    dateColumns.forEach(column => {
      for (let rowIndex = 0; rowIndex < localTableData.rows; rowIndex++) {
        const cellValue = getCellValue(rowIndex, column.idx)
        if (cellValue) {
          dateValues.push(cellValue)
        }
      }
    })

    return { dateColumns, dateValues }
  }

  const { dateColumns, dateValues } = getDateColumnsAndValues()
  const nextUpcomingDate = findNextUpcomingDate(dateValues)

  if (!token) {
    return (
      <div className="status-error p-4 rounded-lg">
        <p className="text-body font-medium">{t('errors.noAccessToken')}</p>
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
      await updateTableConfig(localTableData.slug, token, {}) // Test permissions
      setIsAdmin(true)
    } catch {
      setIsAdmin(false)
    }
  }

  // Check admin status on mount
  if (token && isAdmin === null) {
    checkAdminStatus()
  }

  // Admin actions for row/column management
  const addRow = async () => {
    if (!token || !isAdmin) {
      return
    }

    try {
      setStructureError(null)
      const { api } = await import('@/lib/api')
      await api.addRows(localTableData.slug, token, {})

      // Update local state immediately
      setLocalTableData(prev => ({
        ...prev,
        rows: prev.rows + 1,
      }))
    } catch (error) {
      setStructureError(error instanceof Error ? error.message : t('admin.failedToAddRow'))
    } finally {
    }
  }

  // Calculate column widths with minimum constraints
  const getColumnWidth = (column: any) => {
    // Give date columns more minimum width to reduce truncation
    const isDateColumn = column.format === 'date' || column.format === 'timerange'
    const minWidth = isDateColumn ? 200 : 120

    if (column.width) {
      return Math.max(column.width, minWidth) + 'px'
    }
    return `minmax(${minWidth}px, 1fr)`
  }

  return (
    <div className="relative">
      {/* FIXED: Container with proper overflow handling for rounded corners */}
      <div className="card-elevated overflow-hidden">
        {(error || structureError) && (
          <div className="status-error p-3 text-sm">
            <strong>{t('common.error')}:</strong> {error || structureError}
          </div>
        )}

        {/* FIXED: Table with proper corner handling */}
        <div className="overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow className="border-b border-gray-300">
                {localTableData.columns.map(column => (
                  <TableHead
                    key={column.idx}
                    className="bg-secondary text-secondary-foreground font-semibold text-left border-r border-gray-200 last:border-r-0"
                    style={{
                      width: getColumnWidth(column),
                      minWidth:
                        column.format === 'date' || column.format === 'timerange'
                          ? '200px'
                          : '120px',
                    }}
                  >
                    <div className="flex items-center">
                      <span className="text-body font-medium">
                        {column.header || t('table.columnNumber', { number: column.idx + 1 })}
                      </span>
                      {(column.format === 'date' || column.format === 'timerange') && (
                        <span
                          className="ml-2 text-xs text-primary"
                          aria-label={
                            column.format === 'timerange'
                              ? t('admin.formatTimeRange')
                              : t('table.dateFormat')
                          }
                        >
                          {column.format === 'timerange' ? '🕐' : t('table.dateFormatIcon')}
                        </span>
                      )}
                    </div>
                  </TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {Array.from({ length: localTableData.rows }).map((_, rowIndex) => {
                // Check if this row contains the next upcoming date
                const isNextDateRow = dateColumns.some(column => {
                  const cellValue = getCellValue(rowIndex, column.idx)
                  return cellValue && nextUpcomingDate && isNextUpcomingDate(cellValue, dateValues)
                })

                return (
                  <TableRow
                    key={rowIndex}
                    className="border-b border-gray-200 hover:bg-muted/50"
                    style={isNextDateRow ? { borderLeft: '4px solid hsl(var(--primary))' } : {}}
                  >
                    {localTableData.columns.map(column => (
                      <ShadcnTableCell
                        key={`${rowIndex}-${column.idx}`}
                        className="p-0 border-r border-gray-200 last:border-r-0"
                        style={{
                          width: getColumnWidth(column),
                          minWidth:
                            column.format === 'date' || column.format === 'timerange'
                              ? '200px'
                              : '120px',
                        }}
                      >
                        <TableCell
                          row={rowIndex}
                          col={column.idx}
                          value={getCellValue(rowIndex, column.idx)}
                          onCellChange={updateCell}
                          format={column.format}
                        />
                      </ShadcnTableCell>
                    ))}
                  </TableRow>
                )
              })}
            </TableBody>
          </Table>
        </div>

        {/* FIXED: Add Row Button with proper corner handling */}
        {isAdmin && !localTableData.fixed_rows && (
          <div className="border-t border-gray-200">
            <Button
              variant="ghost"
              className="w-full justify-center text-secondary-foreground hover:text-primary hover:bg-interaction-highlight min-h-[48px] px-3 rounded-none"
              onClick={addRow}
            >
              <Plus className="w-4 h-4 mr-2" />
              <span className="text-body font-medium">{t('table.addNewRow')}</span>
            </Button>
          </div>
        )}
      </div>

      {/* Admin floating button using design system */}
      {isAdmin && (
        <Button
          onClick={() => setIsAdminDialogOpen(true)}
          className="fixed bottom-6 right-6 rounded-full w-14 h-14 shadow-lg z-40 btn-primary"
          size="icon"
          title={t('admin.settings')}
        >
          <Settings className="w-6 h-6" />
        </Button>
      )}

      {/* Admin dialog */}
      {isAdmin && token && (
        <AdminDialog
          tableData={localTableData}
          token={token}
          isOpen={isAdminDialogOpen}
          onClose={() => setIsAdminDialogOpen(false)}
          onUpdate={() => {
            // Table data will be refreshed by the drawer
          }}
        />
      )}
    </div>
  )
}
