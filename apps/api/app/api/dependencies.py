"""Shared API dependencies."""
from typing import Optional

import socketio

from app.services.table_service import TableService

# Global reference to the socketio server (set by main.py)
_socketio_server: Optional[socketio.AsyncServer] = None


def set_socketio_server(server: socketio.AsyncServer) -> None:
    """Set the global socketio server reference."""
    global _socketio_server
    _socketio_server = server


def get_socketio_server() -> socketio.AsyncServer:
    """Get the socketio server instance."""
    if _socketio_server is None:
        raise RuntimeError("SocketIO server not initialized")
    return _socketio_server


def get_table_service() -> TableService:
    """Get table service instance."""
    return TableService()
