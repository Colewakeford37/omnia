# Use official NocoBase image
FROM nocobase/nocobase:latest

# Switch to root to set up
USER root

# Copy our plugin source
COPY packages/plugins/@custom/real-estate-crm /app/packages/plugins/@custom/real-estate-crm

# Fix permissions
RUN chown -R node:node /app

# Switch to node user
USER node
WORKDIR /app

# Install dependencies (linking the plugin workspace)
RUN yarn install

# Build the plugin
RUN yarn build

# Start command
CMD ["yarn", "start"]
