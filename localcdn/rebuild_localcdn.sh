#!/usr/bin/env bash
# rebuild_localcdn.sh
# This script stops and removes any containers on the "localcdn-net" network,
# removes and recreates the network, then restarts the origin and two edge containers.

set -e

NETWORK="localcdn-net"
ORIGIN_IMAGE="localcdn-origin"
EDGE_IMAGE="localcdn-edge"
ORIGIN_NAME="origin"
EDGE_NAME_1="edge-us.local"
EDGE_NAME_2="edge-eu.local"

echo "=== Stopping and removing containers on network '$NETWORK' ==="
containers=$(docker ps -a --filter "network=$NETWORK" --format "{{.Names}}")

if [ -n "$containers" ]; then
  for name in $containers; do
    echo "Stopping container: $name"
    docker stop "$name" >/dev/null 2>&1 || true
    echo "Removing container: $name"
    docker rm "$name" >/dev/null 2>&1 || true
  done
else
  echo "No containers found on '$NETWORK'."
fi

echo
echo "=== Removing network '$NETWORK' (if it exists) ==="
docker network rm "$NETWORK" >/dev/null 2>&1 || true

echo
echo "=== Creating network '$NETWORK' ==="
docker network create "$NETWORK"

echo
echo "=== Starting origin container ==="
docker run -d \
  --name "$ORIGIN_NAME" \
  --network "$NETWORK" \
  -p 8080:80 \
  "$ORIGIN_IMAGE"

echo
echo "=== Starting edge‑US container ==="
docker run -d \
  --name "$EDGE_NAME_1" \
  --network "$NETWORK" \
  -p 8081:80 \
  -p 8443:443 \
  -e EDGE_HOSTNAME="$EDGE_NAME_1" \
  -v "$(pwd)/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_IMAGE"

echo
echo "=== Starting edge‑EU container ==="
docker run -d \
  --name "$EDGE_NAME_2" \
  --network "$NETWORK" \
  -p 8082:80 \
  -p 8444:443 \
  -e EDGE_HOSTNAME="$EDGE_NAME_2" \
  -v "$(pwd)/edge/certs":/etc/nginx/certs:ro \
  "$EDGE_IMAGE"

echo
echo "Local CDN environment setup complete."
echo " - Origin:  http://localhost:8080"
echo " - Edge US: http://localhost:8081 or http://edge‑us.local:8081 (HTTPS: https://edge‑us.local:8443)"
echo " - Edge EU: http://localhost:8082 or http://edge‑eu.local:8082 (HTTPS: https://edge‑eu.local:8444)"