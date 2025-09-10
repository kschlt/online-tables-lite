"""Structured logging configuration with request IDs."""
import json
import logging
import time
import uuid
from contextvars import ContextVar
from typing import Any

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

# Context variable to store request ID
request_id_context: ContextVar[str] = ContextVar('request_id', default='')


class JSONFormatter(logging.Formatter):
    """Custom JSON formatter for structured logging."""

    def format(self, record: logging.LogRecord) -> str:
        """Format log record as JSON."""
        log_data: dict[str, Any] = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "request_id": request_id_context.get(''),
        }

        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        # Add extra fields if present
        if hasattr(record, 'extra_fields'):
            log_data.update(record.extra_fields)

        return json.dumps(log_data, ensure_ascii=False)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log requests and responses with unique IDs."""

    async def dispatch(self, request: Request, call_next):
        """Process request with logging."""
        # Generate unique request ID
        request_id = str(uuid.uuid4())
        request_id_context.set(request_id)

        # Start timing
        start_time = time.time()

        # Log request
        logger = logging.getLogger("api.request")
        logger.info("Request started", extra={
            "extra_fields": {
                "method": request.method,
                "url": str(request.url),
                "client_ip": request.client.host if request.client else None,
                "user_agent": request.headers.get("user-agent"),
                "request_id": request_id,
            }
        })

        # Process request
        response = await call_next(request)

        # Calculate duration
        duration = time.time() - start_time

        # Log response
        logger.info("Request completed", extra={
            "extra_fields": {
                "method": request.method,
                "url": str(request.url),
                "status_code": response.status_code,
                "duration_ms": round(duration * 1000, 2),
                "request_id": request_id,
            }
        })

        # Add request ID to response headers for debugging
        response.headers["X-Request-ID"] = request_id

        return response


def setup_logging(environment: str = "development") -> None:
    """Configure structured logging."""
    # Set log level based on environment
    log_level = logging.DEBUG if environment == "development" else logging.INFO

    # Remove existing handlers
    root_logger = logging.getLogger()
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)

    # Create console handler with JSON formatter
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(JSONFormatter())

    # Configure root logger
    root_logger.setLevel(log_level)
    root_logger.addHandler(console_handler)

    # Reduce noise from third-party libraries
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("fastapi").setLevel(logging.INFO)


def get_logger(name: str) -> logging.Logger:
    """Get logger with structured format."""
    return logging.getLogger(name)


def log_error(logger: logging.Logger, message: str, error: Exception, **extra_fields) -> None:
    """Log error with structured format and request context."""
    logger.error(message, exc_info=error, extra={
        "extra_fields": {
            "error_type": type(error).__name__,
            "error_message": str(error),
            "request_id": request_id_context.get(''),
            **extra_fields
        }
    })


def log_info(logger: logging.Logger, message: str, **extra_fields) -> None:
    """Log info with structured format and request context."""
    logger.info(message, extra={
        "extra_fields": {
            "request_id": request_id_context.get(''),
            **extra_fields
        }
    })

    # Fix: Suppress HTTP/2 and HPACK debug logs that are causing spam
    logging.getLogger("hpack.hpack").setLevel(logging.WARNING)
    logging.getLogger("httpcore.http2").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.INFO)

    # Suppress Socket.IO debug logs
    logging.getLogger("socketio").setLevel(logging.INFO)
    logging.getLogger("engineio").setLevel(logging.INFO)

    # Keep our API logs at appropriate levels
    logging.getLogger("api.request").setLevel(logging.INFO)
    logging.getLogger("api.socketio").setLevel(logging.INFO)
    logging.getLogger("api.error").setLevel(logging.ERROR)
