'use client'

import * as React from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

interface CalendarProps {
  mode: 'single'
  selected?: Date
  onSelect: (_date?: Date) => void
  initialFocus?: boolean
  className?: string
}

export function Calendar({ selected, onSelect, className }: CalendarProps) {
  const [currentDate, setCurrentDate] = React.useState(() => {
    // Ensure we always have a valid Date object
    if (selected instanceof Date) {
      return selected
    }
    return new Date()
  })

  const today = new Date()
  const currentMonth = currentDate.getMonth()
  const currentYear = currentDate.getFullYear()

  // Get first day of the month
  const firstDayOfMonth = new Date(currentYear, currentMonth, 1)
  const lastDayOfMonth = new Date(currentYear, currentMonth + 1, 0)

  // Get starting day of the week (0 = Sunday)
  const startingDayOfWeek = firstDayOfMonth.getDay()
  const daysInMonth = lastDayOfMonth.getDate()

  // Create calendar grid
  const days = []

  // Add empty cells for days before month starts
  for (let i = 0; i < startingDayOfWeek; i++) {
    days.push(null)
  }

  // Add days of the month
  for (let day = 1; day <= daysInMonth; day++) {
    days.push(new Date(currentYear, currentMonth, day))
  }

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ]

  const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']

  const goToPreviousMonth = () => {
    setCurrentDate(new Date(currentYear, currentMonth - 1, 1))
  }

  const goToNextMonth = () => {
    setCurrentDate(new Date(currentYear, currentMonth + 1, 1))
  }

  const handleDateClick = (date: Date) => {
    onSelect(date)
  }

  const isSameDay = (date1: Date, date2: Date) => {
    return (
      date1.getDate() === date2.getDate() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getFullYear() === date2.getFullYear()
    )
  }

  const isToday = (date: Date) => {
    return isSameDay(date, today)
  }

  const isSelected = (date: Date) => {
    return selected ? isSameDay(date, selected) : false
  }

  return (
    <div className={cn('p-3', className)}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <Button variant="outline" size="icon" onClick={goToPreviousMonth} className="h-7 w-7">
          <ChevronLeft className="h-4 w-4" />
        </Button>

        <div className="font-semibold">
          {months[currentMonth]} {currentYear}
        </div>

        <Button variant="outline" size="icon" onClick={goToNextMonth} className="h-7 w-7">
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>

      {/* Week days header */}
      <div className="grid grid-cols-7 mb-2">
        {weekDays.map(day => (
          <div
            key={day}
            className="h-9 w-9 text-center text-sm font-medium text-muted-foreground flex items-center justify-center"
          >
            {day}
          </div>
        ))}
      </div>

      {/* Calendar grid */}
      <div className="grid grid-cols-7 gap-1">
        {days.map((date, index) => (
          <div key={index} className="h-9 w-9">
            {date ? (
              <Button
                variant="ghost"
                className={cn(
                  'h-9 w-9 p-0 font-normal hover:bg-accent hover:text-accent-foreground',
                  isToday(date) && !isSelected(date) && 'bg-accent text-accent-foreground',
                  isSelected(date) &&
                    'bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground'
                )}
                onClick={() => handleDateClick(date)}
              >
                {date.getDate()}
              </Button>
            ) : (
              <div />
            )}
          </div>
        ))}
      </div>
    </div>
  )
}
