#!/bin/sh
    # create service (ie. swarm mode)
    # can add repliacas=X flag to make it run X instances
    # mount volume to persist state
    # mount folder for logs
    # pass in logdir args to luigid command
docker service create -d -p 8082:8082 --name docker-luigid-service \
    --replicas=2 \
    --mount type=volume,source=luigistate,destination=/luigi/state \
    --mount type=bind,source=/mnt/c/Users/tungm/Projects/luigi-server/log-mjtung-image,destination=/var/log/luigi \
    mjtung/luigid-service \
    --logdir /var/log/luigi  