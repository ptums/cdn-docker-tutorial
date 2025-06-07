#!/usr/bin/env bash
# rebuild_localcdn.sh
# This script stops and removes any containers on the "localcdn-net" network,
# removes and recreates the network, then restarts the origin and two edge containers.

# Edge US: http://localhost:8081 or http://edge‑us.local:8081 (HTTPS: https://edge‑us.local:8443)"
# Edge EU: http://localhost:8082 or http://edge‑eu.local:8082 (HTTPS: https://edge‑eu.local:8444)"
# Load Balancer: http://localhost:8090"
set -e

  echo "Load balancer "
  curl -s -I http://lb.local:8090/ 
  echo "Edge Us (http): "
  curl -s -I http://edge-us.local:8081/ 
  echo "API "
  curl -I http://lb.local:8090/

