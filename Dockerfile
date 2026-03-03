FROM node:18-slim

WORKDIR /app

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy all packages
COPY packages ./packages

# Build NocoBase
RUN yarn build

# Expose port
EXPOSE 13000

# Start command
CMD ["node", "./packages/core/server/lib/index.js"]
