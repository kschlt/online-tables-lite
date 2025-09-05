/**
 * Editable table cell component with optimistic updates.
 */

import { useState, useEffect, useCallback } from 'react'
import { CellData } from '@/types'

interface TableCellProps {
  row: number
  col: number
  value?: string | null
  width?: number | null
  onCellChange: (row: number, col: number, value: string | null) => void
  isReadonly?: boolean
}

export function TableCell({
  row,
  col,
  value = null,
  width,
  onCellChange,
  isReadonly = false,
}: TableCellProps) {
  const [localValue, setLocalValue] = useState(value || '')
  const [isEditing, setIsEditing] = useState(false)

  // Sync external value changes (from real-time updates)
  useEffect(() => {
    if (!isEditing) {
      setLocalValue(value || '')
    }
  }, [value, isEditing])

  const handleChange = useCallback((newValue: string) => {
    setLocalValue(newValue)
    // Debounced save will happen on blur
  }, [])

  const handleFocus = useCallback(() => {
    setIsEditing(true)
  }, [])

  const handleBlur = useCallback(() => {
    setIsEditing(false)
    // Only save if value changed
    if (localValue !== (value || '')) {
      onCellChange(row, col, localValue || null)
    }
  }, [localValue, value, row, col, onCellChange])

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      ;(e.target as HTMLInputElement).blur()
    }
  }, [])

  if (isReadonly) {
    return (
      <div className="border border-gray-200 p-3 min-h-[48px] bg-gray-50 flex items-center">
        <span className="text-gray-600">{localValue}</span>
      </div>
    )
  }

  return (
    <div className="border border-gray-200 bg-white relative">
      <input
        type="text"
        value={localValue}
        onChange={e => handleChange(e.target.value)}
        onFocus={handleFocus}
        onBlur={handleBlur}
        onKeyDown={handleKeyDown}
        className={`w-full p-3 min-h-[48px] bg-transparent border-none outline-none resize-none ${
          isEditing ? 'bg-blue-50 ring-2 ring-blue-200 ring-inset' : 'hover:bg-gray-50'
        }`}
        placeholder=""
      />
    </div>
  )
}
