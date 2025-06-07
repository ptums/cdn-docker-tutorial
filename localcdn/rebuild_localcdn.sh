#!/usr/bin/env bash
# rebuild_localcdn.sh
# Stops & removes any containers on localcdn-net (and any binding port 4000),
# tears down & recreates the network, then starts:
#  • MySQL (db)
#  • Redis
#  • Origin
#  • Edge-US
#  • Edge-EU
#  • Load Balancer
#  • API
# Finally, it tests the endpoints.
set -e

# ─── Configuration ───────────────────────────────────────
NETWORK="localcdn-net"

DB_IMAGE="mysql:8.0"
DB_NAME="db"               # must match DB_HOST in your entrypoint
DB_ROOT_PASS="example"
DB_DATABASE="scorecardnotes"
DB_SEED="./api/prisma/seed.sql"

REDIS_IMAGE="redis:6.2-alpine"
REDIS_NAME="redis"

ORIGIN_IMAGE="localcdn-origin"
EDGE_IMAGE="localcdn-edge"
LB_IMAGE="localcdn-lb"
API_IMAGE="localcdn-api"

ORIGIN_NAME="origin"
EDGE_NAME_1="edge-us.local"
EDGE_NAME_2="edge-eu.local"
LB_NAME="lb"
API_NAME="api"

# Allow override of host port for API; defaults to 4000
API_HOST_PORT="${API_HOST_PORT:-4000}"
API_CONTAINER_PORT=4000


# ─── Tear down any old containers & network ───────────────────
echo "Stopping & removing containers on network '$NETWORK' (and any on port $API_HOST_PORT)..."
old=$(docker ps -a --filter "network=$NETWORK" --format "{{.Names}}")
bound=$(docker ps -a --filter "publish=$API_HOST_PORT" --format "{{.Names}}")
for name in $old $bound; do
  [ -n "$name" ] && {
    echo "  -> $name"
    docker stop "$name" >/dev/null 2>&1 || true
    docker rm   "$name" >/dev/null 2>&1 || true
  }
done

echo
echo "Removing network '$NETWORK' (if exists)..."
docker network rm "$NETWORK" >/dev/null 2>&1 || true

echo
echo "Creating network '$NETWORK'..."
docker network create "$NETWORK"

# ─── Start MySQL ────────────────────────────────────────────
echo
echo "Starting MySQL container as '$DB_NAME'..."
docker run -d \
  --name "$DB_NAME" \
  --network "$NETWORK" \
  -e MYSQL_ROOT_PASSWORD="$DB_ROOT_PASS" \
  -e MYSQL_DATABASE="$DB_DATABASE" \
  -v "$(pwd)/${DB_SEED}":/docker-entrypoint-initdb.d/seed.sql:ro \
  "$DB_IMAGE"

#   echo "⏳ Waiting for DB container to be healthy…"
# until docker exec db mysqladmin ping -uroot -pexample --silent; do
#   sleep 1
# done
# echo "✅ DB container is ready."

# ─── Start Redis ────────────────────────────────────────────
echo
echo "Starting Redis container as '$REDIS_NAME'..."
docker run -d \
  --name "$REDIS_NAME" \
  --network "$NETWORK" \
  "$REDIS_IMAGE"

# ─── Start Origin & Edges & LB ──────────────────────────────
echo
echo "Starting origin..."
docker run -d --name "$ORIGIN_NAME" --network "$NETWORK" -p 8080:80 "$ORIGIN_IMAGE"

echo
echo "Starting edge-US..."
docker run -d \
  --name "$EDGE_NAME_1" \
  --network "$NETWORK" \
  -p 8081:80 -p 8443:443 \
  -e EDGE_HOSTNAME="$EDGE_NAME_1" \
  -v "$(pwd)/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_IMAGE"

echo
echo "Starting edge-EU..."
docker run -d \
  --name "$EDGE_NAME_2" \
  --network "$NETWORK" \
  -p 8082:80 -p 8444:443 \
  -e EDGE_HOSTNAME="$EDGE_NAME_2" \
  -v "$(pwd)/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_IMAGE"

echo
echo "Starting load balancer..."
docker run -d --name "$LB_NAME" --network "$NETWORK" -p 8090:80 "$LB_IMAGE"

# ─── Start API ───────────────────────────────────────────────
echo
echo "Starting API on host port $API_HOST_PORT..."
docker run -d \
  --name "$API_NAME" \
  --network "$NETWORK" \
  --env-file "$(pwd)/api/.env" \
  -p "${API_HOST_PORT}:${API_CONTAINER_PORT}" \
  "$API_IMAGE"

# ─── Test Endpoints ──────────────────────────────────────────
echo
echo "=== Testing Endpoints ==="

echo "Origin (8080):"
curl -s -I http://localhost:8080 || true
echo

echo "Load Balancer (8090 – root):"
curl -s -I http://localhost:8090 || true
echo

echo "Edge US (HTTP, 8081):"
curl -s -I http://edge-us.local:8081/ || true
echo

echo "Edge EU (HTTP, 8082):"
curl -s -I http://edge-eu.local:8082/ || true
echo

echo "API (direct, $API_HOST_PORT):"
curl -s -I http://localhost:${API_HOST_PORT}/api/users || true
echo

echo "API (via LB):"
curl -s -I http://localhost:8090/api/users || true
echo

echo "=== Done ==="