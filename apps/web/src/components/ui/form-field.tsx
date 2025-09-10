import * as React from 'react'
import { cn } from '@/lib/utils'
import { Label } from '@/components/ui/label'

interface FormFieldProps {
  label?: string
  error?: string | null
  htmlFor?: string
  required?: boolean
  className?: string
  children: React.ReactNode
}

export function FormField({ 
  label, 
  error, 
  htmlFor, 
  required = false, 
  className,
  children 
}: FormFieldProps) {
  return (
    <div className={cn('space-y-2', className)}>
      {label && (
        <Label htmlFor={htmlFor} className="text-body font-medium">
          {label} {required && <span className="text-destructive">*</span>}
        </Label>
      )}
      {children}
      {error && (
        <p className="text-sm text-destructive mt-1 flex items-center gap-1">
          <span className="text-destructive">⚠</span>
          {error}
        </p>
      )}
    </div>
  )
}

interface FormFieldErrorProps {
  error?: string | null
}

export function FormFieldError({ error }: FormFieldErrorProps) {
  if (!error) return null
  
  return (
    <p className="text-sm text-destructive mt-1 flex items-center gap-1">
      <span className="text-destructive">⚠</span>
      {error}
    </p>
  )
}