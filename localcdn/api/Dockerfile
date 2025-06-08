# ─── 1) Builder stage: install deps, generate Prisma client, compile TS ───
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package definitions and install all deps (including dev)
COPY package*.json ./
RUN npm ci

# Copy Prisma schema + generate client
COPY prisma ./prisma
RUN npx prisma generate

# Copy source, build TS → dist
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ─── 2) Production stage: lean runtime ──────────────────────────────────
FROM node:18-alpine
WORKDIR /app

# Only production deps
COPY package*.json ./
RUN npm ci --omit=dev

# Bring in built assets + Prisma client
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/prisma ./prisma

# Copy your .env if you still want defaults in the image
COPY .env .env

# Allow build-time overrides, defaulting to whatever’s in .env
ARG DATABASE_URL
ARG REDIS_URL

# Set runtime environment variables
# 2) Set them as env vars at runtime (or fall back to whatever your .env provides)
ENV NODE_ENV=production \
    DATABASE_URL=${DATABASE_URL} \
    REDIS_URL=${REDIS_URL}

# Expose your API port
EXPOSE 4000

# Launch your app
CMD ["node", "dist/index.js"]