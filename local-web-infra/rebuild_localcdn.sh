#!/usr/bin/env bash
# rebuild_localwebinfa.sh
# Tears down old containers on localwebinfa-net (and any publishing the API port),
# recreates the network, then starts origin, edges, LB, and the API,
# mapping your host's DATABASE_URL and REDIS_URL into the API container.

set -e

# ─── Configuration ───────────────────────────────────────
NETWORK="localwebinfa-net"

ORIGIN_SITE_IMAGE="localwebinfa-site-origin"
EDGE_CDN_IMAGE="localwebinfa-cdn-edge"
ORIGIN_CDN_IMAGE="localwebinfa-cdn-origin"
EDGE_SITE_IMAGE="localwebinfa-site-edge"
LB_IMAGE="localwebinfa-lb"
API_IMAGE="localwebinfa-api"

ORIGIN_SITE_NAME="site_origin"
ORIGIN_CDN_NAME="cdn_origin"
EDGE_SITE_NAME_1="edge-site-us.local"
EDGE_SITE_NAME_2="edge-site-eu.local"
EDGE_CDN_NAME_1="edge-cdn-us.local"
EDGE_CDN_NAME_2="edge-cdn-eu.local"
LB_NAME="lb"
API_NAME="api"

API_HOST_PORT="${API_HOST_PORT:-4000}"
API_CONTAINER_PORT=4000

# Read your host’s DB/Redis URLs (or fallback)
DATABASE_URL="${DATABASE_URL:-mysql://root@localhost:3306/scorecardnotes}"
REDIS_URL="${REDIS_URL:-redis://localhost:6379}"

# ─── Tear down any old containers & network ───────────────
echo "Stopping & removing containers on network '$NETWORK'"
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

# ─── Start Site Origin & Edges & Load Balancer ───────────────────
echo
echo "Starting site origin..."
docker run -d \
  --name "$ORIGIN_SITE_NAME" \
  --network "$NETWORK" \
  -p 8080:80 \
  "$ORIGIN_SITE_IMAGE"

echo
echo "Starting edge-site-us..."
docker run -d \
  --name "$EDGE_SITE_NAME_1" \
  --network "$NETWORK" \
  -p 8081:80 \
  -p 8443:443 \
  -e EDGE_HOSTNAME="$EDGE_SITE_NAME_1" \
  -v "$(pwd)/site/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_SITE_IMAGE"

echo
echo "Starting edge-site-eu..."
docker run -d \
  --name "$EDGE_SITE_NAME_2" \
  --network "$NETWORK" \
  -p 8082:80 \
  -p 8444:443 \
  -e EDGE_HOSTNAME="$EDGE_SITE_NAME_2" \
  -v "$(pwd)/site/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_SITE_IMAGE"

# ─── CDN Site Origin & Edges & Load Balancer ───────────────────
echo
echo "Starting cdn origin..."
docker run -d \
  --name "$ORIGIN_CDN_NAME" \
  --network "$NETWORK" \
  -p 8085:80 \
  "$ORIGIN_CDN_IMAGE"

echo
echo "Starting edge-cdn-us..."
docker run -d \
  --name "$EDGE_CDN_NAME_1" \
  --network "$NETWORK" \
  -p 8086:80 \
  -p 8445:443 \
  -e EDGE_HOSTNAME="$EDGE_CDN_NAME_1" \
  -v "$(pwd)/cdn/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_CDN_IMAGE"

echo
echo "Starting edge-cdn-eu..."
docker run -d \
  --name "$EDGE_CDN_NAME_2" \
  --network "$NETWORK" \
  -p 8087:80 \
  -p 8446:443 \
  -e EDGE_HOSTNAME="$EDGE_CDN_NAME_2" \
  -v "$(pwd)/site/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_CDN_IMAGE"

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
  

# ─── Start Load balancer ───────────────────────────────────────────────
  echo
echo "Starting load balancer..."
docker run -d \
  --name "$LB_NAME" \
  --network "$NETWORK" \
  -p 8090:80 \
  "$LB_IMAGE"

# ─── Test Endpoints ──────────────────────────────────────────
echo
echo "=== Testing Endpoints ==="

echo "Site Origin (8080):"
curl -s -I http://localhost:8080 || true
echo

echo "CDN Origin (8085):"
curl -s -I http://localhost:8085 || true
echo

echo "Load Balancer (8090 – root):"
curl -s -I http://localhost:8090 || true
echo

echo "Site Edge US (HTTP, 8081):"
curl -s -I http://edge-site-us.local:8081/ || true
echo

echo "Site Edge EU (HTTP, 8082):"
curl -s -I http://edge-site-eu.local:8082/ || true
echo

echo "CDN Edge US (HTTP, 8086):"
curl -s -I http://edge-cdn-us.local:8086/ || true
echo

echo "CDN Edge EU (HTTP, 8087):"
curl -s -I http://edge-cdn-eu.local:8087/ || true
echo

echo "API (direct, $API_HOST_PORT):"
curl -s -I http://localhost:${API_HOST_PORT}/api/users || true
echo

echo "API (via LB):"
curl -s -I http://localhost:8090/api/users || true
echo

echo "=== Done ==="