# Use Nginx alpine (ARM-compatible)
FROM nginx:stable-alpine-slim

# Create cache directory inside container
RUN mkdir -p /var/cache/nginx

# Copy custom nginx.conf, replacing default
COPY nginx/nginx.conf.template /etc/nginx/nginx.conf.template

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]




