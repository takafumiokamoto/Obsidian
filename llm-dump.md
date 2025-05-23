Yes, you absolutely can do this in GitHub Actions! It's a common use case for CI/CD pipelines.

You'll essentially translate the shell script logic into workflow steps. Here's how you can structure it:

**Key Components:**

1.  **Trigger:** Decide when this workflow should run (e.g., on push to a specific branch, on manual trigger `workflow_dispatch`).
2.  **AWS Credentials:** Securely provide AWS credentials to your workflow. The recommended way is using OpenID Connect (OIDC) with `aws-actions/configure-aws-credentials`.
3.  **Install `jq`:** The runner environment might not have `jq` pre-installed.
4.  **Fetch, Modify, Register:** These will be `run` steps executing AWS CLI commands.

Here's an example GitHub Actions workflow:

```yaml
name: Update ECS Task Definition Image

on:
  workflow_dispatch: # Allows manual triggering with inputs
    inputs:
      task_family:
        description: 'ECS Task Definition Family (e.g., my-app-task)'
        required: true
        default: 'your-task-definition-family'
      new_image_uri:
        description: 'New Docker Image URI (e.g., 123.dkr.ecr.region.amazonaws.com/repo:tag)'
        required: true
      container_name_to_update:
        description: 'Container name to update (optional; updates first if blank)'
        required: false
      aws_region:
        description: 'AWS Region (e.g., us-east-1)'
        required: true
        default: 'us-east-1'
  # You could also trigger on push to main/master after an image build
  # push:
  #   branches:
  #     - main

jobs:
  update-ecs-image:
    runs-on: ubuntu-latest
    permissions:
      id-token: write # Required for OIDC
      contents: read # Required for actions/checkout

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          # Replace with your IAM Role ARN configured for OIDC
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/YourGitHubActionsECSRole
          aws-region: ${{ github.event.inputs.aws_region }}
          # Alternatively, for static credentials (less secure, use GitHub Secrets):
          # aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          # aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Install jq
        run: sudo apt-get update && sudo apt-get install -y jq

      - name: Fetch current task definition
        id: describe_task_def
        run: |
          echo "Fetching current task definition for family: ${{ github.event.inputs.task_family }}"
          TASK_DEF_FULL_JSON=$(aws ecs describe-task-definition \
            --task-definition "${{ github.event.inputs.task_family }}" \
            --region "${{ github.event.inputs.aws_region }}")

          if [ $? -ne 0 ] || [ -z "$TASK_DEF_FULL_JSON" ]; then
            echo "Error: Failed to fetch task definition for family '${{ github.event.inputs.task_family }}'."
            exit 1
          fi
          # Output the 'taskDefinition' object for the next step
          # This ensures we only pass the relevant part for modification and registration
          TASK_DEF_OBJECT_JSON=$(echo "$TASK_DEF_FULL_JSON" | jq '.taskDefinition')
          echo "task_definition_object<<EOF" >> $GITHUB_OUTPUT
          echo "$TASK_DEF_OBJECT_JSON" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Modify task definition and Register new revision
        id: register_task_def
        env:
          # Make inputs available as environment variables for the script block
          TASK_FAMILY: ${{ github.event.inputs.task_family }}
          NEW_IMAGE_URI: ${{ github.event.inputs.new_image_uri }}
          CONTAINER_NAME_TO_UPDATE: ${{ github.event.inputs.container_name_to_update }}
          AWS_REGION_INPUT: ${{ github.event.inputs.aws_region }}
        run: |
          CURRENT_TASK_DEF_OBJECT='${{ steps.describe_task_def.outputs.task_definition_object }}'

          echo "Current task definition object (first 5 lines of containerDefinitions):"
          echo "$CURRENT_TASK_DEF_OBJECT" | jq '.containerDefinitions' | head -n 5

          if [ -n "$CONTAINER_NAME_TO_UPDATE" ]; then
            echo "Updating image for container '$CONTAINER_NAME_TO_UPDATE' to '$NEW_IMAGE_URI'"
            UPDATED_TASK_DEF_PAYLOAD=$(echo "$CURRENT_TASK_DEF_OBJECT" | jq \
              --arg IMAGE_URI "$NEW_IMAGE_URI" \
              --arg CONTAINER_NAME "$CONTAINER_NAME_TO_UPDATE" '
              (.containerDefinitions[] | select(.name == $CONTAINER_NAME) | .image) = $IMAGE_URI |
              del(.taskDefinitionArn, .revision, .status, .compatibilities, .registeredAt, .registeredBy, .deregisteredAt, .requiresAttributes)
            ')
          else
            echo "CONTAINER_NAME_TO_UPDATE not set. Updating image for the first container to '$NEW_IMAGE_URI'."
            UPDATED_TASK_DEF_PAYLOAD=$(echo "$CURRENT_TASK_DEF_OBJECT" | jq \
              --arg IMAGE_URI "$NEW_IMAGE_URI" '
              .containerDefinitions[0].image = $NEW_IMAGE_URI |
              del(.taskDefinitionArn, .revision, .status, .compatibilities, .registeredAt, .registeredBy, .deregisteredAt, .requiresAttributes)
            ')
          fi

          if [ -z "$UPDATED_TASK_DEF_PAYLOAD" ] || [ "$UPDATED_TASK_DEF_PAYLOAD" == "null" ]; then
              echo "Error: Failed to modify task definition using jq."
              echo "This might happen if CONTAINER_NAME_TO_UPDATE ('$CONTAINER_NAME_TO_UPDATE') was not found,"
              echo "or if the task definition structure is unexpected."
              exit 1
          fi

          echo "--- Payload to be registered (first 15 lines) ---"
          echo "$UPDATED_TASK_DEF_PAYLOAD" | head -n 15
          echo "-------------------------------------------------"

          # Save payload to a temporary file for --cli-input-json
          echo "$UPDATED_TASK_DEF_PAYLOAD" > ./new_task_definition_payload.json

          echo "Registering new task definition revision..."
          REGISTER_OUTPUT=$(aws ecs register-task-definition \
            --region "$AWS_REGION_INPUT" \
            --cli-input-json file://./new_task_definition_payload.json)

          if [ $? -ne 0 ]; then
            echo "Error: Failed to register new task definition revision."
            echo "AWS CLI Output:"
            echo "$REGISTER_OUTPUT"
            exit 1
          fi

          NEW_TASK_DEF_ARN=$(echo "$REGISTER_OUTPUT" | jq -r '.taskDefinition.taskDefinitionArn')
          echo "new_task_def_arn=$NEW_TASK_DEF_ARN" >> $GITHUB_OUTPUT
          echo "Successfully registered new task definition!"
          echo "New Task Definition ARN: $NEW_TASK_DEF_ARN"

      - name: Output New Task Definition ARN
        run: |
          echo "The new task definition ARN is: ${{ steps.register_task_def.outputs.new_task_def_arn }}"
          echo "You might want to use this ARN in a subsequent step to update an ECS service."
          echo "Example: aws ecs update-service --cluster YOUR_CLUSTER --service YOUR_SERVICE --task-definition ${{ steps.register_task_def.outputs.new_task_def_arn }}"
```

