# Use the official Nginx image (ARM64-compatible)
FROM nginx:stable-alpine-slim

# Remove default content and copy our HTML
RUN rm -rf /usr/share/nginx/html/*
COPY html/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Default command (nginx runs in foreground by default)