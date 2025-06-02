# Start edge container

```
# Build the edge image
docker build -t localcdn-edge .

# Run the edge, attach to same network. Name it "edge"
docker run -d \
  --name edge \
  --network localcdn-net \
  -p 8081:80 \
  localcdn-edge
```

```
Build a second one to mimic Multiple Edge Nodes servers
# From ~/localcdn/edge/ (where Dockerfile + nginx.conf live)
docker build -t localcdn-edge .

# Run a second edge, call it edge2, listening on port 8082
docker run -d \
  --name edge2 \
  --network localcdn-net \
  -p 8082:80 \
  localcdn-edge
```

```
Generate a cert for edge servers

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout server.key \
  -out server.crt \
  -subj "/CN=edge.local"
```
