# app/src/__init__.py
from .main import app
from .database import Base, engine, SessionLocal
from .config import DATABASE_URL

__version__ = "0.1.0"
__author__ = "HelloWorld Team"

# Export commonly used components
__all__ = ['app', 'Base', 'engine', 'SessionLocal', 'DATABASE_URL']