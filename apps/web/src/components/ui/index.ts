/**
 * Re-export all UI components from a central location.
 */

// Shadcn/UI components
export { Button } from './button'
export { Input } from './input'
export { Label } from './label'
export {
  Table,
  TableHeader,
  TableBody,
  TableHead,
  TableRow,
  TableCell,
  TableCaption,
} from './table'
export { Sheet, SheetContent, SheetDescription, SheetHeader, SheetTitle } from './sheet'
export { Alert, AlertDescription } from './alert'
export { Badge } from './badge'
export {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from './dropdown-menu'

// Custom components using Shadcn/UI
export { LoadingSpinner } from './loading-spinner'
export { ErrorMessage } from './error-message'
export { PageLayout } from './page-layout'
export { LanguageSwitcher } from './language-switcher'
export { AdminDialog } from './admin-dialog'
export * from './dialog'
export { Header } from './header'
export { DropdownLanguageSwitcher } from './dropdown-language-switcher'
