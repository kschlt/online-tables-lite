/**
 * Language switcher component for i18n support.
 */

'use client'

import { useTranslations } from '@/hooks/use-translations'

interface LanguageSwitcherProps {
  className?: string
}

export function LanguageSwitcher({ className = '' }: LanguageSwitcherProps) {
  const { locale, changeLanguage } = useTranslations()

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
