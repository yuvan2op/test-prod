# Production Deployment Checklist

## Pre-Deployment Setup

### AWS Account & Permissions
- [ ] AWS Account created and configured
- [ ] IAM user with programmatic access
- [ ] AWS CLI installed and configured
- [ ] Appropriate IAM roles created for CodePipeline, CodeBuild, CodeDeploy

### AWS CodePipeline
- [ ] CodePipeline project created (test-prod)
- [ ] Source stage configured (CodeCommit/GitHub)
- [ ] Artifact S3 bucket created
- [ ] Pipeline role has necessary permissions

### AWS CodeBuild
- [ ] CodeBuild project created
- [ ] Service role attached with EC2 and S3 permissions
- [ ] Parameter Store variables configured:
  - [ ] `/testprod/frontend_url`
  - [ ] `/testprod/database_url` (if needed)
- [ ] VPC networking configured (if using private subnets)

### AWS CodeDeploy
- [ ] CodeDeploy application created
- [ ] Deployment group created with EC2 instances tagged
- [ ] Service role with appropriate permissions
- [ ] Deployment configuration set (OneAtATime/HalfAtATime/AllAtOnce)

### EC2 Instances
- [ ] Instance(s) launched with Amazon Linux 2 AMI
- [ ] IAM instance profile attached (CodeDeploy permissions)
- [ ] Security group allows:
  - [ ] Port 22 (SSH) from your IP
  - [ ] Port 5000 (API) from ALB/security group
  - [ ] Port 80/443 (HTTP/HTTPS) from internet/ALB
- [ ] CodeDeploy agent installed and running
- [ ] User data script executed (or commands run manually)
- [ ] EC2 instance tagged for deployment group (e.g., Name=test-prod)

## Code Repository Setup

- [ ] `appspec.yaml` committed to repository
- [ ] `buildspec.yml` committed to repository
- [ ] `scripts/before_install.sh` committed to repository
- [ ] `scripts/start.sh` committed to repository
- [ ] `scripts/stop.sh` committed to repository
- [ ] `.env.production.example` checked in as reference
- [ ] `.gitignore` includes `.env` and `node_modules/`

## First Deployment

### Manual Verification Before Pipeline

```bash
# 1. SSH to EC2 instance
ssh -i your-key.pem ec2-user@your-instance-ip

# 2. Verify CodeDeploy agent
sudo systemctl status codedeploy-agent

# 3. Check application directory
ls -la /home/ec2-user/app/

# 4. Verify Node.js and npm
node --version
npm --version

# 5. Check logs
sudo tail -f /var/log/codedeploy-agent/codedeploy-agent.log
```

### Pipeline Execution

1. [ ] Push code to repository
2. [ ] Monitor pipeline in AWS Console
3. [ ] Check CodeBuild logs for build errors
4. [ ] Check CodeDeploy logs for deployment errors
5. [ ] Verify application is running: `curl http://localhost:5000/api/health`
6. [ ] Test frontend accessibility

## Post-Deployment Verification

### Application Health
```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@your-instance-ip

# Check API server
pm2 list
pm2 logs api

# Test API endpoint
curl -X GET http://localhost:5000/api/health

# Check frontend build
ls -la /home/ec2-user/app/client/dist/
```

### AWS Console Checks
- [ ] CodePipeline shows successful deployment
- [ ] CodeBuild build artifacts created in S3
- [ ] CodeDeploy deployment status: SUCCESS
- [ ] EC2 instance healthy in target group (if using ALB)

### Security & Compliance
- [ ] No sensitive data in logs
- [ ] Environment variables properly configured
- [ ] Secrets stored in AWS Secrets Manager (not in code)
- [ ] HTTPS enabled (if using ALB)
- [ ] Security groups follow principle of least privilege

## Monitoring & Alerts

- [ ] CloudWatch alarms configured for:
  - [ ] EC2 CPU utilization
  - [ ] Memory usage
  - [ ] Disk space
  - [ ] API response time
  - [ ] Error rates

- [ ] CodeDeploy deployment notifications enabled
- [ ] Email alerts configured for pipeline failures
- [ ] Log aggregation configured (CloudWatch Logs)

## Rollback Plan

- [ ] Previous artifact versions retained in S3
- [ ] Documentation on manual rollback procedure
- [ ] CodeDeploy revision history maintained
- [ ] Database backup strategy in place (if applicable)

## Documentation

- [ ] README updated with production deployment steps
- [ ] DEPLOYMENT.md reviewed and accurate
- [ ] AWS_SETUP.md reviewed and complete
- [ ] Team trained on deployment process
- [ ] Runbooks created for common issues

## Maintenance

- [ ] Automated dependency updates configured
- [ ] Security patches applied regularly
- [ ] CodeBuild logs retention policy set
- [ ] S3 artifact cleanup policy configured
- [ ] Cost monitoring enabled

## Troubleshooting Guide

### Deployment Failed
1. Check CodeBuild logs: CodeBuild project → Build history
2. Check CodeDeploy logs: `/var/log/codedeploy-agent/deployments/`
3. Verify IAM permissions for all services
4. Check EC2 security group rules

### Application Not Starting
1. SSH to EC2 and check: `pm2 logs api`
2. Verify dependencies installed: `npm list -g pm2`
3. Check port availability: `sudo lsof -i :5000`
4. Verify environment variables: Check parameter store values

### Build Failures
1. Check Node.js version compatibility
2. Verify npm cache: `npm cache clean --force`
3. Check buildspec.yml for syntax errors
4. Review CodeBuild logs for specific errors

### Timeout Issues
1. Increase CodeBuild timeout in project settings
2. Increase CodeDeploy script timeouts in appspec.yaml
3. Optimize build steps for faster execution
4. Consider instance size for performance

---

## Emergency Contacts & Escalation

- [ ] AWS Support contact information documented
- [ ] Team member escalation paths defined
- [ ] Incident response procedures in place

**Last Updated**: [Date]
**Updated By**: [Name]
**Next Review Date**: [Date]
