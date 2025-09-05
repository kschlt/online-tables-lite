/**
 * Common page layout component with consistent styling.
 */

import type { ReactNode } from 'react'

interface PageLayoutProps {
  children: ReactNode
  title?: string
  description?: string
  maxWidth?: 'sm' | 'md' | 'lg' | 'xl' | 'full'
  className?: string
}

const maxWidthClasses = {
  sm: 'max-w-2xl',
  md: 'max-w-4xl',
  lg: 'max-w-6xl',
  xl: 'max-w-7xl',
  full: 'max-w-full',
}

export function PageLayout({
  children,
  title,
  description,
  maxWidth = 'lg',
  className = '',
}: PageLayoutProps) {
  return (
    <main className={`min-h-screen bg-gray-50 p-4 ${className}`}>
      <div className={`mx-auto ${maxWidthClasses[maxWidth]}`}>
        {(title || description) && (
          <div className="mb-6">
            {title && <h1 className="text-2xl font-bold text-gray-900 mb-2">{title}</h1>}
            {description && <p className="text-gray-600">{description}</p>}
          </div>
        )}
        {children}
      </div>
    </main>
  )
}
