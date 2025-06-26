# Use Node.js base image
FROM node:20-alpine

# Set working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json 
COPY package*.json ./

# Install dependencies
RUN npm install

# Install Vite globally 
RUN npm install -g vite

# Copy the rest of the application code
COPY . .

# Build the Vite app 
RUN npm run build

# Expose the port Vite preview runs on
EXPOSE 5173

# Start the app using Vite preview
CMD ["vite", "preview", "--host", "--port", "5173"]
