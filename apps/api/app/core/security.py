"""Security utilities for token handling."""

import hashlib
import secrets
from typing import Any

from fastapi import Depends, Header, HTTPException

from app.core.database import get_supabase_client
from app.core.logging import request_id_context


def hash_token(token: str) -> str:
    """Hash token with SHA-256."""
    return hashlib.sha256(token.encode()).hexdigest()


def generate_slug() -> str:
    """Generate a random slug."""
    return secrets.token_urlsafe(8)


def generate_token() -> str:
    """Generate a secure token."""
    return secrets.token_urlsafe(32)


def extract_bearer_token(authorization: str = Header(None)) -> str:
    """Extract token from Authorization header."""
    request_id = request_id_context.get("")

    if not authorization:
        raise HTTPException(
            status_code=401,
            detail={"error": "Authorization header required", "request_id": request_id},
        )

    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail={
                "error": "Invalid authorization format. Use 'Bearer <token>'",
                "request_id": request_id,
            },
        )

    return authorization[7:]  # Remove "Bearer " prefix


async def verify_token(table_slug: str, token: str) -> tuple[dict[str, Any], str]:
    """Verify token and return table with role."""
    request_id = request_id_context.get("")

    if not token:
        raise HTTPException(
            status_code=401, detail={"error": "Token required", "request_id": request_id}
        )

    # Hash token for comparison (never log raw tokens)
    token_hash = hash_token(token)

    try:
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
            raise HTTPException(
                status_code=404,
                detail={
                    "error": "Table not found",
                    "request_id": request_id,
                    "table_slug": table_slug,
                },
            )

        table = result.data[0]

        if table["admin_token_hash"] == token_hash:
            return table, "admin"
        elif table["edit_token_hash"] == token_hash:
            return table, "editor"
        else:
            raise HTTPException(
                status_code=403,
                detail={
                    "error": "Invalid token",
                    "request_id": request_id,
                    "table_slug": table_slug,
                },
            )
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    except Exception as e:
        # Log database errors and return standardized error
        import logging

        logger = logging.getLogger("api.auth")
        logger.error(
            "Database error during token verification",
            exc_info=e,
            extra={"extra_fields": {"table_slug": table_slug, "request_id": request_id}},
        )
        raise HTTPException(
            status_code=500,
            detail={"error": "Authentication service unavailable", "request_id": request_id},
        )


async def verify_bearer_token(
    table_slug: str, authorization: str = Depends(extract_bearer_token)
) -> tuple[dict[str, Any], str]:
    """Verify Bearer token and return table with role."""
    return await verify_token(table_slug, authorization)


def get_bearer_auth(slug: str):
    """Create dependency for Bearer token authentication for a specific table."""

    async def _verify_auth(
        authorization: str = Depends(extract_bearer_token),
    ) -> tuple[dict[str, Any], str]:
        return await verify_token(slug, authorization)

    return _verify_auth
