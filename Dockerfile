FROM node:20-slim

WORKDIR /app

COPY package.json yarn.lock ./
# Copy all packages first so yarn can link workspaces
COPY packages ./packages
COPY docs ./docs
COPY locales ./locales
COPY scripts ./scripts

# Install dependencies
# Now that packages are present, yarn will properly link the workspaces (including @nocobase/cli)
RUN yarn install

# Build all packages
RUN yarn build

# Expose port
EXPOSE 13000

# Start command
CMD ["yarn", "start"]
