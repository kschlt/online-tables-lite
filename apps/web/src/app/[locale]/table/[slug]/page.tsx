'use client'

import { useParams, useSearchParams } from 'next/navigation'
import { useTranslations } from 'next-intl'
import { useTable } from '@/hooks'
import { PageLayout, LoadingSpinner, ErrorMessage, Header } from '@/components/ui'
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
    <PageLayout
      header={
        <Header
          title={tableData.title || t('table.untitled')}
          description={tableData.description || undefined}
        />
      }
    >
      <TableGrid tableData={tableData} />
    </PageLayout>
  )
}
