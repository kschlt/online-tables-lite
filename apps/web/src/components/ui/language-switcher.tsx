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
    console.log('LanguageSwitcher mounted, current locale:', locale)
  }, [locale])

  const changeLanguage = (newLocale: string) => {
    console.log('changeLanguage called with:', newLocale)
    console.log('Current pathname:', pathname)

    // Get current locale from pathname instead of useLocale hook
    const currentLocale = pathname.startsWith('/de') ? 'de' : 'en'
    console.log('Current locale from pathname:', currentLocale)

    if (newLocale === currentLocale) {
      console.log('Same locale, returning early')
      return
    }

    setIsChanging(true)

    try {
      console.log('Starting language change...')

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

      console.log('Language change:', {
        from: currentLocale,
        to: newLocale,
        originalPath: pathname,
        pathWithoutLocale,
        newPathname,
        fullUrl,
      })

      router.push(fullUrl)
    } catch (error) {
      console.error('Failed to change language:', error)
      setIsChanging(false)
    }
  }

  const handleEnClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    console.log('EN button clicked')
    changeLanguage('en')
  }

  const handleDeClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    console.log('DE button clicked')
    changeLanguage('de')
  }

  // Don't render until mounted to prevent hydration mismatch
  if (!isMounted) {
    return (
      <div className={cn('flex items-center space-x-2', className)}>
        <Button size="sm" disabled className="px-3 py-1">
          EN
        </Button>
        <Button size="sm" disabled className="px-3 py-1">
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
        variant={currentLocale === 'en' ? 'default' : 'outline'}
        size="sm"
        onClick={handleEnClick}
        disabled={isChanging}
        className="px-3 py-1"
      >
        EN
      </Button>
      <Button
        variant={currentLocale === 'de' ? 'default' : 'outline'}
        size="sm"
        onClick={handleDeClick}
        disabled={isChanging}
        className="px-3 py-1"
      >
        DE
      </Button>
    </div>
  )
}
