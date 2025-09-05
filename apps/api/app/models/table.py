"""Table-related Pydantic models."""
from typing import Optional

from pydantic import BaseModel


class CreateTableRequest(BaseModel):
    """Request model for creating a new table."""

    title: Optional[str] = None
    description: Optional[str] = None
    cols: int = 4
    rows: int = 10


class CreateTableResponse(BaseModel):
    """Response model for table creation."""

    slug: str
    admin_token: str
    edit_token: str


class TableColumn(BaseModel):
    """Table column model."""

    idx: int
    header: Optional[str]
    width: Optional[int]
    today_hint: bool


class CellData(BaseModel):
    """Cell data model."""

    row: int
    col: int
    value: Optional[str]


class TableResponse(BaseModel):
    """Response model for table data."""

    id: str
    slug: str
    title: Optional[str]
    description: Optional[str]
    cols: int
    rows: int
    columns: list[TableColumn]
    cells: list[CellData] = []


class CellUpdateRequest(BaseModel):
    """Request model for updating cells."""

    row: int
    col: int
    value: Optional[str] = None


class CellBatchUpdateRequest(BaseModel):
    """Request model for batch cell updates."""

    cells: list[CellUpdateRequest]


class ColumnConfigUpdate(BaseModel):
    """Request model for updating column configuration."""

    idx: int
    header: Optional[str] = None
    width: Optional[int] = None
    today_hint: Optional[bool] = None


class TableConfigRequest(BaseModel):
    """Request model for updating table configuration."""

    title: Optional[str] = None
    description: Optional[str] = None
    rows: Optional[int] = None
    cols: Optional[int] = None
    columns: Optional[list[ColumnConfigUpdate]] = None


class TableConfigResponse(BaseModel):
    """Response model for table configuration."""

    success: bool
    message: str
    limits: dict[str, int] = {}


class AddRowRequest(BaseModel):
    """Request model for adding rows to a table."""

    count: int = 1


class RemoveRowRequest(BaseModel):
    """Request model for removing rows from a table."""

    count: int = 1


class AddColumnRequest(BaseModel):
    """Request model for adding columns to a table."""

    count: int = 1
    header: Optional[str] = None


class RemoveColumnRequest(BaseModel):
    """Request model for removing columns from a table."""

    count: int = 1


class RowColumnResponse(BaseModel):
    """Response model for row/column operations."""

    success: bool
    message: str
    new_rows: Optional[int] = None
    new_cols: Optional[int] = None
