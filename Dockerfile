# Use official NocoBase image
FROM nocobase/nocobase:latest

# Copy package.json from the base image to preserve all dependencies
# This ensures yarn install and yarn build work perfectly
COPY --from=0 /app/package.json /app/package.json
COPY --from=0 /app/yarn.lock /app/yarn.lock || true

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
