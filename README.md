AWS ECS Fargate Service

## Auto-scaling by schedule
https://docs.aws.amazon.com/autoscaling/application/APIReference/API_ScalableTarget.html
1. Register Scalable Targets

    Resource-id is service/{cluster}/{service-name}
    ```
    aws application-autoscaling register-scalable-target \
        --resource-id service/luigid-cluster/luigid-service2 \
        --scalable-dimension ecs:service:DesiredCount \
        --service-namespace ecs \
        --min-capacity 0 --max-capacity 1 \
        --profile mjtung_cmd --region us-west-2
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