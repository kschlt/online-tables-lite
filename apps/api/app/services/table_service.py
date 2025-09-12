"""Table business logic service."""

from typing import Any, Optional

from app.core.config import settings
from app.core.database import get_supabase_client
from app.core.security import generate_slug, generate_token, hash_token
from app.models.table import (
    AddColumnRequest,
    AddRowRequest,
    CellData,
    CellUpdateRequest,
    ColumnFormat,
    CreateTableRequest,
    CreateTableResponse,
    RemoveColumnRequest,
    RemoveRowRequest,
    TableColumn,
    TableConfigRequest,
    TableResponse,
)


class TableService:
    """Service for table operations."""

    def __init__(self, config_service: Optional["ConfigService"] = None):
        from app.services.config_service import ConfigService
        
        self.supabase = get_supabase_client()
        self.config_service = config_service or ConfigService()

    async def create_table(self, request: CreateTableRequest, locale: str = "en") -> CreateTableResponse:
        """Create a new table with tokens."""
        # Use config defaults if values not provided
        if request.cols is None:
            request.cols = await self.config_service.get_default_table_cols()
        if request.rows is None:
            request.rows = await self.config_service.get_default_table_rows()
            
        # Validate limits upfront
        if request.cols > settings.table_col_limit:
            raise ValueError(f"Columns cannot exceed {settings.table_col_limit}")
        if request.rows > settings.table_row_limit:
            raise ValueError(f"Rows cannot exceed {settings.table_row_limit}")
        if request.cols < 1:
            raise ValueError("Columns must be at least 1")
        if request.rows < 1:
            raise ValueError("Rows must be at least 1")

        # Generate tokens and slug
        slug = generate_slug()
        admin_token = generate_token()
        edit_token = generate_token()

        # Hash tokens for storage
        admin_token_hash = hash_token(admin_token)
        edit_token_hash = hash_token(edit_token)

        # Create table in Supabase
        table_data = {
            "slug": slug,
            "title": request.title,
            "description": request.description,
            "cols": request.cols,
            "rows": request.rows,
            "fixed_rows": False,  # Default to auto rows
            "admin_token_hash": admin_token_hash,
            "edit_token_hash": edit_token_hash,
        }

        try:
            table_result = self.supabase.table("tables").insert(table_data).execute()
            if not table_result.data:
                raise Exception("Failed to create table - no data returned")
            table_id = table_result.data[0]["id"]
        except Exception as e:
            print(f"Database error creating table: {e}")
            print(f"Table data: {table_data}")
            raise

        # Create default columns using configuration
        try:
            default_columns = await self.config_service.get_default_column_config(locale)
        except Exception as e:
            print(f"Warning: Failed to load column config, using fallbacks: {e}")
            default_columns = []

        columns_data = []
        for i in range(request.cols):
            # Use config if available for this column index
            if i < len(default_columns):
                config_col = default_columns[i]
                column_data = {
                    "table_id": table_id,
                    "idx": i,
                    "header": config_col.get("header", f"Column {i + 1}"),
                    "width": None,
                    "format": config_col.get("format", "text"),
                }
            else:
                # Fallback for columns beyond configured defaults
                column_data = {
                    "table_id": table_id,
                    "idx": i,
                    "header": f"Column {i + 1}",
                    "width": None,
                    "format": "text",
                }
            columns_data.append(column_data)

        self.supabase.table("columns").insert(columns_data).execute()

        return CreateTableResponse(slug=slug, admin_token=admin_token, edit_token=edit_token)

    async def get_table_with_columns(self, table_id: str) -> dict[str, Any]:
        """Get table data with columns."""
        # Get table
        table_result = self.supabase.table("tables").select("*").eq("id", table_id).execute()
        table = table_result.data[0]

        # Get columns
        columns_result = (
            self.supabase.table("columns")
            .select("*")
            .eq("table_id", table_id)
            .order("idx")
            .execute()
        )

        columns_data = [
            TableColumn(
                idx=col["idx"],
                header=col["header"],
                width=col["width"],
                format=ColumnFormat(col.get("format", "text")),  # Handle migration
            )
            for col in columns_result.data
        ]

        # Get cells data
        cells_result = (
            self.supabase.table("cells").select("r, c, value").eq("table_id", table_id).execute()
        )

        cells_data = [
            CellData(row=cell["r"], col=cell["c"], value=cell["value"])
            for cell in cells_result.data
        ]

        return TableResponse(
            id=table["id"],
            slug=table["slug"],
            title=table["title"],
            description=table["description"],
            cols=table["cols"],
            rows=table["rows"],
            fixed_rows=table.get("fixed_rows", False),  # Handle migration
            columns=columns_data,
            cells=cells_data,
        )

    async def update_cells(self, table_id: str, cells: list[CellUpdateRequest]) -> None:
        """Batch update cells in a table."""
        for cell in cells:
            # Upsert cell data
            cell_data = {
                "table_id": table_id,
                "r": cell.row,
                "c": cell.col,
                "value": cell.value,
            }

            # Try to update existing cell first
            existing = (
                self.supabase.table("cells")
                .select("id")
                .eq("table_id", table_id)
                .eq("r", cell.row)
                .eq("c", cell.col)
                .execute()
            )

            if existing.data:
                # Update existing cell
                self.supabase.table("cells").update({"value": cell.value}).eq(
                    "id", existing.data[0]["id"]
                ).execute()
            else:
                # Insert new cell
                self.supabase.table("cells").insert(cell_data).execute()

    async def get_cells(self, table_id: str) -> list[dict[str, Any]]:
        """Get all cell data for a table."""
        result = (
            self.supabase.table("cells").select("r, c, value").eq("table_id", table_id).execute()
        )

        return [
            {"row": cell["r"], "col": cell["c"], "value": cell["value"]} for cell in result.data
        ]

    async def update_table_config(
        self, table_id: str, config: TableConfigRequest
    ) -> dict[str, Any]:
        """Update table configuration (admin only)."""
        # Validate limits
        errors = []

        if config.rows is not None:
            if config.rows < 1:
                errors.append("Rows must be at least 1")
            elif config.rows > settings.table_row_limit:
                errors.append(f"Rows cannot exceed {settings.table_row_limit}")

        if errors:
            return {
                "success": False,
                "message": "; ".join(errors),
                "limits": {
                    "max_rows": settings.table_row_limit,
                    "max_cols": settings.table_col_limit,
                },
            }

        # Update table metadata
        update_data = {}
        if config.title is not None:
            update_data["title"] = config.title
        if config.description is not None:
            update_data["description"] = config.description
        if config.rows is not None:
            update_data["rows"] = config.rows
        if config.fixed_rows is not None:
            update_data["fixed_rows"] = config.fixed_rows

        if update_data:
            self.supabase.table("tables").update(update_data).eq("id", table_id).execute()

        # Update column configurations
        if config.columns:
            for col_update in config.columns:
                col_data = {}
                if col_update.header is not None:
                    col_data["header"] = col_update.header
                if col_update.width is not None:
                    col_data["width"] = col_update.width
                if col_update.format is not None:
                    col_data["format"] = col_update.format.value

                if col_data:
                    self.supabase.table("columns").update(col_data).eq("table_id", table_id).eq(
                        "idx", col_update.idx
                    ).execute()

        return {
            "success": True,
            "message": "Configuration updated successfully",
            "limits": {"max_rows": settings.table_row_limit, "max_cols": settings.table_col_limit},
        }

    async def add_rows(self, table_id: str, request: AddRowRequest) -> dict[str, Any]:
        """Add rows to a table."""
        # Get current table data
        table_result = (
            self.supabase.table("tables").select("rows, fixed_rows").eq("id", table_id).execute()
        )
        if not table_result.data:
            return {"success": False, "message": "Table not found", "new_rows": None}

        table = table_result.data[0]

        # Check if rows are fixed
        if table.get("fixed_rows", False):
            return {
                "success": False,
                "message": "Cannot add rows to a table with fixed row count",
                "new_rows": table["rows"],
            }

        current_rows = table["rows"]
        new_rows = current_rows + request.count

        # Check limits
        if new_rows > settings.table_row_limit:
            return {
                "success": False,
                "message": f"Cannot add {request.count} rows. Would exceed limit of {settings.table_row_limit}",
                "new_rows": current_rows,
            }

        # Update table row count
        self.supabase.table("tables").update({"rows": new_rows}).eq("id", table_id).execute()

        return {"success": True, "message": f"Added {request.count} rows", "new_rows": new_rows}

    async def remove_rows(self, table_id: str, request: RemoveRowRequest) -> dict[str, Any]:
        """Remove rows from a table."""
        # Get current table data
        table_result = (
            self.supabase.table("tables").select("rows, fixed_rows").eq("id", table_id).execute()
        )
        if not table_result.data:
            return {"success": False, "message": "Table not found", "new_rows": None}

        table = table_result.data[0]

        # Check if rows are fixed
        if table.get("fixed_rows", False):
            return {
                "success": False,
                "message": "Cannot remove rows from a table with fixed row count",
                "new_rows": table["rows"],
            }

        current_rows = table["rows"]
        new_rows = current_rows - request.count

        # Check minimum
        if new_rows < 1:
            return {
                "success": False,
                "message": f"Cannot remove {request.count} rows. Must have at least 1 row",
                "new_rows": current_rows,
            }

        # Remove cells from deleted rows
        self.supabase.table("cells").delete().eq("table_id", table_id).gte("r", new_rows).execute()

        # Update table row count
        self.supabase.table("tables").update({"rows": new_rows}).eq("id", table_id).execute()

        return {"success": True, "message": f"Removed {request.count} rows", "new_rows": new_rows}

    async def add_columns(self, table_id: str, request: AddColumnRequest) -> dict[str, Any]:
        """Add columns to a table."""
        # Get current table data
        table_result = self.supabase.table("tables").select("cols").eq("id", table_id).execute()
        if not table_result.data:
            return {"success": False, "message": "Table not found", "new_cols": None}

        current_cols = table_result.data[0]["cols"]
        new_cols = current_cols + request.count

        # Check limits
        if new_cols > settings.table_col_limit:
            return {
                "success": False,
                "message": f"Cannot add {request.count} columns. Would exceed limit of {settings.table_col_limit}",
                "new_cols": current_cols,
            }

        # Create new column entries
        new_columns = []
        for i in range(current_cols, new_cols):
            header = request.header if request.header and i == current_cols else f"Column {i + 1}"
            new_columns.append(
                {
                    "table_id": table_id,
                    "idx": i,
                    "header": header,
                    "width": None,
                    "format": "text",  # Default to text format
                }
            )

        self.supabase.table("columns").insert(new_columns).execute()

        # Update table column count
        self.supabase.table("tables").update({"cols": new_cols}).eq("id", table_id).execute()

        return {"success": True, "message": f"Added {request.count} columns", "new_cols": new_cols}

    async def remove_columns(self, table_id: str, request: RemoveColumnRequest) -> dict[str, Any]:
        """Remove columns from a table."""
        # Get current table data
        table_result = self.supabase.table("tables").select("cols").eq("id", table_id).execute()
        if not table_result.data:
            return {"success": False, "message": "Table not found", "new_cols": None}

        current_cols = table_result.data[0]["cols"]
        new_cols = current_cols - request.count

        # Check minimum
        if new_cols < 1:
            return {
                "success": False,
                "message": f"Cannot remove {request.count} columns. Must have at least 1 column",
                "new_cols": current_cols,
            }

        # Remove columns and their cells
        self.supabase.table("columns").delete().eq("table_id", table_id).gte(
            "idx", new_cols
        ).execute()
        self.supabase.table("cells").delete().eq("table_id", table_id).gte("c", new_cols).execute()

        # Update table column count
        self.supabase.table("tables").update({"cols": new_cols}).eq("id", table_id).execute()

        return {
            "success": True,
            "message": f"Removed {request.count} columns",
            "new_cols": new_cols,
        }
