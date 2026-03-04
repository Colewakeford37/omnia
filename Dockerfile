# Use official NocoBase image
FROM nocobase/nocobase:latest

# Switch to root to set up
USER root

# Create plugin directory
RUN mkdir -p /app/packages/plugins/@custom/real-estate-crm

# Copy plugin
COPY packages/plugins/@custom/real-estate-crm /app/packages/plugins/@custom/real-estate-crm

# Fix permissions
RUN chown -R node:node /app

# Switch to node user
USER node
WORKDIR /app

# DEBUG: List files to find where package.json is
# If this fails, we will know the path is wrong
RUN ls -F /app

# Install dependencies specifically for the plugin
# WORKDIR /app/packages/plugins/@custom/real-estate-crm
# RUN yarn install

# Try to build the plugin
# RUN yarn build

# Return to app root
WORKDIR /app

# Start command
CMD ["yarn", "start"]
