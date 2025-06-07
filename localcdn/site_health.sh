#!/usr/bin/env bash
# rebuild_localcdn.sh
# This script stops and removes any containers on the "localcdn-net" network,
# removes and recreates the network, then restarts the origin and two edge containers.

# Edge US: http://localhost:8081 or http://edge‑us.local:8081 (HTTPS: https://edge‑us.local:8443)"
# Edge EU: http://localhost:8082 or http://edge‑eu.local:8082 (HTTPS: https://edge‑eu.local:8444)"
# Load Balancer: http://localhost:8090"
set -e

# === Testing endpoints ===
echo "=== Testing endpoints ==="
echo "Origin:"
curl -s -I http://localhost:8080
echo "Load balancer (root):"
curl -s -I http://localhost:8090
echo "Edge US (HTTP):"
curl -s -I http://edge-us.local:8081
echo "Edge EU (HTTP):"
curl -s -I http://edge-eu.local:8082
echo "API (direct):"
curl -s -I http://localhost:4000/api/users
echo "API (via LB):"
curl -s -I http://localhost:8090/api/users
