# AWS CodePipeline Configuration

This document provides the CloudFormation template to set up AWS CodePipeline for automated deployment.

## Quick Setup

1. **Create S3 Bucket for Artifacts**
```bash
aws s3 mb s3://testprod-codepipeline-artifacts-$(aws sts get-caller-identity --query Account --output text)
```

2. **Create CodeDeploy Application**
```bash
aws codedeploy create-app --application-name test-prod-app --region ap-south-1
```

3. **Create CodeDeploy Deployment Group**
```bash
aws codedeploy create-deployment-group \
  --application-name test-prod-app \
  --deployment-group-name test-prod-dg \
  --service-role-arn arn:aws:iam::ACCOUNT_ID:role/CodeDeployServiceRole \
  --ec2-tag-filters Key=Name,Value=test-prod,Type=KEY_AND_VALUE \
  --deployment-config-name CodeDeployDefault.OneAtATime \
  --region ap-south-1
```

## IAM Roles Required

### CodePipeline Service Role
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::testprod-codepipeline-artifacts-*/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:BatchGetProjects",
        "codebuild:BatchGetReports",
        "codebuild:BatchGetReportGroups",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetApplication",
        "codedeploy:GetApplicationRevision",
        "codedeploy:GetDeployment",
        "codedeploy:GetDeploymentConfig",
        "codedeploy:ListApplicationRevisions",
        "codedeploy:ListDeployments"
      ],
      "Resource": "*"
    }
  ]
}
```

### CodeBuild Service Role
Ensure these policies are attached:
- `AWSCodeBuildAdminAccess` (for dev/testing)
- Custom policy for S3 artifact access

## Pipeline Structure

```
Source (CodeCommit/GitHub)
    ↓
Build (CodeBuild)
    ↓
Deploy (CodeDeploy to EC2)
    ↓
Health Check / Approval
```

## Environment Variables for CodeBuild

Set in CodeBuild project:
- `NODE_ENV`: production
- `AWS_DEFAULT_REGION`: ap-south-1
- `API_PORT`: 5000

Parameter Store variables:
- `/testprod/frontend_url`
- `/testprod/database_url` (optional)
