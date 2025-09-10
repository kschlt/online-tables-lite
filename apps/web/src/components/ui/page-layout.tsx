/**
 * Common page layout component using Shadcn/UI styling.
 */

import type { ReactNode } from 'react'
import { cn } from '@/lib/utils'

interface PageLayoutProps {
  children: ReactNode
  header?: ReactNode
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

export function PageLayout({ children, header, maxWidth = 'lg', className = '' }: PageLayoutProps) {
  return (
    <main className={cn('min-h-screen bg-background', className)}>
      <div className={cn('mx-auto', maxWidthClasses[maxWidth])}>
        {/* Optional Header */}
        {header}

        {/* Content Section */}
        <div className="px-4 py-4">{children}</div>
      </div>
    </main>
  )
}
