"""Table management endpoints."""
from fastapi import APIRouter, Depends, Header, HTTPException

from app.api.dependencies import get_table_service
from app.core.security import verify_token
from app.models.table import (
    AddColumnRequest,
    AddRowRequest,
    CreateTableRequest,
    CreateTableResponse,
    RemoveColumnRequest,
    RemoveRowRequest,
    RowColumnResponse,
    TableConfigRequest,
    TableConfigResponse,
    TableResponse,
)
from app.services.table_service import TableService

router = APIRouter(prefix="/tables", tags=["tables"])


@router.post("", response_model=CreateTableResponse)
async def create_table(
    request: CreateTableRequest,
    table_service: TableService = Depends(get_table_service),
):
    """Create a new table with admin and editor tokens."""
    return await table_service.create_table(request)


@router.get("/{slug}", response_model=TableResponse)
async def get_table(
    slug: str,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Get table data with admin or editor token."""
    table, role = await verify_token(slug, t)
    return await table_service.get_table_with_columns(table["id"])


@router.put("/{slug}/config", response_model=TableConfigResponse)
async def update_table_config(
    slug: str,
    request: TableConfigRequest,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Update table configuration (admin only)."""
    table, role = await verify_token(slug, t)

    # Only admin can update configuration
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    result = await table_service.update_table_config(table["id"], request)
    return TableConfigResponse(**result)


@router.post("/{slug}/rows", response_model=RowColumnResponse)
async def add_rows(
    slug: str,
    request: AddRowRequest,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Add rows to table (admin only)."""
    table, role = await verify_token(slug, t)

    # Only admin can add rows
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    result = await table_service.add_rows(table["id"], request)
    return RowColumnResponse(**result)


@router.delete("/{slug}/rows", response_model=RowColumnResponse)
async def remove_rows(
    slug: str,
    request: RemoveRowRequest,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Remove rows from table (admin only)."""
    table, role = await verify_token(slug, t)

    # Only admin can remove rows
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    result = await table_service.remove_rows(table["id"], request)
    return RowColumnResponse(**result)


@router.post("/{slug}/columns", response_model=RowColumnResponse)
async def add_columns(
    slug: str,
    request: AddColumnRequest,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Add columns to table (admin only)."""
    table, role = await verify_token(slug, t)

    # Only admin can add columns
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    result = await table_service.add_columns(table["id"], request)
    return RowColumnResponse(**result)


@router.delete("/{slug}/columns", response_model=RowColumnResponse)
async def remove_columns(
    slug: str,
    request: RemoveColumnRequest,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Remove columns from table (admin only)."""
    table, role = await verify_token(slug, t)

    # Only admin can remove columns
    if role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    result = await table_service.remove_columns(table["id"], request)
    return RowColumnResponse(**result)
