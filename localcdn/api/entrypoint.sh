#!/usr/bin/env sh
set -e

# ─── Start MariaDB under the 'mysql' user ─────────────────────────
echo "🚀 Launching MariaDB…"
su-exec mysql mariadbd --datadir=/var/lib/mysql &
DB_PID=$!

# ─── Wait until it's ready ────────────────────────────────────────
echo "⏳ Waiting for MariaDB to come up…"
until mariadb-admin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent; do
  sleep 1
done
echo "✅ MariaDB is up."

# ─── Seed on first run (if present) ──────────────────────────────
if [ -f /docker-entrypoint-initdb.d/seed.sql ]; then
  echo "🌱 Seeding database '$MYSQL_DATABASE'…"
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" \
    < /docker-entrypoint-initdb.d/seed.sql
fi

# ─── Finally exec your API ────────────────────────────────────────
echo "🚀 Starting API on port 4000…"
exec node dist/index.js