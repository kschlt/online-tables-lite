"""Table-related Pydantic models."""
from enum import Enum

from pydantic import BaseModel


class ColumnFormat(str, Enum):
    """Column format options."""
    TEXT = "text"
    DATE = "date"
    TIMERANGE = "timerange"


class CreateTableRequest(BaseModel):
    """Request model for creating a new table."""

    title: str | None = None
    description: str | None = None
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
    header: str | None
    width: int | None
    format: ColumnFormat = ColumnFormat.TEXT


class CellData(BaseModel):
    """Cell data model."""

    row: int
    col: int
    value: str | None


class TableResponse(BaseModel):
    """Response model for table data."""

    id: str
    slug: str
    title: str | None
    description: str | None
    cols: int
    rows: int
    fixed_rows: bool = False
    columns: list[TableColumn]
    cells: list[CellData] = []


class CellUpdateRequest(BaseModel):
    """Request model for updating cells."""

    row: int
    col: int
    value: str | None = None


class CellBatchUpdateRequest(BaseModel):
    """Request model for batch cell updates."""

    cells: list[CellUpdateRequest]


class ColumnConfigUpdate(BaseModel):
    """Request model for updating column configuration."""

    idx: int
    header: str | None = None
    width: int | None = None
    format: ColumnFormat | None = None


class TableConfigRequest(BaseModel):
    """Request model for updating table configuration."""

    title: str | None = None
    description: str | None = None
    rows: int | None = None
    fixed_rows: bool | None = None
    columns: list[ColumnConfigUpdate] | None = None


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
    header: str | None = None


class RemoveColumnRequest(BaseModel):
    """Request model for removing columns from a table."""

    count: int = 1


class RowColumnResponse(BaseModel):
    """Response model for row/column operations."""

    success: bool
    message: str
    new_rows: int | None = None
    new_cols: int | None = None
