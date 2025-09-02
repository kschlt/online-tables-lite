import os
import hashlib
import secrets
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import socketio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy import String, Integer, DateTime, Text, select, func
from datetime import datetime
import asyncpg
from dotenv import load_dotenv

load_dotenv()

class Base(DeclarativeBase):
    pass

class Table(Base):
    __tablename__ = "tables"
    
    id: Mapped[str] = mapped_column(String, primary_key=True)
    slug: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    title: Mapped[Optional[str]] = mapped_column(Text)
    description: Mapped[Optional[str]] = mapped_column(Text)
    cols: Mapped[int] = mapped_column(Integer, default=4)
    rows: Mapped[int] = mapped_column(Integer, default=10)
    edit_token_hash: Mapped[str] = mapped_column(Text, nullable=False)
    admin_token_hash: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    last_activity_at: Mapped[datetime] = mapped_column(DateTime, default=func.now())
    deleted_at: Mapped[Optional[datetime]] = mapped_column(DateTime)

class Column(Base):
    __tablename__ = "columns"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    table_id: Mapped[str] = mapped_column(String, nullable=False)
    idx: Mapped[int] = mapped_column(Integer, nullable=False)
    header: Mapped[Optional[str]] = mapped_column(Text)
    width: Mapped[Optional[int]] = mapped_column(Integer)
    today_hint: Mapped[bool] = mapped_column(Integer, default=False)

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

# Database setup
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is required")

engine = create_async_engine(DATABASE_URL)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

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

async def get_db():
    async with async_session() as session:
        yield session

async def verify_token(table_slug: str, token: str, db: AsyncSession) -> tuple[Table, str]:
    """Verify token and return table with role"""
    if not token:
        raise HTTPException(status_code=401, detail="Token required")
    
    # Redact token from any potential logging
    token_hash = hash_token(token)
    
    stmt = select(Table).where(Table.slug == table_slug, Table.deleted_at.is_(None))
    result = await db.execute(stmt)
    table = result.scalar_one_or_none()
    
    if not table:
        raise HTTPException(status_code=404, detail="Table not found")
    
    if table.admin_token_hash == token_hash:
        return table, "admin"
    elif table.edit_token_hash == token_hash:
        return table, "editor"
    else:
        raise HTTPException(status_code=403, detail="Invalid token")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables on startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield

app = FastAPI(lifespan=lifespan)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[os.getenv("CORS_ORIGIN", "http://localhost:3000")],
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
async def create_table(request: CreateTableRequest, db: AsyncSession = Depends(get_db)):
    """Create a new table with admin and editor tokens"""
    
    # Generate tokens and slug
    slug = generate_slug()
    admin_token = generate_token()
    edit_token = generate_token()
    
    # Hash tokens for storage
    admin_token_hash = hash_token(admin_token)
    edit_token_hash = hash_token(edit_token)
    
    # Create table
    table = Table(
        id=secrets.token_urlsafe(16),
        slug=slug,
        title=request.title,
        description=request.description,
        cols=request.cols,
        rows=request.rows,
        admin_token_hash=admin_token_hash,
        edit_token_hash=edit_token_hash
    )
    
    db.add(table)
    
    # Create default columns
    for i in range(request.cols):
        column = Column(
            table_id=table.id,
            idx=i,
            header=f"Column {i + 1}"
        )
        db.add(column)
    
    await db.commit()
    
    return CreateTableResponse(
        slug=slug,
        admin_token=admin_token,
        edit_token=edit_token
    )

@app.get("/api/table/{slug}", response_model=TableResponse)
async def get_table(
    slug: str, 
    t: str = Header(..., description="Token"),
    db: AsyncSession = Depends(get_db)
):
    """Get table data with admin or editor token"""
    
    table, role = await verify_token(slug, t, db)
    
    # Get columns
    stmt = select(Column).where(Column.table_id == table.id).order_by(Column.idx)
    result = await db.execute(stmt)
    columns = result.scalars().all()
    
    columns_data = [
        {
            "idx": col.idx,
            "header": col.header,
            "width": col.width,
            "today_hint": col.today_hint
        }
        for col in columns
    ]
    
    return TableResponse(
        id=table.id,
        slug=table.slug,
        title=table.title,
        description=table.description,
        cols=table.cols,
        rows=table.rows,
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