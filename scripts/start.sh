#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Starting application..."

cd /home/ec2-user/app

# Install PM2 globally if not already installed
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Set environment variables
export NODE_ENV=production
export PORT=${API_PORT:-5000}
export FRONTEND_URL=${FRONTEND_URL:-http://localhost:3000}

# Install production dependencies if node_modules doesn't exist
if [ ! -d "api/node_modules" ]; then
    echo "Installing API dependencies..."
    cd api
    npm ci --only=production
    cd ..
fi

# Start API server with PM2
echo "Starting API server with PM2..."
cd api
pm2 start server.js --name "api" --instances max --exec-mode cluster
pm2 save

cd ..

# Serve frontend with http-server or simple Node.js server
echo "Setting up frontend..."
if [ -d "client/dist" ]; then
    echo "Frontend built successfully at client/dist"
    
    # Install http-server globally for serving static files
    if ! command -v http-server &> /dev/null; then
        echo "Installing http-server for frontend..."
        npm install -g http-server
    fi
    
    # Start frontend server on port 3000
    pm2 start "http-server /home/ec2-user/app/client/dist -p 3000 --cors" --name "frontend" --log-date-format "YYYY-MM-DD HH:mm:ss"
    echo "Frontend server started on port 3000"
else
    echo "Warning: Frontend build artifacts not found at client/dist"
fi

# Log running processes
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Application started successfully"
echo "API running on port 5000"
echo "Frontend running on port 3000"
pm2 list
