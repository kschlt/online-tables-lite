/**
 * Date range utilities for formatting date ranges in German format
 * Examples: "Di, 13. Mai 19:00 - 20:30" or "13.05.2025 19:00 - 20:30"
 */

export interface DateRange {
  start: string | Date
  end: string | Date
}

/**
 * Parse a date range string or return individual dates
 * Supports formats like:
 * - "2025-05-13T19:00:00.000Z|2025-05-13T20:30:00.000Z" (pipe separated)
 * - Single ISO date (will be treated as start date only)
 */
export function parseDateRange(value: string): DateRange | null {
  if (!value) {
    return null
  }

  // Check if it's a pipe-separated date range
  if (value.includes('|')) {
    const [start, end] = value.split('|')
    if (start && end) {
      return { start: start.trim(), end: end.trim() }
    }
  }

  // Check if it's a date with embedded time range (e.g., "2025-09-11T19:00:00-20:30")
  const timeRangeMatch = value.match(/^(.+T\d{2}:\d{2}:\d{2})(?:\.000Z)?-(\d{2}):(\d{2})$/)
  if (timeRangeMatch) {
    const [, startPart, endHour, endMin] = timeRangeMatch
    // Create end date by copying the date part and changing the time
    const startDate = new Date(startPart.includes('.000Z') ? startPart : startPart + '.000Z')
    const endDate = new Date(startDate)
    endDate.setHours(parseInt(endHour), parseInt(endMin), 0, 0)

    return {
      start: startDate.toISOString(),
      end: endDate.toISOString(),
    }
  }

  // Single date - treat as start date only
  return { start: value, end: value }
}

/**
 * Format date range for display in German format
 * @param range - Date range object
 * @param locale - Locale for formatting (defaults to 'de-DE')
 * @returns Formatted string like "Di, 13. Mai 19:00 - 20:30"
 */
export function formatDateRange(range: DateRange, locale: string = 'de-DE'): string {
  if (!range) {
    return ''
  }

  try {
    const startDate = new Date(range.start)
    const endDate = new Date(range.end)

    if (isNaN(startDate.getTime())) {
      return String(range.start)
    }

    // If same date, show full date with time range
    if (startDate.toDateString() === endDate.toDateString() && !isNaN(endDate.getTime())) {
      // Use proper German formatting
      const dayName = startDate.toLocaleDateString(locale, { weekday: 'short' })
      const day = startDate.getDate()
      const month = startDate.toLocaleDateString(locale, { month: 'short' })

      // Format times consistently for German locale
      const formatTime = (date: Date) => {
        const hours = date.getHours().toString().padStart(2, '0')
        const minutes = date.getMinutes().toString().padStart(2, '0')
        return `${hours}:${minutes}`
      }

      const startTime = formatTime(startDate)
      const endTime = formatTime(endDate)

      return `${dayName}, ${day}. ${month} ${startTime} - ${endTime}`
    }

    // If only start date or different dates, show just the start date
    const dayName = startDate.toLocaleDateString(locale, { weekday: 'short' })
    const day = startDate.getDate()
    const month = startDate.toLocaleDateString(locale, { month: 'short' })

    // Format time consistently
    const formatTime = (date: Date) => {
      const hours = date.getHours().toString().padStart(2, '0')
      const minutes = date.getMinutes().toString().padStart(2, '0')
      return `${hours}:${minutes}`
    }

    const startTime = formatTime(startDate)

    return `${dayName}, ${day}. ${month} ${startTime}`
  } catch {
    // Error formatting date range, return fallback
    return String(range.start)
  }
}

/**
 * Create a date range string for storage
 * @param start - Start date
 * @param end - End date (optional)
 * @returns Pipe-separated date string or single date
 */
export function createDateRangeString(start: Date | string, end?: Date | string): string {
  const startISO = start instanceof Date ? start.toISOString() : start
  if (end) {
    const endISO = end instanceof Date ? end.toISOString() : end
    return `${startISO}|${endISO}`
  }
  return startISO
}

/**
 * Parse input string and create proper time range format
 * Handles formats like "9.09.2025 19:00-20:00"
 * @param input - User input string
 * @param format - Column format
 * @returns Pipe-separated time range or null
 */
export function parseTimeRangeInput(input: string): string | null {
  if (!input) {
    return null
  }

  const cleaned = input.trim()

  // Handle format like "9.09.2025 19:00-20:00" or "9.9.25 19:00-20:00"
  const timeRangeMatch = cleaned.match(
    /^(\d{1,2})\.(\d{1,2})\.(\d{2,4})\s+(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$/
  )

  if (timeRangeMatch) {
    const [, day, month, year, startHour, startMin, endHour, endMin] = timeRangeMatch
    const fullYear = year.length === 2 ? `20${year}` : year

    // Validate date components
    const dayNum = parseInt(day)
    const monthNum = parseInt(month)
    const yearNum = parseInt(fullYear)
    const startHourNum = parseInt(startHour)
    const startMinNum = parseInt(startMin)
    const endHourNum = parseInt(endHour)
    const endMinNum = parseInt(endMin)

    // Validate ranges
    if (monthNum < 1 || monthNum > 12 || dayNum < 1 || dayNum > 31) {
      return null
    }

    if (startHourNum < 0 || startHourNum > 23 || endHourNum < 0 || endHourNum > 23) {
      return null
    }

    if (startMinNum < 0 || startMinNum > 59 || endMinNum < 0 || endMinNum > 59) {
      return null
    }

    try {
      // Create dates with proper timezone handling
      const dateStr = `${fullYear}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`
      const startTimeStr = `${startHour.padStart(2, '0')}:${startMin}:00.000Z`
      const endTimeStr = `${endHour.padStart(2, '0')}:${endMin}:00.000Z`

      const startDate = new Date(`${dateStr}T${startTimeStr}`)
      const endDate = new Date(`${dateStr}T${endTimeStr}`)

      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        return null
      }

      // Ensure end time is after start time
      if (endDate <= startDate) {
        return null
      }

      // Validate the date is reasonable (not too far in past/future)
      const now = new Date()
      const minYear = now.getFullYear() - 10
      const maxYear = now.getFullYear() + 10

      if (yearNum < minYear || yearNum > maxYear) {
        return null
      }

      return createDateRangeString(startDate, endDate)
    } catch {
      return null
    }
  }

  return null
}
