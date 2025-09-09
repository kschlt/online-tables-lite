'use client'

import * as React from 'react'
import { Calendar as CalendarIcon } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { TimePickerInput } from '@/components/ui/time-picker-input'
import type { ColumnFormat } from '@/types'

interface DatePickerProps {
  value?: Date | null
  onChange: (date: Date | null) => void
  placeholder?: string
  format?: ColumnFormat
  disabled?: boolean
  className?: string
}

export function DatePicker({
  value,
  onChange,
  format: columnFormat = 'date',
  disabled,
  className,
}: DatePickerProps) {
  const [open, setOpen] = React.useState(false)
  const [timeStart, setTimeStart] = React.useState('')
  const [timeEnd, setTimeEnd] = React.useState('')
  const [pendingDate, setPendingDate] = React.useState<Date | null>(null)

  // Initialize state when value changes or popover opens
  React.useEffect(() => {
    if (value && columnFormat === 'datetime') {
      const hours = value.getHours()
      const minutes = value.getMinutes()
      setTimeStart(`${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`)
      setPendingDate(value)
    } else if (value) {
      setPendingDate(value)
    }
  }, [value, columnFormat])

  // Reset pending date when opening popover
  React.useEffect(() => {
    if (open) {
      setPendingDate(value || null)
      if (value && columnFormat === 'datetime') {
        const hours = value.getHours()
        const minutes = value.getMinutes()
        setTimeStart(`${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`)
      }
    }
  }, [open, value, columnFormat])

  const handleDateSelect = (selectedDate: Date | undefined) => {
    if (!selectedDate) {
      onChange(null)
      setOpen(false)
      return
    }

    // For datetime mode, store the selected date temporarily
    if (columnFormat === 'datetime') {
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

    const finalDate = new Date(pendingDate)

    // Apply start time if provided
    if (timeStart) {
      const [hours, minutes] = timeStart.split(':').map(Number)
      if (!isNaN(hours) && !isNaN(minutes) && hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59) {
        finalDate.setHours(hours, minutes, 0, 0)
      }
    }

    onChange(finalDate)
    setOpen(false)
  }

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
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
          selected={pendingDate || value || undefined}
          onSelect={handleDateSelect}
          initialFocus
        />

        {/* Time inputs for datetime format */}
        {columnFormat === 'datetime' && (
          <div className="p-3 border-t">
            <div className="space-y-3">
              <div className="flex items-center space-x-2">
                <label className="text-sm font-medium">Start:</label>
                <TimePickerInput
                  value={timeStart}
                  onChange={value => handleTimeChange(value)}
                  className="rounded-md"
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <label className="text-sm font-medium">End:</label>
                  <TimePickerInput
                    value={timeEnd}
                    onChange={value => handleTimeChange(value, true)}
                    className="rounded-md"
                    placeholder="Optional"
                  />
                </div>
                <Button
                  size="sm"
                  onClick={handleOkClick}
                  className="h-8"
                >
                  OK
                </Button>
              </div>
            </div>
          </div>
        )}
      </PopoverContent>
    </Popover>
  )
}
