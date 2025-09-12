'use client'

import { useState, useEffect } from 'react'
import { Input } from '@/components/ui/input'

interface NumericInputProps {
  id?: string
  value: number | string
  onChange: (value: number) => void
  onValidationChange?: (isValid: boolean, error: string | null) => void
  min?: number
  max?: number
  defaultValue?: number
  placeholder?: string
  className?: string
  disabled?: boolean
  compact?: boolean
  required?: boolean
  validateFn?: (value: number) => string | null
}

export function NumericInput({
  id,
  value,
  onChange,
  onValidationChange,
  min = 1,
  max = 1000,
  defaultValue,
  placeholder,
  className = '',
  disabled = false,
  compact = false,
  required = true, // eslint-disable-line @typescript-eslint/no-unused-vars
  validateFn,
}: NumericInputProps) {
  const [internalValue, setInternalValue] = useState<number | string>(value)
  const [error, setError] = useState<string | null>(null)

  // Sync external value changes
  useEffect(() => {
    setInternalValue(value)
  }, [value])

  const validateValue = (val: number): string | null => {
    if (validateFn) {
      return validateFn(val)
    }

    if (isNaN(val) || val < min || val > max) {
      if (compact) {
        return `${min}-${max}`
      }
      return `Value must be between ${min} and ${max}`
    }
    return null
  }

  const handleChange = (inputValue: string) => {
    // Allow empty string temporarily
    if (inputValue === '') {
      setInternalValue('')
      // Clear error when user starts typing
      if (error) {
        setError(null)
        onValidationChange?.(true, null)
      }
      return
    }

    const numericValue = parseInt(inputValue, 10)
    if (!isNaN(numericValue)) {
      const clampedValue = Math.max(min, Math.min(max, numericValue))
      setInternalValue(clampedValue)
      onChange(clampedValue)

      // Clear error when user enters valid input
      if (error) {
        setError(null)
        onValidationChange?.(true, null)
      }
    }
  }

  const handleBlur = () => {
    // If field is empty after blur, set to default value
    if (
      typeof internalValue === 'string' &&
      (internalValue === '' || internalValue === null || internalValue === undefined)
    ) {
      const fallbackValue = defaultValue ?? min
      setInternalValue(fallbackValue)
      onChange(fallbackValue)
    }

    // Validate current value
    const currentValue =
      typeof internalValue === 'string' ? parseInt(internalValue, 10) : internalValue
    const validationError = validateValue(currentValue)
    setError(validationError)
    onValidationChange?.(validationError === null, validationError)
  }

  return (
    <div className="space-y-1">
      <Input
        id={id}
        type="number"
        min={min}
        max={max}
        value={internalValue}
        onChange={e => handleChange(e.target.value)}
        onBlur={handleBlur}
        placeholder={placeholder}
        className={`${className} ${error ? 'border-destructive' : ''}`}
        disabled={disabled}
      />
      {error && (
        <div className={`text-destructive text-xs ${compact ? 'leading-tight' : ''}`}>{error}</div>
      )}
    </div>
  )
}
