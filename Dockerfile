FROM node:18-slim

WORKDIR /app

# Install dependencies - skip postinstall for now
COPY package.json yarn.lock ./
RUN yarn install --ignore-scripts

# Copy all packages
COPY packages ./packages
COPY docs ./docs
COPY locales ./locales
COPY scripts ./scripts

# Build all packages - this makes nocobase CLI available
RUN yarn build

# Now run postinstall which needs nocobase CLI
RUN yarn postinstall

# Expose port
EXPOSE 13000

# Start command
CMD ["yarn", "start"]
