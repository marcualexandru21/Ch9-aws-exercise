#!/usr/bin/env bash

export IMAGE=$1
docker-compose -f docker-compose.yaml down --detach
docker-compose -f docker-compose.yaml up --detach
echo "Successssss"