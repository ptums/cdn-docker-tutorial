#!/usr/bin/env bash
# rebuild_localcdn.sh
# Tears down old containers on localcdn-net (and any publishing the API port),
# recreates the network, then starts origin, edges, LB, and the API,
# mapping your host's DATABASE_URL and REDIS_URL into the API container.

set -e

# ─── Configuration ───────────────────────────────────────
NETWORK="localcdn-net"
API_IMAGE="localcdn-api"
API_NAME="api"

API_HOST_PORT="${API_HOST_PORT:-4000}"
API_CONTAINER_PORT=4000

# Read your host’s DB/Redis URLs (or fallback)
DATABASE_URL="${DATABASE_URL:-mysql://root@localhost:3306/scorecardnotes}"
REDIS_URL="${REDIS_URL:-redis://localhost:6379}"

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

echo "API (direct, $API_HOST_PORT):"
curl -s -I http://localhost:${API_HOST_PORT}/api/users || true
echo

echo "API (via LB):"
curl -s -I http://localhost:8090/api/users || true
echo

echo "=== Done ==="