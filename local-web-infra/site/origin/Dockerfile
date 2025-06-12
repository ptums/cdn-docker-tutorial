# ─── 1) Builder stage ─────────────────────────────────────────────
FROM node:18-alpine AS builder
WORKDIR /app

# copy package.json (and lockfile if you have one) and install deps
COPY app/package.json app/package-lock.json* ./
RUN npm install

# copy everything and build with Vite
COPY app .
RUN npm run build      # Vite outputs to /app/dist

# ─── 2) Serve stage ──────────────────────────────────────────────
FROM nginx:alpine
WORKDIR /

# install wget so HEALTHCHECK can use it
RUN apk add --no-cache wget \
    && rm -rf /usr/share/nginx/html/*

# copy the Vite-built files into nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# optional healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost/ || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]