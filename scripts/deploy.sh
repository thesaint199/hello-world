#!/bin/bash

# Exit on any error
set -e

# Default values
ENVIRONMENT="dev"
REGION="us-east-1"
SKIP_TESTS=false
SKIP_BUILD=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print usage
usage() {
    echo "Usage: $0 [-e <environment>] [-r <region>] [-s] [-b]"
    echo "  -e: Environment (dev/staging/prod) [default: dev]"
    echo "  -r: AWS Region [default: us-east-1]"
    echo "  -s: Skip tests"
    echo "  -b: Skip build"
    echo "  -h: Show this help message"
    exit 1
}

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

# Parse command line arguments
while getopts "e:r:sbh" opt; do
    case $opt in
        e) ENVIRONMENT="$OPTARG";;
        r) REGION="$OPTARG";;
        s) SKIP_TESTS=true;;
        b) SKIP_BUILD=true;;
        h) usage;;
        ?) usage;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    error "Invalid environment. Must be dev, staging, or prod"
fi

# Check AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    error "AWS credentials not found or invalid"
fi

# Function to run tests
run_tests() {
    log "Running tests..."
    cd app
    if ! pytest tests/; then
        error "Tests failed"
    fi
    cd ..
}

# Function to build and push Docker image
build_and_push() {
    log "Building and pushing Docker image..."
    
    # Get ECR repository
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    ECR_REPO="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/hello-world"
    
    # Login to ECR
    aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
    
    # Build image
    docker build -t hello-world:latest ./app
    
    # Tag image
    COMMIT_HASH=$(git rev-parse --short HEAD)
    docker tag hello-world:latest ${ECR_REPO}:${COMMIT_HASH}
    docker tag hello-world:latest ${ECR_REPO}:latest
    
    # Push image
    docker push ${ECR_REPO}:${COMMIT_HASH}
    docker push ${ECR_REPO}:latest
    
    log "Image pushed successfully: ${ECR_REPO}:${COMMIT_HASH}"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    log "Deploying infrastructure to ${ENVIRONMENT}..."
    cd infrastructure
    
    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        npm install
    fi
    
    # Deploy with CDK
    npm run deploy:${ENVIRONMENT}
    
    cd ..
}

# Function to verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Get the service URL
    SERVICE_URL=$(aws cloudformation describe-stacks \
        --stack-name "HelloWorld-${ENVIRONMENT}" \
        --query 'Stacks[0].Outputs[?OutputKey==`ServiceURL`].OutputValue' \
        --output text)
    
    # Check if service is responding
    if curl -s -f "${SERVICE_URL}/health" > /dev/null; then
        log "Deployment verified successfully"
    else
        error "Deployment verification failed"
    fi
}

# Main deployment process
main() {
    log "Starting deployment to ${ENVIRONMENT} environment"
    
    # Run tests unless skipped
    if [ "$SKIP_TESTS" = false ]; then
        run_tests
    else
        warn "Skipping tests"
    fi
    
    # Build and push unless skipped
    if [ "$SKIP_BUILD" = false ]; then
        build_and_push
    else
        warn "Skipping build and push"
    fi
    
    # Deploy infrastructure
    deploy_infrastructure
    
    # Verify deployment
    verify_deployment
    
    log "Deployment completed successfully"
}

# Create deployment backup
backup_deployment() {
    BACKUP_DIR="deployments/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup current state
    aws cloudformation describe-stacks \
        --stack-name "HelloWorld-${ENVIRONMENT}" \
        > "$BACKUP_DIR/stack_state.json"
    
    log "Deployment backup created in $BACKUP_DIR"
}

# Error handling
trap 'error "An error occurred. Exiting..."' ERR

# Run main deployment
main

# Backup the deployment
backup_deployment