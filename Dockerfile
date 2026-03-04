# Use official NocoBase image
FROM nocobase/nocobase:latest

# Switch to root to set up
USER root

# Copy local package.json (with workspace fix) and plugin
COPY package.json yarn.lock tsconfig.json ./
COPY packages/plugins/@custom/real-estate-crm ./packages/plugins/@custom/real-estate-crm

# Fix permissions
RUN chown -R node:node /app

# Switch to node user
USER node
WORKDIR /app

# Install dependencies (will download from npm)
RUN yarn install

# Build
RUN yarn build

# Start command
CMD ["yarn", "start"]
