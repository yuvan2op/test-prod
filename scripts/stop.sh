#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Stopping application..."

# Stop PM2 processes
if command -v pm2 &> /dev/null; then
    echo "Stopping PM2 services..."
    pm2 stop api || true
    pm2 stop frontend || true
    pm2 delete api || true
    pm2 delete frontend || true
else
    echo "PM2 not found, skipping PM2 stop..."
fi

# Kill any lingering Node processes on ports 5000 and 3000
echo "Cleaning up Node.js processes..."
pkill -f "node server.js" || true
pkill -f "http-server" || true
fuser -k 5000/tcp || true
fuser -k 3000/tcp || true

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Application stopped successfully"

