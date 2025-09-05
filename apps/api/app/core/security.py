"""Security utilities for token handling."""
import hashlib
import secrets

from fastapi import HTTPException

from app.core.database import get_supabase_client


def hash_token(token: str) -> str:
    """Hash token with SHA-256."""
    return hashlib.sha256(token.encode()).hexdigest()


def generate_slug() -> str:
    """Generate a random slug."""
    return secrets.token_urlsafe(8)


def generate_token() -> str:
    """Generate a secure token."""
    return secrets.token_urlsafe(32)


async def verify_token(table_slug: str, token: str) -> tuple[dict, str]:
    """Verify token and return table with role."""
    if not token:
        raise HTTPException(status_code=401, detail="Token required")

    # Hash token for comparison (never log raw tokens)
    token_hash = hash_token(token)

    # Get table from Supabase
    supabase = get_supabase_client()
    result = (
        supabase.table("tables")
        .select("*")
        .eq("slug", table_slug)
        .is_("deleted_at", "null")
        .execute()
    )

    if not result.data:
        raise HTTPException(status_code=404, detail="Table not found")

    table = result.data[0]

    if table["admin_token_hash"] == token_hash:
        return table, "admin"
    elif table["edit_token_hash"] == token_hash:
        return table, "editor"
    else:
        raise HTTPException(status_code=403, detail="Invalid token")
