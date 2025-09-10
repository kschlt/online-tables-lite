'use client'

import * as React from 'react'
import { Calendar as CalendarIcon } from 'lucide-react'
import { useTranslations } from 'next-intl'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { TimePickerInput } from '@/components/ui/time-picker-input'
import { createDateRangeString, parseDateRange } from '@/lib/date-range-utils'
import type { ColumnFormat } from '@/types'

interface DatePickerProps {
  value?: Date | null | string // Allow string for timerange format
  onChange: (_date: Date | null | string) => void // Return string for timerange
  placeholder?: string
  format?: ColumnFormat
  disabled?: boolean
  className?: string
}

export const DatePicker = React.forwardRef<HTMLButtonElement, DatePickerProps>(
  ({ value, onChange, format: columnFormat = 'date', disabled, className }, ref) => {
    const t = useTranslations()
    const [open, setOpen] = React.useState(false)
    const [timeStart, setTimeStart] = React.useState('')
    const [timeEnd, setTimeEnd] = React.useState('')
    const [pendingDate, setPendingDate] = React.useState<Date | null>(null)

    // Initialize state when value changes or popover opens
    React.useEffect(() => {
      if (value && columnFormat === 'timerange' && typeof value === 'string') {
        // Parse timerange format
        const dateRange = parseDateRange(value)
        if (dateRange) {
          const startDate = new Date(dateRange.start)
          const endDate = new Date(dateRange.end)
          setPendingDate(startDate)
          setTimeStart(
            `${startDate.getHours().toString().padStart(2, '0')}:${startDate.getMinutes().toString().padStart(2, '0')}`
          )
          setTimeEnd(
            `${endDate.getHours().toString().padStart(2, '0')}:${endDate.getMinutes().toString().padStart(2, '0')}`
          )
        }
      } else if (value && value instanceof Date) {
        setPendingDate(value)
      }
    }, [value, columnFormat])

    // Reset pending date when opening popover
    React.useEffect(() => {
      if (open) {
        // Handle different value types properly
        if (value instanceof Date) {
          setPendingDate(value)
        } else if (typeof value === 'string' && columnFormat === 'timerange') {
          // For timerange, parse both date and times from the string
          const dateRange = parseDateRange(value)
          if (dateRange) {
            const startDate = new Date(dateRange.start)
            const endDate = new Date(dateRange.end)
            setPendingDate(startDate)
            // Set both start and end times
            setTimeStart(
              `${startDate.getHours().toString().padStart(2, '0')}:${startDate.getMinutes().toString().padStart(2, '0')}`
            )
            setTimeEnd(
              `${endDate.getHours().toString().padStart(2, '0')}:${endDate.getMinutes().toString().padStart(2, '0')}`
            )
          } else {
            setPendingDate(null)
            setTimeStart('')
            setTimeEnd('')
          }
        } else {
          setPendingDate(null)
          setTimeStart('')
          setTimeEnd('')
        }
      }
    }, [open, value, columnFormat])

    const handleDateSelect = (selectedDate: Date | undefined) => {
      if (!selectedDate) {
        onChange(null)
        setOpen(false)
        return
      }

      // For timerange mode, store the selected date temporarily
      if (columnFormat === 'timerange') {
        setPendingDate(selectedDate)
        // Don't call onChange yet - wait for OK button
        return
      }

      // For regular date mode, apply immediately and close
      onChange(selectedDate)
      setOpen(false)
    }

    const handleTimeChange = (timeValue: string, isEndTime = false) => {
      if (isEndTime) {
        setTimeEnd(timeValue)
      } else {
        setTimeStart(timeValue)
      }
      // Don't call onChange here - wait for OK button
    }

    const handleOkClick = () => {
      if (!pendingDate) {
        setOpen(false)
        return
      }

      // For timerange format, create both start and end dates
      if (columnFormat === 'timerange') {
        const startDate = new Date(pendingDate)
        const endDate = new Date(pendingDate)

        // Apply start time
        if (timeStart) {
          const [startHours, startMinutes] = timeStart.split(':').map(Number)
          if (
            !isNaN(startHours) &&
            !isNaN(startMinutes) &&
            startHours >= 0 &&
            startHours <= 23 &&
            startMinutes >= 0 &&
            startMinutes <= 59
          ) {
            startDate.setHours(startHours, startMinutes, 0, 0)
          }
        }

        // Apply end time
        if (timeEnd) {
          const [endHours, endMinutes] = timeEnd.split(':').map(Number)
          if (
            !isNaN(endHours) &&
            !isNaN(endMinutes) &&
            endHours >= 0 &&
            endHours <= 23 &&
            endMinutes >= 0 &&
            endMinutes <= 59
          ) {
            endDate.setHours(endHours, endMinutes, 0, 0)
          }
        } else {
          // Default to 1 hour after start if no end time specified
          endDate.setTime(startDate.getTime() + 60 * 60 * 1000)
        }

        // Validate that end time is after start time
        if (endDate <= startDate) {
          endDate.setTime(startDate.getTime() + 60 * 60 * 1000) // Add 1 hour
        }

        const timeRangeString = createDateRangeString(startDate, endDate)
        onChange(timeRangeString)
        setOpen(false)
        return
      }

      // For regular date format, just return the selected date
      onChange(pendingDate)
      setOpen(false)
    }

    return (
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            ref={ref}
            variant="ghost"
            size="sm"
            className={cn('h-8 w-8 p-0', className)}
            disabled={disabled}
          >
            <CalendarIcon className="h-4 w-4" />
          </Button>
        </PopoverTrigger>
        <PopoverContent className="w-auto p-0" align="start">
          <Calendar
            mode="single"
            selected={pendingDate || (value instanceof Date ? value : undefined)}
            onSelect={handleDateSelect}
            initialFocus
          />

          {/* Clear button for date format */}
          {columnFormat === 'date' && (
            <div className="p-3 border-t">
              <Button
                variant="secondary"
                size="sm"
                onClick={() => {
                  onChange(null)
                  setOpen(false)
                }}
                className="w-full"
              >
                {t('common.clear')}
              </Button>
            </div>
          )}

          {/* Time inputs for timerange format */}
          {columnFormat === 'timerange' && (
            <div className="p-3 border-t">
              <div className="space-y-3">
                <div className="flex items-center space-x-2">
                  <label className="text-sm font-medium w-12">Start:</label>
                  <TimePickerInput
                    value={timeStart}
                    onChange={value => handleTimeChange(value)}
                    className="rounded-md"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2">
                    <label className="text-sm font-medium w-12">End:</label>
                    <TimePickerInput
                      value={timeEnd}
                      onChange={value => handleTimeChange(value, true)}
                      className="rounded-md"
                      placeholder="Required"
                    />
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => {
                        onChange(null)
                        setOpen(false)
                      }}
                    >
                      {t('common.clear')}
                    </Button>
                    <Button
                      size="sm"
                      onClick={handleOkClick}
                      disabled={columnFormat === 'timerange' && (!timeStart || !timeEnd)}
                    >
                      OK
                    </Button>
                  </div>
                </div>
                {columnFormat === 'timerange' && (!timeStart || !timeEnd) && (
                  <div className="text-xs text-red-500">
                    {t('validation.selectStartAndEndTimes')}
                  </div>
                )}
              </div>
            </div>
          )}
        </PopoverContent>
      </Popover>
    )
  }
)

DatePicker.displayName = 'DatePicker'
