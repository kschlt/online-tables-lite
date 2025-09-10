'use client'

import { useState, useEffect } from 'react'
import { useTranslations, useLocale } from 'next-intl'
import { useSearchParams, useRouter } from 'next/navigation'
import { PageLayout, ErrorMessage } from '@/components/ui'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

import { FormField } from '@/components/ui/form-field'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { createTable } from '@/lib/api'
import { CheckCircle, Settings, Edit } from 'lucide-react'
import type { CreateTableRequest, CreateTableResponse } from '@/types'

export default function Home() {
  const t = useTranslations()
  const locale = useLocale()
  const searchParams = useSearchParams()
  const router = useRouter()
  const [isCreating, setIsCreating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<CreateTableResponse | null>(null)
  const [isClient, setIsClient] = useState(false)
  const [fieldErrors, setFieldErrors] = useState<Record<string, string | null>>({
    title: null,
    cols: null,
    rows: null,
  })

  const [formData, setFormData] = useState<CreateTableRequest>({
    title: '',
    description: '',
    cols: 3,
    rows: 5,
  })

  // Ensure we're on the client side
  useEffect(() => {
    setIsClient(true)
  }, [])

  // Check for success state in URL parameters
  useEffect(() => {
    if (!isClient) {
      return
    }

    const successData = searchParams.get('success')
    if (successData) {
      try {
        const parsedData = JSON.parse(decodeURIComponent(successData))
        setResult(parsedData)
      } catch (err) {
        console.error('Failed to parse success data:', err)
      }
    }
  }, [searchParams, isClient])

  // Validation helpers
  const validateField = (field: string, value: any): string | null => {
    switch (field) {
      case 'title':
        if (!value || !value.trim()) {
          return t('errors.titleRequired')
        }
        return null
      case 'cols':
        const cols = Number(value)
        if (isNaN(cols) || cols < 1 || cols > 64) {
          return t('errors.columnsOutOfRange')
        }
        return null
      case 'rows':
        const rows = Number(value)
        if (isNaN(rows) || rows < 1 || rows > 500) {
          return t('errors.rowsOutOfRange')
        }
        return null
      default:
        return null
    }
  }

  const validateForm = (): boolean => {
    const newErrors: Record<string, string | null> = {
      title: validateField('title', formData.title),
      cols: validateField('cols', formData.cols),
      rows: validateField('rows', formData.rows),
    }

    setFieldErrors(newErrors)

    return Object.values(newErrors).every(error => error === null)
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsCreating(true)
    setError(null)

    // Validate form
    if (!validateForm()) {
      setIsCreating(false)
      return
    }

    try {
      // Ensure numeric values are properly typed
      const requestData: CreateTableRequest = {
        title: formData.title?.trim() || '',
        description: formData.description?.trim() || '',
        cols: Number(formData.cols),
        rows: Number(formData.rows),
      }

      const response = await createTable(requestData)
      setResult(response)

      // Store success state in URL parameters
      const successData = encodeURIComponent(JSON.stringify(response))
      const newUrl = `/${locale}?success=${successData}`
      router.replace(newUrl)
    } catch (err) {
      setError(err instanceof Error ? err.message : t('errors.failedToCreateTable'))
    } finally {
      setIsCreating(false)
    }
  }

  const resetForm = () => {
    setResult(null)
    setFormData({ title: '', description: '', cols: 3, rows: 5 })
    setFieldErrors({ title: null, cols: null, rows: null })
    // Clear URL parameters
    router.replace(`/${locale}`)
  }

  const handleFieldChange = (field: keyof CreateTableRequest, value: string | number) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    // Clear field error on change
    if (fieldErrors[field]) {
      setFieldErrors(prev => ({ ...prev, [field]: null }))
    }
  }

  const handleNumericFieldChange = (field: 'cols' | 'rows', value: string) => {
    // Allow empty string temporarily
    if (value === '') {
      setFormData(prev => ({ ...prev, [field]: '' as any }))
      // Clear field error on change
      if (fieldErrors[field]) {
        setFieldErrors(prev => ({ ...prev, [field]: null }))
      }
      return
    }

    const numericValue = parseInt(value, 10)
    if (!isNaN(numericValue)) {
      const min = field === 'cols' ? 1 : 1
      const max = field === 'cols' ? 64 : 500
      const clampedValue = Math.max(min, Math.min(max, numericValue))
      handleFieldChange(field, clampedValue)
    }
  }

  const handleFieldBlur = (field: string, value: any) => {
    const error = validateField(field, value)
    setFieldErrors(prev => ({ ...prev, [field]: error }))
  }

  const handleNumericFieldBlur = (field: 'cols' | 'rows') => {
    // If field is empty after blur, set to default value
    if (
      typeof formData[field] === 'string' &&
      (formData[field] === '' || formData[field] === null || formData[field] === undefined)
    ) {
      const defaultValue = field === 'cols' ? 3 : 5
      setFormData(prev => ({ ...prev, [field]: defaultValue }))
    }
    handleFieldBlur(field, formData[field])
  }

  // Don't render success state until client-side hydration is complete
  if (result && isClient) {
    const baseUrl = typeof window !== 'undefined' ? window.location.origin : ''
    const adminUrl = `${baseUrl}/${locale}/table/${result.slug}?t=${result.admin_token}`
    const editUrl = `${baseUrl}/${locale}/table/${result.slug}?t=${result.edit_token}`

    return (
      <PageLayout title={t('app.title')} description={t('app.description')} maxWidth="xl">
        <div className="card-elevated p-6">
          <div className="flex justify-start items-center mb-6">
            <div className="flex items-center gap-2">
              <CheckCircle className="w-6 h-6 text-success" />
              <h2 className="text-heading-2 text-success">
                {t('errors.tableCreatedSuccessfully')}
              </h2>
            </div>
          </div>

          <div className="space-y-6">
            <Alert className="status-info">
              <Settings className="h-4 w-4" />
              <AlertDescription>
                <div>
                  <h3 className="font-semibold text-body mb-2">{t('links.adminTitle')}</h3>
                  <p className="text-body-sm mb-2">{t('links.adminDescription')}</p>
                  <div className="bg-background border border-border rounded p-2 font-mono text-sm break-all">
                    <a href={adminUrl} className="text-primary hover:text-primary-hover">
                      {adminUrl}
                    </a>
                  </div>
                </div>
              </AlertDescription>
            </Alert>

            <Alert className="status-success">
              <Edit className="h-4 w-4" />
              <AlertDescription>
                <div>
                  <h3 className="font-semibold text-body mb-2">{t('links.editorTitle')}</h3>
                  <p className="text-body-sm mb-2">{t('links.editorDescription')}</p>
                  <div className="bg-background border border-border rounded p-2 font-mono text-sm break-all">
                    <a href={editUrl} className="text-success hover:opacity-80">
                      {editUrl}
                    </a>
                  </div>
                </div>
              </AlertDescription>
            </Alert>

            <div className="flex space-x-4">
              <Button variant="secondary" onClick={resetForm}>
                {t('links.createAnother')}
              </Button>
            </div>
          </div>
        </div>
      </PageLayout>
    )
  }

  return (
    <PageLayout title={t('app.title')} description={t('app.description')} maxWidth="xl">
      <div className="card-elevated p-6">
        <div className="mb-6">
          <h1 className="text-heading-2">{t('app.createTable')}</h1>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6" noValidate>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormField label={t('table.title')} htmlFor="title" required error={fieldErrors.title}>
              <Input
                type="text"
                id="title"
                value={formData.title}
                onChange={e => handleFieldChange('title', e.target.value)}
                onBlur={e => handleFieldBlur('title', e.target.value)}
                placeholder={t('table.title')}
                className={fieldErrors.title ? 'border-destructive' : ''}
              />
            </FormField>

            <FormField label={t('table.description')} htmlFor="description">
              <Input
                type="text"
                id="description"
                value={formData.description}
                onChange={e => handleFieldChange('description', e.target.value)}
                placeholder={t('table.description')}
              />
            </FormField>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <FormField label={t('table.columns')} htmlFor="cols" required error={fieldErrors.cols}>
              <Input
                type="number"
                id="cols"
                min="1"
                max="64"
                value={formData.cols}
                onChange={e => handleNumericFieldChange('cols', e.target.value)}
                onBlur={() => handleNumericFieldBlur('cols')}
                className={fieldErrors.cols ? 'border-destructive' : ''}
              />
            </FormField>

            <FormField label={t('table.rows')} htmlFor="rows" required error={fieldErrors.rows}>
              <Input
                type="number"
                id="rows"
                min="1"
                max="500"
                value={formData.rows}
                onChange={e => handleNumericFieldChange('rows', e.target.value)}
                onBlur={() => handleNumericFieldBlur('rows')}
                className={fieldErrors.rows ? 'border-destructive' : ''}
              />
            </FormField>
          </div>

          {error && <ErrorMessage message={error} />}

          <div className="flex justify-end">
            <Button type="submit" disabled={isCreating} className="btn-primary">
              {isCreating ? t('common.loading') : t('app.createTable')}
            </Button>
          </div>
        </form>
      </div>
    </PageLayout>
  )
}
