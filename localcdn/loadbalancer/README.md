# Load balancer

```
docker build -t localcdn-lb .
```

```
docker run -d \
  --name lb \
  --network localcdn-net \
  -p 8090:80 \
  localcdn-lb
```

```
docker logs --tail 50 localcdn-lb
```
