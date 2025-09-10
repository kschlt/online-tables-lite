'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { LanguageSwitcher } from '@/components/ui/language-switcher'
import { Menu, X } from 'lucide-react'
import { cn } from '@/lib/utils'

interface NavigationMenuProps {
  className?: string
}

export function NavigationMenu({ className }: NavigationMenuProps) {
  const [isOpen, setIsOpen] = useState(false)

  const toggleMenu = () => {
    setIsOpen(!isOpen)
  }

  return (
    <div className={cn('relative', className)}>
      {/* Hamburger Button with proper sizing */}
      <Button
        variant="ghost"
        size="sm"
        onClick={toggleMenu}
        className="h-12 w-12 md:h-14 md:w-14 p-0 flex items-center justify-center"
        aria-label="Open navigation menu"
      >
        <Menu className="h-6 w-6 md:h-7 md:w-7" />
      </Button>

      {/* Menu Overlay */}
      {isOpen && (
        <>
          <div
            className="fixed inset-0 bg-black bg-opacity-50 z-40"
            onClick={() => setIsOpen(false)}
          />
          <div className="absolute top-0 right-0 mt-2 w-64 bg-white border border-border rounded-lg shadow-lg z-50 p-4">
            {/* Close Button */}
            <div className="flex justify-end mb-4">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setIsOpen(false)}
                className="h-8 w-8 p-0 flex items-center justify-center"
                aria-label="Close navigation menu"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>

            {/* Menu Content */}
            <div className="space-y-4">
              <div>
                <h3 className="text-body-sm font-medium text-muted-foreground mb-2">Language</h3>
                <LanguageSwitcher />
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  )
}
