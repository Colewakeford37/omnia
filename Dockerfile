FROM nocobase/nocobase:latest
USER root

# Copy the CRM SQL file and installation script for Method 2
COPY docker/nocobase/nocobase-crm.sql /app/docker/nocobase/nocobase-crm.sql
COPY docker/nocobase/install-nocobase-crm-method2.sh /app/nocobase/storage/scripts/10-install-crm-method2.sh
RUN chmod +x /app/nocobase/storage/scripts/10-install-crm-method2.sh

# Ensure the docker directory exists and has proper permissions
RUN mkdir -p /app/docker/nocobase && chown -R node:node /app

RUN chown -R node:node /app
