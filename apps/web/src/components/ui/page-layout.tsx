/**
 * Common page layout component using Shadcn/UI styling.
 */

import type { ReactNode } from 'react'
import { cn } from '@/lib/utils'

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
    <main className={cn('min-h-screen bg-background p-4', className)}>
      <div className={cn('mx-auto', maxWidthClasses[maxWidth])}>
        {(title || description) && (
          <div className="mb-6 space-y-2">
            {title && (
              <h1 className="text-3xl font-bold tracking-tight text-foreground">
                {title}
              </h1>
            )}
            {description && (
              <p className="text-muted-foreground">{description}</p>
            )}
          </div>
        )}
        {children}
      </div>
    </main>
  )
}
