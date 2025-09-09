import { getRequestConfig } from 'next-intl/server'

export default getRequestConfig(async ({ locale }) => {
  // Ensure locale is valid
  if (!locale || !['en', 'de'].includes(locale)) {
    locale = 'en'
  }

  return {
    messages: (await import(`../messages/${locale}.json`)).default,
    locale: locale,
  }
})
