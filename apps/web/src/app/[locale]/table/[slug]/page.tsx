'use client'

import { useParams, useSearchParams } from 'next/navigation'
import { useTranslations } from 'next-intl'
import { useTable } from '@/hooks'
import { PageLayout, LoadingSpinner, ErrorMessage } from '@/components/ui'
import { TableGrid } from '@/components/table'

export default function TablePage() {
  const t = useTranslations()
  const params = useParams()
  const searchParams = useSearchParams()

  const slug = params.slug as string
  const token = searchParams.get('t')

  const { tableData, isLoading, error } = useTable({ slug, token })

  if (isLoading) {
    return (
      <PageLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <LoadingSpinner size="lg" />
        </div>
      </PageLayout>
    )
  }

  if (error) {
    return (
      <PageLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <div className="text-center">
            <ErrorMessage message={error} className="max-w-md" />
          </div>
        </div>
      </PageLayout>
    )
  }

  if (!tableData) {
    return (
      <PageLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <div className="text-center">
            <ErrorMessage message={t('errors.genericError')} className="max-w-md" />
          </div>
        </div>
      </PageLayout>
    )
  }

  return (
    <PageLayout>
      <div className="mb-6">
        <div className="mb-6">
          <h1 className="text-heading-1 mb-2">{tableData.title || t('table.untitled')}</h1>
          {tableData.description && (
            <p className="text-body text-muted-foreground">{tableData.description}</p>
          )}
        </div>
      </div>
      <TableGrid tableData={tableData} />
    </PageLayout>
  )
}
