/**
 * Editable table cell component with optimistic updates.
 */

import { useState, useEffect, useCallback } from 'react'
import { CellData } from '@/types'
import { getTodayDate, formatDateForDisplay, isToday, getRelativeDateDescription, parseDate } from '@/lib/date-utils'

interface TableCellProps {
  row: number
  col: number
  value?: string | null
  width?: number | null
  onCellChange: (row: number, col: number, value: string | null) => void
  isReadonly?: boolean
  todayHint?: boolean
}

export function TableCell({
  row,
  col,
  value = null,
  width,
  onCellChange,
  isReadonly = false,
  todayHint = false,
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
      let valueToSave = localValue || null
      
      // For date columns, try to normalize the date format
      if (todayHint && localValue) {
        const parsedDate = parseDate(localValue)
        if (parsedDate) {
          valueToSave = parsedDate // Save as ISO format
          setLocalValue(parsedDate) // Update local state with normalized format
        }
      }
      
      onCellChange(row, col, valueToSave)
    }
  }, [localValue, value, row, col, onCellChange, todayHint])

  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      ;(e.target as HTMLInputElement).blur()
    }
  }, [])

  const insertTodayDate = useCallback(() => {
    const today = getTodayDate().iso
    setLocalValue(today)
    onCellChange(row, col, today)
  }, [row, col, onCellChange])

  // Format display value for date columns
  const displayValue = todayHint && localValue ? formatDateForDisplay(localValue) : localValue
  const isValueToday = todayHint && localValue ? isToday(localValue) : false
  const relativeDateDesc = todayHint && localValue ? getRelativeDateDescription(localValue) : null

  if (isReadonly) {
    return (
      <div className={`border border-gray-200 p-3 min-h-[48px] bg-gray-50 flex items-center ${
        todayHint ? 'bg-blue-50' : ''
      }`}>
        <span className={`text-gray-600 ${isValueToday ? 'font-medium text-blue-700' : ''}`}>
          {displayValue}
        </span>
        {relativeDateDesc && (
          <span className="ml-2 text-xs text-blue-600 bg-blue-100 px-2 py-1 rounded">
            {relativeDateDesc}
          </span>
        )}
      </div>
    )
  }

  return (
    <div className={`border border-gray-200 bg-white relative ${
      todayHint ? 'bg-blue-50' : ''
    }`}>
      <input
        type="text"
        value={localValue}
        onChange={e => handleChange(e.target.value)}
        onFocus={handleFocus}
        onBlur={handleBlur}
        onKeyDown={handleKeyDown}
        className={`w-full p-3 min-h-[48px] bg-transparent border-none outline-none resize-none ${
          isEditing ? 'bg-blue-50 ring-2 ring-blue-200 ring-inset' : todayHint ? 'hover:bg-blue-50' : 'hover:bg-gray-50'
        } ${isValueToday && !isEditing ? 'font-medium text-blue-700' : ''}`}
        placeholder={todayHint ? 'YYYY-MM-DD' : ''}
      />
      
      {/* Today date helper button */}
      {todayHint && isEditing && (
        <button
          type="button"
          onClick={insertTodayDate}
          className="absolute right-1 top-1 p-1 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 rounded border border-blue-200 transition-colors"
          title="Insert today's date"
        >
          📅 Today
        </button>
      )}
      
      {/* Relative date indicator when not editing */}
      {todayHint && !isEditing && relativeDateDesc && (
        <div className="absolute right-1 top-1 p-1 text-xs text-blue-600 bg-blue-100 rounded">
          {relativeDateDesc}
        </div>
      )}
    </div>
  )
}
