#!/bin/bash

# Exit on any error
set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to log warnings
warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Function to log errors
error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        error "Python 3 is required but not installed"
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is required but not installed"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is required but not installed"
    fi
    
    # Check Node.js (for infrastructure)
    if ! command -v node &> /dev/null; then
        error "Node.js is required but not installed"
    fi
    
    log "All system requirements met"
}

# Setup Python virtual environment
setup_python_env() {
    log "Setting up Python virtual environment..."
    
    # Create venv if it doesn't exist
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate || source venv/Scripts/activate
    
    # Install requirements
    cd app
    pip install -r requirements.txt
    cd ..
    
    log "Python environment setup complete"
}

# Setup local database
setup_database() {
    log "Setting up local database..."
    
    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        cat > .env << EOL
DATABASE_URL=postgresql://user:password@localhost:5432/hello_db
ENVIRONMENT=development
DEBUG=true
EOL
    fi
    
    # Start PostgreSQL container
    docker-compose up -d db
    
    # Wait for database to be ready
    log "Waiting for database to be ready..."
    sleep 5
    
    log "Database setup complete"
}

# Setup Node.js environment
setup_node_env() {
    log "Setting up Node.js environment..."
    
    cd infrastructure
    
    # Install dependencies
    npm install
    
    # Build TypeScript
    npm run build
    
    cd ..
    
    log "Node.js environment setup complete"
}

# Initialize git hooks
setup_git_hooks() {
    log "Setting up Git hooks..."
    
    # Create pre-commit hook
    mkdir -p .git/hooks
    cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash
set -e

echo "Running pre-commit checks..."

# Run Python tests
cd app
python -m pytest tests/

# Run linting
flake8 .

# Check TypeScript
cd ../infrastructure
npm run lint

echo "Pre-commit checks passed"
EOL
    
    chmod +x .git/hooks/pre-commit
    
    log "Git hooks setup complete"
}

# Clean up function
cleanup() {
    log "Cleaning up..."
    
    # Remove old build artifacts
    find . -type d -name "__pycache__" -exec rm -r {} +
    find . -type d -name ".pytest_cache" -exec rm -r {} +
    find . -type d -name "node_modules" -exec rm -r {} +
    
    log "Cleanup complete"
}

# Main initialization process
main() {
    log "Starting local development environment initialization"
    
    # Check requirements first
    check_requirements
    
    # Clean up old artifacts
    cleanup
    
    # Setup environments
    setup_python_env
    setup_node_env
    setup_database
    setup_git_hooks
    
    log "Starting development servers..."
    docker-compose up --build -d
    
    log "Local development environment initialized successfully!"
    log "Application is running at: http://localhost:8000"
    log "API documentation available at: http://localhost:8000/docs"
}

# Error handling
trap 'error "An error occurred during initialization"' ERR

# Run main initialization
main

# Print final instructions
cat << EOL

${GREEN}========================================
Local Development Environment Ready!
========================================${NC}

To start developing:
1. Access the API at: http://localhost:8000
2. View API docs at: http://localhost:8000/docs
3. View logs with: docker-compose logs -f

To run tests:
- Python tests: cd app && pytest
- Infrastructure tests: cd infrastructure && npm test

To stop the environment:
- docker-compose down

Happy coding! 🚀
EOL