# Use Nginx alpine (ARM-compatible)
FROM nginx:stable-alpine-slim

# Create the images directory
RUN mkdir -p /usr/share/nginx/html/images

# Copy images from the host to the container
COPY images/ /usr/share/nginx/html/images/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create a simple index page to show available images
RUN echo '<html><head><title>CDN Origin Server</title></head><body><h1>CDN Origin Server</h1><p>Images are available at /images/</p></body></html>' > /usr/share/nginx/html/index.html

# Set proper ownership and permissions
# nginx runs as user 'nginx' (UID 101) in the alpine image
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod -R 644 /usr/share/nginx/html/images/* 2>/dev/null || true

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