**Before using this workflow:**

1.  **Create an IAM Role for GitHub Actions:**
    *   Go to IAM in your AWS console.
    *   Create a new role.
    *   Select "Web identity" as the trusted entity type.
    *   Identity provider: Choose `OpenID Connect provider URL: https://token.actions.githubusercontent.com` (you might need to create this OIDC provider in IAM if it's your first time).
    *   Audience: `sts.amazonaws.com`.
    *   Add permissions: You'll need at least:
        *   `ecs:DescribeTaskDefinition`
        *   `ecs:RegisterTaskDefinition`
        *   (If you plan to update services later): `ecs:UpdateService`, `iam:PassRole` (for the task execution role and task role).
    *   Give the role a name (e.g., `YourGitHubActionsECSRole`).
    *   Note down the ARN of this role.

2.  **Add Secrets to GitHub Repository:**
    *   Go to your GitHub repository > Settings > Secrets and variables > Actions.
    *   Add a new repository secret:
        *   `AWS_ACCOUNT_ID`: Your 12-digit AWS Account ID.
        *   (If not using OIDC) `AWS_ACCESS_KEY_ID`: Your AWS access key.
        *   (If not using OIDC) `AWS_SECRET_ACCESS_KEY`: Your AWS secret key.

3.  **Customize Workflow Inputs:**
    *   Update the `default` values for `task_family` and `aws_region` in the `workflow_dispatch` inputs, or provide them when you run the workflow.
    *   The `new_image_uri` will typically come from a previous step in your CI/CD pipeline that builds and pushes your Docker image (e.g., to ECR). You would then pass that output as an input to this job or this workflow. For this standalone example, it's a manual input.

**How it works:**

1.  **`on: workflow_dispatch`**: Allows you to trigger this workflow manually from the Actions tab in GitHub and provide inputs.
2.  **`permissions`**: Grants the necessary permissions for the OIDC token exchange.
3.  **`aws-actions/configure-aws-credentials@v4`**: This action securely fetches temporary AWS credentials using the OIDC role.
4.  **`Install jq`**: Ensures `jq` is available.
5.  **`Fetch current task definition`**:
    *   Uses `aws ecs describe-task-definition` to get the JSON of the latest active task definition.
    *   Crucially, it then uses `jq '.taskDefinition'` to extract *only the `taskDefinition` object* from the full response. This is because `register-task-definition` expects this object directly, not the entire `describe-task-definition` output.
    *   The `taskDefinition` object is passed to the next step using `GITHUB_OUTPUT`.
6.  **`Modify task definition and Register new revision`**:
    *   Retrieves the `task_definition_object` from the previous step.
    *   Uses `jq` to modify the `image` field within the `containerDefinitions` array. It handles both updating a specific container by name (if `CONTAINER_NAME_TO_UPDATE` is provided) or updating the first container.
    *   It also uses `jq` to `del` (delete) fields that are not allowed or are read-only when registering a new task definition (like `taskDefinitionArn`, `revision`, `status`, etc.).
    *   The modified JSON payload is saved to a temporary file (`./new_task_definition_payload.json`).
    *   `aws ecs register-task-definition --cli-input-json file://./new_task_definition_payload.json` registers the new revision. Using `file://` is robust for passing complex JSON.
    *   The ARN of the newly registered task definition is captured using `jq` and set as an output of this step.
7.  **`Output New Task Definition ARN`**: A simple step to display the ARN. You would typically use this ARN in a subsequent step to update an ECS service.

This workflow provides a solid foundation for automating your ECS task definition updates. Remember to adapt the IAM role permissions and workflow inputs to your specific needs.