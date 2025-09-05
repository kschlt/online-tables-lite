/**
 * Table grid component for displaying table data.
 */

import { useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { useCellEditor } from '@/hooks/use-cell-editor';
import { AdminDrawer } from '@/components/ui';
import { TableCell } from './table-cell';
import type { TableData } from '@/types';

interface TableGridProps {
  tableData: TableData;
}

export function TableGrid({ tableData }: TableGridProps) {
  const searchParams = useSearchParams();
  const token = searchParams.get('t');
  const [isAdminDrawerOpen, setIsAdminDrawerOpen] = useState(false);
  const [isAdmin, setIsAdmin] = useState<boolean | null>(null);

  const {
    getCellValue,
    updateCell,
    isUpdating,
    error,
    hasPendingUpdates,
    isConnected,
  } = useCellEditor({
    tableId: tableData.id,
    tableSlug: tableData.slug,
    token: token || '',
    initialCells: tableData.cells || [],
  });

  if (!token) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-red-700">No access token provided</p>
      </div>
    );
  }

  // Check if user is admin by trying to access config (simplified approach)
  const checkAdminStatus = async () => {
    if (!token || isAdmin !== null) return;
    
    try {
      const { updateTableConfig } = await import('@/lib/api');
      await updateTableConfig(tableData.slug, token, {}); // Empty request to test permissions
      setIsAdmin(true);
    } catch (err) {
      setIsAdmin(false);
    }
  };

  // Check admin status on mount
  if (token && isAdmin === null) {
    checkAdminStatus();
  }

  return (
    <div className="relative">
      <div className="bg-white rounded-lg shadow overflow-x-auto">
      {/* Status indicator */}
      {(isUpdating || hasPendingUpdates || !isConnected) && (
        <div className={`border-b p-2 text-sm ${
          !isConnected 
            ? 'bg-yellow-50 border-yellow-200 text-yellow-700'
            : 'bg-blue-50 border-blue-200 text-blue-700'
        }`}>
          {!isConnected && '⚠️ Disconnected - '}
          {isUpdating ? 'Saving...' : hasPendingUpdates ? 'Unsaved changes' : ''}
          {!isConnected && !isUpdating && !hasPendingUpdates && 'Attempting to reconnect...'}
        </div>
      )}
      
      {error && (
        <div className="bg-red-50 border-b border-red-200 p-2 text-sm text-red-700">
          Error: {error}
        </div>
      )}

      {/* Headers */}
      <div
        className="grid gap-0 min-w-full"
        style={{ gridTemplateColumns: `repeat(${tableData.cols}, 1fr)` }}
      >
        {tableData.columns.map((column) => (
          <div
            key={column.idx}
            className="border border-gray-200 p-3 bg-gray-50 font-medium text-gray-900"
            style={{ width: column.width ? `${column.width}px` : 'auto' }}
          >
            {column.header || `Column ${column.idx + 1}`}
            {column.today_hint && (
              <span className="ml-2 text-xs text-blue-600" aria-label="Today hint">
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
          style={{ gridTemplateColumns: `repeat(${tableData.cols}, 1fr)` }}
        >
          {tableData.columns.map((column) => (
            <TableCell
              key={`${rowIndex}-${column.idx}`}
              row={rowIndex}
              col={column.idx}
              value={getCellValue(rowIndex, column.idx)}
              width={column.width}
              onCellChange={updateCell}
            />
          ))}
        </div>
      ))}
      </div>

      {/* Admin floating button */}
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
  );
}