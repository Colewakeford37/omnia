FROM nocobase/nocobase:latest
USER root
COPY packages/plugins/@custom/real-estate-crm /app/packages/plugins/@custom/real-estate-crm
RUN chown -R node:node /app
