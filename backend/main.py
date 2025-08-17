from fastapi import FastAPI, Request
from pydantic import BaseModel
import psycopg2
from typing import List
from datetime import datetime
import os
import time
import requests

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

def detect_cloud_provider():
    """
    Detect the cloud provider by checking metadata services and environment variables.
    Returns: str - 'aws', 'azure', or 'unknown'
    """
    # Check environment variable first (can be set in deployment)
    cloud_provider = os.getenv("CLOUD_PROVIDER", "").lower()
    if cloud_provider in ["aws", "azure", "gcp"]:
        return cloud_provider
    
    try:
        # Try AWS metadata service (with timeout)
        response = requests.get(
            "http://169.254.169.254/latest/meta-data/instance-id", 
            timeout=2,
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"}
        )
        if response.status_code == 200:
            return "aws"
    except:
        pass
    
    try:
        # Try Azure metadata service (with timeout)
        response = requests.get(
            "http://169.254.169.254/metadata/instance?api-version=2021-02-01",
            timeout=2,
            headers={"Metadata": "true"}
        )
        if response.status_code == 200:
            return "azure"
    except:
        pass
    
    try:
        # Try GCP metadata service (with timeout)
        response = requests.get(
            "http://metadata.google.internal/computeMetadata/v1/instance/id",
            timeout=2,
            headers={"Metadata-Flavor": "Google"}
        )
        if response.status_code == 200:
            return "gcp"
    except:
        pass
    
    # Check for Kubernetes environment variables that might indicate cloud provider
    if os.getenv("AWS_REGION"):
        return "aws"
    elif os.getenv("AZURE_RESOURCE_GROUP"):
        return "azure"
    
    return "unknown"

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
    """
    Health check endpoint for load balancers and monitoring.
    Tests database connectivity and returns system status.
    """
    try:
        # Test database connection
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT 1")
        cur.fetchone()
        cur.close()
        conn.close()
        
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "database": "connected",
            "version": "1.0.0"
        }
    except Exception as e:
        return {
            "status": "unhealthy", 
            "timestamp": datetime.utcnow().isoformat(),
            "database": "disconnected",
            "error": str(e),
            "version": "1.0.0"
        }

@app.get("/")
def root():
    """Root endpoint with basic API information."""
    return {
        "message": "Proj API Server",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }

@app.get("/api/cloud-info")
def get_cloud_info():
    """
    Get cloud provider information and deployment details.
    """
    cloud_provider = detect_cloud_provider()
    
    return {
        "cloud_provider": cloud_provider,
        "region": os.getenv("AWS_REGION") or os.getenv("AZURE_REGION") or "unknown",
        "environment": os.getenv("ENVIRONMENT", "dev"),
        "timestamp": datetime.utcnow().isoformat()
    }

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

if __name__ == "__main__":
    import uvicorn
    
    # Get configuration from environment
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", "8000"))
    
    print(f"🚀 Starting Proj API server on {host}:{port}")
    print(f"📊 Health check: http://{host}:{port}/health")
    print(f"📖 API docs: http://{host}:{port}/docs")
    
    uvicorn.run(app, host=host, port=port)

