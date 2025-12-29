# Full Stack Application

A professional full-stack application built with Vite (React) frontend and Node.js (Express) backend, designed for deployment testing with Jenkins.

## Project Structure

```
.
├── api/              # Node.js Express backend server
│   ├── server.js     # Express server (runs on port 5000)
│   ├── package.json  # Backend dependencies
│   └── .env.example  # Environment variables example
├── client/           # Vite React frontend
│   ├── src/          # React source files
│   ├── index.html    # HTML entry point
│   ├── vite.config.js # Vite configuration (runs on port 5173)
│   ├── package.json  # Frontend dependencies
│   └── .env.example  # Environment variables example
├── .gitignore        # Git ignore file
└── README.md         # This file

```

## Technology Stack

### Frontend (Client)
- **Vite** - Next generation frontend tooling
- **React** - UI library
- **Port:** 5173

### Backend (API)
- **Node.js** - JavaScript runtime
- **Express** - Web framework
- **CORS** - Cross-origin resource sharing
- **dotenv** - Environment variables
- **Port:** 5000

## Setup Instructions

### Prerequisites
- Node.js (v16 or higher)
- npm or yarn

### Backend Setup (API)

1. Navigate to the API directory:
   ```bash
   cd api
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create environment file (optional):
   ```bash
   cp .env.example .env
   ```
   Edit `.env` if you need to change default settings.

4. Start the backend server:
   ```bash
   npm start
   ```
   
   Or for development with auto-reload:
   ```bash
   npm run dev
   ```

   The API server will run on `http://localhost:5000`

### Frontend Setup (Client)

1. Navigate to the client directory:
   ```bash
   cd client
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create environment file (optional):
   ```bash
   cp .env.example .env
   ```
   Edit `.env` if your API URL is different from default.

4. Start the development server:
   ```bash
   npm run dev
   ```

   The frontend will run on `http://localhost:5173`

5. Build for production:
   ```bash
   npm run build
   ```

## Usage

1. Start the API server first (port 5000)
2. Start the frontend development server (port 5173)
3. Open your browser and navigate to `http://localhost:5173`
4. The frontend will display the connection status and allow you to test API integration

## API Endpoints

### Health Check
- **GET** `/api/health`
  - Returns server status and environment information
  - Response:
    ```json
    {
      "status": "ok",
      "message": "API server is running",
      "timestamp": "2024-01-01T00:00:00.000Z",
      "environment": "development"
    }
    ```

### Data Endpoint
- **GET** `/api/data`
  - Returns sample data from the API
  - Response:
    ```json
    {
      "success": true,
      "message": "Data retrieved successfully",
      "data": {
        "timestamp": "2024-01-01T00:00:00.000Z",
        "server": "Node.js Express API",
        "version": "1.0.0"
      }
    }
    ```

## Deployment

This application is ready for deployment testing with Jenkins or other CI/CD pipelines.

### Build Commands

**Backend:**
```bash
cd api
npm install --production
npm start
```

**Frontend:**
```bash
cd client
npm install
npm run build
# Serve the dist/ folder with a static file server
```

### Environment Variables

**API (.env):**
- `PORT` - Server port (default: 5000)
- `NODE_ENV` - Environment mode (development/production)
- `FRONTEND_URL` - Frontend URL for CORS (default: http://localhost:5173)

**Client (.env):**
- `VITE_API_URL` - API base URL (default: http://localhost:5000)

## Features

- ✅ Professional project structure
- ✅ Environment variable configuration
- ✅ CORS enabled for cross-origin requests
- ✅ Error handling and logging
- ✅ Health check endpoint
- ✅ Responsive UI design
- ✅ Production-ready build configuration
- ✅ Deployment-friendly setup

## License

ISC
