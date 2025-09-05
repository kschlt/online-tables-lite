'use client';

import { useParams, useSearchParams } from 'next/navigation';
import { useTable } from '@/hooks';
import { PageLayout, LoadingSpinner, ErrorMessage } from '@/components/ui';
import { TableGrid } from '@/components/table';

export default function TablePage() {
  const params = useParams();
  const searchParams = useSearchParams();

  const slug = params.slug as string;
  const token = searchParams.get('t');

  const { tableData, isLoading, error } = useTable({ slug, token });

  if (isLoading) {
    return (
      <PageLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <LoadingSpinner size="lg" />
        </div>
      </PageLayout>
    );
  }

  if (error) {
    return (
      <PageLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <ErrorMessage message={error} className="max-w-md" />
        </div>
      </PageLayout>
    );
  }

  if (!tableData) {
    return (
      <PageLayout>
        <div className="flex items-center justify-center min-h-[50vh]">
          <div className="text-gray-600">Table not found</div>
        </div>
      </PageLayout>
    );
  }

  return (
    <PageLayout
      title={tableData.title || `Table ${tableData.slug}`}
      description={tableData.description || undefined}
      maxWidth="full"
    >
      <TableGrid tableData={tableData} />
    </PageLayout>
  );
}
