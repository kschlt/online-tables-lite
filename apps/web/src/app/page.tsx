'use client'

import { useState } from 'react'
import { PageLayout } from '@/components/ui'
import { createTable } from '@/lib/api'
import type { CreateTableRequest } from '@/types'

export default function Home() {
  const [isCreating, setIsCreating] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<{
    slug: string
    adminToken: string
    editToken: string
  } | null>(null)
  
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
      setError(err instanceof Error ? err.message : 'Failed to create table')
    } finally {
      setIsCreating(false)
    }
  }

  if (result) {
    const adminUrl = `${window.location.origin}/table/${result.slug}?t=${result.adminToken}`
    const editUrl = `${window.location.origin}/table/${result.slug}?t=${result.editToken}`
    
    return (
      <PageLayout
        title="Online Tables Lite"
        description="Collaborative table editing application"
        maxWidth="2xl"
      >
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-green-800 mb-4">✅ Table Created Successfully!</h2>
          
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 className="font-semibold text-blue-900 mb-2">🔧 Admin Link (Configure Table)</h3>
              <p className="text-sm text-blue-700 mb-2">Use this link to configure the table, add/remove rows and columns:</p>
              <div className="bg-white p-3 rounded border font-mono text-xs break-all">
                <a href={adminUrl} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline">
                  {adminUrl}
                </a>
              </div>
            </div>

            <div className="bg-green-50 border border-green-200 rounded-lg p-4">
              <h3 className="font-semibold text-green-900 mb-2">✏️ Editor Link (Edit Data)</h3>
              <p className="text-sm text-green-700 mb-2">Share this link with collaborators to edit table data:</p>
              <div className="bg-white p-3 rounded border font-mono text-xs break-all">
                <a href={editUrl} target="_blank" rel="noopener noreferrer" className="text-green-600 hover:underline">
                  {editUrl}
                </a>
              </div>
            </div>

            <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
              <h4 className="font-semibold text-gray-900 mb-2">🚀 Next Steps:</h4>
              <ul className="text-sm text-gray-700 space-y-1">
                <li>• Open the <strong>Admin Link</strong> to configure your table (headers, widths, etc.)</li>
                <li>• Share the <strong>Editor Link</strong> with collaborators</li>
                <li>• Both links support real-time collaborative editing</li>
                <li>• Bookmark both links - you'll need them to access your table</li>
              </ul>
            </div>
          </div>

          <button
            onClick={() => setResult(null)}
            className="mt-6 bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Create Another Table
          </button>
        </div>
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="Online Tables Lite"
      description="Collaborative table editing application"
      maxWidth="md"
    >
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Create New Table</h2>
        <p className="text-gray-600 mb-6">
          Create collaborative tables with real-time editing, admin controls, and custom column widths.
        </p>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded text-red-700 text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
              Table Title
            </label>
            <input
              type="text"
              id="title"
              value={formData.title || ''}
              onChange={e => setFormData(prev => ({ ...prev, title: e.target.value }))}
              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="My Collaborative Table"
            />
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
              Description (Optional)
            </label>
            <textarea
              id="description"
              value={formData.description || ''}
              onChange={e => setFormData(prev => ({ ...prev, description: e.target.value }))}
              rows={3}
              className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Brief description of what this table is for..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="cols" className="block text-sm font-medium text-gray-700 mb-1">
                Columns
              </label>
              <input
                type="number"
                id="cols"
                min="1"
                max="64"
                value={formData.cols || 3}
                onChange={e => setFormData(prev => ({ ...prev, cols: parseInt(e.target.value) || 3 }))}
                className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-500 mt-1">1-64 columns</p>
            </div>

            <div>
              <label htmlFor="rows" className="block text-sm font-medium text-gray-700 mb-1">
                Rows
              </label>
              <input
                type="number"
                id="rows"
                min="1"
                max="500"
                value={formData.rows || 5}
                onChange={e => setFormData(prev => ({ ...prev, rows: parseInt(e.target.value) || 5 }))}
                className="w-full border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <p className="text-xs text-gray-500 mt-1">1-500 rows</p>
            </div>
          </div>

          <button
            type="submit"
            disabled={isCreating}
            className="w-full bg-blue-600 text-white py-3 px-4 rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isCreating ? 'Creating Table...' : 'Create Table'}
          </button>
        </form>

        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <h3 className="font-medium text-gray-900 mb-2">✨ Features Included:</h3>
          <ul className="text-sm text-gray-600 space-y-1">
            <li>• Real-time collaborative editing</li>
            <li>• Admin controls (add/remove rows & columns)</li>
            <li>• Custom column widths and headers</li>
            <li>• Today date highlighting for date columns</li>
            <li>• Secure token-based access control</li>
          </ul>
        </div>
      </div>
    </PageLayout>
  )
}
