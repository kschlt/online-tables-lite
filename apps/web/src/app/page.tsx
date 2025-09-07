'use client'

import { useState } from 'react'
import { useTranslations } from '@/hooks/use-translations'
import { PageLayout, LanguageSwitcher } from '@/components/ui'
import { createTable } from '@/lib/api'
import type { CreateTableRequest, CreateTableResponse } from '@/types'

export default function Home() {
  const { t } = useTranslations()
  const [isCreating, setIsCreating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<CreateTableResponse | null>(null)
  
  const [formData, setFormData] = useState<CreateTableRequest>({
    title: '',
    description: '',
    cols: 3,
    rows: 5
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsCreating(true)
    setError(null)

    try {
      const response = await createTable(formData)
      setResult(response)
    } catch (err) {
      setError(err instanceof Error ? err.message : t('errors.failedToCreateTable'))
    } finally {
      setIsCreating(false)
    }
  }

  if (result) {
    const adminUrl = `${window.location.origin}/table/${result.slug}?t=${result.admin_token}`
    const editUrl = `${window.location.origin}/table/${result.slug}?t=${result.edit_token}`
    
    return (
      <PageLayout
        title={t('app.title')}
        description={t('app.description')}
        maxWidth="xl"
      >
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold text-green-800">✅ {t('errors.tableCreatedSuccessfully')}</h2>
            <LanguageSwitcher />
          </div>
          
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 className="font-semibold text-blue-900 mb-2">🔧 Admin Link (Configure Table)</h3>
              <p className="text-sm text-blue-700 mb-2">Use this link to configure table settings, add/remove rows and columns:</p>
              <div className="bg-white border border-blue-200 rounded p-2 font-mono text-sm break-all">
                <a href={adminUrl} className="text-blue-600 hover:text-blue-800">
                  {adminUrl}
                </a>
              </div>
            </div>
            
            <div className="bg-green-50 border border-green-200 rounded-lg p-4">
              <h3 className="font-semibold text-green-900 mb-2">✏️ Editor Link (Edit Table)</h3>
              <p className="text-sm text-green-700 mb-2">Share this link with others to allow them to edit the table:</p>
              <div className="bg-white border border-green-200 rounded p-2 font-mono text-sm break-all">
                <a href={editUrl} className="text-green-600 hover:text-green-800">
                  {editUrl}
                </a>
              </div>
            </div>
            
            <div className="flex space-x-4">
              <button
                onClick={() => {
                  setResult(null)
                  setFormData({ title: '', description: '', cols: 3, rows: 5 })
                }}
                className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 transition-colors"
              >
                {t('common.add')} {t('table.columns')}
              </button>
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
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-bold text-gray-900">{t('app.createTable')}</h1>
          <LanguageSwitcher />
        </div>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-2">
                {t('table.title')}
              </label>
              <input
                type="text"
                id="title"
                value={formData.title}
                onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder={t('table.title')}
              />
            </div>
            
            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-2">
                {t('table.description')}
              </label>
              <input
                type="text"
                id="description"
                value={formData.description}
                onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder={t('table.description')}
              />
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label htmlFor="cols" className="block text-sm font-medium text-gray-700 mb-2">
                {t('table.columns')}
              </label>
              <input
                type="number"
                id="cols"
                min="1"
                max="64"
                value={formData.cols}
                onChange={(e) => setFormData(prev => ({ ...prev, cols: parseInt(e.target.value) || 1 }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            
            <div>
              <label htmlFor="rows" className="block text-sm font-medium text-gray-700 mb-2">
                {t('table.rows')}
              </label>
              <input
                type="number"
                id="rows"
                min="1"
                max="500"
                value={formData.rows}
                onChange={(e) => setFormData(prev => ({ ...prev, rows: parseInt(e.target.value) || 1 }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>
          
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <p className="text-red-700">{error}</p>
            </div>
          )}
          
          <div className="flex justify-end">
            <button
              type="submit"
              disabled={isCreating}
              className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {isCreating ? t('common.loading') : t('app.createTable')}
            </button>
          </div>
        </form>
      </div>
    </PageLayout>
  )
}
