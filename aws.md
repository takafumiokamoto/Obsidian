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
# ECS EXEC有効
aws ecs update-service --region <region> --cluster <cluster-name> --service <service-name> --enable-execute-command
# ECS EXEC(コンテナに入る)
aws ecs execute-command --region <region> --cluster <cluster-name> --container <container-name> --task <task-id> --interactive --command "/bin/bash"
```

## STS

### commands

```shell
# asusume-rolesする
aws sts assume-role --role-arn <role-arn> --role-session-name <role-session-name>
#トークン情報がjsonで変えてくるので、それぞれを環境変数に設定
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
そのあとaws configure
# プロファイルを指定して実行
aws <command> --profile <profile-name>
# assume元確認
aws sts get-caller-identity
```
