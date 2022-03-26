#!/bin/bash
cd ~/my_autoware/docker/

docker build \
    --tag koutaohishi/autoware \
    --network host \
    .
