import os
import hashlib
import secrets
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import socketio
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

# Pydantic models
class CreateTableRequest(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    cols: int = 4
    rows: int = 10

class CreateTableResponse(BaseModel):
    slug: str
    admin_token: str
    edit_token: str

class TableResponse(BaseModel):
    id: str
    slug: str
    title: Optional[str]
    description: Optional[str]
    cols: int
    rows: int
    columns: list[dict]

# Supabase setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
    raise ValueError("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables are required")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

# Socket.IO setup
sio = socketio.AsyncServer(async_mode='asgi', cors_allowed_origins=os.getenv("CORS_ORIGIN", "*"))

def hash_token(token: str) -> str:
    """Hash token with SHA-256"""
    return hashlib.sha256(token.encode()).hexdigest()

def generate_slug() -> str:
    """Generate a random slug"""
    return secrets.token_urlsafe(8)

def generate_token() -> str:
    """Generate a secure token"""
    return secrets.token_urlsafe(32)

async def verify_token(table_slug: str, token: str) -> tuple[dict, str]:
    """Verify token and return table with role"""
    if not token:
        raise HTTPException(status_code=401, detail="Token required")
    
    # Redact token from any potential logging
    token_hash = hash_token(token)
    
    # Get table from Supabase
    result = supabase.table("tables").select("*").eq("slug", table_slug).is_("deleted_at", "null").execute()
    
    if not result.data:
        raise HTTPException(status_code=404, detail="Table not found")
    
    table = result.data[0]
    
    if table["admin_token_hash"] == token_hash:
        return table, "admin"
    elif table["edit_token_hash"] == token_hash:
        return table, "editor"
    else:
        raise HTTPException(status_code=403, detail="Invalid token")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Tables will be created via Supabase SQL editor
    yield

app = FastAPI(lifespan=lifespan)

# CORS middleware - handle both with/without trailing slash
cors_origin = os.getenv("CORS_ORIGIN", "http://localhost:3000")
allowed_origins = [cors_origin]
if cors_origin.endswith("/"):
    allowed_origins.append(cors_origin.rstrip("/"))
else:
    allowed_origins.append(cors_origin + "/")

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Socket.IO app
socket_app = socketio.ASGIApp(sio, app)

@app.get("/healthz")
async def health_check():
    return {"status": "healthy"}

@app.post("/api/table", response_model=CreateTableResponse)
async def create_table(request: CreateTableRequest):
    """Create a new table with admin and editor tokens"""
    
    # Generate tokens and slug
    slug = generate_slug()
    admin_token = generate_token()
    edit_token = generate_token()
    
    # Hash tokens for storage
    admin_token_hash = hash_token(admin_token)
    edit_token_hash = hash_token(edit_token)
    
    # Create table in Supabase (let UUID be auto-generated)
    table_data = {
        "slug": slug,
        "title": request.title,
        "description": request.description,
        "cols": request.cols,
        "rows": request.rows,
        "admin_token_hash": admin_token_hash,
        "edit_token_hash": edit_token_hash
    }
    
    table_result = supabase.table("tables").insert(table_data).execute()
    table_id = table_result.data[0]["id"]
    
    # Create default columns
    columns_data = [
        {
            "table_id": table_id,
            "idx": i,
            "header": f"Column {i + 1}",
            "width": None,
            "today_hint": False
        }
        for i in range(request.cols)
    ]
    
    supabase.table("columns").insert(columns_data).execute()
    
    return CreateTableResponse(
        slug=slug,
        admin_token=admin_token,
        edit_token=edit_token
    )

@app.get("/api/table/{slug}", response_model=TableResponse)
async def get_table(
    slug: str, 
    t: str = Header(..., description="Token", alias="t")
):
    """Get table data with admin or editor token"""
    
    table, role = await verify_token(slug, t)
    
    # Get columns from Supabase
    columns_result = supabase.table("columns").select("*").eq("table_id", table["id"]).order("idx").execute()
    
    columns_data = [
        {
            "idx": col["idx"],
            "header": col["header"],
            "width": col["width"],
            "today_hint": col["today_hint"]
        }
        for col in columns_result.data
    ]
    
    return TableResponse(
        id=table["id"],
        slug=table["slug"],
        title=table["title"],
        description=table["description"],
        cols=table["cols"],
        rows=table["rows"],
        columns=columns_data
    )

@sio.event
async def connect(sid, environ):
    print(f"Client {sid} connected")

@sio.event
async def disconnect(sid):
    print(f"Client {sid} disconnected")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:socket_app", host="0.0.0.0", port=8000, reload=True)