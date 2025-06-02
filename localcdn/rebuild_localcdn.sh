#!/usr/bin/env bash
# rebuild_localcdn.sh
# This script stops and removes any containers on the "localcdn-net" network,
# removes and recreates the network, then restarts the origin and edge containers.

set -e

NETWORK="localcdn-net"
ORIGIN_IMAGE="localcdn-origin"
EDGE_IMAGE="localcdn-edge"
ORIGIN_NAME="origin"
EDGE_NAME_1="edge-us"
EDGE_NAME_2="edge-eu"

echo "=== Stopping and removing containers on network '$NETWORK' ==="
# Get all container names attached to the network
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
echo "=== Starting edge container ==="
docker run -d \
  --name "$EDGE_NAME_1" \
  --network "$NETWORK" \
  -p 8081:80 \
  "$EDGE_IMAGE"

echo
echo "=== Starting edge 2 container ==="
docker run -d \
  --name "$EDGE_NAME_2" \
  --network "$NETWORK" \
  -p 8082:80 \
  "$EDGE_IMAGE"

echo
echo "Local CDN environment setup complete."
echo " - Origin: http://localhost:8080"
echo " - Edge1:   http://localhost:8081 or http://edge-us.local:8081/"
echo " - Edge2:   http://localhost:8082 or http://edge-eu.local:8082/"