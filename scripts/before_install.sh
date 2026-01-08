#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Starting before_install phase..."

# Update system packages
echo "Updating system packages..."
sudo yum update -y

# Check if Node.js is installed, if not install it
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -sL https://rpm.nodesource.com/setup_20.x | sudo bash -
    sudo yum install -y nodejs
else
    echo "Node.js already installed: $(node --version)"
fi

# Create app directory if it doesn't exist
if [ ! -d "/home/ec2-user/app" ]; then
    echo "Creating /home/ec2-user/app directory..."
    sudo mkdir -p /home/ec2-user/app
    sudo chown -R ec2-user:ec2-user /home/ec2-user/app
fi

# Stop any existing services
echo "Stopping existing services..."
if pm2 pid api > /dev/null 2>&1; then
    pm2 stop api || true
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] before_install phase completed"
