export default {
  apps: [
    {
      name: "test-prod-backend",
      script: "server.js",
      instances: "max",
      exec_mode: "cluster",
      env: {
        NODE_ENV: "production",
        PORT: 5000
      }
    }
  ]
};
