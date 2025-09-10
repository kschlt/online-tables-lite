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
      <div className="flex items-center justify-between">
        {/* Title Section */}
        <div className="flex-1 min-w-0">
          {title && <h1 className="text-heading-1 truncate">{title}</h1>}
          {description && (
            <p className="text-body-sm text-muted-foreground mt-1 truncate">{description}</p>
          )}
          {children}
        </div>

        {/* Navigation Menu */}
        <div className="flex-shrink-0 ml-4">
          <NavigationMenu />
        </div>
      </div>
    </div>
  )
}
