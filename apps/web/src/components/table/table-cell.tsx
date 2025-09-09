'use client'

import { useState, useEffect, useCallback } from 'react'
import { useTranslations } from 'next-intl'
import { useLocale } from 'next-intl'
import { ColumnFormat } from '@/types'
import { formatDateForDisplay, parseDate } from '@/lib/date-utils'
import { Input } from '@/components/ui/input'
import { DatePicker } from '@/components/ui/date-picker'

interface TableCellProps {
  row: number
  col: number
  value?: string | null
  onCellChange: (row: number, col: number, value: string | null) => void
  isReadonly?: boolean
  format?: ColumnFormat
}

export function TableCell({
  row,
  col,
  value = null,
  onCellChange,
  isReadonly = false,
  format = 'text',
}: TableCellProps) {
  const t = useTranslations()
  const [localValue, setLocalValue] = useState(value || '')
  const [isEditing, setIsEditing] = useState(false)

  const isDateFormat = format === 'date' || format === 'datetime'
  const locale = useLocale()

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

      // For date/datetime columns, try to normalize the date format
      if (isDateFormat && localValue) {
        const parsedDate = parseDate(localValue, format)
        if (parsedDate) {
          valueToSave = parsedDate // Save as ISO format
          setLocalValue(parsedDate) // Update local state with normalized format
        }
      }

      onCellChange(row, col, valueToSave)
    }
  }, [localValue, value, row, col, onCellChange, isDateFormat, format])

  const handleDatePickerChange = useCallback(
    (date: Date | null) => {
      if (date) {
        const isoString =
          format === 'datetime' ? date.toISOString() : date.toISOString().split('T')[0]
        setLocalValue(isoString)
        onCellChange(row, col, isoString)
      } else {
        setLocalValue('')
        onCellChange(row, col, null)
      }
      setIsEditing(false)
    },
    [row, col, onCellChange, format]
  )

  // Format display value for date/datetime columns
  const displayValue =
    isDateFormat && localValue ? formatDateForDisplay(localValue, format, locale) : localValue

  // Convert string value to Date object for DatePicker
  const dateValue = isDateFormat && localValue ? new Date(localValue.split('T')[0]) : null

  if (isReadonly) {
    return (
      <div
        className={`border border-border p-3 min-h-[48px] flex items-center ${
          isDateFormat ? 'bg-primary-light' : 'bg-muted'
        }`}
      >
        <span className="text-muted-foreground">{displayValue}</span>
      </div>
    )
  }

  return (
    <div className="relative">
      <div className="flex items-center space-x-1">
        <Input
          type="text"
          value={localValue}
          onChange={e => handleChange(e.target.value)}
          onFocus={handleFocus}
          onBlur={handleBlur}
          className={`flex-1 min-h-[48px] ${isDateFormat ? 'bg-primary-light' : ''} ${
            isEditing
              ? 'bg-primary-light ring-2 ring-primary/20'
              : isDateFormat
                ? 'hover:bg-primary-light'
                : ''
          }`}
          placeholder={
            isDateFormat ? (format === 'datetime' ? 'DD.MM.YYYY HH:MM' : 'DD.MM.YYYY') : ''
          }
        />

        {/* DatePicker button for date/datetime columns */}
        {isDateFormat && (
          <div className="flex-shrink-0">
            <DatePicker
              value={dateValue}
              onChange={handleDatePickerChange}
              format={format}
              placeholder="Pick date"
            />
          </div>
        )}
      </div>
    </div>
  )
}
