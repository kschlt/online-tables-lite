'use client'

import { useState, useEffect } from 'react'
import { useTranslations, useLocale } from 'next-intl'
import { useSearchParams, useRouter } from 'next/navigation'
import { PageLayout, LanguageSwitcher, ErrorMessage } from '@/components/ui'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
  
  const [formData, setFormData] = useState<CreateTableRequest>({
    title: '',
    description: '',
    cols: 3,
    rows: 5
  })

  // Ensure we're on the client side
  useEffect(() => {
    setIsClient(true)
  }, [])

  // Check for success state in URL parameters
  useEffect(() => {
    if (!isClient) return
    
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsCreating(true)
    setError(null)

    try {
      const response = await createTable(formData)
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
    // Clear URL parameters
    router.replace(`/${locale}`)
  }

  // Don't render success state until client-side hydration is complete
  if (result && isClient) {
    const baseUrl = typeof window !== 'undefined' ? window.location.origin : ''
    const adminUrl = `${baseUrl}/${locale}/table/${result.slug}?t=${result.admin_token}`
    const editUrl = `${baseUrl}/${locale}/table/${result.slug}?t=${result.edit_token}`
    
    return (
      <PageLayout
        title={t('app.title')}
        description={t('app.description')}
        maxWidth="xl"
      >
        <div className="card-elevated p-6">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center gap-2">
              <CheckCircle className="w-6 h-6 text-success" />
              <h2 className="text-heading-2 text-success">{t('errors.tableCreatedSuccessfully')}</h2>
            </div>
            <LanguageSwitcher />
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
              <Button
                variant="secondary"
                onClick={resetForm}
              >
                {t('links.createAnother')}
              </Button>
            </div>
          </div>
        </div>
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title={t('app.title')}
      description={t('app.description')}
      maxWidth="xl"
    >
      <div className="card-elevated p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-heading-2">{t('app.createTable')}</h1>
          <LanguageSwitcher />
        </div>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <Label htmlFor="title" className="text-body font-medium">
                {t('table.title')}
              </Label>
              <Input
                type="text"
                id="title"
                value={formData.title}
                onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
                placeholder={t('table.title')}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="description" className="text-body font-medium">
                {t('table.description')}
              </Label>
              <Input
                type="text"
                id="description"
                value={formData.description}
                onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                placeholder={t('table.description')}
              />
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <Label htmlFor="cols" className="text-body font-medium">
                {t('table.columns')}
              </Label>
              <Input
                type="number"
                id="cols"
                min="1"
                max="64"
                value={formData.cols}
                onChange={(e) => setFormData(prev => ({ ...prev, cols: parseInt(e.target.value) || 1 }))}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="rows" className="text-body font-medium">
                {t('table.rows')}
              </Label>
              <Input
                type="number"
                id="rows"
                min="1"
                max="500"
                value={formData.rows}
                onChange={(e) => setFormData(prev => ({ ...prev, rows: parseInt(e.target.value) || 1 }))}
              />
            </div>
          </div>
          
          {error && (
            <ErrorMessage message={error} />
          )}
          
          <div className="flex justify-end">
            <Button
              type="submit"
              disabled={isCreating}
              className="btn-primary"
            >
              {isCreating ? t('common.loading') : t('app.createTable')}
            </Button>
          </div>
        </form>
      </div>
    </PageLayout>
  )
}
