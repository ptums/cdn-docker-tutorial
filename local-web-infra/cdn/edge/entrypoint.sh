#!/usr/bin/env sh
set -e

# Replace ${EDGE_HOSTNAME} in the template, write final config
envsubst '${CDN_HOSTNAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start Nginx in foreground
exec nginx -g 'daemon off;'