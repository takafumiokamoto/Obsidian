# github actions

## sharing workflow job

You can shere workflow job using the composite action

.github/workflows/parent.yml

```yaml
jobs:
  hoge:
    name: hoge
    timeout-minutes: 3
    runs-on:
      - ubuntu
    steps:
      - uses: ./.github/workflows/child
```

.github/workflows/child/actions.yml

```yaml
runs:
  using: "composite"
  steps:
    - name: child action
      run: echo "hoge"
```

## How to use PostgreSQL in workflow

Postgres needs a couple of seconds to start up.\
Due to supplying the d option, the workflow continues before Postgres starts up.\
Because of that, it should explicitly wait for Postgres's startup.\
The Service Container doesn't have this problem.

```yaml
- name: setup postgres
  env:
    POSTGRES_NAME: db
    POSTGRES_PASSWORD: pass
    POSTGRES_USER: user
  run: |
    docker run -d -p 5432:5432 \
    -e POSTGRES_NAME=${{ env.POSTGRES_NAME }} \
    -e POSTGRES_USER=${{ env.POSTGRES_USER }} \
    -e POSTGRES_PASSWORD=${{ env.POSTGRES_PASSWORD }} \
    --name postgres \
    --health-cmd pg_isready \
    --health-interval 10s \
    --health-timeout 5s \
    --health-retries 5 \
    public.ecr.aws/docker/library/postgres:17
    until docker exec postgres pg_isready; do
      echo "Waiting for PostgreSQL to be ready..."
      sleep 2
    done
    docker exec -i postgres psql -U ${{ env.POSTGRES_USER }} -d ${{ env.POSTGRES_NAME }} < database/init.sql
```

## Formating doesn't work for Github Workflow file in VScode

known problem
<https://stackoverflow.com/questions/76819800/there-is-no-formatter-for-github-actions-workflow-files-installed>
<https://github.com/github/vscode-github-actions/issues/195>

## All composite actions shoud specify 'shell:bash' in every step

You can ommit specifying the default shell unless using composite actions

```yaml
name: Main Workflow

on:
  push:
    branches:
      - main
defaults:
  run:
    shell: bash
jobs:
```

known problem
<https://github.com/orgs/community/discussions/18597>

## Completed on workflow_run

'completed' doesn't mean success of workflow, it means that is has been 'finished'

```yaml
name: hoge
on:
  workflow_run:
    workflows:
      - foo
    types:
      - completed
```

If you want to run a workflow only if previous jobs were successful,\
it can be achieved with the following code.\
The dependent job (later job) should be controlled by the 'needs' keyword.\
This results skipping the workflow.
If you want to prevent triggering workflow, it can be achieved by 'workflow_call' on previous workflow.

```yaml
jobs:
  test-job:
    name: test-job
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    timeout-minutes: 30
    runs-on:
      - ubuntu
  later-job:
    name: later-job
    need: test-job
    timeout-minutes: 30
    runs-on:
      - ubuntu
```
