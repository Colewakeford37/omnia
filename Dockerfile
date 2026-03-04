# Use official NocoBase image as base - this is MUCH faster than building from scratch
FROM nocobase/nocobase:latest

# Switch to root to install dependencies
USER root

# Create the custom plugin directory
RUN mkdir -p /app/packages/plugins/@custom/real-estate-crm

# Copy our custom plugin into the image
COPY packages/plugins/@custom/real-estate-crm /app/packages/plugins/@custom/real-estate-crm

# Set permissions for the entire app directory so 'node' user can write to it
RUN chown -R node:node /app

# Switch back to node user
USER node

# Install dependencies for the new plugin
WORKDIR /app
RUN yarn install

# Rebuild the application to include the new plugin
RUN yarn build

# Expose port
EXPOSE 13000

# Start command
CMD ["yarn", "start"]
