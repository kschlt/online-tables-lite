"""Application configuration settings."""
import os

from dotenv import load_dotenv
from pydantic import BaseModel

load_dotenv()


class Settings(BaseModel):
    """Application settings."""

    # Database
    supabase_url: str = os.getenv("SUPABASE_URL", "")
    supabase_service_role_key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")

    # CORS
    cors_origin: str = os.getenv("CORS_ORIGIN", "http://localhost:3000")
    environment: str = os.getenv("ENVIRONMENT", "development")

    @property
    def cors_origins(self) -> list[str]:
        """Get CORS origins based on environment."""
        origins = [self.cors_origin]

        # Handle trailing slash variations
        if self.cors_origin.endswith("/"):
            origins.append(self.cors_origin.rstrip("/"))
        else:
            origins.append(self.cors_origin + "/")

        # Add development origins only in development
        if self.environment == "development":
            origins.extend([
                "http://localhost:3000",
                "http://localhost:3001",
                "http://localhost:3002",
            ])

        return origins

    @property
    def trusted_hosts(self) -> list[str]:
        """Get trusted hosts based on environment."""
        if self.environment == "production":
            # Production hosts - customize for your deployment
            return [
                "online-table-lite-api.fly.dev",  # Fly.io app domain
                "*.vercel.app",      # Vercel preview domains
            ]
        else:
            # Development - allow localhost and test hosts
            return ["localhost", "127.0.0.1", "0.0.0.0", "testserver"]

    # Table limits
    table_row_limit: int = int(os.getenv("TABLE_ROW_LIMIT", "500"))
    table_col_limit: int = int(os.getenv("TABLE_COL_LIMIT", "64"))

    # CSV settings
    csv_delimiter: str = os.getenv("CSV_DELIMITER", ";")
    csv_max_mb: int = int(os.getenv("CSV_MAX_MB", "5"))
    allow_editor_export: bool = os.getenv("ALLOW_EDITOR_EXPORT", "false").lower() == "true"
    allow_editor_import: bool = os.getenv("ALLOW_EDITOR_IMPORT", "false").lower() == "true"

    def validate_required_settings(self) -> None:
        """Validate that required settings are present."""
        if not self.supabase_url:
            raise ValueError("SUPABASE_URL environment variable is required")
        if not self.supabase_service_role_key:
            raise ValueError("SUPABASE_SERVICE_ROLE_KEY environment variable is required")


settings = Settings()
settings.validate_required_settings()
