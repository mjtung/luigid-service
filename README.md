# AWS ECS Fargate Service

This Docker service runs a Luigi daemon.  I've set this up in AWS ECS, running as a Fargate service.

## Auto-scaling by schedule

We auto-scale to turn off the service in off-hours, saving resources.
Auto-scaling on a schedule is only available via the AWS CLI.

https://docs.aws.amazon.com/autoscaling/application/APIReference/API_ScalableTarget.html
https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-scheduled-scaling.html
1. Register Scalable Targets

    Resource-id is service/{cluster}/{service-name}
    ```
    aws application-autoscaling register-scalable-target \
        --resource-id service/luigid-cluster/luigid-service2 \
        --scalable-dimension ecs:service:DesiredCount \
        --service-namespace ecs \
        --min-capacity 1 --max-capacity 1 \
    ```
    Verify

    ```
    aws application-autoscaling describe-scalable-targets --service-namespace ecs
    ```
2. Scale out schedule

    One time schedule: `--schedule "at(2021-03-31T22:00:00)"`
    Cron schedule: `--schedule "cron(cron expression)"`

    We set schedule to be *Mon-Sat, 0:00 AM, UTC*
    ```
    aws application-autoscaling put-scheduled-action --service-namespace ecs \
        --scalable-dimension ecs:service:DesiredCount \
        --resource-id service/luigid-cluster/luigid-service2 \
        --scheduled-action-name scale-out \
        --schedule "cron(0 0 ? * 2-7 *)" \
        --scalable-target-action MinCapacity=1,MaxCapacity=1 \
    ```

3. Scale in schedule

    One time schedule: `--schedule "at(2021-03-31T22:00:00)"`
    Cron schedule: `--schedule "cron(cron expression)"`

    We set scale-in schedule to be *Mon-Sat, 10:00AM, UTC*
    ```
    aws application-autoscaling put-scheduled-action --service-namespace ecs \
        --scalable-dimension ecs:service:DesiredCount \
        --resource-id service/luigid-cluster/luigid-service2 \
        --scheduled-action-name scale-in \
        --schedule "cron(0 10 ? * 2-7 *)" \
        --scalable-target-action MaxCapacity=0,MinCapacity=0 \
    ```

4. Verify
    ```
    aws application-autoscaling describe-scheduled-actions --service-namespace ecs
    ```

5. Delete / Remove
    ```
    aws application-autoscaling delete-scheduled-action --service-namespace ecs \
        --scalable-dimension ecs:service:DesiredCount \
        --resource-id service/luigid-cluster/luigid-service2 \
        --scheduled-action-name scale-in \
    ```

## Service Discovery with Route53

The Fargate service uses Service Discovery with Route53, so that the Luigi worker tasks may communicate with the Daemon.  Because the service is running on a schdule, the IP-address of the Luigi Daemon is dynamic - it can be different every time it starts up.  Route 53 is a DNS service that maps {service-discovery-service}.{service-discovery-namespace} to the dynamic IP address.  Therefore, to call the service, we only need to access `http://{service-discovery-service}.{service-discovery-namespace}`

If you check the NGINX conf file in the Luigi Task repository, it sets the DNS resolver to `10.0.0.2`.  The `*.*.*.2` address is the default VPC DNS resolver in AWS.  This assumes that the Luigi Daemon service must be running on the `10.0.0.*` subnet of the VPC.