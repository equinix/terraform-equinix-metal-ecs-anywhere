# AWS ECS Anywhere on Equinix Metal

## Pre-Requisites

## Deployment

```
aws ecr get-login-password --region $(terraform output -raw aws-region) | docker login --password-stdin --username AWS $(terraform output -raw ecr-url)
docker build -t $(terraform output -raw ecr-url) ./app
docker push $(terraform output -raw ecr-url)
```

```
sed -e s#CHANGEME_IMAGE#$(terraform output -raw ecr-url)# \
    -e s#CHANGEME_EXECUTION_ROLE_ARN#$(terraform output -raw iam-exec-role)# \
    -e s#CHANGEME_TASK_ROLE_ARN#$(terraform output -raw iam-task-role)# \
    -e s#CHANGEME_AWSLOGS_GROUP#"ecs-external-"$(terraform output -raw ecs-cluster)# \
    -e s#CHANGEME_REGION#$(terraform output -raw aws-region)# \
    -e s#CHANGEME_SQS_QUEUE_URL#$(terraform output -raw sqs-url)# \
    templates/ecs_task_definition-template.json > ecs_task_definition.json
aws ecs register-task-definition --cli-input-json file://ecs_task_definition.json --region $(terraform output -raw aws-region)
aws ecs create-service --service-name ecsworker-external-service --cluster $(terraform output -raw ecs-cluster) --launch-type EXTERNAL --desired-count 1 --task-definition ecsworker-external --region $(terraform output -raw aws-region)
```

## Testing

```
watch ls -la /data/sourcefolder/
watch ls -la /data/destinationfolder/

for i in `seq 10 20`; do touch /data/sourcefolder/0$i; done
```

```
for i in `seq 10 20`; do aws sqs send-message --queue-url $(terraform output -raw sqs-url-public) --region $(terraform output -raw aws-region) --message-body "0$i"; done
```