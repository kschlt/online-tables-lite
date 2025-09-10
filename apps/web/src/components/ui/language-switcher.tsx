'use client'

import { useRouter, usePathname, useSearchParams } from 'next/navigation'
import { useLocale } from 'next-intl'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { useState, useEffect } from 'react'

interface LanguageSwitcherProps {
  className?: string
}

export function LanguageSwitcher({ className = '' }: LanguageSwitcherProps) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const locale = useLocale()
  const [isChanging, setIsChanging] = useState(false)
  const [isMounted, setIsMounted] = useState(false)

  // Prevent hydration mismatch by only rendering after mount
  useEffect(() => {
    setIsMounted(true)
    // Component mounted
  }, [locale])

  const changeLanguage = (newLocale: string) => {
    // Starting language change

    // Get current locale from pathname instead of useLocale hook
    const currentLocale = pathname.startsWith('/de') ? 'de' : 'en'
    // Current locale determined from pathname

    if (newLocale === currentLocale) {
      // Same locale, no change needed
      return
    }

    setIsChanging(true)

    try {
      // Performing language change

      // Get the path without the current locale
      let pathWithoutLocale = pathname

      // Remove the current locale from the beginning of the path
      if (pathname.startsWith(`/${currentLocale}/`)) {
        // Pattern: /en/some/path -> /some/path
        pathWithoutLocale = pathname.substring(`/${currentLocale}`.length)
      } else if (pathname === `/${currentLocale}`) {
        // Pattern: /en -> /
        pathWithoutLocale = '/'
      } else if (pathname === '/') {
        // Pattern: / -> /
        pathWithoutLocale = '/'
      } else {
        // Fallback: try to remove locale from path
        pathWithoutLocale = pathname.replace(`/${currentLocale}`, '')
      }

      // Ensure pathWithoutLocale starts with /
      if (!pathWithoutLocale.startsWith('/')) {
        pathWithoutLocale = '/' + pathWithoutLocale
      }

      // Create new path with new locale
      const newPathname = `/${newLocale}${pathWithoutLocale === '/' ? '' : pathWithoutLocale}`

      // Preserve search parameters
      const searchString = searchParams.toString()
      const fullUrl = searchString ? `${newPathname}?${searchString}` : newPathname

      // Language change complete

      router.push(fullUrl)
    } catch {
      // Failed to change language
      setIsChanging(false)
    }
  }

  const handleEnClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    // EN language selected
    changeLanguage('en')
  }

  const handleDeClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    // DE language selected
    changeLanguage('de')
  }

  // Don't render until mounted to prevent hydration mismatch
  if (!isMounted) {
    return (
      <div className={cn('flex items-center space-x-2', className)}>
        <Button variant="toggle" size="sm" disabled className="px-3 py-1">
          EN
        </Button>
        <Button variant="toggle" size="sm" disabled className="px-3 py-1">
          DE
        </Button>
      </div>
    )
  }

  // Get current locale from pathname for button highlighting
  const currentLocale = pathname.startsWith('/de') ? 'de' : 'en'

  return (
    <div className={cn('flex items-center space-x-2', className)}>
      <Button
        variant={currentLocale === 'en' ? 'toggle-selected' : 'toggle'}
        size="sm"
        onClick={handleEnClick}
        disabled={isChanging}
        className="px-3 py-1"
        aria-pressed={currentLocale === 'en'}
      >
        EN
      </Button>
      <Button
        variant={currentLocale === 'de' ? 'toggle-selected' : 'toggle'}
        size="sm"
        onClick={handleDeClick}
        disabled={isChanging}
        className="px-3 py-1"
        aria-pressed={currentLocale === 'de'}
      >
        DE
      </Button>
    </div>
  )
}
