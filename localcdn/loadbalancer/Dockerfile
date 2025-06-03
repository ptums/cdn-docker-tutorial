# ~/localcdn/loadbalancer/Dockerfile

# Use a small Nginx base (ARM‑compatible)
FROM nginx:1.28.0-alpine-slim

# Remove the default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom load balancer config into place
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 (inside container)
EXPOSE 80

# Launch Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]