# AWS Deployment Configuration Guide

## Overview
This project is configured for production deployment on AWS EC2 using CodePipeline, CodeBuild, and CodeDeploy.

## Files Structure

### buildspec.yml
- **Pre-build**: Installs dependencies for both frontend and backend
- **Build**: Builds React frontend and validates Node.js API server
- **Post-build**: Confirms successful build
- **Artifacts**: Packages only necessary files for deployment

### appspec.yaml
- **Version**: 0.0 (standard for EC2)
- **OS**: Linux (Amazon Linux 2)
- **Hooks**: 
  - `BeforeInstall`: System setup and dependency checks
  - `ApplicationStart`: Starts the application with PM2
  - `ApplicationStop`: Gracefully stops services

## Deployment Prerequisites

### EC2 Instance Requirements
- **AMI**: Amazon Linux 2 (recommended)
- **Instance Type**: t3.small or larger
- **Security Group Rules**:
  - Inbound: Port 22 (SSH), 5000 (API), 3000 (Web)
  - Outbound: All traffic

### IAM Role (EC2 Instance)
Attach these policies:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeploymentConfig",
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": "*"
    }
  ]
}
```

### CodeDeploy Agent Installation
```bash
#!/bin/bash
cd /home/ec2-user
wget https://aws-codedeploy-${AWS_REGION}.s3.${AWS_REGION}.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
```

## Environment Variables

### CodeBuild Parameter Store (SSM)
Store these in AWS Systems Manager Parameter Store:
- `/testprod/frontend_url`: Frontend application URL (e.g., http://yourdomain.com)
- `/testprod/database_url`: Database connection string (optional)

## Deployment Process

### 1. Push to Repository
```bash
git push origin main
```

### 2. CodePipeline Triggers
- Source stage pulls from CodeCommit/GitHub
- Build stage runs `buildspec.yml`
- Deploy stage runs `appspec.yaml`

### 3. CodeBuild Execution
- Installs dependencies
- Builds React frontend (output in `client/dist`)
- Validates API server
- Creates artifacts zip file

### 4. CodeDeploy Execution
- Copies artifacts to `/home/ec2-user/app`
- Runs `before_install.sh` - system setup
- Runs `start.sh` - starts Node.js app with PM2

## Monitoring & Logs

### CodeDeploy Logs
```bash
tail -f /var/log/codedeploy-agent/codedeploy-agent.log
tail -f /var/log/codedeploy-agent/deployments/*/logs/scripts.log
```

### Application Logs (PM2)
```bash
pm2 logs api
pm2 list
```

### CodeBuild Logs
Available in CloudWatch Logs under `/aws/codebuild/test-prod`

## Troubleshooting

### Deployment Fails at ApplicationStart
Check PM2 logs:
```bash
pm2 logs
pm2 describe api
```

### Node.js Dependency Issues
```bash
cd /home/ec2-user/app/api
rm -rf node_modules
npm ci --only=production
```

### Port Already in Use
```bash
sudo fuser -k 5000/tcp
```

## Production Best Practices

1. **Environment Secrets**: Use AWS Secrets Manager for sensitive data
2. **Health Checks**: Implement /api/health endpoint monitoring
3. **Auto Scaling**: Use EC2 Auto Scaling groups for high availability
4. **Load Balancing**: Place behind Application Load Balancer (ALB)
5. **Monitoring**: Enable CloudWatch alarms and metrics
6. **Backups**: Configure automated snapshots for stateful data

## Security Checklist

- [ ] Enable CloudTrail logging
- [ ] Use VPC with private subnets for EC2
- [ ] Enable Security Groups with least privilege
- [ ] Rotate IAM credentials regularly
- [ ] Enable CodeDeploy agent security updates
- [ ] Use HTTPS/TLS for all connections
- [ ] Store secrets in Secrets Manager, not in code

## API Endpoint Configuration

The API server runs on port 5000 (configurable via `API_PORT` environment variable).

### Health Check Endpoint
```
GET http://your-instance:5000/api/health
```

### CORS Configuration
Update in `api/server.js`:
```javascript
FRONTEND_URL: process.env.FRONTEND_URL || 'http://localhost:5173'
```

## Support & Documentation

- [AWS CodeDeploy Documentation](https://docs.aws.amazon.com/codedeploy/)
- [AWS CodeBuild Documentation](https://docs.aws.amazon.com/codebuild/)
- [AppSpec Reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html)
