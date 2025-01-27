# Hello World DevOps Challenge

A production-quality CI/CD pipeline for a dockerized "Hello World" application with database integration.

## 🌟 Features

- Dockerized FastAPI application with PostgreSQL database
- AWS CDK infrastructure as code
- Multi-environment deployment pipeline (Dev, Staging, Prod)
- Automated testing and security scanning
- Infrastructure monitoring and alerting
- Least privilege access implementation

## 🏗️ Architecture

```
├── Application Layer: FastAPI (Container)
├── Database Layer: PostgreSQL RDS
├── Infrastructure Layer: AWS (ECS, RDS, VPC)
└── CI/CD Pipeline: GitHub Actions
```

## 🚀 Quick Start

### Prerequisites

- Python 3.9+
- Node.js 14+
- Docker and Docker Compose
- AWS CLI configured
- GitHub account

### Local Development

1. Clone the repository:
```bash
git clone <repository-url>
cd hello-world
```

2. Set up Python virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
cd app
pip install -r requirements.txt
```

3. Run the application locally:
```bash
docker-compose up --build
```

The application will be available at `http://localhost:8000`

### Deploy to AWS

1. Install AWS CDK dependencies:
```bash
cd infrastructure
npm install
```

2. Bootstrap AWS CDK (first time only):
```bash
npm run bootstrap
```

3. Deploy to development:
```bash
npm run deploy:dev
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/hello_db
AWS_REGION=us-east-1
ENVIRONMENT=development
```

### AWS Configuration

1. Configure AWS credentials:
```bash
aws configure
```

2. Update `cdk.json` with your specific requirements.

## 🔒 Security

- Database is deployed in private subnets
- Least privilege IAM roles
- Security group restrictions
- Regular vulnerability scanning
- Secrets management through AWS Secrets Manager

## 📊 Monitoring

- CloudWatch metrics and alarms
- RDS performance insights
- Application health checks
- Error rate monitoring
- Custom dashboard for key metrics

## 🧪 Testing

Run the test suite:

```bash
# Application tests
cd app
pytest

# Infrastructure tests
cd infrastructure
npm test
```

## 📝 Development Tasks

Priority list for future improvements:

1. **High Priority**
   - Implement automated database backups
   - Add application logging with ELK stack
   - Set up WAF for API protection
   - Implement auto-scaling policies

2. **Medium Priority**
   - Add API documentation with Swagger
   - Implement blue-green deployment
   - Set up performance monitoring
   - Add cost optimization tagging

3. **Lower Priority**
   - Implement API rate limiting
   - Add service mesh integration
   - Set up cross-region disaster recovery
   - Implement custom metrics dashboard

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the ISC License

## 📞 Support

For support and questions, please create an issue in the repository.

## 🏗️ Project Structure

```
.
├── .github/workflows      # CI/CD pipeline configurations
├── app                   # Application code
│   ├── src              # Source code
│   ├── tests            # Test files
│   └── Dockerfile       # Container configuration
├── infrastructure       # AWS CDK infrastructure code
└── scripts              # Utility scripts
```

## 🔄 CI/CD Pipeline

The pipeline includes:

1. **On Pull Request:**
   - Code linting
   - Unit tests
   - Security scanning
   - Infrastructure validation

2. **On Merge to Main:**
   - Build Docker image
   - Push to ECR
   - Deploy to staging
   - Run integration tests
   - Deploy to production

## ⚙️ Operations

### Deployment

```bash
# Deploy to staging
npm run deploy:staging

# Deploy to production
npm run deploy:prod
```

### Rollback

```bash
# Rollback to previous version
npm run rollback
```

### Monitoring

1. Access CloudWatch dashboards
2. Check application logs
3. Monitor RDS metrics
4. Review access logs