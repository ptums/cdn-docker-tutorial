# 1) Builder stage — compile TS & generate Prisma client
FROM node:18-alpine AS builder
WORKDIR /usr/src/app

COPY package*.json tsconfig.json ./
COPY prisma ./prisma
COPY src ./src

RUN npm install \
 && npx prisma generate \
 && npm run build


# 2) Production stage — Node + embedded MariaDB
FROM node:18-alpine
WORKDIR /usr/src/app

# ─── Install MariaDB server/client + su-exec ───────────────────
RUN apk add --no-cache \
      mariadb \
      mariadb-client \
      su-exec \
    # ─── Ensure both data dir and socket dir exist & are owned ─────────────
    && mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

# initialize the data directory (empty on first build)
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# copy optional seed SQL
COPY prisma/seed.sql /docker-entrypoint-initdb.d/seed.sql:ro

# copy in your built API
COPY package*.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist

# copy & make executable our entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV NODE_ENV=production \
    MYSQL_ROOT_PASSWORD=example \
    MYSQL_DATABASE=scorecardnotes

# expose API port + MySQL port
EXPOSE 4000 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]