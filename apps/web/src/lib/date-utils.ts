/**
 * Date utilities for date and datetime functionality.
 */

import { format, parse, isValid, startOfDay } from 'date-fns'
import { de, enUS } from 'date-fns/locale'
import type { ColumnFormat } from '@/types'

/**
 * Get today's date in various formats.
 */
export function getTodayDate() {
  const today = new Date()
  return {
    iso: today.toISOString().split('T')[0], // YYYY-MM-DD
    us: today.toLocaleDateString('en-US'), // MM/DD/YYYY
    eu: today.toLocaleDateString('en-GB'), // DD/MM/YYYY
    readable: today.toLocaleDateString('en-US', {
      weekday: 'short',
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    }), // Fri, Dec 1, 2023
  }
}

/**
 * Parse various date and datetime formats and return ISO string.
 */
export function parseDate(value: string, columnFormat: ColumnFormat = 'date'): string | null {
  if (!value || typeof value !== 'string') {
    return null
  }

  const cleaned = value.trim()
  if (!cleaned) {
    return null
  }

  // Handle datetime format with time ranges (e.g., "13.05.24 19:00-20:30")
  if (columnFormat === 'datetime') {
    const datetimeMatch = cleaned.match(
      /^(\d{1,2})\.(\d{1,2})\.(\d{2,4})(?:\s+(\d{1,2}):(\d{2})(?:-(\d{1,2}):(\d{2}))?)?$/
    )
    if (datetimeMatch) {
      const [, day, month, year, startHour, startMin, endHour, endMin] = datetimeMatch
      const fullYear = year.length === 2 ? `20${year}` : year

      try {
        const date = parse(`${day}.${month}.${fullYear}`, 'dd.MM.yyyy', new Date())
        if (!isValid(date)) {
          return null
        }

        if (startHour && startMin) {
          date.setHours(parseInt(startHour), parseInt(startMin), 0, 0)
          // Store time range info in a custom format: ISO + time range
          const timeRange = endHour && endMin ? `-${endHour.padStart(2, '0')}:${endMin}` : ''
          return (
            date.toISOString().split('T')[0] +
            'T' +
            `${startHour.padStart(2, '0')}:${startMin}:00` +
            timeRange
          )
        }

        return date.toISOString().split('T')[0]
      } catch {
        return null
      }
    }
  }

  // Handle date formats: DD.MM.YY or DD.MM.YYYY
  const dateMatch = cleaned.match(/^(\d{1,2})\.(\d{1,2})\.(\d{2,4})$/)
  if (dateMatch) {
    const [, day, month, year] = dateMatch
    const fullYear = year.length === 2 ? `20${year}` : year

    try {
      const date = parse(`${day}.${month}.${fullYear}`, 'dd.MM.yyyy', new Date())
      if (isValid(date)) {
        return date.toISOString().split('T')[0]
      }
      return null
    } catch {
      return null
    }
  }

  // Fallback to ISO format parsing
  if (/^\d{4}-\d{2}-\d{2}/.test(cleaned)) {
    try {
      const date = new Date(cleaned)
      if (isNaN(date.getTime())) {
        return null
      }
      return date.toISOString().split('T')[0]
    } catch {
      return null
    }
  }

  return null
}

/**
 * Format date/datetime string for display with locale support.
 */
export function formatDateForDisplay(
  value: string,
  columnFormat: ColumnFormat = 'date',
  locale: string = 'en'
): string {
  if (!value) {
    return ''
  }

  try {
    // Handle datetime format with time range
    if (columnFormat === 'datetime' && value.includes('T')) {
      const [datePart, timePart] = value.split('T')
      const date = new Date(datePart)

      if (!isValid(date)) {
        return value
      }

      // Extract time range if present
      let timeDisplay = ''
      if (timePart) {
        const timeMatch = timePart.match(/^(\d{2}):(\d{2}):00(?:-(\d{2}):(\d{2}))?$/)
        if (timeMatch) {
          const [, startHour, startMin, endHour, endMin] = timeMatch
          if (endHour && endMin) {
            timeDisplay = ` ${startHour}:${startMin}-${endHour}:${endMin}`
          } else {
            timeDisplay = ` ${startHour}:${startMin}`
          }
        }
      }

      const dateLocale = locale === 'de' ? de : enUS
      const dateFormat = locale === 'de' ? 'EEE, d. MMM' : 'EEE, d MMM'

      return format(date, dateFormat, { locale: dateLocale }) + timeDisplay
    }

    // Handle regular date format
    const date = new Date(value)
    if (!isValid(date)) {
      return value
    }

    const dateLocale = locale === 'de' ? de : enUS
    const dateFormat = locale === 'de' ? 'EEE, d. MMM' : 'EEE, d MMM'

    return format(date, dateFormat, { locale: dateLocale })
  } catch {
    return value
  }
}

/**
 * Check if a string represents today's date.
 */
export function isToday(value: string): boolean {
  if (!value) {
    return false
  }

  try {
    const date = new Date(value.split('T')[0]) // Handle both date and datetime formats
    const today = startOfDay(new Date())
    return startOfDay(date).getTime() === today.getTime()
  } catch {
    return false
  }
}

/**
 * Find the next upcoming date from a list of date values.
 */
export function findNextUpcomingDate(dateValues: string[]): string | null {
  const now = new Date()
  const today = startOfDay(now)

  let nextDate: Date | null = null
  let nextDateValue: string | null = null

  for (const value of dateValues) {
    if (!value) {
      continue
    }

    try {
      const date = new Date(value.split('T')[0]) // Handle both date and datetime formats
      const dateStart = startOfDay(date)

      // Only consider dates that are today or in the future
      if (dateStart >= today) {
        if (!nextDate || dateStart < nextDate) {
          nextDate = dateStart
          nextDateValue = value
        }
      }
    } catch {
      continue
    }
  }

  return nextDateValue
}

/**
 * Check if a date value represents the next upcoming date.
 */
export function isNextUpcomingDate(value: string, allDateValues: string[]): boolean {
  const nextDate = findNextUpcomingDate(allDateValues)
  return nextDate === value
}
