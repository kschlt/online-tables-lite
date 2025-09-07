/**
 * Table grid component using Shadcn/UI components and design system.
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
  TableCell as ShadcnTableCell 
} from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Plus, Settings } from 'lucide-react'
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
    if (!token || !isAdmin) return

    try {
      setIsUpdatingStructure(true)
      setStructureError(null)
      const { api } = await import('@/lib/api')
      await api.addRows(localTableData.slug, token, {})
      
      // Update local state immediately
      setLocalTableData(prev => ({
        ...prev,
        rows: prev.rows + 1
      }))
    } catch (err) {
      setStructureError(err instanceof Error ? err.message : t('admin.failedToAddRow'))
    } finally {
      setIsUpdatingStructure(false)
    }
  }

  // Calculate column widths with minimum constraints
  const getColumnWidth = (column: any) => {
    if (column.width) {
      return Math.max(column.width, 120) + 'px'
    }
    return 'minmax(120px, 1fr)'
  }

  return (
    <div className="relative">
      <div className="card-elevated">
        {/* Status indicator using design system */}
        {(isUpdating || hasPendingUpdates || !isConnected || isUpdatingStructure) && (
          <div className={`border-b p-3 text-sm ${
            !isConnected
              ? 'status-warning'
              : 'status-info'
          }`}>
            {!isConnected && `⚠️ ${t('status.disconnected')} - `}
            {isUpdatingStructure ? t('status.updatingStructure') : 
             isUpdating ? t('common.saving') : hasPendingUpdates ? t('status.unsavedChanges') : ''}
            {!isConnected && !isUpdating && !hasPendingUpdates && !isUpdatingStructure && t('status.connecting')}
          </div>
        )}

        {(error || structureError) && (
          <div className="status-error p-3 text-sm">
            <strong>{t('common.error')}:</strong> {error || structureError}
          </div>
        )}

        {/* Table using Shadcn/UI components */}
        <Table>
          <TableHeader>
            <TableRow>
              {localTableData.columns.map(column => (
                <TableHead
                  key={column.idx}
                  className="bg-secondary text-secondary-foreground font-semibold text-left border border-border"
                  style={{ 
                    width: getColumnWidth(column),
                    minWidth: '120px'
                  }}
                >
                  <div className="flex items-center">
                    <span className="text-body font-medium">
                      {column.header || t('table.columnNumber', { number: column.idx + 1 })}
                    </span>
                    {column.format === 'date' && (
                      <span className="ml-2 text-xs text-primary" aria-label={t('table.dateFormat')}>
                        {t('table.dateFormatIcon')}
                      </span>
                    )}
                  </div>
                </TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {Array.from({ length: localTableData.rows }).map((_, rowIndex) => (
              <TableRow key={rowIndex}>
                {localTableData.columns.map(column => (
                  <ShadcnTableCell
                    key={`${rowIndex}-${column.idx}`}
                    className="p-0 border border-border"
                    style={{ 
                      width: getColumnWidth(column),
                      minWidth: '120px'
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
            ))}
          </TableBody>
        </Table>

        {/* Add Row Button using design system */}
        {isAdmin && !localTableData.fixed_rows && (
          <div className="border-t border-border p-3">
            <Button
              variant="ghost"
              className="w-full justify-center text-secondary-foreground hover:text-primary hover:bg-primary-light"
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
