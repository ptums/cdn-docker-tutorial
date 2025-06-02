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
