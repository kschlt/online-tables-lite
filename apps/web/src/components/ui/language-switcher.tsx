/**
 * Language switcher component for i18n support.
 */

'use client'

import { useRouter, usePathname } from 'next/navigation'
import { useLocale } from 'next-intl'

interface LanguageSwitcherProps {
  className?: string
}

export function LanguageSwitcher({ className = '' }: LanguageSwitcherProps) {
  const router = useRouter()
  const pathname = usePathname()
  const locale = useLocale()

  const changeLanguage = (newLocale: string) => {
    // Remove the current locale from the pathname
    const pathWithoutLocale = pathname.replace(`/${locale}`, '')
    // Navigate to the new locale
    router.push(`/${newLocale}${pathWithoutLocale}`)
  }

  return (
    <div className={`flex items-center space-x-2 ${className}`}>
      <button
        onClick={() => changeLanguage('en')}
        className={`px-2 py-1 text-sm rounded transition-colors ${
          locale === 'en'
            ? 'bg-blue-600 text-white'
            : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
        }`}
      >
        EN
      </button>
      <button
        onClick={() => changeLanguage('de')}
        className={`px-2 py-1 text-sm rounded transition-colors ${
          locale === 'de'
            ? 'bg-blue-600 text-white'
            : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
        }`}
      >
        DE
      </button>
    </div>
  )
}
