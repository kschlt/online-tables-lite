import { PageLayout } from '@/components/ui';

export default function Home() {
  return (
    <PageLayout
      title="Online Tables Lite"
      description="Collaborative table editing application"
      maxWidth="md"
    >
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Get Started</h2>
        <p className="text-gray-600 mb-4">
          Create collaborative tables that you can share and edit in real-time.
        </p>
        <p className="text-sm text-gray-500">
          Phase 2 features (table creation and editing) coming soon.
        </p>
      </div>
    </PageLayout>
  );
}
