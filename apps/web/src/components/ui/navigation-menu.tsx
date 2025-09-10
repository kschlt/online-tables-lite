'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { DropdownLanguageSwitcher } from '@/components/ui/dropdown-language-switcher'
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '@/components/ui/sheet'
import { Menu } from 'lucide-react'
import { cn } from '@/lib/utils'

interface NavigationMenuProps {
  className?: string
}

export function NavigationMenu({ className }: NavigationMenuProps) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className={cn('relative', className)}>
      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <SheetTrigger asChild>
          <Button
            variant="ghost"
            size="icon"
            className="h-12 w-12 md:h-14 md:w-14"
            aria-label="Open navigation menu"
          >
            <Menu className="h-6 w-6 md:h-7 md:w-7" />
          </Button>
        </SheetTrigger>
        <SheetContent side="right" className="w-[320px] sm:w-[420px]">
          <div className="absolute left-4 top-4">
            <DropdownLanguageSwitcher className="flex-shrink-0" />
          </div>
          <SheetHeader className="sr-only">
            <SheetTitle>Menu</SheetTitle>
          </SheetHeader>

          <div className="mt-12 space-y-4">
            {/* Future menu items can go here */}
            <div className="text-sm text-muted-foreground">More menu options coming soon...</div>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  )
}
