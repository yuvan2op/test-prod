#!/bin/bash
# EC2 Instance User Data Script
# Use this when launching EC2 instances to pre-configure the system

#!/bin/bash
set -e

echo "Starting EC2 initialization..."

# Update system
yum update -y

# Install Node.js 20.x
curl -sL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# Install PM2 globally
npm install -g pm2

# Create application directory
mkdir -p /home/ec2-user/app
chown -R ec2-user:ec2-user /home/ec2-user/app

# Install CodeDeploy Agent
cd /home/ec2-user
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

# Start and enable CodeDeploy Agent
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Create log directory for CodeDeploy
mkdir -p /var/log/codedeploy-agent/deployments

# PM2 startup hook
su - ec2-user -c "pm2 startup -u ec2-user --hp /home/ec2-user"

echo "EC2 initialization completed successfully"
