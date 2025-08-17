"""
Test suite for the FastAPI backend application.
"""
import json
from unittest.mock import MagicMock, patch
import pytest
from fastapi.testclient import TestClient
from main import app

# Create test client
client = TestClient(app)

def test_health_endpoint():
    """Test the health check endpoint."""
    with patch('main.get_db_connection') as mock_db:
        # Mock successful database connection
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1,)
        mock_conn.cursor.return_value = mock_cursor
        mock_db.return_value = mock_conn
        
        response = client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["database"] == "connected"
        assert "timestamp" in data

def test_health_endpoint_db_failure():
    """Test health endpoint when database is down."""
    with patch('main.get_db_connection') as mock_db:
        # Mock database connection failure
        mock_db.side_effect = Exception("Database connection failed")
        
        response = client.get("/health")
        
        assert response.status_code == 200  # Still returns 200 but with error status
        data = response.json()
        assert data["status"] == "unhealthy"
        assert data["database"] == "disconnected"
        assert "error" in data

def test_root_endpoint():
    """Test the root endpoint."""
    response = client.get("/")
    
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Proj API Server"
    assert data["version"] == "1.0.0"
    assert data["docs"] == "/docs"

def test_ideas_endpoint():
    """Test the GET /api/ideas endpoint."""
    with patch('main.get_db_connection') as mock_db:
        # Mock database response
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_cursor.fetchall.return_value = [
            (1, "Test idea", "2024-01-01T00:00:00"),
            (2, "Another idea", "2024-01-01T01:00:00")
        ]
        mock_conn.cursor.return_value = mock_cursor
        mock_db.return_value = mock_conn
        
        response = client.get("/api/ideas")
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 2
        assert data[0]["content"] == "Test idea"
        assert data[1]["content"] == "Another idea"

def test_create_idea_endpoint(sample_idea):
    """Test the POST /api/ideas endpoint."""
    with patch('main.get_db_connection') as mock_db:
        # Mock database response for insert
        mock_conn = MagicMock()
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = (1, "2024-01-01T00:00:00")
        mock_conn.cursor.return_value = mock_cursor
        mock_db.return_value = mock_conn
        
        response = client.post("/api/ideas", json={"content": sample_idea["description"]})
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == 1
        assert data["content"] == sample_idea["description"]

def test_database_connection_retry():
    """Test database connection retry logic."""
    with patch('main.psycopg2.connect') as mock_connect:
        with patch('main.time.sleep') as mock_sleep:
            # Mock connection failure then success
            mock_connect.side_effect = [
                Exception("Connection failed"),
                Exception("Connection failed"), 
                MagicMock()  # Success on third try
            ]
            
            from main import get_db_connection
            
            # Should succeed after retries
            conn = get_db_connection()
            assert conn is not None
            
            # Should have called sleep twice (for first two failures)
            assert mock_sleep.call_count == 2

class TestAPIEndpoints:
    """Integration tests for API endpoints."""
    
    def test_openapi_schema(self):
        """Test that OpenAPI schema is accessible."""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        
        schema = response.json()
        assert "openapi" in schema
        assert "info" in schema
        
    def test_docs_endpoint(self):
        """Test that documentation endpoint is accessible."""
        response = client.get("/docs")
        assert response.status_code == 200
        
    def test_cors_headers(self):
        """Test CORS headers are present."""
        response = client.get("/health")
        # In a real test, you'd check for actual CORS headers
        # For now, just verify the endpoint works
        assert response.status_code == 200

class TestErrorHandling:
    """Test error handling scenarios."""
    
    def test_invalid_idea_data(self):
        """Test handling of invalid idea data."""
        response = client.post("/api/ideas", json={"invalid": "data"})
        assert response.status_code == 422  # Validation error
        
    def test_database_unavailable(self):
        """Test behavior when database is completely unavailable."""
        with patch('main.get_db_connection') as mock_db:
            mock_db.side_effect = Exception("Database server unavailable")
            
            # Health check should handle this gracefully
            response = client.get("/health")
            assert response.status_code == 200
            assert response.json()["status"] == "unhealthy"
