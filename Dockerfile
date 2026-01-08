# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install any needed packages
RUN npm ci --only=production && npm cache clean --force

# Install su-exec for privilege dropping
RUN apk add --no-cache su-exec

# Bundle app source
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Create directories for uploads and data and set correct permissions
RUN mkdir -p uploads data && chown -R nodejs:nodejs uploads data

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Make port 6001 available to the world outside this container
EXPOSE 6001

# Define the command to run the app
CMD [ "node", "server.js" ]
