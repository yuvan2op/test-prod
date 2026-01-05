FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm i --only=production

# Copy source code
COPY . .
EXPOSE 5000

# Run backend server
CMD ["npm", "start"]