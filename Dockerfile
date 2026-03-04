# Use official NocoBase image
FROM nocobase/nocobase:latest

# Switch to root to set up
USER root

# Copy package.json and yarn.lock for monorepo setup
COPY package.json yarn.lock tsconfig.json ./

# Copy plugin source
COPY packages/plugins/@custom/real-estate-crm ./packages/plugins/@custom/real-estate-crm

# Fix permissions
RUN chown -R node:node /app

# Switch to node user
USER node

# Install and Build
# Install dependencies (monorepo style)
RUN yarn install

# Build all packages (including plugins)
RUN yarn build

# Start command
CMD ["yarn", "start"]
