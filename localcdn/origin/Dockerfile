# # Use the official Nginx image (ARM64-compatible)
# FROM nginx:stable-alpine-slim

# # Remove default content and copy our HTML
# RUN rm -rf /usr/share/nginx/html/*
# COPY html/ /usr/share/nginx/html/

# # Expose port 80
# EXPOSE 80

# Default command (nginx runs in foreground by default)


# ─── 1) Build stage ─────────────────────────────────────────────
FROM node:18-alpine AS builder
WORKDIR /app

# copy and install dependencies
COPY package*.json ./
RUN npm ci

# copy source & build
COPY . .
RUN npm run build     # produces /app/build

# ─── 2) Serve stage ────────────────────────────────────────────
FROM nginx:alpine
# remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# copy React build into nginx
COPY --from=builder /app/build /usr/share/nginx/html

# (optional) expose a health-check endpoint
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost/ || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]