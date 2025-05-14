# AWS

## ecr

### commands

```shell
aws ecr get-login-password | docker login --username AWS --password-stdin <ecr-repo-uri>
```

## ECS

### commands

```shell
aws ecs describe-services | jq
# enable ECS exec
aws ecs update-service --region <region> --cluster <cluster-name> --service <service-name> --enable-execute-command
# ECS EXEC(login to container)
aws ecs execute-command --region <region> --cluster <cluster-name> --container <container-name> --task <task-id> --interactive --command "/bin/bash"
```

## STS

### commands

```shell
# asusume-roles
aws sts assume-role --role-arn <role-arn> --role-session-name <role-session-name>
# Access key and token are going to be returned,
export AWS_ACCESS_KEY_ID="xxxxxxx"
export AWS_SECRET_ACCESS_KEY="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
export AWS_SESSION_TOKEN="zzzzzzzzzzzz"
aws configure list
# This doesn't affect execution role such as (IAM role for EC2, TskRole for ECS)
# logging out
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
# execute command with profile
aws <command> --profile <profile-name>
# check assume source
aws sts get-caller-identity
```

## S3

### commands

create key

```shell
aws s3api put-bucket --bucket <bucket-name> --key <object-key>
```

put object

```shell
aws s3 cp <file-path> <s3-uri>
```
