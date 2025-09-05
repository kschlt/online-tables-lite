/**
 * Error message component with consistent styling.
 */

interface ErrorMessageProps {
  message: string
  className?: string
}

export function ErrorMessage({ message, className = '' }: ErrorMessageProps) {
  return (
    <div className={`text-red-600 bg-red-50 border border-red-200 rounded-lg p-4 ${className}`}>
      <p className="text-sm font-medium">Error</p>
      <p className="text-sm">{message}</p>
    </div>
  )
}
