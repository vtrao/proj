from fastapi import FastAPI, Request
from pydantic import BaseModel
import psycopg2
from typing import List
from datetime import datetime
import os
import time

app = FastAPI()

# Build DATABASE_URL from individual components
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_NAME = os.getenv("DB_NAME", "appdb")
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:5432/{DB_NAME}"

class Idea(BaseModel):
    id: int = None
    content: str
    created_at: datetime = None

def get_db_connection():
    # Add retry logic for database connection
    max_retries = 5
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            conn = psycopg2.connect(DATABASE_URL)
            return conn
        except psycopg2.OperationalError as e:
            retry_count += 1
            if retry_count >= max_retries:
                raise e
            print(f"Database connection attempt {retry_count} failed. Retrying in 2 seconds...")
            time.sleep(2)

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/api/ideas", response_model=List[Idea])
def list_ideas():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, content, created_at FROM ideas ORDER BY created_at DESC;")
    ideas = [Idea(id=r[0], content=r[1], created_at=r[2]) for r in cur.fetchall()]
    cur.close()
    conn.close()
    return ideas

@app.post("/api/ideas", response_model=Idea)
def add_idea(idea: Idea):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO ideas (content, created_at) VALUES (%s, %s) RETURNING id, created_at;",
                (idea.content, datetime.utcnow()))
    row = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return Idea(id=row[0], content=idea.content, created_at=row[1])

