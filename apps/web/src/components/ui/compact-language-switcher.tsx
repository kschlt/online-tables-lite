'use client'

import { useRouter, usePathname, useSearchParams } from 'next/navigation'
import { useLocale } from 'next-intl'
import { Button } from '@/components/ui/button'
import { cn } from '@/lib/utils'
import { useState, useEffect } from 'react'

interface CompactLanguageSwitcherProps {
  className?: string
}

export function CompactLanguageSwitcher({ className = '' }: CompactLanguageSwitcherProps) {
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const locale = useLocale()
  const [isChanging, setIsChanging] = useState(false)
  const [isMounted, setIsMounted] = useState(false)

  // Prevent hydration mismatch by only rendering after mount
  useEffect(() => {
    setIsMounted(true)
  }, [locale])

  const changeLanguage = (newLocale: string) => {
    const currentLocale = pathname.startsWith('/de') ? 'de' : 'en'

    if (newLocale === currentLocale) {
      return
    }

    setIsChanging(true)

    try {
      let pathWithoutLocale = pathname

      if (pathname.startsWith(`/${currentLocale}/`)) {
        pathWithoutLocale = pathname.substring(`/${currentLocale}`.length)
      } else if (pathname === `/${currentLocale}`) {
        pathWithoutLocale = '/'
      } else if (pathname === '/') {
        pathWithoutLocale = '/'
      } else {
        pathWithoutLocale = pathname.replace(`/${currentLocale}`, '')
      }

      if (!pathWithoutLocale.startsWith('/')) {
        pathWithoutLocale = '/' + pathWithoutLocale
      }

      const newPathname = `/${newLocale}${pathWithoutLocale === '/' ? '' : pathWithoutLocale}`
      const searchString = searchParams.toString()
      const fullUrl = searchString ? `${newPathname}?${searchString}` : newPathname

      router.push(fullUrl)
    } catch {
      setIsChanging(false)
    }
  }

  const handleEnClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    changeLanguage('en')
  }

  const handleDeClick = (e: React.MouseEvent) => {
    e.preventDefault()
    e.stopPropagation()
    changeLanguage('de')
  }

  if (!isMounted) {
    return (
      <div className={cn('flex items-center space-x-1', className)}>
        <Button variant="ghost" size="sm" disabled className="px-2 py-1 h-7 text-xs">
          EN
        </Button>
        <Button variant="ghost" size="sm" disabled className="px-2 py-1 h-7 text-xs">
          DE
        </Button>
      </div>
    )
  }

  const currentLocale = pathname.startsWith('/de') ? 'de' : 'en'

  return (
    <div className={cn('flex items-center space-x-1', className)}>
      <Button
        variant={currentLocale === 'en' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={handleEnClick}
        disabled={isChanging}
        className="px-2 py-1 h-7 text-xs"
        aria-pressed={currentLocale === 'en'}
      >
        EN
      </Button>
      <Button
        variant={currentLocale === 'de' ? 'secondary' : 'ghost'}
        size="sm"
        onClick={handleDeClick}
        disabled={isChanging}
        className="px-2 py-1 h-7 text-xs"
        aria-pressed={currentLocale === 'de'}
      >
        DE
      </Button>
    </div>
  )
}
