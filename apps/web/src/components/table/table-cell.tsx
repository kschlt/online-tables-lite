'use client'

import { useState, useEffect, useCallback } from 'react'
import { useTranslations } from 'next-intl'
import { CellData, ColumnFormat } from '@/types'
import { getTodayDate, formatDateForDisplay, isToday, getRelativeDateDescription, parseDate } from '@/lib/date-utils'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

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
  const t = useTranslations()
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
      <div className={`border border-border p-3 min-h-[48px] flex items-center ${
        isDateFormat ? 'bg-primary-light' : 'bg-muted'
      }`}>
        <span className={`text-muted-foreground ${isValueToday ? 'font-medium text-primary' : ''}`}>
          {displayValue}
        </span>
        {relativeDateDesc && (
          <Badge variant="secondary" className="ml-2 text-xs">
            {t('table.relativeDate', { description: relativeDateDesc })}
          </Badge>
        )}
      </div>
    )
  }

  return (
    <div className="relative">
      <Input
        type="text"
        value={localValue}
        onChange={(e) => handleChange(e.target.value)}
        onFocus={handleFocus}
        onBlur={handleBlur}
        className={`w-full min-h-[48px] ${
          isDateFormat ? 'bg-primary-light' : ''
        } ${
          isEditing ? 'bg-primary-light ring-2 ring-primary/20' : isDateFormat ? 'hover:bg-primary-light' : ''
        } ${isValueToday && !isEditing ? 'font-medium text-primary' : ''}`}
        placeholder={isDateFormat ? t('table.dateFormat') : ''}
      />
      
      {/* Today date helper button */}
      {isDateFormat && isEditing && (
        <Button
          type="button"
          variant="secondary"
          size="sm"
          onClick={insertTodayDate}
          className="absolute right-1 top-1 text-xs"
          title={t('table.insertToday')}
        >
          {t('table.today')}
        </Button>
      )}
      
      {/* Relative date indicator when not editing */}
      {isDateFormat && !isEditing && relativeDateDesc && (
        <Badge variant="secondary" className="absolute right-1 top-1 text-xs">
          {t('table.relativeDate', { description: relativeDateDesc })}
        </Badge>
      )}
    </div>
  )
}
