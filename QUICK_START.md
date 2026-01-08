# AWS Deployment - Quick Reference

## 🚀 One-Time Setup (First Time Only)

### 1. Create S3 Bucket for Pipeline Artifacts
```bash
aws s3 mb s3://testprod-artifacts-$(aws sts get-caller-identity --query Account --output text) \
  --region ap-south-1
```

### 2. Create CodeDeploy Application
```bash
aws codedeploy create-app \
  --application-name test-prod \
  --region ap-south-1
```

### 3. Create CodeDeploy Deployment Group
```bash
aws codedeploy create-deployment-group \
  --application-name test-prod \
  --deployment-group-name test-prod-dg \
  --service-role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/CodeDeployServiceRole \
  --ec2-tag-filters Key=Name,Value=test-prod,Type=KEY_AND_VALUE \
  --deployment-config-name CodeDeployDefault.OneAtATime \
  --region ap-south-1
```

### 4. Create IAM Roles

**CodePipeline Service Role** - Trust Relationship:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": "arn:aws:s3:::testprod-artifacts-*/*"
    },
    {
      "Effect": "Allow",
      "Action": ["codebuild:*", "codedeploy:*"],
      "Resource": "*"
    }
  ]
}
```

### 5. Launch EC2 Instances

**Requirements:**
- AMI: Amazon Linux 2
- Instance Type: t3.small or larger
- Tags: `Name=test-prod` (required for CodeDeploy)
- IAM Role: EC2 instance with CodeDeploy permissions
- Security Groups: Allow 22, 5000, 80, 443

**User Data Script:**
```bash
#!/bin/bash
yum update -y
curl -sL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
npm install -g pm2
mkdir -p /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/app
cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
```

## 📋 File Overview

| File | Purpose |
|------|---------|
| `appspec.yaml` | CodeDeploy deployment instructions for EC2 |
| `buildspec.yml` | CodeBuild build steps (Node, npm, build) |
| `scripts/before_install.sh` | Pre-deployment setup (Node, PM2, etc.) |
| `scripts/start.sh` | Start application with PM2 |
| `scripts/stop.sh` | Stop running services |

## 🔄 Deployment Flow

```
1. Push to Git
        ↓
2. CodePipeline triggered
        ↓
3. CodeBuild runs buildspec.yml
   - Installs dependencies
   - Builds React frontend
   - Validates Node.js server
   - Creates artifacts
        ↓
4. CodeDeploy runs appspec.yaml
   - Copies files to EC2
   - Runs before_install.sh
   - Runs start.sh
   - Verifies health
        ↓
5. Application running on EC2
```

## ✅ Verification Commands

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@your-instance-ip

# Check application status
pm2 list

# View application logs
pm2 logs api
pm2 logs frontend

# Test API health
curl http://localhost:5000/api/health

# Test Frontend
curl http://localhost:3000

# Check CodeDeploy agent
sudo systemctl status codedeploy-agent

# View deployment logs
sudo tail -f /var/log/codedeploy-agent/codedeploy-agent.log
```

## 🔑 Environment Variables (CodeBuild)

### As Variables:
- `NODE_ENV`: production
- `AWS_DEFAULT_REGION`: ap-south-1
- `API_PORT`: 5000

### From Parameter Store:
- `/testprod/frontend_url` → `$FRONTEND_URL`
- `/testprod/database_url` → `$DATABASE_URL` (optional)

## 📊 CloudWatch Monitoring

### Logs to Monitor:
```
/aws/codebuild/test-prod
/aws/codedeploy/test-prod
/var/log/codedeploy-agent/codedeploy-agent.log (on EC2)
```

### Health Check:
```bash
curl -i http://your-instance:5000/api/health
```

Expected Response:
```json
{
  "status": "ok",
  "message": "API server is running",
  "timestamp": "2024-01-08T...",
  "environment": "production"
}
```

## 🐛 Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| CodeDeploy agent not running | `sudo systemctl restart codedeploy-agent` |
| Port 5000 already in use | `sudo fuser -k 5000/tcp` |
| npm install fails | `npm cache clean --force` |
| Build timeout | Increase timeout in CodeBuild project settings |
| Deployment fails | Check `/var/log/codedeploy-agent/deployments/` |

## 📞 Support Resources

- [AWS CodePipeline Docs](https://docs.aws.amazon.com/codepipeline/)
- [AWS CodeBuild Docs](https://docs.aws.amazon.com/codebuild/)
- [AWS CodeDeploy Docs](https://docs.aws.amazon.com/codedeploy/)
- [AppSpec Reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html)

---

**All configuration files are production-ready and professionally formatted.**
**For detailed setup, see DEPLOYMENT.md and AWS_SETUP.md**
