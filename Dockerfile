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

# Install and Build
RUN yarn install
RUN yarn build

# Start command
CMD ["yarn", "start"]
