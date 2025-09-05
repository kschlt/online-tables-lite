'use client';

/**
 * Admin drawer component for table configuration.
 */

import { useState } from 'react';
import { TableData, TableConfigRequest, ColumnConfigUpdate } from '@/types';
import { updateTableConfig } from '@/lib/api';

interface AdminDrawerProps {
  tableData: TableData;
  token: string;
  isOpen: boolean;
  onClose: () => void;
  onUpdate: (updatedTable: TableData) => void;
}

export function AdminDrawer({ tableData, token, isOpen, onClose, onUpdate }: AdminDrawerProps) {
  const [isUpdating, setIsUpdating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [title, setTitle] = useState(tableData.title || '');
  const [description, setDescription] = useState(tableData.description || '');
  const [rows, setRows] = useState(tableData.rows);
  const [cols, setCols] = useState(tableData.cols);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsUpdating(true);
    setError(null);

    try {
      const columnUpdates: ColumnConfigUpdate[] = tableData.columns.map(col => ({
        idx: col.idx,
        header: col.header,
        width: col.width,
        today_hint: col.today_hint,
      }));

      const request: TableConfigRequest = {
        title: title || null,
        description: description || null,
        rows,
        cols,
        columns: columnUpdates,
      };

      const response = await updateTableConfig(tableData.slug, token, request);
      
      if (response.success) {
        // Refresh table data - simplified approach
        window.location.reload();
      } else {
        setError(response.message);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update configuration');
    } finally {
      setIsUpdating(false);
    }
  };

  const addColumn = () => {
    if (cols < 64) { // Max limit
      setCols(cols + 1);
    }
  };

  const removeColumn = () => {
    if (cols > 1) { // Min limit
      setCols(cols - 1);
    }
  };

  const addRow = () => {
    if (rows < 500) { // Max limit
      setRows(rows + 1);
    }
  };

  const removeRow = () => {
    if (rows > 1) { // Min limit
      setRows(rows - 1);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg max-w-md w-full max-h-[90vh] overflow-y-auto">
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

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
                Table Title
              </label>
              <input
                type="text"
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
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
                onChange={(e) => setDescription(e.target.value)}
                rows={3}
                className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter table description"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Rows ({rows})
                </label>
                <div className="flex items-center space-x-2">
                  <button
                    type="button"
                    onClick={removeRow}
                    disabled={rows <= 1}
                    className="w-8 h-8 rounded border border-gray-300 flex items-center justify-center hover:bg-gray-50 disabled:opacity-50"
                  >
                    −
                  </button>
                  <span className="flex-1 text-center">{rows}</span>
                  <button
                    type="button"
                    onClick={addRow}
                    disabled={rows >= 500}
                    className="w-8 h-8 rounded border border-gray-300 flex items-center justify-center hover:bg-gray-50 disabled:opacity-50"
                  >
                    +
                  </button>
                </div>
                <div className="text-xs text-gray-500 mt-1">Max: 500</div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Columns ({cols})
                </label>
                <div className="flex items-center space-x-2">
                  <button
                    type="button"
                    onClick={removeColumn}
                    disabled={cols <= 1}
                    className="w-8 h-8 rounded border border-gray-300 flex items-center justify-center hover:bg-gray-50 disabled:opacity-50"
                  >
                    −
                  </button>
                  <span className="flex-1 text-center">{cols}</span>
                  <button
                    type="button"
                    onClick={addColumn}
                    disabled={cols >= 64}
                    className="w-8 h-8 rounded border border-gray-300 flex items-center justify-center hover:bg-gray-50 disabled:opacity-50"
                  >
                    +
                  </button>
                </div>
                <div className="text-xs text-gray-500 mt-1">Max: 64</div>
              </div>
            </div>

            <div className="flex justify-end space-x-3 pt-4">
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
  );
}