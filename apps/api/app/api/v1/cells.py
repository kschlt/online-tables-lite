"""Cell management endpoints."""
from fastapi import APIRouter, Depends, Header, HTTPException

from app.api.dependencies import get_table_service, get_socketio_server
from app.core.security import verify_token
from app.models.table import CellBatchUpdateRequest
from app.services.table_service import TableService

router = APIRouter(prefix="/tables", tags=["cells"])

# We'll get the socketio server from main module when needed
sio = None


@router.post("/{slug}/cells")
async def update_cells(
    slug: str,
    request: CellBatchUpdateRequest,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Batch update cells in a table."""
    table, role = await verify_token(slug, t)
    
    # Only admin and editor can update cells
    if role not in ["admin", "editor"]:
        raise HTTPException(status_code=403, detail="Insufficient permissions")
    
    # Update cells in database
    await table_service.update_cells(table["id"], request.cells)
    
    # Emit real-time update to other clients in the table room
    sio = get_socketio_server()
    room = f"table:{table['id']}"
    cell_updates = [{"row": cell.row, "col": cell.col, "value": cell.value} for cell in request.cells]
    
    await sio.emit("cell_update", {
        "table_id": table["id"],
        "cells": cell_updates
    }, room=room)
    
    print(f"Emitted cell update to room {room}: {len(cell_updates)} cells")
    
    return {"success": True, "updated_cells": len(request.cells)}


@router.get("/{slug}/cells")
async def get_cells(
    slug: str,
    t: str = Header(..., description="Token", alias="t"),
    table_service: TableService = Depends(get_table_service),
):
    """Get all cell data for a table."""
    table, role = await verify_token(slug, t)
    cells = await table_service.get_cells(table["id"])
    return {"cells": cells}