/**
 * Custom translation hook for better maintainability
 * Single source of truth for all translations
 */

import { useRouter } from 'next/navigation'
import { translations, translationsDE, type TranslationKeys } from '@/lib/translations'

type Locale = 'en' | 'de'

export function useTranslations() {
  const router = useRouter()
  
  // Get locale from URL path
  const getLocale = (): Locale => {
    if (typeof window !== 'undefined') {
      const path = window.location.pathname
      return path.startsWith('/de') ? 'de' : 'en'
    }
    return 'en'
  }

  const locale = getLocale()
  const t = locale === 'de' ? translationsDE : translations

  const changeLanguage = (newLocale: Locale) => {
    if (typeof window !== 'undefined') {
      const currentPath = window.location.pathname
      const pathWithoutLocale = currentPath.replace(/^\/(en|de)/, '')
      router.push(`/${newLocale}${pathWithoutLocale}`)
    }
  }

  return {
    t: (key: string, params?: Record<string, string | number>) => {
      const keys = key.split('.')
      let value: any = t
      
      for (const k of keys) {
        value = value?.[k]
      }
      
      if (typeof value === 'string') {
        // Replace parameters like {{number}} with actual values
        if (params) {
          return value.replace(/\{\{(\w+)\}\}/g, (match, paramKey) => {
            return String(params[paramKey] || match)
          })
        }
        return value
      }
      
      return key // Fallback to key if translation not found
    },
    locale,
    changeLanguage
  }
}
