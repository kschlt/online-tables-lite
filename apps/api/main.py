"""FastAPI application entry point."""

from contextlib import asynccontextmanager

import socketio
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse, Response

from app.api.dependencies import set_socketio_server
from app.api.v1.cells import router as cells_router
from app.api.v1.tables import router as tables_router
from app.core.config import settings
from app.core.logging import RequestLoggingMiddleware, setup_logging

# Socket.IO setup - environment-aware CORS origins
cors_origins = settings.cors_origins

sio = socketio.AsyncServer(async_mode="asgi", cors_allowed_origins=cors_origins)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Add security headers to responses."""

    async def dispatch(self, request: Request, call_next):
        response: Response = await call_next(request)

        # Security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"

        # HSTS only in production
        if settings.environment == "production":
            response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"

        return response


@sio.event
async def connect(sid, environ):
    """Handle client connection."""
    import logging

    logger = logging.getLogger("api.socketio")
    logger.info("Socket.IO client connected", extra={"extra_fields": {"client_id": sid}})


@sio.event
async def disconnect(sid):
    """Handle client disconnection."""
    import logging

    logger = logging.getLogger("api.socketio")
    logger.info("Socket.IO client disconnected", extra={"extra_fields": {"client_id": sid}})


@sio.event
async def join_table(sid, data):
    """Join a table room for real-time updates."""
    table_id = data.get("table_id")
    if table_id:
        room = f"table:{table_id}"
        await sio.enter_room(sid, room)
        await sio.emit("room_joined", {"table_id": table_id}, room=sid)

        import logging

        logger = logging.getLogger("api.socketio")
        logger.info(
            "Client joined table room",
            extra={"extra_fields": {"client_id": sid, "table_id": table_id, "room": room}},
        )


@sio.event
async def leave_table(sid, data):
    """Leave a table room."""
    table_id = data.get("table_id")
    if table_id:
        room = f"table:{table_id}"
        await sio.leave_room(sid, room)

        import logging

        logger = logging.getLogger("api.socketio")
        logger.info(
            "Client left table room",
            extra={"extra_fields": {"client_id": sid, "table_id": table_id, "room": room}},
        )


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    import logging

    logger = logging.getLogger("api.startup")

    # Startup
    logger.info(
        "FastAPI server starting up",
        extra={
            "extra_fields": {
                "environment": settings.environment,
                "cors_origins_count": len(settings.cors_origins),
            }
        },
    )
    yield
    # Shutdown
    logger.info("FastAPI server shutting down")


def create_app() -> FastAPI:
    """Create and configure FastAPI application."""
    # Setup structured logging
    setup_logging(settings.environment)

    app = FastAPI(
        title="Online Tables Lite API",
        description="Collaborative table editing with real-time synchronization",
        version="1.0.0",
        lifespan=lifespan,
        max_request_size=1024 * 1024,  # 1MB limit
    )

    # Add exception handlers
    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        """Handle Pydantic validation errors with detailed messages."""
        import logging

        logger = logging.getLogger("api.validation")

        logger.error(
            "Validation error",
            extra={
                "extra_fields": {
                    "url": str(request.url),
                    "method": request.method,
                    "errors": exc.errors(),
                    "body": await request.body()
                    if request.method in ["POST", "PUT", "PATCH"]
                    else None,
                }
            },
        )

        return JSONResponse(
            status_code=422,
            content={
                "detail": "Validation error",
                "errors": exc.errors(),
                "message": "Please check your request format and field types",
            },
        )

    @app.exception_handler(ValueError)
    async def value_error_handler(request: Request, exc: ValueError):
        """Handle ValueError exceptions."""
        import logging

        logger = logging.getLogger("api.error")

        logger.error(
            "Value error",
            extra={
                "extra_fields": {
                    "url": str(request.url),
                    "method": request.method,
                    "error": str(exc),
                }
            },
        )

        return JSONResponse(
            status_code=400, content={"detail": str(exc), "message": "Invalid input value"}
        )

    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception):
        """Handle unexpected exceptions."""
        import logging

        logger = logging.getLogger("api.error")

        logger.error(
            "Unexpected error",
            extra={
                "extra_fields": {
                    "url": str(request.url),
                    "method": request.method,
                    "error": str(exc),
                    "type": type(exc).__name__,
                }
            },
            exc_info=exc,
        )

        return JSONResponse(
            status_code=500,
            content={"detail": "Internal server error", "message": "An unexpected error occurred"},
        )

    # Request logging middleware (must be first for proper timing)
    app.add_middleware(RequestLoggingMiddleware)

    # Security headers middleware
    app.add_middleware(SecurityHeadersMiddleware)

    # Security middleware
    app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.trusted_hosts)

    # CORS middleware
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
        """Enhanced health check with connectivity tests."""
        import logging
        import time

        import fastapi
        import pydantic
        import uvicorn

        from app.core.database import get_supabase_client

        logger = logging.getLogger("api.health")
        health_status = {
            "status": "healthy",
            "timestamp": time.time(),
            "environment": settings.environment,
            "version": {
                "api": "1.0.0",
                "fastapi": fastapi.__version__,
                "pydantic": pydantic.__version__,
                "uvicorn": uvicorn.__version__,
            },
        }

        # Test database connectivity
        try:
            supabase = get_supabase_client()
            # Simple query to test connection
            supabase.table("tables").select("id").limit(1).execute()
            health_status["database"] = {
                "status": "connected",
                "response_time_ms": 0,  # Could add timing if needed
            }
            logger.info("Health check - database connected")
        except Exception as e:
            health_status["database"] = {"status": "error", "error": str(e)}
            health_status["status"] = "degraded"
            logger.error("Health check - database connection failed", exc_info=e)

        # Test Socket.IO server
        try:
            if sio and hasattr(sio, "manager"):
                # Get client count safely
                try:
                    client_count = len(sio.manager.rooms.get("/", {}))
                except (AttributeError, KeyError):
                    client_count = 0

                health_status["socketio"] = {"status": "running", "connected_clients": client_count}
                logger.info("Health check - Socket.IO server running")
            else:
                health_status["socketio"] = {"status": "not_initialized"}
                logger.warning("Health check - Socket.IO not initialized")
        except Exception as e:
            health_status["socketio"] = {"status": "error", "error": str(e)}
            logger.error("Health check - Socket.IO check failed", exc_info=e)

        return health_status

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
    import os
    import uvicorn

    # Environment-aware port configuration
    port = int(os.getenv("PORT", "8000"))  # Default to 8000 for local dev, Fly.io sets PORT=8080
    host = os.getenv("HOST", "0.0.0.0")    # Always bind to all interfaces for containerized deployments
    reload = os.getenv("ENVIRONMENT", "development") == "development"
    
    print(f"🚀 Starting server on {host}:{port} (reload={reload})")
    uvicorn.run("main:socket_app", host=host, port=port, reload=reload)
