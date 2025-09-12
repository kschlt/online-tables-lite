"""Configuration service for app-wide settings."""

import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional
from app.core.database import get_supabase_client


class ConfigService:
    """Service for managing application configuration."""

    def __init__(self):
        self.supabase = get_supabase_client()
        self._config_cache: Optional[Dict[str, Dict[str, str]]] = None
        self._app_config: Optional[Dict[str, Any]] = None

    async def load_all_config(self) -> Dict[str, Dict[str, str]]:
        """Load all configuration from database and cache it."""
        if self._config_cache is not None:
            return self._config_cache

        try:
            result = self.supabase.table("app_config").select("key, value_en, value_de").execute()
            
            config = {}
            for row in result.data:
                config[row["key"]] = {
                    "value_en": row["value_en"],
                    "value_de": row["value_de"]
                }
            
            self._config_cache = config
            return config
        except Exception as e:
            print(f"Warning: Failed to load configuration from database: {e}")
            return {}

    async def get_config_value(self, key: str, locale: str = "en") -> Optional[str]:
        """Get a configuration value by key and locale."""
        config = await self.load_all_config()
        
        if key not in config:
            return None
            
        # Try to get locale-specific value, fallback to English
        value = config[key].get(f"value_{locale}")
        if value is None:
            value = config[key].get("value_en")
            
        return value

    async def get_app_title(self, locale: str = "en") -> Optional[str]:
        """Get the application title."""
        return await self.get_config_value("app.title", locale)

    async def get_app_description(self, locale: str = "en") -> Optional[str]:
        """Get the application description."""
        return await self.get_config_value("app.description", locale)


    def _load_app_config(self) -> Dict[str, Any]:
        """Load app configuration from JSON file."""
        if self._app_config is not None:
            return self._app_config
            
        try:
            config_path = Path(__file__).parent.parent / "config" / "app.json"
            with open(config_path, 'r') as f:
                self._app_config = json.load(f)
                return self._app_config
        except Exception as e:
            print(f"Warning: Failed to load app config from JSON: {e}")
            # Return default config
            self._app_config = {
                "table": {
                    "defaultRows": 10,
                    "defaultCols": 5,
                    "defaultColumns": []
                }
            }
            return self._app_config

    async def get_default_column_config(self, locale: str = "en") -> List[Dict[str, Any]]:
        """Get default column configuration from JSON file."""
        config = self._load_app_config()
        
        try:
            columns = config.get("table", {}).get("defaultColumns", [])
            if not columns:
                return self._get_fallback_columns(locale)
                
            localized_columns = []
            for col in columns:
                header = col.get("header", {})
                localized_header = header.get(locale, header.get("en", f"Column {col.get('index', 0) + 1}"))
                localized_columns.append({
                    "index": col.get("index", 0),
                    "header": localized_header,
                    "format": col.get("format", "text")
                })
            return localized_columns
        except Exception as e:
            print(f"Warning: Invalid column config: {e}")
            return self._get_fallback_columns(locale)

    async def get_default_table_rows(self) -> int:
        """Get default number of rows for new tables."""
        config = self._load_app_config()
        return config.get("table", {}).get("defaultRows", 10)

    async def get_default_table_cols(self) -> int:
        """Get default number of columns for new tables."""
        config = self._load_app_config()
        return config.get("table", {}).get("defaultCols", 5)

    def _get_fallback_columns(self, locale: str = "en") -> List[Dict[str, Any]]:
        """Hardcoded fallback column configuration."""
        date_header = "Date" if locale == "en" else "Datum"
        
        columns = [
            {"index": 0, "header": date_header, "format": "date"}
        ]
        
        for i in range(1, 5):
            columns.append({
                "index": i,
                "header": f"No {i}",
                "format": "text"
            })
        
        return columns

    def clear_cache(self) -> None:
        """Clear the configuration cache (for testing or after updates)."""
        self._config_cache = None

    async def get_all_config_for_frontend(self) -> Dict[str, Any]:
        """Get all configuration formatted for frontend consumption."""
        config = await self.load_all_config()
        
        # Transform for frontend
        result = {}
        for key, values in config.items():
            result[key] = {
                "en": values.get("value_en"),
                "de": values.get("value_de")
            }
        
        return result