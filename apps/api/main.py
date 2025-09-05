"""FastAPI application entry point."""
from contextlib import asynccontextmanager

import socketio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.dependencies import set_socketio_server
from app.api.v1.cells import router as cells_router
from app.api.v1.tables import router as tables_router
from app.core.config import settings

# Socket.IO setup
sio = socketio.AsyncServer(async_mode="asgi", cors_allowed_origins=settings.cors_origin)


@sio.event
async def connect(sid, environ):
    """Handle client connection."""
    print(f"Client {sid} connected")


@sio.event
async def disconnect(sid):
    """Handle client disconnection."""
    print(f"Client {sid} disconnected")


@sio.event
async def join_table(sid, data):
    """Join a table room for real-time updates."""
    table_id = data.get("table_id")
    if table_id:
        room = f"table:{table_id}"
        await sio.enter_room(sid, room)
        print(f"Client {sid} joined table room {room}")
        await sio.emit("room_joined", {"table_id": table_id}, room=sid)


@sio.event
async def leave_table(sid, data):
    """Leave a table room."""
    table_id = data.get("table_id")
    if table_id:
        room = f"table:{table_id}"
        await sio.leave_room(sid, room)
        print(f"Client {sid} left table room {room}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    # Startup
    print("🚀 FastAPI server starting up...")
    yield
    # Shutdown
    print("⏹️ FastAPI server shutting down...")


def create_app() -> FastAPI:
    """Create and configure FastAPI application."""
    app = FastAPI(
        title="Online Tables Lite API",
        description="Collaborative table editing with real-time synchronization",
        version="1.0.0",
        lifespan=lifespan,
    )

    # CORS middleware
    cors_origins = [settings.cors_origin]
    if settings.cors_origin.endswith("/"):
        cors_origins.append(settings.cors_origin.rstrip("/"))
    else:
        cors_origins.append(settings.cors_origin + "/")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Health check endpoint
    @app.get("/healthz")
    async def health_check():
        return {"status": "healthy"}

    # API routes
    app.include_router(tables_router, prefix="/api/v1")
    app.include_router(cells_router, prefix="/api/v1")

    return app


# Create app instance
app = create_app()

# Set global socketio server reference
set_socketio_server(sio)

# Create Socket.IO ASGI app
socket_app = socketio.ASGIApp(sio, app)


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:socket_app", host="0.0.0.0", port=8000, reload=True)
