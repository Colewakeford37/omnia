# Use official NocoBase image
FROM nocobase/nocobase:latest

# Switch to root to set up
USER root

# DEBUG: List contents of root to find package.json
RUN ls -F /

# Copy our plugin source
COPY packages/plugins/@custom/real-estate-crm /app/packages/plugins/@custom/real-estate-crm || true

# Fix permissions
RUN chown -R node:node /app || true

# Switch to node user
USER node
WORKDIR /app

# Set Database Environment Variables
ENV DB_DIALECT=postgres
ENV DB_HOST=${PGHOST}
ENV DB_PORT=${PGPORT}
ENV DB_DATABASE=${PGDATABASE}
ENV DB_USER=${PGUSER}
ENV DB_PASSWORD=${PGPASSWORD}

# Start command
CMD ["yarn", "start"]
