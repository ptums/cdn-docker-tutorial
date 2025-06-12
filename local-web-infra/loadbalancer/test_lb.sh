#!/usr/bin/env bash

for i in $(seq 1 5); do
  curl -s -I http://lb.local:8090/ | grep "X-Backend-Server"
done
