'use client'

import * as React from 'react'
import { useTranslations } from 'next-intl'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Dialog, DialogContent, DialogTitle } from '@/components/ui/dialog'
import { VisuallyHidden } from '@radix-ui/react-visually-hidden'
import { TimePickerInput } from '@/components/ui/time-picker-input'
import { createDateRangeString, parseDateRange } from '@/lib/date-range-utils'
import type { ColumnFormat } from '@/types'

interface MobileDatePickerProps {
  value?: Date | null | string
  onChange: (_date: Date | null | string) => void
  format?: ColumnFormat
  open: boolean
  onOpenChange: (open: boolean) => void
  title?: string
}

export function MobileDatePicker({
  value,
  onChange,
  format: columnFormat = 'date',
  open,
  onOpenChange,
  title = 'Select Date',
}: MobileDatePickerProps) {
  const t = useTranslations()
  const [timeStart, setTimeStart] = React.useState('')
  const [timeEnd, setTimeEnd] = React.useState('')
  const [pendingDate, setPendingDate] = React.useState<Date | null>(null)

  // Initialize state when value changes or dialog opens
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

  // Reset pending date when opening dialog
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
      onOpenChange(false)
      return
    }

    // For timerange mode, store the selected date temporarily
    if (columnFormat === 'timerange') {
      setPendingDate(selectedDate)
      // Don't close - wait for Done button since timerange needs time input
      return
    }

    // For regular date mode, apply immediately and close (same as desktop)
    // Use setTimeout to avoid any potential state update conflicts
    setTimeout(() => {
      onChange(selectedDate)
      onOpenChange(false)
    }, 0)
  }

  const handleTimeChange = (timeValue: string, isEndTime = false) => {
    if (isEndTime) {
      setTimeEnd(timeValue)
    } else {
      setTimeStart(timeValue)
    }
    // Don't call onChange here - wait for Done button
  }

  const handleDoneClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    if (!pendingDate) {
      onOpenChange(false)
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
      onOpenChange(false)
      return
    }

    // For regular date format, just return the selected date
    onChange(pendingDate)
    onOpenChange(false)
  }

  const handleClear = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    onChange(null)
    onOpenChange(false)
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-sm mx-auto gap-0 rounded-lg [&>button]:hidden p-4">
        {/* Always include DialogTitle for accessibility, but hide it visually */}
        <VisuallyHidden>
          <DialogTitle>{title}</DialogTitle>
        </VisuallyHidden>

        <Calendar
          mode="single"
          selected={pendingDate || (value instanceof Date ? value : undefined)}
          onSelect={handleDateSelect}
          initialFocus
          className="w-full"
        />

        {/* Clear button for date format */}
        {columnFormat === 'date' && (
          <div className="mt-4 pt-4 border-t">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleClear}
              className="w-full h-8"
            >
              {t('common.clear')}
            </Button>
          </div>
        )}

        {/* Time inputs for timerange format */}
        {columnFormat === 'timerange' && (
          <div className="mt-4 pt-4 border-t">
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
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={handleClear}
                    className="h-8"
                  >
                    {t('common.clear')}
                  </Button>
                  <Button
                    type="button"
                    size="sm"
                    onClick={handleDoneClick}
                    className="h-8"
                    disabled={!timeStart || !timeEnd}
                  >
                    OK
                  </Button>
                </div>
              </div>
              {(!timeStart || !timeEnd) && (
                <div className="text-xs text-red-500">
                  {t('validation.selectStartAndEndTimes')}
                </div>
              )}
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  )
}