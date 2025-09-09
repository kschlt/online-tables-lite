"""Cell management endpoints."""
from fastapi import APIRouter, Depends, HTTPException

from app.api.dependencies import get_socketio_server, get_table_service
from app.core.security import extract_bearer_token, verify_token
from app.models.table import CellBatchUpdateRequest
from app.services.table_service import TableService

router = APIRouter(prefix="/tables", tags=["cells"])

# We'll get the socketio server from main module when needed
sio = None


@router.post("/{slug}/cells")
async def update_cells(
    slug: str,
    request: CellBatchUpdateRequest,
    table_service: TableService = Depends(get_table_service),
    authorization: str = Depends(extract_bearer_token),
):
    """Batch update cells in a table."""
    table, role = await verify_token(slug, authorization)

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

    # Log the real-time update
    import logging
    logger = logging.getLogger("api.realtime")
    logger.info("Cell update broadcast", extra={
        "extra_fields": {
            "table_id": table["id"],
            "room": room,
            "cells_updated": len(cell_updates)
        }
    })

    return {"success": True, "updated_cells": len(request.cells)}


@router.get("/{slug}/cells")
async def get_cells(
    slug: str,
    table_service: TableService = Depends(get_table_service),
    authorization: str = Depends(extract_bearer_token),
):
    """Get all cell data for a table."""
    table, role = await verify_token(slug, authorization)
    cells = await table_service.get_cells(table["id"])
    return {"cells": cells}
