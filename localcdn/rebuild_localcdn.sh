#!/usr/bin/env bash
# rebuild_localcdn.sh
# Tears down old containers on localcdn-net (and any publishing the API port),
# recreates the network, then starts origin, edges, LB, and the API,
# mapping your host's DATABASE_URL and REDIS_URL into the API container.

set -e

# ─── Configuration ───────────────────────────────────────
NETWORK="localcdn-net"

ORIGIN_IMAGE="localcdn-origin"
EDGE_IMAGE="localcdn-edge"
LB_IMAGE="localcdn-lb"
API_IMAGE="localcdn-api"

ORIGIN_NAME="origin"
EDGE_NAME_1="edge-us.local"
EDGE_NAME_2="edge-eu.local"
LB_NAME="lb"
API_NAME="api"

API_HOST_PORT="${API_HOST_PORT:-4000}"
API_CONTAINER_PORT=4000

# Read your host’s DB/Redis URLs (or fallback)
DATABASE_URL="${DATABASE_URL:-mysql://root@localhost:3306/scorecardnotes}"
REDIS_URL="${REDIS_URL:-redis://localhost:6379}"

# ─── Tear down any old containers & network ───────────────
echo "Stopping & removing containers on network '$NETWORK' and any binding port $API_HOST_PORT..."
old=$(docker ps -a --filter "network=$NETWORK" --format "{{.Names}}")
bound=$(docker ps -a --filter "publish=$API_HOST_PORT" --format "{{.Names}}")
for name in $old $bound; do
  if [ -n "$name" ]; then
    echo "  -> $name"
    docker stop "$name" >/dev/null 2>&1 || true
    docker rm   "$name" >/dev/null 2>&1 || true
  fi
done

echo
echo "Removing network '$NETWORK' (if exists)..."
docker network rm "$NETWORK" >/dev/null 2>&1 || true

echo
echo "Creating network '$NETWORK'..."
docker network create "$NETWORK"

# ─── Start Origin & Edges & Load Balancer ───────────────────
echo
echo "Starting origin..."
docker run -d \
  --name "$ORIGIN_NAME" \
  --network "$NETWORK" \
  -p 8080:80 \
  "$ORIGIN_IMAGE"

echo
echo "Starting edge-US..."
docker run -d \
  --name "$EDGE_NAME_1" \
  --network "$NETWORK" \
  -p 8081:80 \
  -p 8443:443 \
  -e EDGE_HOSTNAME="$EDGE_NAME_1" \
  -v "$(pwd)/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_IMAGE"

echo
echo "Starting edge-EU..."
docker run -d \
  --name "$EDGE_NAME_2" \
  --network "$NETWORK" \
  -p 8082:80 \
  -p 8444:443 \
  -e EDGE_HOSTNAME="$EDGE_NAME_2" \
  -v "$(pwd)/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_IMAGE"

echo
echo "Starting load balancer..."
docker run -d \
  --name "$LB_NAME" \
  --network "$NETWORK" \
  -p 8090:80 \
  "$LB_IMAGE"

# ─── Start API ───────────────────────────────────────────────
echo
echo "Starting API container '$API_NAME' on host port $API_HOST_PORT..."
docker run -d \
  --name "$API_NAME" \
  --network "$NETWORK" \
  -e DATABASE_URL="$DATABASE_URL" \
  -e REDIS_URL="$REDIS_URL" \
  -e NODE_ENV="production" \
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