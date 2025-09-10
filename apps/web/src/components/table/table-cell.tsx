'use client'

import { useState, useEffect, useCallback } from 'react'
import { useLocale } from 'next-intl'
import { ColumnFormat } from '@/types'
import { formatDateForDisplay, parseDateString } from '@/lib/date-utils'
import { parseDateRange, formatDateRange } from '@/lib/date-range-utils'
import { Input } from '@/components/ui/input'
import { DatePicker } from '@/components/ui/date-picker'
import { MobileDatePicker } from '@/components/ui/mobile-date-picker'

interface TableCellProps {
  row: number
  col: number
  value?: string | null
  onCellChange: (_row: number, _col: number, _value: string | null) => void
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
  const [localValue, setLocalValue] = useState(value || '')
  const [isEditing, setIsEditing] = useState(false)
  const [showMobileDatePicker, setShowMobileDatePicker] = useState(false)

  const isDateFormat = format === 'date'
  const isTimeRangeFormat = format === 'timerange'
  const locale = useLocale()

  // Sync external value changes (from real-time updates)
  useEffect(() => {
    if (!isEditing) {
      setLocalValue(value || '')
    }
  }, [value, isEditing])

  const handleChange = useCallback((newValue: string) => {
    setLocalValue(newValue)
  }, [])

  const handleFocus = useCallback(() => {
    if (!isTimeRangeFormat) {
      setIsEditing(true)
    }
  }, [isTimeRangeFormat])

  const handleBlur = useCallback(() => {
    if (!isTimeRangeFormat) {
      setIsEditing(false)

      // Only save if value changed
      if (localValue !== (value || '')) {
        let valueToSave = localValue || null

        // For date columns, try to normalize the date format
        if (isDateFormat && localValue) {
          const parsedDate = parseDateString(localValue)
          if (parsedDate) {
            valueToSave = parsedDate.toISOString() // Save as ISO format
            setLocalValue(parsedDate.toISOString()) // Update local state with normalized format
          }
        }

        onCellChange(row, col, valueToSave)
      }
    }
  }, [localValue, value, row, col, onCellChange, isDateFormat, isTimeRangeFormat])

  const handleDatePickerChange = useCallback(
    (date: Date | null | string) => {
      if (date) {
        if (typeof date === 'string') {
          // Timerange format - date is already a formatted string
          setLocalValue(date)
          onCellChange(row, col, date)
        } else {
          // Date format
          const isoString = date.toISOString().split('T')[0]
          setLocalValue(isoString)
          onCellChange(row, col, isoString)
        }
      } else {
        setLocalValue('')
        onCellChange(row, col, null)
      }
      setIsEditing(false)
    },
    [row, col, onCellChange]
  )

  // Mobile click handler for date cells
  const handleCellClick = useCallback(() => {
    if ((isDateFormat || isTimeRangeFormat) && window.innerWidth < 768) {
      // On mobile, show the mobile date picker dialog
      setShowMobileDatePicker(true)
    }
  }, [isDateFormat, isTimeRangeFormat])

  // Format display value for date/timerange columns
  const displayValue = (() => {
    if ((!isDateFormat && !isTimeRangeFormat) || !localValue) {
      return localValue
    }

    // For timerange format, always try to parse as date range
    if (isTimeRangeFormat) {
      const dateRange = parseDateRange(localValue)
      if (dateRange) {
        return formatDateRange(dateRange, locale)
      }
      return localValue
    }

    // For date format - only single date formatting
    if (isDateFormat) {
      return formatDateForDisplay(localValue, locale, format)
    }

    return localValue
  })()

  // Convert value for DatePicker (Date for date, string for timerange)
  const dateValue = (() => {
    if (isTimeRangeFormat && localValue) {
      return localValue // Pass string directly for timerange
    } else if (isDateFormat && localValue) {
      return new Date(localValue.split('T')[0])
    }
    return null
  })()

  if (isReadonly) {
    return (
      <div
        className={`p-3 min-h-[48px] flex items-center ${
          isDateFormat || isTimeRangeFormat ? 'bg-date-column' : 'bg-muted'
        }`}
      >
        <span className="text-muted-foreground">{displayValue}</span>
      </div>
    )
  }

  return (
    <div
      className={`relative min-h-[48px] flex items-center transition-colors duration-200 ${
        isDateFormat || isTimeRangeFormat
          ? 'bg-date-column hover:bg-date-column/80 cursor-pointer md:cursor-default'
          : 'hover:bg-muted/30'
      } ${isEditing ? 'ring-2 ring-primary/20 bg-interaction-highlight' : ''}`}
      onClick={handleCellClick}
      data-cell={`${row}-${col}`}
    >
      <div className="flex items-center space-x-2 w-full px-3">
        <Input
          type="text"
          value={isEditing ? localValue : displayValue}
          onChange={e => handleChange(e.target.value)}
          onFocus={handleFocus}
          onBlur={handleBlur}
          readOnly={isTimeRangeFormat}
          className={`flex-1 min-h-[40px] border-none shadow-none p-0 bg-transparent focus-visible:ring-0 focus-visible:ring-offset-0 truncate`}
        />

        {/* DatePicker button for desktop only */}
        {(isDateFormat || isTimeRangeFormat) && (
          <div className="flex-shrink-0 hidden md:block">
            <DatePicker
              value={dateValue}
              onChange={handleDatePickerChange}
              format={format}
              placeholder="Pick date"
            />
          </div>
        )}
      </div>

      {/* Mobile Date Picker Dialog */}
      {(isDateFormat || isTimeRangeFormat) && (
        <MobileDatePicker
          value={dateValue}
          onChange={handleDatePickerChange}
          format={format}
          open={showMobileDatePicker}
          onOpenChange={setShowMobileDatePicker}
          title={format === 'timerange' ? 'Select Time Range' : 'Select Date'}
        />
      )}
    </div>
  )
}
