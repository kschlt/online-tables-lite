'use client'

import { useRouter, usePathname, useSearchParams } from 'next/navigation'
import { useLocale } from 'next-intl'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { cn } from '@/lib/utils'
import { useState, useEffect } from 'react'
import { Globe, Check } from 'lucide-react'

interface DropdownLanguageSwitcherProps {
  className?: string
}

export function DropdownLanguageSwitcher({ className = '' }: DropdownLanguageSwitcherProps) {
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

  if (!isMounted) {
    return (
      <Button variant="ghost" size="sm" disabled className={cn('h-8 w-8 p-0', className)}>
        <Globe className="h-4 w-4" />
      </Button>
    )
  }

  const currentLocale = pathname.startsWith('/de') ? 'de' : 'en'

  const languages = [
    { code: 'en', label: 'EN' },
    { code: 'de', label: 'DE' },
  ]

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button 
          variant="ghost" 
          size="sm" 
          className={cn('h-8 w-8 p-0', className)}
          aria-label="Change language"
        >
          <Globe className="h-4 w-4" />
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-32">
        {languages.map((language) => (
          <DropdownMenuItem
            key={language.code}
            onClick={() => changeLanguage(language.code)}
            disabled={isChanging}
            className="flex items-center justify-between px-3 py-2"
          >
            <span className="font-medium">{language.label}</span>
            {currentLocale === language.code && (
              <Check className="h-4 w-4" />
            )}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  )
}
