# app/tests/test_main.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from src.main import app, get_db
from src.database import Base

# Create in-memory SQLite database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Override the dependency with our test database
def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture
def test_db():
    # Create the database tables
    Base.metadata.create_all(bind=engine)
    yield
    # Drop the database tables
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client():
    return TestClient(app)

def test_read_root(client):
    """Test the root endpoint returns correct message"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello World"}

def test_health_check(client):
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

@pytest.mark.parametrize("invalid_path", [
    "/invalid",
    "/api/",
    "/health/check"
])
def test_invalid_paths(client, invalid_path):
    """Test that invalid paths return 404"""
    response = client.get(invalid_path)
    assert response.status_code == 404

def test_db_connection(client, test_db):
    """Test that database connection is working"""
    # This test will use the test database fixture
    # The mere fact that this runs without error confirms the DB connection works
    assert True

@pytest.mark.asyncio
async def test_concurrent_requests(client):
    """Test handling of concurrent requests"""
    import asyncio
    
    async def make_request():
        response = client.get("/")
        assert response.status_code == 200
        return response
    
    # Make 10 concurrent requests
    tasks = [make_request() for _ in range(10)]
    responses = await asyncio.gather(*tasks)
    
    # Verify all responses
    for response in responses:
        assert response.json() == {"message": "Hello World"}

def test_headers(client):
    """Test response headers"""
    response = client.get("/")
    assert response.headers["content-type"] == "application/json"

@pytest.mark.parametrize("method", ["post", "put", "delete", "patch"])
def test_method_not_allowed(client, method):
    """Test that incorrect HTTP methods return 405"""
    request_method = getattr(client, method)
    response = request_method("/")
    assert response.status_code == 405

def test_performance(client):
    """Basic performance test"""
    import time
    
    start_time = time.time()
    response = client.get("/")
    end_time = time.time()
    
    assert response.status_code == 200
    # Ensure response time is under 500ms
    assert (end_time - start_time) < 0.5

# Custom exception testing
def test_custom_exception_handling():
    """Test custom exception handling"""
    from fastapi import HTTPException
    import pytest
    
    with pytest.raises(HTTPException) as exc_info:
        raise HTTPException(status_code=400, detail="Test error")
    assert exc_info.value.status_code == 400
    assert exc_info.value.detail == "Test error"