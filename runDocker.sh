#!/bin/sh
    # mount volume to persist state
    # mount folder for logs
    # pass in logdir args to luigid command
docker run -d -p 8081:8082 --name luigid-service \
    -v luigistate:/luigi/state \
    -v /mnt/c/Users/tungm/Projects/luigi-server/log-mjtung-image:/var/log/luigi \
    luigid-service:0.1 \
    --logdir /var/log/luigi  