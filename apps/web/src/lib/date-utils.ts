import { parseDateRange } from './date-range-utils'

export type ColumnFormat = 'text' | 'date' | 'timerange'

/**
 * Format a date string for display in the UI
 * Handles both single dates and timerange formats based on column format
 */
export function formatDateForDisplay(value: string, locale: string = 'en', columnFormat?: ColumnFormat): string {
  if (!value) {
    return ''
  }

  try {
    // For date columns, only show date (no time)
    if (columnFormat === 'date') {
      const date = new Date(value)
      if (isNaN(date.getTime())) {
        return value // Return original if not a valid date
      }

      return date.toLocaleDateString(locale, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      })
    }

    // For timerange columns, check if it's a timerange format
    if (columnFormat === 'timerange') {
      const dateRange = parseDateRange(value)
      if (dateRange) {
        const startDate = new Date(dateRange.start)
        const endDate = new Date(dateRange.end)

        const startFormatted = startDate.toLocaleDateString(locale, {
          year: 'numeric',
          month: 'short',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
        })

        const endFormatted = endDate.toLocaleDateString(locale, {
          year: 'numeric',
          month: 'short',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
        })

        return `${startFormatted} - ${endFormatted}`
      }
    }

    // Fallback: try to parse as timerange first (for backward compatibility)
    const dateRange = parseDateRange(value)
    if (dateRange) {
      const startDate = new Date(dateRange.start)
      const endDate = new Date(dateRange.end)

      const startFormatted = startDate.toLocaleDateString(locale, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      })

      const endFormatted = endDate.toLocaleDateString(locale, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      })

      return `${startFormatted} - ${endFormatted}`
    }

    // Single date format
    const date = new Date(value)
    if (isNaN(date.getTime())) {
      return value // Return original if not a valid date
    }

    return date.toLocaleDateString(locale, {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  } catch {
    // console.warn('Error formatting date:', error)
    return value
  }
}

/**
 * Check if a date is today
 */
export function isToday(date: Date): boolean {
  const today = new Date()
  return (
    date.getDate() === today.getDate() &&
    date.getMonth() === today.getMonth() &&
    date.getFullYear() === today.getFullYear()
  )
}

/**
 * Check if a date is tomorrow
 */
export function isTomorrow(date: Date): boolean {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return (
    date.getDate() === tomorrow.getDate() &&
    date.getMonth() === tomorrow.getMonth() &&
    date.getFullYear() === tomorrow.getFullYear()
  )
}

/**
 * Get today's date as ISO string (date only)
 */
export function getTodayISO(): string {
  const today = new Date()
  return today.toISOString().split('T')[0]
}

/**
 * Get tomorrow's date as ISO string (date only)
 */
export function getTomorrowISO(): string {
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  return tomorrow.toISOString().split('T')[0]
}

/**
 * Extract date from a value, handling both date and timerange formats
 */
export function extractDateFromValue(value: string): string | null {
  if (!value) {
    return null
  }

  try {
    // Check if it's a timerange format (pipe-separated)
    if (value.includes('|')) {
      const [startDate] = value.split('|')
      const date = new Date(startDate.trim())
      if (isNaN(date.getTime())) {
        return null
      }
      return date.toISOString().split('T')[0]
    }

    // Check if it's a timerange format with embedded time range
    const timeRangeMatch = value.match(/^(.+T\d{2}:\d{2}:\d{2})(?:\.000Z)?-(\d{2}):(\d{2})$/)
    if (timeRangeMatch) {
      const [, startPart] = timeRangeMatch
      const startDate = new Date(startPart.includes('.000Z') ? startPart : startPart + '.000Z')
      return startDate.toISOString().split('T')[0]
    }

    // Single date format
    const date = new Date(value)
    if (isNaN(date.getTime())) {
      return null
    }

    return date.toISOString().split('T')[0]
  } catch {
    return null
  }
}

/**
 * Find the next upcoming date from a list of dates
 * Now handles both date and timerange formats
 */
export function findNextUpcomingDate(dates: string[]): string | null {
  const today = new Date()
  const validDates = dates
    .map(dateStr => extractDateFromValue(dateStr))
    .filter(dateStr => dateStr !== null)
    .map(dateStr => new Date(dateStr!))
    .filter(date => !isNaN(date.getTime()) && date >= today)
    .sort((a, b) => a.getTime() - b.getTime())


  return validDates.length > 0 ? validDates[0].toISOString().split('T')[0] : null
}

/**
 * Check if a date is the next upcoming date
 * Now handles both date and timerange formats
 */
export function isNextUpcomingDate(dateStr: string, allDates: string[]): boolean {
  const nextUpcoming = findNextUpcomingDate(allDates)
  const extractedDate = extractDateFromValue(dateStr)
  return nextUpcoming === extractedDate
}

/**
 * Format a date for input fields (YYYY-MM-DD format)
 */
export function formatDateForInput(date: Date): string {
  return date.toISOString().split('T')[0]
}

/**
 * Parse a date string and return a Date object
 */
export function parseDateString(dateStr: string): Date | null {
  const date = new Date(dateStr)
  return isNaN(date.getTime()) ? null : date
}

/**
 * Get relative time string (e.g., "2 days ago", "in 3 hours")
 */
export function getRelativeTime(date: Date, locale: string = 'en'): string {
  const now = new Date()
  const diffMs = date.getTime() - now.getTime()
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffMinutes = Math.floor(diffMs / (1000 * 60))

  if (Math.abs(diffDays) >= 1) {
    return new Intl.RelativeTimeFormat(locale).format(diffDays, 'day')
  } else if (Math.abs(diffHours) >= 1) {
    return new Intl.RelativeTimeFormat(locale).format(diffHours, 'hour')
  } else {
    return new Intl.RelativeTimeFormat(locale).format(diffMinutes, 'minute')
  }
}
