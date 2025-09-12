"""Configuration endpoints."""

from fastapi import APIRouter, Depends
from typing import Any, Dict

from app.api.dependencies import get_config_service
from app.services.config_service import ConfigService

router = APIRouter(prefix="/config", tags=["config"])


@router.get("", response_model=Dict[str, Any])
async def get_config(
    config_service: ConfigService = Depends(get_config_service),
):
    """Get all application configuration for frontend."""
    return await config_service.get_all_config_for_frontend()



@router.get("/{key}")
async def get_config_value(
    key: str,
    locale: str = "en",
    config_service: ConfigService = Depends(get_config_service),
):
    """Get a specific configuration value by key."""
    value = await config_service.get_config_value(key, locale)
    if value is None:
        return {"error": f"Configuration key '{key}' not found"}
    
    return {"key": key, "value": value, "locale": locale}