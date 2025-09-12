/**
 * Header component for displaying page title and navigation
 */

import type { ReactNode } from 'react'
import { cn } from '@/lib/utils'
import { NavigationMenu } from '@/components/ui/navigation-menu'

interface HeaderProps {
  title?: string
  description?: string
  children?: ReactNode
  className?: string
}

export function Header({ title, description, children, className }: HeaderProps) {
  return (
    <div className={cn('bg-card px-4 py-3', className)}>
      {/* Title row with hamburger menu vertically centered */}
      <div className="flex items-center justify-between">
        {/* Title - left aligned */}
        <div className="flex-1 min-w-0">
          {title && <h1 className="text-heading-1 truncate">{title}</h1>}
        </div>

        {/* Navigation Menu */}
        <div className="flex-shrink-0 ml-4">
          <NavigationMenu />
        </div>
      </div>

      {/* Description below - left aligned */}
      {description && (
        <div className="mt-1">
          <p className="text-body-sm text-muted-foreground truncate">{description}</p>
        </div>
      )}

      {/* Additional children below */}
      {children && <div className="mt-2">{children}</div>}
    </div>
  )
}
