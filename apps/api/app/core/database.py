"""Database client setup."""

from supabase import Client, create_client

from app.core.config import settings

# Supabase client instance
supabase: Client = create_client(settings.supabase_url, settings.supabase_service_role_key)


def get_supabase_client() -> Client:
    """Get Supabase client instance."""
    return supabase
