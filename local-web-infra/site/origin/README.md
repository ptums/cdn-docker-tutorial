```
# Build the edge image
docker build -t localwebinfa-origin .

# Run the edge, attach to same network. Name it "edge"
docker run -d \
  --name edge \
  --network localwebinfa-net \
  -p 8081:80 \
  localwebinfa-edge
```
