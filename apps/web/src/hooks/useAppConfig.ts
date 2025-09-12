import { useState, useEffect } from 'react'
import { useTranslations, useLocale } from 'next-intl'
import { getConfig } from '@/lib/api'
import appConfig from '../../config/app.json'

interface ConfigData {
  [key: string]: {
    en: string | null
    de: string | null
  }
}

interface DefaultTableConfig {
  cols: number
  rows: number
  columns: Array<{
    index: number
    header: string
    format: string
  }>
}

export const useAppConfig = () => {
  const t = useTranslations()
  const locale = useLocale() as 'en' | 'de'
  const [config, setConfig] = useState<ConfigData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Load config on mount
  useEffect(() => {
    loadConfig()
  }, [])

  const loadConfig = async () => {
    try {
      setLoading(true)
      setError(null)

      const configData = await getConfig()
      setConfig(configData)
    } catch (err) {
      // Config loading failed, fall back to i18n translations
      setError(err instanceof Error ? err.message : 'Failed to load configuration')
    } finally {
      setLoading(false)
    }
  }

  const getConfigValue = (key: string): string => {
    if (config && config[key]) {
      // Try locale-specific value first, then English fallback
      const value = config[key][locale] || config[key].en
      if (value) {
        return value
      }
    }
    // Final fallback to i18n translation
    return t(key)
  }

  const getAppTitle = (): string => {
    return getConfigValue('app.title')
  }

  const getAppDescription = (): string => {
    return getConfigValue('app.description')
  }

  const getDefaultTableConfig = (): DefaultTableConfig => {
    try {
      return {
        cols: appConfig.table.defaultCols,
        rows: appConfig.table.defaultRows,
        columns: appConfig.table.defaultColumns.map(col => ({
          index: col.index,
          header: col.header[locale] || col.header.en,
          format: col.format,
        })),
      }
    } catch {
      // Failed to load app config, using hardcoded fallback
      // Hardcoded fallback
      return {
        cols: 5,
        rows: 10,
        columns: [
          { index: 0, header: locale === 'en' ? 'Date' : 'Datum', format: 'date' },
          { index: 1, header: 'No 1', format: 'text' },
          { index: 2, header: 'No 2', format: 'text' },
          { index: 3, header: 'No 3', format: 'text' },
          { index: 4, header: 'No 4', format: 'text' },
        ],
      }
    }
  }

  return {
    config,
    loading,
    error,
    isLoaded: !loading && !error && !!config,
    getConfigValue,
    getAppTitle,
    getAppDescription,
    getDefaultTableConfig,
    refresh: loadConfig,
  }
}
