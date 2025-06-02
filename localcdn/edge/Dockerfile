# Use Nginx alpine (ARM-compatible)
FROM nginx:stable-alpine-slim

# Create cache directory inside container
RUN mkdir -p /var/cache/nginx

# Copy custom nginx.conf, replacing default
COPY nginx/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80