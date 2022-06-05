#!/usr/bin/env bash

# Create nwo docker network
docker network create nwo-network

# Teardown old containers and resources gracefully if it exits
docker stop kong-api-gateway
docker rm kong-api-gateway
docker network disconnect nwo-network kong-api-gateway

# Build docker image - uses layer caching
docker build -t kong-api-gateway .

# Builds local docker image
docker run -d \
    --name kong-api-gateway \
    --net nwo-network \
    -e "KONG_DATABASE=off" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    kong-api-gateway

# wait for container to finish spinning up
sleep 5

# Initialize kong declarative config
http :8001/config config=@kong.yml
# docker exec -it kong kong reload

# Follow log output - for debugging or other
docker logs -f kong-api-gateway