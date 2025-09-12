import createMiddleware from 'next-intl/middleware'
import appConfig from '../config/app.json'

export default createMiddleware({
  locales: ['en', 'de'],
  defaultLocale: appConfig.defaultLanguage as 'en' | 'de',
  localePrefix: 'always',
})

export const config = {
  matcher: [
    // Match all pathnames except for
    // - … if they start with `/api`, `/_next` or `/_vercel`
    // - … the ones containing a dot (e.g. `favicon.ico`)
    '/((?!api|_next|_vercel|.*\\..*).*)',
  ],
}
