import os
import asyncio
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import asyncpg

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI()

# CORS setup
origins = [os.getenv("FRONTEND_DOMAIN", "http://localhost:3000")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Content-Type", "Authorization"],
)

# Connection pool
db_pool = None

@app.on_event("startup")
async def startup():
    global db_pool
    try:
        db_pool = await asyncpg.create_pool(
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME"),
            host=os.getenv("DB_HOST"),
            port=int(os.getenv("DB_PORT")),
            min_size=1,
            max_size=5
        )
        print("✅ Database connection pool created")
    except Exception as e:
        print(f"❌ Failed to create DB pool: {e}")

@app.on_event("shutdown")
async def shutdown():
    global db_pool
    if db_pool:
        await db_pool.close()
        print("🛑 Database pool closed")

@app.get("/api")
async def api():
    return {"message": "Hello from the backend!"}

@app.get("/health")
async def health():
    return {"status": "OK"}

@app.get("/")
async def root():
    return {
        "message": "🚀 Deployment Successful!",
        "status": "running",
        "timestamp": asyncio.get_event_loop().time(),
        "origin": os.getenv("FRONTEND_DOMAIN"),
        "Database password": os.getenv("DB_PASSWORD"),
        "Database name": os.getenv("DB_NAME")
    }

@app.get("/data")
async def get_data():
    global db_pool
    try:
        async with db_pool.acquire() as conn:
            row = await conn.fetchrow("SELECT NOW() as current_time")
            return {"Date": row["current_time"], "message": "Hello from the database!"}
    except Exception as e:
        print(f"❌ Error while querying database: {e}")
        return {"error": "Server error"}
