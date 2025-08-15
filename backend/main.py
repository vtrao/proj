from fastapi import FastAPI, Request
from pydantic import BaseModel
import psycopg2
from typing import List
from datetime import datetime
import os

app = FastAPI()

DATABASE_URL = os.getenv("DATABASE_URL", "dbname=ideas_db user=postgres password=postgres host=db")

class Idea(BaseModel):
    id: int = None
    content: str
    created_at: datetime = None

def get_db_connection():
    conn = psycopg2.connect(DATABASE_URL)
    return conn

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

