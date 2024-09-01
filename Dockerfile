# Use a Node base image
FROM node:20 AS builder

# Set the working directory
WORKDIR /app

# Copy the project files to the working directory
COPY . .

# Install dependencies and build the project
RUN npm install
RUN npm run docs:build

# Use Nginx to serve the static files
FROM nginx:alpine

# Copy the static files to the Nginx web directory
COPY --from=builder /app/.vitepress/dist /usr/share/nginx/html

# Expose the Nginx port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
