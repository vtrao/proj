"""
Test configuration and fixtures for the backend application.
"""
import pytest
import asyncio
import os
from unittest.mock import MagicMock

# Set test environment
os.environ["ENVIRONMENT"] = "test"
os.environ["DATABASE_URL"] = "sqlite:///./test.db"

@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest.fixture
def mock_database():
    """Mock database connection for testing."""
    return MagicMock()

@pytest.fixture
def sample_idea():
    """Sample idea data for testing."""
    return {
        "title": "Test Idea",
        "description": "This is a test idea",
        "category": "Technology",
        "status": "active"
    }
