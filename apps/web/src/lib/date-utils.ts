/**
 * Date utilities for today hint functionality.
 */

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
 * Parse various date formats and return ISO date string.
 */
export function parseDate(value: string): string | null {
  if (!value || typeof value !== 'string') {
    return null
  }

  // Clean the input
  const cleaned = value.trim()
  if (!cleaned) {
    return null
  }

  // Try parsing different formats
  const formats = [
    // ISO format: YYYY-MM-DD
    /^\d{4}-\d{2}-\d{2}$/,
    // US format: MM/DD/YYYY or M/D/YYYY
    /^\d{1,2}\/\d{1,2}\/\d{4}$/,
    // EU format: DD/MM/YYYY or D/M/YYYY
    /^\d{1,2}\/\d{1,2}\/\d{4}$/,
    // Dash format: MM-DD-YYYY or DD-MM-YYYY
    /^\d{1,2}-\d{1,2}-\d{4}$/,
    // Dot format: MM.DD.YYYY or DD.MM.YYYY
    /^\d{1,2}\.\d{1,2}\.\d{4}$/,
  ]

  // Check if it matches any expected format
  const matchesFormat = formats.some(format => format.test(cleaned))
  if (!matchesFormat) {
    return null
  }

  try {
    // Try to parse with native Date constructor
    const date = new Date(cleaned)

    // Check if date is valid
    if (isNaN(date.getTime())) {
      return null
    }

    // Return ISO format
    return date.toISOString().split('T')[0]
  } catch {
    return null
  }
}

/**
 * Format date string for display.
 */
export function formatDateForDisplay(value: string): string {
  const parsed = parseDate(value)
  if (!parsed) {
    return value // Return original if not a valid date
  }

  try {
    const date = new Date(parsed)
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    })
  } catch {
    return value
  }
}

/**
 * Check if a string represents today's date.
 */
export function isToday(value: string): boolean {
  const parsed = parseDate(value)
  if (!parsed) {
    return false
  }

  const today = getTodayDate().iso
  return parsed === today
}

/**
 * Get relative date description (today, yesterday, tomorrow, etc.).
 */
export function getRelativeDateDescription(value: string): string | null {
  const parsed = parseDate(value)
  if (!parsed) {
    return null
  }

  const today = new Date()
  const targetDate = new Date(parsed)

  // Calculate difference in days
  const diffTime = targetDate.getTime() - today.getTime()
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays === 0) {
    return 'Today'
  } else if (diffDays === 1) {
    return 'Tomorrow'
  } else if (diffDays === -1) {
    return 'Yesterday'
  } else if (diffDays > 0 && diffDays <= 7) {
    return `In ${diffDays} days`
  } else if (diffDays < 0 && diffDays >= -7) {
    return `${Math.abs(diffDays)} days ago`
  }

  return null
}
