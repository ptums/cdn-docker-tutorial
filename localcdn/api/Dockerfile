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
COPY .env .env

# Expose your API port
ENV NODE_ENV=production
EXPOSE 4000

# Use env-file or -e flags to pass DATABASE_URL, REDIS_URL, etc.
CMD ["node", "dist/index.js"]