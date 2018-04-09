#!/bin/bash

docker-compose up -d --build --scale web=4 --scale consumer=4

# For simplicity reasons set config right here
docker-compose exec redis-master redis-cli config set notify-keyspace-events Kx

docker-compose logs -f --tail 5 netcat