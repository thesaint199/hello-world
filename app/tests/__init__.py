# app/tests/__init__.py
import sys
import os

# Add the src directory to the Python path for testing
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../src')))

# Test configuration
TEST_DATABASE_URL = "postgresql://test_user:test_password@localhost:5432/test_db"