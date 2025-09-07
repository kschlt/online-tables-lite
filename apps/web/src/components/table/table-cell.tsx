/**
 * Editable table cell component with optimistic updates.
 */

'use client'

import { useState, useEffect, useCallback } from 'react'
import { useTranslations } from '@/hooks/use-translations'
import { CellData, ColumnFormat } from '@/types'
import { getTodayDate, formatDateForDisplay, isToday, getRelativeDateDescription, parseDate } from '@/lib/date-utils'

interface TableCellProps {
  row: number
  col: number
  value?: string | null
  width?: number | null
  onCellChange: (row: number, col: number, value: string | null) => void
  isReadonly?: boolean
  format?: ColumnFormat
}

export function TableCell({
  row,
  col,
  value = null,
  width,
  onCellChange,
  isReadonly = false,
  format = 'text',
}: TableCellProps) {
  const { t } = useTranslations()
  const [localValue, setLocalValue] = useState(value || '')
  const [isEditing, setIsEditing] = useState(false)

  const isDateFormat = format === 'date'

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
      if (isDateFormat && localValue) {
        const parsedDate = parseDate(localValue)
        if (parsedDate) {
          valueToSave = parsedDate // Save as ISO format
          setLocalValue(parsedDate) // Update local state with normalized format
        }
      }
      
      onCellChange(row, col, valueToSave)
    }
  }, [localValue, value, row, col, onCellChange, isDateFormat])

  const insertTodayDate = useCallback(() => {
    const today = getTodayDate().iso
    setLocalValue(today)
    onCellChange(row, col, today)
  }, [row, col, onCellChange])

  // Format display value for date columns
  const displayValue = isDateFormat && localValue ? formatDateForDisplay(localValue) : localValue
  const isValueToday = isDateFormat && localValue ? isToday(localValue) : false
  const relativeDateDesc = isDateFormat && localValue ? getRelativeDateDescription(localValue) : null

  if (isReadonly) {
    return (
      <div
        className={`border border-gray-200 p-3 min-h-[48px] flex items-center ${
          isDateFormat ? 'bg-blue-50' : ''
        }`}
      >
        <span className={`text-gray-600 ${isValueToday ? 'font-medium text-blue-700' : ''}`}>
          {displayValue}
        </span>
        {relativeDateDesc && (
          <span className="ml-2 text-xs text-blue-600 bg-blue-100 px-2 py-1 rounded">
            {t('table.relativeDate', { description: relativeDateDesc })}
          </span>
        )}
      </div>
    )
  }

  return (
    <div className="relative">
      <input
        type="text"
        value={localValue}
        onChange={(e) => handleChange(e.target.value)}
        onFocus={handleFocus}
        onBlur={handleBlur}
        className={`w-full border border-gray-200 p-3 min-h-[48px] focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors ${
          isDateFormat ? 'bg-blue-50' : ''
        } ${
          isEditing ? 'bg-blue-50 ring-2 ring-blue-200 ring-inset' : isDateFormat ? 'hover:bg-blue-50' : 'hover:bg-gray-50'
        } ${isValueToday && !isEditing ? 'font-medium text-blue-700' : ''}`}
        placeholder={isDateFormat ? t('table.dateFormat') : ''}
      />
      
      {/* Today date helper button */}
      {isDateFormat && isEditing && (
        <button
          type="button"
          onClick={insertTodayDate}
          className="absolute right-1 top-1 p-1 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 rounded border border-blue-200 transition-colors"
          title={t('table.insertToday')}
        >
          {t('table.today')}
        </button>
      )}
      
      {/* Relative date indicator when not editing */}
      {isDateFormat && !isEditing && relativeDateDesc && (
        <div className="absolute right-1 top-1 p-1 text-xs text-blue-600 bg-blue-100 rounded">
          {t('table.relativeDate', { description: relativeDateDesc })}
        </div>
      )}
    </div>
  )
}
