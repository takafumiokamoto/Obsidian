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
aws configure --profile new-profile-name
AWS Access Key ID [None]: XXXXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXX
Default region name [None]: ap-northeast-1
Default output format [None]: json
# execute command with profile
aws <command> --profile <profile-name>
# check assume source
aws sts get-caller-identity
```
