"""Table business logic service."""
from typing import Any

from app.core.database import get_supabase_client
from app.core.security import generate_slug, generate_token, hash_token
from app.models.table import (
    CreateTableRequest, CreateTableResponse, TableColumn, TableResponse, 
    CellUpdateRequest, CellData, TableConfigRequest, ColumnConfigUpdate
)
from app.core.config import settings


class TableService:
    """Service for table operations."""

    def __init__(self):
        self.supabase = get_supabase_client()

    async def create_table(self, request: CreateTableRequest) -> CreateTableResponse:
        """Create a new table with tokens."""
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
            "admin_token_hash": admin_token_hash,
            "edit_token_hash": edit_token_hash,
        }

        table_result = self.supabase.table("tables").insert(table_data).execute()
        table_id = table_result.data[0]["id"]

        # Create default columns
        columns_data = [
            {
                "table_id": table_id,
                "idx": i,
                "header": f"Column {i + 1}",
                "width": None,
                "today_hint": False,
            }
            for i in range(request.cols)
        ]

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
                today_hint=col["today_hint"],
            )
            for col in columns_result.data
        ]

        # Get cells data
        cells_result = (
            self.supabase.table("cells")
            .select("r, c, value")
            .eq("table_id", table_id)
            .execute()
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
                self.supabase.table("cells").update({"value": cell.value}).eq("id", existing.data[0]["id"]).execute()
            else:
                # Insert new cell
                self.supabase.table("cells").insert(cell_data).execute()

    async def get_cells(self, table_id: str) -> list[dict[str, Any]]:
        """Get all cell data for a table."""
        result = (
            self.supabase.table("cells")
            .select("r, c, value")
            .eq("table_id", table_id)
            .execute()
        )
        
        return [
            {"row": cell["r"], "col": cell["c"], "value": cell["value"]}
            for cell in result.data
        ]

    async def update_table_config(self, table_id: str, config: TableConfigRequest) -> dict[str, Any]:
        """Update table configuration (admin only)."""
        # Validate limits
        errors = []
        
        if config.rows is not None:
            if config.rows < 1:
                errors.append("Rows must be at least 1")
            elif config.rows > settings.table_row_limit:
                errors.append(f"Rows cannot exceed {settings.table_row_limit}")
        
        if config.cols is not None:
            if config.cols < 1:
                errors.append("Columns must be at least 1")
            elif config.cols > settings.table_col_limit:
                errors.append(f"Columns cannot exceed {settings.table_col_limit}")
        
        if errors:
            return {
                "success": False,
                "message": "; ".join(errors),
                "limits": {
                    "max_rows": settings.table_row_limit,
                    "max_cols": settings.table_col_limit
                }
            }
        
        # Update table metadata
        update_data = {}
        if config.title is not None:
            update_data["title"] = config.title
        if config.description is not None:
            update_data["description"] = config.description
        if config.rows is not None:
            update_data["rows"] = config.rows
        if config.cols is not None:
            update_data["cols"] = config.cols
        
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
                if col_update.today_hint is not None:
                    col_data["today_hint"] = col_update.today_hint
                
                if col_data:
                    self.supabase.table("columns").update(col_data).eq("table_id", table_id).eq("idx", col_update.idx).execute()
        
        # Handle column count changes
        if config.cols is not None:
            current_result = self.supabase.table("columns").select("idx").eq("table_id", table_id).execute()
            current_cols = len(current_result.data)
            
            if config.cols > current_cols:
                # Add new columns
                new_columns = []
                for i in range(current_cols, config.cols):
                    new_columns.append({
                        "table_id": table_id,
                        "idx": i,
                        "header": f"Column {i + 1}",
                        "width": None,
                        "today_hint": False,
                    })
                if new_columns:
                    self.supabase.table("columns").insert(new_columns).execute()
            
            elif config.cols < current_cols:
                # Remove excess columns and their cells
                self.supabase.table("columns").delete().eq("table_id", table_id).gte("idx", config.cols).execute()
                self.supabase.table("cells").delete().eq("table_id", table_id).gte("c", config.cols).execute()
        
        return {
            "success": True,
            "message": "Configuration updated successfully",
            "limits": {
                "max_rows": settings.table_row_limit,
                "max_cols": settings.table_col_limit
            }
        }
