#!/bin/bash

mkdir -p root-dir
chown 1000:1000 root-dir

docker-compose --env-file env_configs/.env.tf2 up

