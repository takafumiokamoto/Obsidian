# Self-hosted Runner on ECS Fargate with GitHub App and Docker-in-Docker
Created: 6/9/2025, 1:01:26 AM
Last Updated: 6/9/2025, 1:14:21 AM
---

### User

I want to set up a self-hosted runner for GitHub and have decided to use AWS ECS Fargate for hosting.
However, I have two concerns with this approach:
Firstly, a Personal Access Token (PAT) is required to retrieve the runner registration token on startup, which I would like to avoid.
Secondly, since Fargate doesn't allow privileged containers, running Docker commands inside the self-hosted runner will be problematic.
I would like you to create a comprehensive guide to solve this problem.
The guide must meet the following requirements:
- Use GitHub App for authentication.
- Use CloudFormation to create AWS resources.
- Use Python to create an entrypoint script for the Docker container.
- Use the docker-in-docker sidecar pattern.

To start, could you please show me the title of each step? I will ask you about them individually afterwards.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants to set up a self-hosted GitHub runner on AWS ECS Fargate with specific requirements to address two main concerns:

1. Avoiding Personal Access Token (PAT) by using GitHub App authentication
2. Solving Docker-in-Docker issues on Fargate (which doesn't support privileged containers) using a sidecar pattern

The requirements are:
- Use GitHub App for authentication
- Use CloudFormation for AWS resources
- Use Python for entrypoint script
- Use docker-in-docker sidecar pattern

I need to break this down into logical steps that would comprehensively solve this problem. Let me think about the overall architecture and steps needed:

1. Create a GitHub App for authentication
2. Set up AWS infrastructure with CloudFormation (IAM roles, ECS cluster, task definition, etc.)
3. Create the main runner container with Python entrypoint
4. Set up the Docker-in-Docker sidecar container
5. Configure the ECS task definition to use both containers
6. Handle GitHub App authentication and token retrieval
7. Deploy and test the solution

Let me structure this as a comprehensive guide with clear step titles.
</details>

Here's a comprehensive guide to set up a self-hosted GitHub runner on AWS ECS Fargate using GitHub App authentication and Docker-in-Docker sidecar pattern:

## Step-by-Step Guide: Self-Hosted GitHub Runner on ECS Fargate

### Step 1: Create and Configure GitHub App
Set up GitHub App with necessary permissions for runner registration

### Step 2: Setup AWS IAM Roles and Policies
Create IAM roles for ECS task execution and GitHub App authentication

### Step 3: Store GitHub App Credentials in AWS Secrets Manager
Securely store GitHub App private key and configuration

### Step 4: Create Docker Images
Build custom Docker images for the runner and Docker-in-Docker sidecar

### Step 5: Develop Python Entrypoint Script
Create the main application logic for GitHub App authentication and runner registration

### Step 6: Configure ECS Task Definition
Set up the multi-container task with proper networking and volume sharing

### Step 7: Deploy CloudFormation Stack
Create all AWS resources including ECS cluster, service, and supporting infrastructure

### Step 8: Setup Auto-scaling and Monitoring
Configure auto-scaling policies and CloudWatch monitoring

### Step 9: Test and Validate the Setup
Verify runner registration and Docker functionality

### Step 10: Maintenance and Troubleshooting
Best practices for ongoing maintenance and common issues

Which step would you like me to elaborate on first?


---

### User

Let's dive into Step 1.
Remember, you should be as detailed and comprehensive as possible.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants a detailed and comprehensive guide for Step 1: Create and Configure GitHub App. This is about setting up a GitHub App that can be used for authentication instead of a Personal Access Token (PAT). I need to cover:

1. What is a GitHub App and why it's better than PAT for this use case
2. How to create a GitHub App
3. What permissions are needed
4. How to configure the app properly
5. How to generate and download the private key
6. Important considerations for security

I should be very detailed and provide step-by-step instructions with screenshots references where appropriate.
</details>

# Step 1: Create and Configure GitHub App

## Overview
GitHub Apps provide a more secure and scalable alternative to Personal Access Tokens (PATs) for authenticating self-hosted runners. Unlike PATs, GitHub Apps can be scoped to specific repositories or organizations and don't require a user account, making them ideal for automated systems.

## Prerequisites
- Administrator access to the GitHub repository or organization where you want to register runners
- Understanding of GitHub App permissions model

## 1.1 Navigate to GitHub App Creation

### For Organization-level App:
1. Go to your GitHub organization
2. Click **Settings** in the top navigation bar
3. In the left sidebar, click **Developer settings**
4. Click **GitHub Apps**
5. Click **New GitHub App**

### For Repository-level App:
1. Navigate to your repository
2. Click **Settings** tab
3. In the left sidebar, click **Developer settings**
4. Click **GitHub Apps**
5. Click **New GitHub App**

## 1.2 Configure Basic App Information

Fill out the following required fields:

### GitHub App name
```
my-org-self-hosted-runners
```
*Note: This name must be unique across all GitHub Apps*

### Description
```
Self-hosted GitHub Actions runner for ECS Fargate deployment
```

### Homepage URL
```
https://github.com/your-org/your-repo
```
*Use your organization or repository URL*

### Webhook Configuration
- **Webhook URL**: Leave blank (not needed for runner registration)
- **Webhook secret**: Leave blank
- **SSL verification**: Enable SSL verification (checked)

## 1.3 Configure Repository Permissions

Set the following permissions for your GitHub App:

### Repository permissions:
| Permission | Access Level | Purpose |
|------------|--------------|---------|
| **Actions** | Write | Register and manage self-hosted runners |
| **Administration** | Read | Access repository settings for runner registration |
| **Metadata** | Read | Access basic repository information |
| **Pull requests** | Write | Allow runners to update PR status (optional) |
| **Checks** | Write | Allow runners to create check runs (optional) |
| **Contents** | Read | Allow runners to checkout code |

### Organization permissions (if creating org-level app):
| Permission | Access Level | Purpose |
|------------|--------------|---------|
| **Self-hosted runners** | Write | Manage organization-level runners |
| **Administration** | Read | Access organization settings |

## 1.4 Configure Account Permissions

Leave all account permissions set to **No access** unless you have specific requirements.

## 1.5 Configure Installation Settings

### Where can this GitHub App be installed?
- Select **Only on this account** for security
- This restricts the app to your organization/account only

## 1.6 Create the GitHub App

1. Review all settings
2. Click **Create GitHub App**
3. You'll be redirected to your new GitHub App's settings page

## 1.7 Generate and Download Private Key

1. On your GitHub App settings page, scroll down to **Private keys**
2. Click **Generate a private key**
3. A `.pem` file will be automatically downloaded
4. **Important**: Store this file securely - you cannot download it again

### Private Key Security Notes:
- The private key is used to generate JWT tokens for authentication
- Never commit this key to version control
- Store it in AWS Secrets Manager (covered in Step 3)
- The key cannot be regenerated - you can only create new keys

## 1.8 Note Important App Information

Record the following information from your GitHub App settings:

### App ID
Found at the top of the settings page:
```
App ID: 123456
```

### Installation ID
1. Click **Install App** in the left sidebar
2. Click **Install** next to your organization/account
3. Choose repositories (select specific repositories or all repositories)
4. Click **Install**
5. Note the installation ID from the URL: `https://github.com/settings/installations/12345678`

### Client ID
Found in the **General** section:
```
Client ID: Iv1.a1b2c3d4e5f6g7h8
```

## 1.9 Verify App Installation

1. Navigate to your repository or organization settings
2. Go to **Actions** → **Runners**
3. You should see an option to "Add runner" (this confirms proper permissions)

## 1.10 Example Environment Variables

You'll need these values for later steps:

```bash
GITHUB_APP_ID=123456
GITHUB_APP_INSTALLATION_ID=12345678
GITHUB_APP_CLIENT_ID=Iv1.a1b2c3d4e5f6g7h8
GITHUB_PRIVATE_KEY_PATH=/path/to/private-key.pem
```

## 1.11 Security Best Practices

### Private Key Management:
- Never store the private key in plain text in your code
- Use AWS Secrets Manager to store the private key securely
- Rotate keys periodically (GitHub allows multiple active keys)

### App Permissions:
- Follow principle of least privilege
- Only grant permissions your runners actually need
- Review permissions periodically

### Installation Scope:
- Limit app installation to specific repositories when possible
- Monitor app usage in GitHub's audit logs

## 1.12 Testing App Authentication

You can test your GitHub App authentication using curl:

```bash
# Generate JWT token (you'll implement this in Python later)
JWT_TOKEN="your-jwt-token-here"

# Test authentication
curl -H "Authorization: Bearer $JWT_TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/app
```

## Common Issues and Troubleshooting

### Issue: "App not found" error
- **Solution**: Verify App ID is correct and app is installed on the target repository/organization

### Issue: Permission denied when registering runners
- **Solution**: Ensure "Actions" permission is set to "Write" and "Administration" is set to "Read"

### Issue: Private key authentication failures
- **Solution**: Verify the private key file format and ensure it hasn't been corrupted during transfer

## Next Steps

With your GitHub App created and configured, you now have:
- App ID for identification
- Installation ID for targeting your organization/repository
- Private key for authentication
- Proper permissions for runner registration

In Step 2, we'll create the necessary AWS IAM roles and policies to securely use these credentials in your ECS Fargate environment.


---

### User

Let's move on to  Step 2.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants to move on to Step 2, which is about setting up AWS IAM roles and policies for the GitHub runner on ECS Fargate. This step needs to be comprehensive and detailed, covering:

1. ECS Task Execution Role - for basic ECS operations
2. ECS Task Role - for the application-level permissions the containers need
3. Policies for accessing Secrets Manager (for GitHub App credentials)
4. Policies for ECS operations
5. Policies for CloudWatch logging
6. Trust relationships
7. Security best practices

I should provide the actual IAM policy documents and explain what each permission does and why it's needed.
</details>

# Step 2: Setup AWS IAM Roles and Policies

## Overview
AWS IAM roles and policies are essential for securely running your GitHub self-hosted runner on ECS Fargate. We need two primary roles: an ECS Task Execution Role (for AWS service operations) and an ECS Task Role (for application-level permissions). This step ensures your containers can access GitHub App credentials from Secrets Manager, write logs to CloudWatch, and perform necessary ECS operations.

## Prerequisites
- AWS CLI configured with appropriate permissions
- Administrator access to AWS IAM (or permissions to create roles and policies)
- Understanding of IAM roles, policies, and trust relationships

## 2.1 Understanding Required IAM Roles

### ECS Task Execution Role
- Used by the ECS service to start and manage containers
- Handles container image pulling, logging setup, and Secrets Manager access
- Required for all Fargate tasks

### ECS Task Role
- Used by the application code running inside containers
- Provides permissions for application-specific operations
- Optional but recommended for security

## 2.2 Create ECS Task Execution Role

### 2.2.1 Trust Policy for ECS Task Execution Role

Create the trust relationship document:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowECSTasksAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 2.2.2 Create the ECS Task Execution Role

Using AWS CLI:
```bash
# Create the role
aws iam create-role \
  --role-name GitHubRunnerECSTaskExecutionRole \
  --assume-role-policy-document file://ecs-task-execution-trust-policy.json \
  --description "ECS Task Execution Role for GitHub self-hosted runners"
```

### 2.2.3 Custom Policy for ECS Task Execution Role

Create a custom policy for enhanced logging and Secrets Manager access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/ecs/github-runner*",
        "arn:aws:logs:*:*:log-group:/ecs/github-runner*:*"
      ]
    },
    {
      "Sid": "ECRPermissions",
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ECRAuthPermissions",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerPermissions",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": [
        "arn:aws:secretsmanager:*:*:secret:github-runner/*"
      ]
    }
  ]
}
```

### 2.2.4 Attach Policies to ECS Task Execution Role

```bash
# Create and attach custom policy
aws iam create-policy \
  --policy-name GitHubRunnerECSTaskExecutionPolicy \
  --policy-document file://ecs-task-execution-policy.json \
  --description "Custom policy for GitHub runner ECS task execution"

# Attach the custom policy
aws iam attach-role-policy \
  --role-name GitHubRunnerECSTaskExecutionRole \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubRunnerECSTaskExecutionPolicy

# Attach AWS managed policy for basic ECS task execution
aws iam attach-role-policy \
  --role-name GitHubRunnerECSTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

## 2.3 Create ECS Task Role

### 2.3.1 Trust Policy for ECS Task Role

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowECSTasksAssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 2.3.2 Create the ECS Task Role

```bash
# Create the role
aws iam create-role \
  --role-name GitHubRunnerECSTaskRole \
  --assume-role-policy-document file://ecs-task-trust-policy.json \
  --description "ECS Task Role for GitHub self-hosted runners application code"
```

### 2.3.3 Custom Policy for ECS Task Role

Create a policy for application-level permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SecretsManagerReadAccess",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:*:*:secret:github-runner/*"
      ]
    },
    {
      "Sid": "CloudWatchLogsWriteAccess",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:*:*:log-group:/ecs/github-runner*:*"
      ]
    },
    {
      "Sid": "ECSTaskMetadata",
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTasks",
        "ecs:DescribeTaskDefinition"
      ],
      "Resource": "*"
    },
    {
      "Sid": "SSMParameterStore",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:parameter/github-runner/*"
      ]
    }
  ]
}
```

### 2.3.4 Attach Policy to ECS Task Role

```bash
# Create and attach custom policy
aws iam create-policy \
  --policy-name GitHubRunnerECSTaskPolicy \
  --policy-document file://ecs-task-policy.json \
  --description "Custom policy for GitHub runner ECS task application code"

# Attach the custom policy
aws iam attach-role-policy \
  --role-name GitHubRunnerECSTaskRole \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/GitHubRunnerECSTaskPolicy
```

## 2.4 Create Auto Scaling Role (Optional)

If you plan to use auto-scaling for your ECS service:

### 2.4.1 Trust Policy for Auto Scaling

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 2.4.2 Create Auto Scaling Role

```bash
# Create the role
aws iam create-role \
  --role-name GitHubRunnerAutoScalingRole \
  --assume-role-policy-document file://autoscaling-trust-policy.json \
  --description "Auto Scaling Role for GitHub runner ECS service"

# Attach AWS managed policy
aws iam attach-role-policy \
  --role-name GitHubRunnerAutoScalingRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSServiceRolePolicy
```

## 2.5 Create CloudFormation Deployment Role

For deploying your infrastructure via CloudFormation:

### 2.5.1 Trust Policy for CloudFormation

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudformation.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### 2.5.2 CloudFormation Deployment Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECSFullAccess",
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMRoleManagement",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PassRole",
        "iam:GetRole",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies"
      ],
      "Resource": [
        "arn:aws:iam::*:role/GitHubRunner*"
      ]
    },
    {
      "Sid": "VPCManagement",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeAvailabilityZones"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:DeleteLogGroup",
        "logs:DescribeLogGroups",
        "logs:PutRetentionPolicy"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ApplicationAutoScaling",
      "Effect": "Allow",
      "Action": [
        "application-autoscaling:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## 2.6 Verification and Testing

### 2.6.1 Verify Role Creation

```bash
# List all GitHub runner related roles
aws iam list-roles --query 'Roles[?contains(RoleName, `GitHubRunner`)].{RoleName:RoleName,CreateDate:CreateDate}'

# Get specific role details
aws iam get-role --role-name GitHubRunnerECSTaskExecutionRole
aws iam get-role --role-name GitHubRunnerECSTaskRole
```

### 2.6.2 Verify Policy Attachments

```bash
# Check attached policies for task execution role
aws iam list-attached-role-policies --role-name GitHubRunnerECSTaskExecutionRole

# Check attached policies for task role
aws iam list-attached-role-policies --role-name GitHubRunnerECSTaskRole
```

### 2.6.3 Test Role Assumption (Optional)

```bash
# Test assuming the task execution role
aws sts assume-role \
  --role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerECSTaskExecutionRole \
  --role-session-name test-session
```

## 2.7 Security Best Practices

### Principle of Least Privilege
- Only grant permissions that are absolutely necessary
- Use resource-level restrictions where possible (e.g., specific S3 buckets, log groups)
- Regularly review and audit permissions

### Resource Naming Convention
- Use consistent naming patterns for easy identification
- Include environment indicators (dev, staging, prod)
- Example: `GitHubRunnerECSTaskExecutionRole-prod`

### Policy Versioning
- Keep track of policy changes
- Use version comments in policy documents
- Test policies in development environments first

### Monitoring and Auditing
- Enable CloudTrail for IAM actions
- Set up CloudWatch alarms for unusual IAM activity
- Regularly review access patterns

## 2.8 Role ARNs Summary

After completing this step, you'll have the following role ARNs:

```bash
# Task Execution Role
arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerECSTaskExecutionRole

# Task Role
arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerECSTaskRole

# Auto Scaling Role (if created)
arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerAutoScalingRole

# CloudFormation Role (if created)
arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerCloudFormationRole
```

## Common Issues and Troubleshooting

### Issue: "AccessDenied" when ECS tries to pull secrets
- **Solution**: Verify the task execution role has `secretsmanager:GetSecretValue` permission and the resource ARN matches your secret

### Issue: Container fails to start with logging errors
- **Solution**: Check that the task execution role has CloudWatch Logs permissions and the log group exists

### Issue: "Invalid principal" error when creating roles
- **Solution**: Ensure the service principals are correct (`ecs-tasks.amazonaws.com` for ECS roles)

### Issue: CloudFormation deployment fails with permission errors
- **Solution**: Verify the CloudFormation role has all necessary permissions for the resources being created

## Next Steps

With your IAM roles and policies configured, you now have:
- Secure access patterns for ECS task execution
- Application-level permissions for GitHub App authentication
- Proper resource isolation and security boundaries

In Step 3, we'll store your GitHub App credentials securely in AWS Secrets Manager, leveraging the IAM roles we just created.


---

### User

Now move on to Step 3.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants me to continue with Step 3, which is about storing GitHub App credentials in AWS Secrets Manager. This step should be comprehensive and detailed, covering:

1. Creating secrets in Secrets Manager
2. Storing the GitHub App private key securely
3. Storing other GitHub App configuration data
4. Setting up proper IAM permissions (which we already covered in Step 2)
5. Best practices for secret management
6. Testing access to secrets
7. Rotation strategies
8. CloudFormation integration for secret creation

I should provide detailed instructions, examples, and best practices while being comprehensive.
</details>

# Step 3: Store GitHub App Credentials in AWS Secrets Manager

## Overview
AWS Secrets Manager provides secure, encrypted storage for sensitive information like GitHub App private keys and configuration data. This step establishes a secure foundation for your GitHub runner authentication, enabling automatic secret rotation and fine-grained access control through the IAM roles we created in Step 2.

## Prerequisites
- Completed Step 1 (GitHub App created with private key downloaded)
- Completed Step 2 (IAM roles and policies configured)
- AWS CLI configured with appropriate permissions
- GitHub App private key file (.pem) securely stored locally

## 3.1 Understanding Secret Structure

We'll create separate secrets for different types of data:

### Primary GitHub App Secret
- **Name**: `github-runner/app-credentials`
- **Content**: GitHub App private key and core configuration
- **Access**: ECS Task Execution Role and ECS Task Role

### Runner Configuration Secret
- **Name**: `github-runner/runner-config`
- **Content**: Runner-specific settings and labels
- **Access**: ECS Task Role only

## 3.2 Prepare GitHub App Private Key

### 3.2.1 Validate Private Key Format

Ensure your private key is in the correct format:

```bash
# Check if the private key is valid
openssl rsa -in your-github-app-private-key.pem -check -noout

# View key details (optional)
openssl rsa -in your-github-app-private-key.pem -text -noout | head -20
```

### 3.2.2 Convert Private Key for JSON Storage

Since we'll store the key in JSON format, we need to handle newlines properly:

```bash
# Convert private key to single-line format for JSON
PRIVATE_KEY_CONTENT=$(cat your-github-app-private-key.pem | sed ':a;N;$!ba;s/\n/\\n/g')
echo "Private key prepared for JSON storage"
```

## 3.3 Create GitHub App Credentials Secret

### 3.3.1 Prepare Secret Value

Create a JSON file with your GitHub App credentials:

```json
{
  "app_id": "123456",
  "installation_id": "12345678",
  "client_id": "Iv1.a1b2c3d4e5f6g7h8",
  "private_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...\n-----END RSA PRIVATE KEY-----",
  "github_api_url": "https://api.github.com",
  "github_url": "https://github.com"
}
```

Save this as `github-app-credentials.json`.

### 3.3.2 Create the Secret Using AWS CLI

```bash
# Create the primary GitHub App credentials secret
aws secretsmanager create-secret \
  --name "github-runner/app-credentials" \
  --description "GitHub App credentials for self-hosted runners" \
  --secret-string file://github-app-credentials.json \
  --tags '[
    {
      "Key": "Project",
      "Value": "GitHubRunner"
    },
    {
      "Key": "Environment",
      "Value": "production"
    },
    {
      "Key": "ManagedBy",
      "Value": "CloudFormation"
    }
  ]'
```

### 3.3.3 Verify Secret Creation

```bash
# List secrets to confirm creation
aws secretsmanager list-secrets \
  --query 'SecretList[?contains(Name, `github-runner`)].{Name:Name,Description:Description,LastChangedDate:LastChangedDate}'

# Test retrieving the secret (without showing the value)
aws secretsmanager describe-secret \
  --secret-id "github-runner/app-credentials"
```

## 3.4 Create Runner Configuration Secret

### 3.4.1 Prepare Runner Configuration

Create a JSON file with runner-specific settings:

```json
{
  "repository_owner": "your-org",
  "repository_name": "your-repo",
  "runner_group": "default",
  "runner_labels": ["self-hosted", "linux", "x64", "fargate", "docker"],
  "runner_name_prefix": "fargate-runner",
  "work_directory": "/actions-runner/_work",
  "runner_scope": "repository",
  "max_jobs": 1,
  "ephemeral": true,
  "disable_update": true,
  "unattended": true
}
```

Save this as `runner-config.json`.

### 3.4.2 Create Runner Configuration Secret

```bash
# Create the runner configuration secret
aws secretsmanager create-secret \
  --name "github-runner/runner-config" \
  --description "GitHub Actions runner configuration settings" \
  --secret-string file://runner-config.json \
  --tags '[
    {
      "Key": "Project",
      "Value": "GitHubRunner"
    },
    {
      "Key": "Environment",
      "Value": "production"
    },
    {
      "Key": "Type",
      "Value": "Configuration"
    }
  ]'
```

## 3.5 Create Additional Secrets (Optional)

### 3.5.1 Docker Registry Credentials (if using private ECR)

If you're using a private Docker registry:

```json
{
  "registry_url": "123456789012.dkr.ecr.us-west-2.amazonaws.com",
  "username": "AWS",
  "password": "generated-token"
}
```

```bash
# Create Docker registry secret
aws secretsmanager create-secret \
  --name "github-runner/docker-registry" \
  --description "Docker registry credentials for GitHub runner images" \
  --secret-string file://docker-registry-credentials.json
```

### 3.5.2 Webhook Secret (for future enhancements)

```json
{
  "webhook_secret": "your-randomly-generated-webhook-secret",
  "webhook_url": "https://your-api-gateway-url.amazonaws.com/webhook"
}
```

```bash
# Create webhook secret
aws secretsmanager create-secret \
  --name "github-runner/webhook-config" \
  --description "Webhook configuration for GitHub runner automation" \
  --secret-string file://webhook-config.json
```

## 3.6 Configure Secret Resource Policies

### 3.6.1 Create Resource Policy for App Credentials

Resource policies provide additional access control at the secret level:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowECSTaskAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerECSTaskExecutionRole",
          "arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerECSTaskRole"
        ]
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "*"
    },
    {
      "Sid": "AllowCloudFormationAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerCloudFormationRole"
      },
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

### 3.6.2 Apply Resource Policy

```bash
# Apply resource policy to the app credentials secret
aws secretsmanager put-resource-policy \
  --secret-id "github-runner/app-credentials" \
  --resource-policy file://secret-resource-policy.json

# Verify the policy was applied
aws secretsmanager get-resource-policy \
  --secret-id "github-runner/app-credentials"
```

## 3.7 Setup Secret Rotation (Optional but Recommended)

### 3.7.1 Create Lambda Function for GitHub App Key Rotation

Create a Lambda function that can generate new GitHub App private keys:

```python
import boto3
import json
import requests
from datetime import datetime, timedelta

def lambda_handler(event, context):
    """
    Lambda function to rotate GitHub App private keys
    """
    secrets_client = boto3.client('secretsmanager')
    
    # This is a placeholder - GitHub doesn't currently support
    # programmatic private key rotation, but you can implement
    # manual rotation workflows here
    
    return {
        'statusCode': 200,
        'body': json.dumps('Rotation check completed')
    }
```

### 3.7.2 Configure Automatic Rotation

```bash
# Enable automatic rotation (30 days)
aws secretsmanager rotate-secret \
  --secret-id "github-runner/app-credentials" \
  --rotation-lambda-arn "arn:aws:lambda:region:account:function:github-app-key-rotator" \
  --rotation-rules AutomaticallyAfterDays=30
```

## 3.8 Test Secret Access

### 3.8.1 Test Direct Access

```bash
# Test retrieving the GitHub App credentials
aws secretsmanager get-secret-value \
  --secret-id "github-runner/app-credentials" \
  --query 'SecretString' \
  --output text | jq '.'

# Test retrieving runner configuration
aws secretsmanager get-secret-value \
  --secret-id "github-runner/runner-config" \
  --query 'SecretString' \
  --output text | jq '.'
```

### 3.8.2 Test Access with IAM Role (Simulate ECS Task)

```bash
# Assume the ECS task role
ROLE_ARN="arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubRunnerECSTaskRole"
CREDENTIALS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name test-session)

# Extract credentials
export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')

# Test secret access with assumed role
aws secretsmanager get-secret-value \
  --secret-id "github-runner/app-credentials" \
  --query 'SecretString' \
  --output text

# Clean up environment variables
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

## 3.9 Create CloudFormation Template for Secrets

For infrastructure as code, create a CloudFormation template:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'GitHub Runner Secrets Manager Configuration'

Parameters:
  GitHubAppId:
    Type: String
    Description: GitHub App ID
    NoEcho: true
  
  GitHubInstallationId:
    Type: String
    Description: GitHub App Installation ID
    NoEcho: true
  
  GitHubClientId:
    Type: String
    Description: GitHub App Client ID
    NoEcho: true
  
  GitHubPrivateKey:
    Type: String
    Description: GitHub App Private Key (PEM format)
    NoEcho: true

Resources:
  GitHubAppCredentialsSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: github-runner/app-credentials
      Description: GitHub App credentials for self-hosted runners
      SecretString: !Sub |
        {
          "app_id": "${GitHubAppId}",
          "installation_id": "${GitHubInstallationId}",
          "client_id": "${GitHubClientId}",
          "private_key": "${GitHubPrivateKey}",
          "github_api_url": "https://api.github.com",
          "github_url": "https://github.com"
        }
      Tags:
        - Key: Project
          Value: GitHubRunner
        - Key: Environment
          Value: !Ref AWS::StackName
        - Key: ManagedBy
          Value: CloudFormation

  RunnerConfigSecret:
    Type: AWS::SecretsManager::Secret
    Properties:
      Name: github-runner/runner-config
      Description: GitHub Actions runner configuration settings
      SecretString: !Sub |
        {
          "repository_owner": "your-org",
          "repository_name": "your-repo",
          "runner_group": "default",
          "runner_labels": ["self-hosted", "linux", "x64", "fargate", "docker"],
          "runner_name_prefix": "fargate-runner",
          "work_directory": "/actions-runner/_work",
          "runner_scope": "repository",
          "max_jobs": 1,
          "ephemeral": true,
          "disable_update": true,
          "unattended": true
        }
      Tags:
        - Key: Project
          Value: GitHubRunner
        - Key: Type
          Value: Configuration

Outputs:
  GitHubAppCredentialsSecretArn:
    Description: ARN of the GitHub App credentials secret
    Value: !Ref GitHubAppCredentialsSecret
    Export:
      Name: !Sub "${AWS::StackName}-GitHubAppCredentialsSecretArn"
  
  RunnerConfigSecretArn:
    Description: ARN of the runner configuration secret
    Value: !Ref RunnerConfigSecret
    Export:
      Name: !Sub "${AWS::StackName}-RunnerConfigSecretArn"
```

### 3.9.1 Deploy Secrets with CloudFormation

```bash
# Deploy the secrets stack
aws cloudformation create-stack \
  --stack-name github-runner-secrets \
  --template-body file://secrets-template.yaml \
  --parameters \
    ParameterKey=GitHubAppId,ParameterValue="123456" \
    ParameterKey=GitHubInstallationId,ParameterValue="12345678" \
    ParameterKey=GitHubClientId,ParameterValue="Iv1.a1b2c3d4e5f6g7h8" \
    ParameterKey=GitHubPrivateKey,ParameterValue="$(cat your-github-app-private-key.pem | sed ':a;N;$!ba;s/\n/\\n/g')" \
  --capabilities CAPABILITY_IAM
```

## 3.10 Security Best Practices

### Secret Naming Convention
- Use hierarchical naming: `github-runner/app-credentials`
- Include environment indicators: `github-runner/app-credentials-prod`
- Be consistent across all secrets

### Access Control
- Use resource-based policies in addition to IAM policies
- Implement least privilege access
- Regularly audit secret access patterns

### Monitoring and Alerting
- Enable CloudTrail logging for Secrets Manager API calls
- Set up CloudWatch alarms for unusual access patterns
- Monitor failed secret retrieval attempts

### Key Rotation
- Plan for regular private key rotation
- Implement automated rotation where possible
- Keep track of key expiration dates

## 3.11 Environment Variables for ECS Task Definition

For your ECS task definition, you'll reference secrets as environment variables:

```json
{
  "environment": [
    {
      "name": "GITHUB_APP_ID",
      "valueFrom": "arn:aws:secretsmanager:region:account:secret:github-runner/app-credentials:app_id::"
    },
    {
      "name": "GITHUB_INSTALLATION_ID",
      "valueFrom": "arn:aws:secretsmanager:region:account:secret:github-runner/app-credentials:installation_id::"
    }
  ],
  "secrets": [
    {
      "name": "GITHUB_PRIVATE_KEY",
      "valueFrom": "arn:aws:secretsmanager:region:account:secret:github-runner/app-credentials:private_key::"
    }
  ]
}
```

## Common Issues and Troubleshooting

### Issue: "AccessDenied" when retrieving secrets
- **Solution**: Verify IAM roles have correct `secretsmanager:GetSecretValue` permissions and resource ARNs match

### Issue: Private key format errors
- **Solution**: Ensure newlines are properly escaped when storing in JSON format

### Issue: Secret not found during ECS task startup
- **Solution**: Check secret names match exactly, including case sensitivity

### Issue: Resource policy conflicts
- **Solution**: Ensure resource policies don't contradict IAM policies; resource policies are additional restrictions

## Next Steps

With your GitHub App credentials securely stored in AWS Secrets Manager, you now have:
- Encrypted storage for sensitive GitHub App data
- Secure access patterns through IAM roles
- Infrastructure as code templates for consistent deployment
- Monitoring and rotation capabilities

In Step 4, we'll create the Docker images for your self-hosted runner and Docker-in-Docker sidecar, which will use these secrets for GitHub authentication.


---

### User

Let's move on to Step 4.
Remember, you should be as detailed and comprehensive as possible.
Do not forget about using Python for the entry point script.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants to move to Step 4, which is about creating Docker images. Based on the requirements mentioned in the initial prompt, I need to create:

1. A Docker image for the GitHub runner
2. A Docker-in-Docker sidecar image
3. Python entrypoint script for the runner container

The requirements are:
- Use GitHub App for authentication (we set this up in steps 1-3)
- Use Python to create an entrypoint script for the Docker container
- Use the docker-in-docker sidecar pattern

I need to be comprehensive and detailed, covering:
- Dockerfile for the main runner container
- Python entrypoint script that handles GitHub App authentication and runner registration
- Docker-in-Docker sidecar configuration
- Build process and best practices
- Security considerations
- Testing the images

Let me structure this properly:

1. Overview of the docker-in-docker pattern
2. Create the main runner Dockerfile
3. Create the Python entrypoint script (this is crucial)
4. Create the Docker-in-Docker sidecar Dockerfile
5. Build scripts and automation
6. Testing the images
7. Push to ECR
8. Security best practices
</details>

# Step 4: Create Docker Images

## Overview
This step creates two custom Docker images using the Docker-in-Docker (DinD) sidecar pattern. The main runner container handles GitHub App authentication and runner registration using Python, while the DinD sidecar provides Docker daemon functionality without requiring privileged containers in Fargate.

## Prerequisites
- Docker installed and running locally
- AWS CLI configured with ECR permissions
- Completed Steps 1-3 (GitHub App, IAM roles, and secrets configured)
- Understanding of Docker multi-stage builds and networking

## 4.1 Understanding the Docker-in-Docker Sidecar Pattern

### Architecture Overview
```
┌─────────────────────────────────────────────────────────────┐
│                    ECS Fargate Task                         │
│                                                             │
│  ┌─────────────────────────┐  ┌─────────────────────────┐   │
│  │   GitHub Runner         │  │   Docker-in-Docker      │   │
│  │   Container             │  │   Sidecar               │   │
│  │                         │  │                         │   │
│  │ • Python entrypoint     │  │ • Docker daemon         │   │
│  │ • GitHub App auth       │  │ • Image management      │   │
│  │ • Runner registration   │  │ • Container execution   │   │
│  │ • Job execution         │  │                         │   │
│  └─────────────────────────┘  └─────────────────────────┘   │
│              │                            │                 │
│              └────────────────────────────┘                 │
│                     Shared Volume                           │
│                  /var/run/docker.sock                       │
└─────────────────────────────────────────────────────────────┘
```

### Benefits of This Pattern
- No privileged containers required
- Isolated Docker daemon per task
- Better security posture
- Compatible with Fargate constraints

## 4.2 Create Project Structure

First, let's set up the project directory structure:

```bash
mkdir -p github-runner-fargate/{runner,dind,scripts,configs}
cd github-runner-fargate

# Create directory structure
tree .
# .
# ├── runner/
# │   ├── Dockerfile
# │   ├── entrypoint.py
# │   ├── requirements.txt
# │   └── utils/
# │       ├── __init__.py
# │       ├── github_auth.py
# │       ├── runner_manager.py
# │       └── config_loader.py
# ├── dind/
# │   ├── Dockerfile
# │   └── docker-entrypoint.sh
# ├── scripts/
# │   ├── build.sh
# │   └── push-to-ecr.sh
# └── configs/
#     └── docker-daemon.json
```

## 4.3 Create the Main Runner Container

### 4.3.1 Runner Dockerfile

Create `runner/Dockerfile`:

```dockerfile
# Multi-stage build for GitHub Actions runner
FROM ubuntu:22.04 as runner-base

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-venv \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (not daemon)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for many GitHub Actions)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install additional tools commonly used in CI/CD
RUN apt-get update && apt-get install -y \
    zip \
    unzip \
    tar \
    gzip \
    bzip2 \
    xz-utils \
    rsync \
    openssh-client \
    vim \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Create runner user
RUN useradd -m -s /bin/bash runner \
    && usermod -aG docker runner

# Download and install GitHub Actions runner
WORKDIR /actions-runner
RUN RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/v//') \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && chown -R runner:runner /actions-runner

# Install Python dependencies
COPY runner/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt

# Copy Python application code
COPY runner/ /app/
RUN chmod +x /app/entrypoint.py \
    && chown -R runner:runner /app

# Create work directory
RUN mkdir -p /actions-runner/_work \
    && chown -R runner:runner /actions-runner/_work

# Set up environment
ENV RUNNER_ALLOW_RUNASROOT=1
ENV DOCKER_HOST=unix:///var/run/docker.sock
ENV PYTHONPATH=/app
ENV PATH="/actions-runner:${PATH}"

# Switch to runner user
USER runner
WORKDIR /actions-runner

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python3 /app/healthcheck.py

# Use Python entrypoint
ENTRYPOINT ["python3", "/app/entrypoint.py"]
```

### 4.3.2 Python Requirements

Create `runner/requirements.txt`:

```txt
# Core dependencies
boto3>=1.34.0
requests>=2.31.0
PyJWT>=2.8.0
cryptography>=41.0.0

# GitHub API client
PyGithub>=1.59.0

# Utility libraries
click>=8.1.0
python-dotenv>=1.0.0
pyyaml>=6.0
tenacity>=8.2.0

# Logging and monitoring
structlog>=23.1.0
prometheus_client>=0.17.0

# AWS SDK extensions
boto3-stubs[secretsmanager,ecs]>=1.34.0

# Date/time handling
python-dateutil>=2.8.2

# JSON Web Token handling
jwcrypto>=1.5.0
```

### 4.3.3 Python Utility Modules

Create `runner/utils/__init__.py`:

```python
"""
GitHub Runner utilities package
"""

__version__ = "1.0.0"
__author__ = "GitHub Runner Team"

# Make key classes available at package level
from .github_auth import GitHubAppAuth
from .runner_manager import RunnerManager
from .config_loader import ConfigLoader

__all__ = [
    "GitHubAppAuth",
    "RunnerManager", 
    "ConfigLoader"
]
```

Create `runner/utils/config_loader.py`:

```python
"""
Configuration loader for GitHub runner
"""

import json
import os
import logging
from typing import Dict, Any, Optional
import boto3
from botocore.exceptions import ClientError


logger = logging.getLogger(__name__)


class ConfigLoader:
    """Load configuration from various sources"""
    
    def __init__(self):
        self.secrets_client = boto3.client('secretsmanager')
        self._config_cache = {}
    
    def load_from_secrets_manager(self, secret_name: str) -> Dict[str, Any]:
        """
        Load configuration from AWS Secrets Manager
        
        Args:
            secret_name: Name of the secret to retrieve
            
        Returns:
            Dictionary containing the secret data
            
        Raises:
            ConfigError: If secret cannot be retrieved or parsed
        """
        if secret_name in self._config_cache:
            logger.debug(f"Using cached config for {secret_name}")
            return self._config_cache[secret_name]
        
        try:
            logger.info(f"Retrieving secret: {secret_name}")
            response = self.secrets_client.get_secret_value(SecretId=secret_name)
            
            secret_data = json.loads(response['SecretString'])
            self._config_cache[secret_name] = secret_data
            
            logger.info(f"Successfully loaded secret: {secret_name}")
            return secret_data
            
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == 'SecretNotFound':
                raise ConfigError(f"Secret {secret_name} not found")
            elif error_code == 'AccessDenied':
                raise ConfigError(f"Access denied to secret {secret_name}")
            else:
                raise ConfigError(f"Error retrieving secret {secret_name}: {e}")
        except json.JSONDecodeError as e:
            raise ConfigError(f"Invalid JSON in secret {secret_name}: {e}")
    
    def load_from_environment(self) -> Dict[str, Any]:
        """
        Load configuration from environment variables
        
        Returns:
            Dictionary containing environment configuration
        """
        config = {}
        
        # GitHub App configuration
        if os.getenv('GITHUB_APP_ID'):
            config['github_app_id'] = os.getenv('GITHUB_APP_ID')
        if os.getenv('GITHUB_INSTALLATION_ID'):
            config['github_installation_id'] = os.getenv('GITHUB_INSTALLATION_ID')
        if os.getenv('GITHUB_PRIVATE_KEY'):
            config['github_private_key'] = os.getenv('GITHUB_PRIVATE_KEY')
        
        # Runner configuration
        config.update({
            'repository_owner': os.getenv('REPOSITORY_OWNER', ''),
            'repository_name': os.getenv('REPOSITORY_NAME', ''),
            'runner_group': os.getenv('RUNNER_GROUP', 'default'),
            'runner_labels': os.getenv('RUNNER_LABELS', 'self-hosted,linux,x64,fargate').split(','),
            'runner_name_prefix': os.getenv('RUNNER_NAME_PREFIX', 'fargate-runner'),
            'work_directory': os.getenv('WORK_DIRECTORY', '/actions-runner/_work'),
            'max_jobs': int(os.getenv('MAX_JOBS', '1')),
            'ephemeral': os.getenv('EPHEMERAL', 'true').lower() == 'true',
            'disable_update': os.getenv('DISABLE_UPDATE', 'true').lower() == 'true',
        })
        
        # AWS configuration
        config.update({
            'aws_region': os.getenv('AWS_DEFAULT_REGION', 'us-west-2'),
            'secrets_prefix': os.getenv('SECRETS_PREFIX', 'github-runner'),
        })
        
        return {k: v for k, v in config.items() if v}  # Filter out empty values
    
    def get_merged_config(self) -> Dict[str, Any]:
        """
        Get merged configuration from all sources
        Priority: Environment variables > Secrets Manager
        
        Returns:
            Complete configuration dictionary
        """
        config = {}
        
        # Load from Secrets Manager first
        try:
            secrets_prefix = os.getenv('SECRETS_PREFIX', 'github-runner')
            
            # Load GitHub App credentials
            app_credentials = self.load_from_secrets_manager(f"{secrets_prefix}/app-credentials")
            config.update(app_credentials)
            
            # Load runner configuration
            runner_config = self.load_from_secrets_manager(f"{secrets_prefix}/runner-config")
            config.update(runner_config)
            
        except ConfigError as e:
            logger.warning(f"Could not load from Secrets Manager: {e}")
        
        # Override with environment variables
        env_config = self.load_from_environment()
        config.update(env_config)
        
        # Validate required configuration
        self._validate_config(config)
        
        return config
    
    def _validate_config(self, config: Dict[str, Any]) -> None:
        """
        Validate that required configuration is present
        
        Args:
            config: Configuration dictionary to validate
            
        Raises:
            ConfigError: If required configuration is missing
        """
        required_fields = [
            'app_id',
            'installation_id', 
            'private_key',
            'repository_owner',
            'repository_name'
        ]
        
        missing_fields = [field for field in required_fields if not config.get(field)]
        
        if missing_fields:
            raise ConfigError(f"Missing required configuration: {', '.join(missing_fields)}")
        
        logger.info("Configuration validation passed")


class ConfigError(Exception):
    """Configuration related errors"""
    pass
```

Create `runner/utils/github_auth.py`:

```python
"""
GitHub App authentication utilities
"""

import time
import jwt
import requests
import logging
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from tenacity import retry, stop_after_attempt, wait_exponential


logger = logging.getLogger(__name__)


class GitHubAppAuth:
    """Handle GitHub App authentication and token management"""
    
    def __init__(self, app_id: str, private_key: str, installation_id: str):
        """
        Initialize GitHub App authentication
        
        Args:
            app_id: GitHub App ID
            private_key: GitHub App private key (PEM format)
            installation_id: GitHub App installation ID
        """
        self.app_id = app_id
        self.private_key = private_key
        self.installation_id = installation_id
        self.base_url = "https://api.github.com"
        
        # Token cache
        self._installation_token = None
        self._token_expires_at = None
        
        logger.info(f"Initialized GitHub App auth for app_id: {app_id}")
    
    def _generate_jwt_token(self) -> str:
        """
        Generate JWT token for GitHub App authentication
        
        Returns:
            JWT token string
        """
        now = int(time.time())
        
        payload = {
            'iat': now - 60,  # Issued at time (60 seconds ago to account for clock skew)
            'exp': now + 600,  # Expires in 10 minutes
            'iss': self.app_id  # Issuer (GitHub App ID)
        }
        
        token = jwt.encode(payload, self.private_key, algorithm='RS256')
        logger.debug("Generated JWT token for GitHub App")
        
        return token
    
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
    def _get_installation_token(self) -> str:
        """
        Get installation access token from GitHub
        
        Returns:
            Installation access token
            
        Raises:
            GitHubAuthError: If token retrieval fails
        """
        # Check if we have a valid cached token
        if (self._installation_token and self._token_expires_at and 
            datetime.now() < self._token_expires_at - timedelta(minutes=5)):
            logger.debug("Using cached installation token")
            return self._installation_token
        
        logger.info("Requesting new installation token from GitHub")
        
        jwt_token = self._generate_jwt_token()
        
        headers = {
            'Authorization': f'Bearer {jwt_token}',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'GitHub-Runner-Fargate/1.0'
        }
        
        url = f"{self.base_url}/app/installations/{self.installation_id}/access_tokens"
        
        try:
            response = requests.post(url, headers=headers, timeout=30)
            response.raise_for_status()
            
            token_data = response.json()
            self._installation_token = token_data['token']
            
            # Parse expiration time
            expires_at_str = token_data['expires_at']
            self._token_expires_at = datetime.fromisoformat(expires_at_str.replace('Z', '+00:00'))
            
            logger.info(f"Successfully obtained installation token, expires at: {self._token_expires_at}")
            return self._installation_token
            
        except requests.exceptions.RequestException as e:
            raise GitHubAuthError(f"Failed to get installation token: {e}")
        except KeyError as e:
            raise GitHubAuthError(f"Invalid response format: missing {e}")
    
    def get_headers(self) -> Dict[str, str]:
        """
        Get headers for GitHub API requests with current token
        
        Returns:
            Dictionary of headers for API requests
        """
        token = self._get_installation_token()
        
        return {
            'Authorization': f'token {token}',
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'GitHub-Runner-Fargate/1.0'
        }
    
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
    def make_request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """
        Make authenticated request to GitHub API
        
        Args:
            method: HTTP method (GET, POST, etc.)
            endpoint: API endpoint (without base URL)
            **kwargs: Additional arguments for requests
            
        Returns:
            Response object
            
        Raises:
            GitHubAuthError: If request fails
        """
        url = f"{self.base_url}{endpoint}"
        headers = self.get_headers()
        
        # Merge with any provided headers
        if 'headers' in kwargs:
            headers.update(kwargs['headers'])
        kwargs['headers'] = headers
        
        # Set timeout if not provided
        kwargs.setdefault('timeout', 30)
        
        try:
            logger.debug(f"Making {method} request to {endpoint}")
            response = requests.request(method, url, **kwargs)
            response.raise_for_status()
            
            return response
            
        except requests.exceptions.RequestException as e:
            logger.error(f"GitHub API request failed: {e}")
            raise GitHubAuthError(f"API request failed: {e}")
    
    def test_authentication(self) -> bool:
        """
        Test GitHub App authentication
        
        Returns:
            True if authentication is successful
            
        Raises:
            GitHubAuthError: If authentication fails
        """
        try:
            response = self.make_request('GET', '/app')
            app_data = response.json()
            
            logger.info(f"Authentication test successful for app: {app_data.get('name', 'Unknown')}")
            return True
            
        except Exception as e:
            logger.error(f"Authentication test failed: {e}")
            raise GitHubAuthError(f"Authentication test failed: {e}")


class GitHubAuthError(Exception):
    """GitHub authentication related errors"""
    pass
```

Create `runner/utils/runner_manager.py`:

```python
"""
GitHub Actions runner management utilities
"""

import os
import uuid
import time
import socket
import subprocess
import logging
import json
from typing import Dict, Any, Optional
from tenacity import retry, stop_after_attempt, wait_exponential

from .github_auth import GitHubAppAuth, GitHubAuthError


logger = logging.getLogger(__name__)


class RunnerManager:
    """Manage GitHub Actions runner lifecycle"""
    
    def __init__(self, auth: GitHubAppAuth, config: Dict[str, Any]):
        """
        Initialize runner manager
        
        Args:
            auth: GitHub App authentication instance
            config: Runner configuration dictionary
        """
        self.auth = auth
        self.config = config
        self.runner_name = None
        self.registration_token = None
        
        # Runner paths
        self.runner_dir = "/actions-runner"
        self.config_script = os.path.join(self.runner_dir, "config.sh")
        self.run_script = os.path.join(self.runner_dir, "run.sh")
        
        logger.info("Initialized RunnerManager")
    
    def generate_runner_name(self) -> str:
        """
        Generate unique runner name
        
        Returns:
            Unique runner name
        """
        if self.runner_name:
            return self.runner_name
        
        prefix = self.config.get('runner_name_prefix', 'fargate-runner')
        hostname = socket.gethostname()
        unique_id = str(uuid.uuid4())[:8]
        timestamp = int(time.time())
        
        self.runner_name = f"{prefix}-{hostname}-{unique_id}-{timestamp}"
        
        logger.info(f"Generated runner name: {self.runner_name}")
        return self.runner_name
    
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
    def get_registration_token(self) -> str:
        """
        Get runner registration token from GitHub
        
        Returns:
            Registration token string
            
        Raises:
            RunnerError: If token retrieval fails
        """
        if self.registration_token:
            logger.debug("Using cached registration token")
            return self.registration_token
        
        logger.info("Requesting runner registration token")
        
        # Determine scope and endpoint
        scope = self.config.get('runner_scope', 'repository')
        
        if scope == 'organization':
            endpoint = f"/orgs/{self.config['repository_owner']}/actions/runners/registration-token"
        else:  # repository scope
            endpoint = f"/repos/{self.config['repository_owner']}/{self.config['repository_name']}/actions/runners/registration-token"
        
        try:
            response = self.auth.make_request('POST', endpoint)
            token_data = response.json()
            
            self.registration_token = token_data['token']
            expires_at = token_data.get('expires_at')
            
            logger.info(f"Successfully obtained registration token, expires at: {expires_at}")
            return self.registration_token
            
        except GitHubAuthError as e:
            raise RunnerError(f"Failed to get registration token: {e}")
        except KeyError as e:
            raise RunnerError(f"Invalid token response format: missing {e}")
    
    def configure_runner(self) -> bool:
        """
        Configure the GitHub Actions runner
        
        Returns:
            True if configuration is successful
            
        Raises:
            RunnerError: If configuration fails
        """
        logger.info("Configuring GitHub Actions runner")
        
        # Get registration token
        token = self.get_registration_token()
        runner_name = self.generate_runner_name()
        
        # Determine GitHub URL based on scope
        scope = self.config.get('runner_scope', 'repository')
        if scope == 'organization':
            github_url = f"https://github.com/{self.config['repository_owner']}"
        else:
            github_url = f"https://github.com/{self.config['repository_owner']}/{self.config['repository_name']}"
        
        # Prepare configuration command
        config_cmd = [
            self.config_script,
            "--url", github_url,
            "--token", token,
            "--name", runner_name,
            "--work", self.config.get('work_directory', '/actions-runner/_work'),
            "--unattended"
        ]
        
        # Add labels if specified
        labels = self.config.get('runner_labels', [])
        if labels:
            config_cmd.extend(["--labels", ",".join(labels)])
        
        # Add runner group if specified
        runner_group = self.config.get('runner_group')
        if runner_group and runner_group != 'default':
            config_cmd.extend(["--runnergroup", runner_group])
        
        # Add ephemeral flag if specified
        if self.config.get('ephemeral', True):
            config_cmd.append("--ephemeral")
        
        # Disable automatic updates
        if self.config.get('disable_update', True):
            config_cmd.append("--disableupdate")
        
        try:
            logger.info(f"Running configuration command: {' '.join(config_cmd[:-2])} --token [REDACTED] {' '.join(config_cmd[-1:])}")
            
            result = subprocess.run(
                config_cmd,
                cwd=self.runner_dir,
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            
            if result.returncode == 0:
                logger.info("Runner configuration successful")
                logger.debug(f"Configuration output: {result.stdout}")
                return True
            else:
                logger.error(f"Runner configuration failed with exit code: {result.returncode}")
                logger.error(f"Error output: {result.stderr}")
                raise RunnerError(f"Configuration failed: {result.stderr}")
                
        except subprocess.TimeoutExpired:
            raise RunnerError("Runner configuration timed out")
        except Exception as e:
            raise RunnerError(f"Configuration error: {e}")
    
    def start_runner(self) -> None:
        """
        Start the GitHub Actions runner
        
        Raises:
            RunnerError: If runner startup fails
        """
        logger.info("Starting GitHub Actions runner")
        
        try:
            # Verify runner is configured
            settings_file = os.path.join(self.runner_dir, ".runner")
            if not os.path.exists(settings_file):
                raise RunnerError("Runner not configured - settings file missing")
            
            # Start the runner
            logger.info("Executing runner start command")
            result = subprocess.run(
                [self.run_script],
                cwd=self.runner_dir,
                text=True
            )
            
            # The run.sh script runs until the runner is stopped
            logger.info(f"Runner exited with code: {result.returncode}")
            
        except KeyboardInterrupt:
            logger.info("Runner interrupted by user")
        except Exception as e:
            logger.error(f"Runner execution error: {e}")
            raise RunnerError(f"Runner execution failed: {e}")
    
    def cleanup_runner(self) -> None:
        """
        Clean up runner registration
        """
        logger.info("Cleaning up runner registration")
        
        try:
            # Remove runner configuration
            remove_cmd = [
                self.config_script,
                "remove",
                "--token", self.get_registration_token()
            ]
            
            result = subprocess.run(
                remove_cmd,
                cwd=self.runner_dir,
                capture_output=True,
                text=True,
                timeout=60
            )
            
            if result.returncode == 0:
                logger.info("Runner cleanup successful")
            else:
                logger.warning(f"Runner cleanup failed: {result.stderr}")
                
        except Exception as e:
            logger.warning(f"Error during runner cleanup: {e}")
    
    def verify_docker_connectivity(self) -> bool:
        """
        Verify Docker daemon connectivity
        
        Returns:
            True if Docker is accessible
        """
        try:
            result = subprocess.run(
                ["docker", "version"],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                logger.info("Docker connectivity verified")
                logger.debug(f"Docker version: {result.stdout}")
                return True
            else:
                logger.error(f"Docker connectivity failed: {result.stderr}")
                return False
                
        except Exception as e:
            logger.error(f"Docker connectivity check error: {e}")
            return False


class RunnerError(Exception):
    """Runner management related errors"""
    pass
```

### 4.3.4 Main Python Entrypoint Script

Create `runner/entrypoint.py`:

```python
#!/usr/bin/env python3
"""
GitHub Actions Runner Entrypoint for AWS Fargate

This script handles:
- GitHub App authentication
- Runner registration and configuration  
- Docker daemon connectivity verification
- Graceful shutdown handling
"""

import os
import sys
import signal
import logging
import time
from typing import Optional

# Add utils to Python path
sys.path.insert(0, '/app')

from utils.config_loader import ConfigLoader, ConfigError
from utils.github_auth import GitHubAppAuth, GitHubAuthError  
from utils.runner_manager import RunnerManager, RunnerError


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


class GitHubRunnerFargate:
    """Main GitHub Runner application for Fargate"""
    
    def __init__(self):
        self.config_loader = ConfigLoader()
        self.config: Optional[dict] = None
        self.auth: Optional[GitHubAppAuth] = None
        self.runner: Optional[RunnerManager] = None
        self.shutdown_requested = False
        
        # Register signal handlers
        signal.signal(signal.SIGTERM, self._signal_handler)
        signal.signal(signal.SIGINT, self._signal_handler)
        
        logger.info("GitHub Runner Fargate initialized")
    
    def _signal_handler(self, signum: int, frame) -> None:
        """Handle shutdown signals"""
        logger.info(f"Received signal {signum}, initiating graceful shutdown")
        self.shutdown_requested = True
    
    def load_configuration(self) -> None:
        """Load and validate configuration"""
        logger.info("Loading configuration")
        
        try:
            self.config = self.config_loader.get_merged_config()
            
            # Log configuration (without sensitive data)
            safe_config = {k: v for k, v in self.config.items() 
                          if 'private_key' not in k.lower() and 'token' not in k.lower()}
            logger.info(f"Configuration loaded: {safe_config}")
            
        except ConfigError as e:
            logger.error(f"Configuration error: {e}")
            sys.exit(1)
    
    def initialize_github_auth(self) -> None:
        """Initialize GitHub App authentication"""
        logger.info("Initializing GitHub App authentication")
        
        try:
            self.auth = GitHubAppAuth(
                app_id=str(self.config['app_id']),
                private_key=self.config['private_key'],
                installation_id=str(self.config['installation_id'])
            )
            
            # Test authentication
            self.auth.test_authentication()
            logger.info("GitHub App authentication successful")
            
        except (GitHubAuthError, KeyError) as e:
            logger.error(f"GitHub authentication error: {e}")
            sys.exit(1)
    
    def initialize_runner_manager(self) -> None:
        """Initialize runner manager"""
        logger.info("Initializing runner manager")
        
        try:
            self.runner = RunnerManager(self.auth, self.config)
            
            # Verify Docker connectivity
            if not self.runner.verify_docker_connectivity():
                logger.error("Docker daemon not accessible")
                logger.info("Waiting for Docker daemon to become available...")
                
                # Wait for Docker daemon with timeout
                max_wait = 120  # 2 minutes
                wait_interval = 5
                waited = 0
                
                while waited < max_wait:
                    if self.runner.verify_docker_connectivity():
                        logger.info("Docker daemon is now accessible")
                        break
                    
                    time.sleep(wait_interval)
                    waited += wait_interval
                    logger.info(f"Still waiting for Docker daemon... ({waited}/{max_wait}s)")
                else:
                    logger.error("Docker daemon did not become available within timeout")
                    sys.exit(1)
            
            logger.info("Runner manager initialized successfully")
            
        except RunnerError as e:
            logger.error(f"Runner manager initialization error: {e}")
            sys.exit(1)
    
    def run_runner(self) -> None:
        """Configure and run the GitHub Actions runner"""
        logger.info("Starting GitHub Actions runner")
        
        try:
            # Configure the runner
            if not self.runner.configure_runner():
                logger.error("Runner configuration failed")
                sys.exit(1)
            
            logger.info("Runner configured successfully, starting execution")
            
            # Start the runner (this blocks until runner stops)
            self.runner.start_runner()
            
        except RunnerError as e:
            logger.error(f"Runner execution error: {e}")
            sys.exit(1)
        except KeyboardInterrupt:
            logger.info("Runner interrupted")
        finally:
            # Clean up runner registration
            if self.runner:
                self.runner.cleanup_runner()
    
    def healthcheck(self) -> bool:
        """
        Health check for container orchestration
        
        Returns:
            True if healthy, False otherwise
        """
        try:
            # Check if configuration is loaded
            if not self.config:
                return False
            
            # Check if GitHub authentication is working
            if self.auth:
                try:
                    self.auth.test_authentication()
                except GitHubAuthError:
                    return False
            
            # Check if Docker is accessible
            if self.runner:
                return self.runner.verify_docker_connectivity()
            
            return True
            
        except Exception:
            return False
    
    def run(self) -> None:
        """Main execution flow"""
        logger.info("Starting GitHub Runner Fargate application")
        
        try:
            # Load configuration
            self.load_configuration()
            
            # Initialize GitHub authentication
            self.initialize_github_auth()
            
            # Initialize runner manager
            self.initialize_runner_manager()
            
            # Run the runner
            self.run_runner()
            
        except Exception as e:
            logger.error(f"Unexpected error: {e}", exc_info=True)
            sys.exit(1)
        
        logger.info("GitHub Runner Fargate application finished")


def main():
    """Entry point"""
    # Check for health check mode
    if len(sys.argv) > 1 and sys.argv[1] == "healthcheck":
        app = GitHubRunnerFargate()
        try:
            app.load_configuration()
            app.initialize_github_auth()
            app.initialize_runner_manager()
            healthy = app.healthcheck()
        except:
            healthy = False
        
        sys.exit(0 if healthy else 1)
    
    # Normal startup
    app = GitHubRunnerFargate()
    app.run()


if __name__ == "__main__":
    main()
```

### 4.3.5 Health Check Script

Create `runner/healthcheck.py`:

```python
#!/usr/bin/env python3
"""
Health check script for GitHub Runner container
"""

import sys
import subprocess
import logging

# Suppress logging for health checks
logging.disable(logging.CRITICAL)

def main():
    """Perform health check"""
    try:
        # Check if Docker is accessible
        result = subprocess.run(
            ["docker", "version"],
            capture_output=True,
            timeout=10
        )
        
        if result.returncode != 0:
            sys.exit(1)
        
        # Check if runner process might be running
        result = subprocess.run(
            ["pgrep", "-f", "Runner.Listener"],
            capture_output=True
        )
        
        # Exit code 0 means healthy
        sys.exit(0)
        
    except Exception:
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## 4.4 Create Docker-in-Docker Sidecar Container

### 4.4.1 DinD Dockerfile

Create `dind/Dockerfile`:

```dockerfile
# Docker-in-Docker sidecar for GitHub Actions runner
FROM docker:24-dind

# Install additional tools
RUN apk add --no-cache \
    curl \
    bash \
    jq \
    git \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Create docker user and group with specific IDs to match runner container
RUN addgroup -g 999 docker || true \
    && adduser -D -s /bin/bash -G docker dockeruser || true

# Copy custom Docker daemon configuration
COPY dind/docker-daemon.json /etc/docker/daemon.json

# Copy entrypoint script
COPY dind/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create directories
RUN mkdir -p /var/lib/docker \
    && chmod 755 /var/lib/docker

# Expose Docker daemon port
EXPOSE 2376

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD docker version || exit 1

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["dockerd"]
```

### 4.4.2 Docker Daemon Configuration

Create `configs/docker-daemon.json`:

```json
{
  "hosts": ["unix:///var/run/docker.sock"],
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "registry-mirrors": [],
  "insecure-registries": [],
  "live-restore": false,
  "userland-proxy": false,
  "experimental": false,
  "features": {
    "buildkit": true
  },
  "default-ulimits": {
    "nofile": {
      "Hard": 64000,
      "Name": "nofile",
      "Soft": 64000
    }
  },
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 3
}
```

### 4.4.3 DinD Entrypoint Script

Create `dind/docker-entrypoint.sh`:

```bash
#!/bin/bash
set -e

# Docker-in-Docker entrypoint script for GitHub Actions runner sidecar

echo "Starting Docker-in-Docker sidecar..."

# Set up Docker daemon environment
export DOCKER_TLS_CERTDIR=""
export DOCKER_DRIVER=${DOCKER_DRIVER:-overlay2}

# Create necessary directories
mkdir -p /var/lib/docker
mkdir -p /var/run

# Set permissions for Docker socket
touch /var/run/docker.sock
chmod 666 /var/run/docker.sock

# Function to handle graceful shutdown
shutdown_handler() {
    echo "Received shutdown signal, stopping Docker daemon..."
    if [ -n "$DOCKER_PID" ]; then
        kill -TERM "$DOCKER_PID"
        wait "$DOCKER_PID"
    fi
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Wait for any existing Docker daemon to stop
while pgrep dockerd > /dev/null; do
    echo "Waiting for existing Docker daemon to stop..."
    sleep 2
done

# Start Docker daemon in background
echo "Starting Docker daemon..."
dockerd \
    --host=unix:///var/run/docker.sock \
    --storage-driver="$DOCKER_DRIVER" \
    --config-file=/etc/docker/daemon.json \
    &

DOCKER_PID=$!

# Wait for Docker daemon to be ready
echo "Waiting for Docker daemon to be ready..."
timeout=60
counter=0

while ! docker version > /dev/null 2>&1; do
    if [ $counter -gt $timeout ]; then
        echo "Docker daemon failed to start within $timeout seconds"
        exit 1
    fi
    
    echo "Docker daemon not ready yet... (${counter}/${timeout})"
    sleep 1
    counter=$((counter + 1))
done

echo "Docker daemon is ready!"

# Log Docker daemon status
docker version
docker info

# Keep the container running and monitor Docker daemon
while kill -0 "$DOCKER_PID" 2>/dev/null; do
    sleep 30
    
    # Health check
    if ! docker version > /dev/null 2>&1; then
        echo "Docker daemon health check failed"
        exit 1
    fi
done

echo "Docker daemon has stopped"
wait "$DOCKER_PID"
```

Make the script executable:

```bash
chmod +x dind/docker-entrypoint.sh
```

## 4.5 Create Build Scripts

### 4.5.1 Main Build Script

Create `scripts/build.sh`:

```bash
#!/bin/bash
set -euo pipefail

# GitHub Runner Fargate - Build Script

# Configuration
REGISTRY_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
RUNNER_IMAGE_NAME="github-runner-fargate"
DIND_IMAGE_NAME="github-runner-dind"
TAG="${IMAGE_TAG:-latest}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker not found. Please install Docker."
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        error "AWS CLI not found. Please install AWS CLI."
        exit 1
    fi
    
    if [ -z "${AWS_ACCOUNT_ID:-}" ]; then
        error "AWS_ACCOUNT_ID environment variable not set"
        exit 1
    fi
    
    if [ -z "${AWS_REGION:-}" ]; then
        error "AWS_REGION environment variable not set"
        exit 1
    fi
    
    log "Prerequisites check passed"
}

# Login to ECR
ecr_login() {
    log "Logging into Amazon ECR..."
    
    aws ecr get-login-password --region "$AWS_REGION" | \
        docker login --username AWS --password-stdin "$REGISTRY_URL"
    
    if [ $? -eq 0 ]; then
        log "ECR login successful"
    else
        error "ECR login failed"
        exit 1
    fi
}

# Create ECR repositories if they don't exist
create_ecr_repos() {
    log "Creating ECR repositories if they don't exist..."
    
    # Create runner repository
    aws ecr describe-repositories --repository-names "$RUNNER_IMAGE_NAME" \
        --region "$AWS_REGION" >/dev/null 2>&1 || {
        log "Creating ECR repository: $RUNNER_IMAGE_NAME"
        aws ecr create-repository \
            --repository-name "$RUNNER_IMAGE_NAME" \
            --region "$AWS_REGION" \
            --image-scanning-configuration scanOnPush=true
    }
    
    # Create DinD repository
    aws ecr describe-repositories --repository-names "$DIND_IMAGE_NAME" \
        --region "$AWS_REGION" >/dev/null 2>&1 || {
        log "Creating ECR repository: $DIND_IMAGE_NAME"
        aws ecr create-repository \
            --repository-name "$DIND_IMAGE_NAME" \
            --region "$AWS_REGION" \
            --image-scanning-configuration scanOnPush=true
    }
}

# Build Docker images
build_images() {
    log "Building Docker images..."
    
    # Build runner image
    log "Building GitHub runner image..."
    docker build \
        -t "$RUNNER_IMAGE_NAME:$TAG" \
        -t "$REGISTRY_URL/$RUNNER_IMAGE_NAME:$TAG" \
        -f runner/Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        log "Runner image build successful"
    else
        error "Runner image build failed"
        exit 1
    fi
    
    # Build DinD image
    log "Building Docker-in-Docker sidecar image..."
    docker build \
        -t "$DIND_IMAGE_NAME:$TAG" \
        -t "$REGISTRY_URL/$DIND_IMAGE_NAME:$TAG" \
        -f dind/Dockerfile \
        .
    
    if [ $? -eq 0 ]; then
        log "DinD image build successful"
    else
        error "DinD image build failed"
        exit 1
    fi
}

# Test images locally
test_images() {
    log "Testing images locally..."
    
    # Test runner image
    log "Testing runner image..."
    docker run --rm "$RUNNER_IMAGE_NAME:$TAG" python3 -c "import sys; print(f'Python version: {sys.version}')"
    
    # Test DinD image
    log "Testing DinD image..."
    docker run --rm --privileged "$DIND_IMAGE_NAME:$TAG" docker --version
    
    log "Image tests passed"
}

# Push images to ECR
push_images() {
    log "Pushing images to ECR..."
    
    # Push runner image
    log "Pushing runner image..."
    docker push "$REGISTRY_URL/$RUNNER_IMAGE_NAME:$TAG"
    
    if [ $? -eq 0 ]; then
        log "Runner image push successful"
    else
        error "Runner image push failed"
        exit 1
    fi
    
    # Push DinD image
    log "Pushing DinD image..."
    docker push "$REGISTRY_URL/$DIND_IMAGE_NAME:$TAG"
    
    if [ $? -eq 0 ]; then
        log "DinD image push successful"
    else
        error "DinD image push failed"
        exit 1
    fi
}

# Cleanup local images (optional)
cleanup() {
    if [ "${CLEANUP_LOCAL:-false}" = "true" ]; then
        log "Cleaning up local images..."
        docker rmi "$RUNNER_IMAGE_NAME:$TAG" "$REGISTRY_URL/$RUNNER_IMAGE_NAME:$TAG" || true
        docker rmi "$DIND_IMAGE_NAME:$TAG" "$REGISTRY_URL/$DIND_IMAGE_NAME:$TAG" || true
    fi
}

# Main execution
main() {
    log "Starting GitHub Runner Fargate build process..."
    
    check_prerequisites
    ecr_login
    create_ecr_repos
    build_images
    test_images
    push_images
    cleanup
    
    log "Build process completed successfully!"
    log "Runner image: $REGISTRY_URL/$RUNNER_IMAGE_NAME:$TAG"
    log "DinD image: $REGISTRY_URL/$DIND_IMAGE_NAME:$TAG"
}

# Help function
show_help() {
    cat << EOF
GitHub Runner Fargate Build Script

Usage: $0 [OPTIONS]

Environment Variables:
    AWS_ACCOUNT_ID      AWS Account ID (required)
    AWS_REGION          AWS Region (required)
    IMAGE_TAG          Image tag (default: latest)
    CLEANUP_LOCAL      Clean up local images after push (default: false)

Examples:
    AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-west-2 ./build.sh
    AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-west-2 IMAGE_TAG=v1.0.0 ./build.sh

EOF
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
```

Make the build script executable:

```bash
chmod +x scripts/build.sh
```

### 4.5.2 ECR Push Script

Create `scripts/push-to-ecr.sh`:

```bash
#!/bin/bash
set -euo pipefail

# ECR Push Script for GitHub Runner Fargate

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Source build configuration
source "$SCRIPT_DIR/build.sh"

# Main function for pushing only
push_only() {
    log "ECR Push Only Mode"
    
    check_prerequisites
    ecr_login
    create_ecr_repos
    push_images
    
    log "Push completed successfully!"
}

# Execute push only
push_only "$@"
```

## 4.6 Test Docker Images Locally

### 4.6.1 Local Testing Setup

Create `scripts/test-local.sh`:

```bash
#!/bin/bash
set -euo pipefail

# Local testing script for GitHub Runner Fargate

# Configuration
NETWORK_NAME="github-runner-test"
RUNNER_CONTAINER="test-runner"
DIND_CONTAINER="test-dind"

# Cleanup function
cleanup() {
    echo "Cleaning up test environment..."
    docker stop "$RUNNER_CONTAINER" "$DIND_CONTAINER" 2>/dev/null || true
    docker rm "$RUNNER_CONTAINER" "$DIND_CONTAINER" 2>/dev/null || true
    docker network rm "$NETWORK_NAME" 2>/dev/null || true
}

# Set up test environment
setup() {
    echo "Setting up test environment..."
    
    # Clean up any existing test containers
    cleanup
    
    # Create test network
    docker network create "$NETWORK_NAME"
    
    # Start DinD container
    docker run -d \
        --name "$DIND_CONTAINER" \
        --network "$NETWORK_NAME" \
        --privileged \
        github-runner-dind:latest
    
    # Wait for DinD to be ready
    echo "Waiting for Docker daemon to be ready..."
    sleep 10
    
    # Test DinD connectivity
    docker exec "$DIND_CONTAINER" docker version
}

# Test runner container
test_runner() {
    echo "Testing runner container..."
    
    # Start runner container (dry run mode)
    docker run -d \
        --name "$RUNNER_CONTAINER" \
        --network "$NETWORK_NAME" \
        -e DOCKER_HOST="tcp://$DIND_CONTAINER:2376" \
        -e GITHUB_APP_ID="test" \
        -e GITHUB_INSTALLATION_ID="test" \
        -e GITHUB_PRIVATE_KEY="test" \
        -e REPOSITORY_OWNER="test" \
        -e REPOSITORY_NAME="test" \
        github-runner-fargate:latest \
        python3 -c "
import sys
sys.path.insert(0, '/app')
from utils.config_loader import ConfigLoader
from utils.github_auth import GitHubAppAuth
print('Configuration and imports working correctly')
"
    
    # Check container logs
    sleep 5
    docker logs "$RUNNER_CONTAINER"
}

# Main execution
main() {
    echo "Starting local testing..."
    
    # Trap cleanup on exit
    trap cleanup EXIT
    
    setup
    test_runner
    
    echo "Local testing completed!"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 4.6.2 Run Local Tests

```bash
# Make test script executable
chmod +x scripts/test-local.sh

# Build images first
AWS_ACCOUNT_ID=123456789012 AWS_REGION=us-west-2 ./scripts/build.sh

# Run local tests
./scripts/test-local.sh
```

## 4.7 Security Best Practices

### 4.7.1 Image Security Scanning

Add security scanning to your build process:

```bash
# Install Docker Scout or similar tool
docker scout cves github-runner-fargate:latest
docker scout cves github-runner-dind:latest

# Use AWS ECR image scanning
aws ecr put-image-scanning-configuration \
    --repository-name github-runner-fargate \
    --image-scanning-configuration scanOnPush=true

aws ecr put-image-scanning-configuration \
    --repository-name github-runner-dind \
    --image-scanning-configuration scanOnPush=true
```

### 4.7.2 Multi-stage Build Optimization

The Dockerfile already uses multi-stage builds to minimize image size and attack surface.

### 4.7.3 Non-root User

Both containers run as non-root users where possible, improving security posture.

## 4.8 Build and Deploy Images

### 4.8.1 Set Environment Variables

```bash
export AWS_ACCOUNT_ID=123456789012
export AWS_REGION=us-west-2
export IMAGE_TAG=v1.0.0
```

### 4.8.2 Run Build Process

```bash
# Build and push images
./scripts/build.sh

# Verify images in ECR
aws ecr list-images --repository-name github-runner-fargate --region $AWS_REGION
aws ecr list-images --repository-name github-runner-dind --region $AWS_REGION
```

## Common Issues and Troubleshooting

### Issue: Docker build fails with permission errors
- **Solution**: Ensure Docker daemon is running and user has proper permissions

### Issue: ECR login fails
- **Solution**: Verify AWS credentials and IAM permissions for ECR operations

### Issue: Python import errors in container
- **Solution**: Check PYTHONPATH environment variable and ensure all utility modules are properly packaged

### Issue: DinD container fails to start Docker daemon
- **Solution**: Verify privileged mode is enabled and check container logs for specific errors

### Issue: Runner container cannot connect to DinD
- **Solution**: Ensure containers are on the same network and DOCKER_HOST is correctly set

## Next Steps

With your Docker images built and pushed to ECR, you now have:
- A secure runner container with Python-based GitHub App authentication
- A Docker-in-Docker sidecar for container operations
- Automated build and deployment scripts
- Local testing capabilities
- Security scanning integration

In Step 5, we'll develop the comprehensive Python entrypoint script that orchestrates the GitHub App authentication, runner registration, and job execution workflow.


---

### User

Let's move on to Step 5.
Always remember, you should be as detailed and comprehensive as possible.


---

### Assistant (claude-4-sonnet-reasoning)

<details>
<summary>Reasoning</summary>

The user wants me to move on to Step 5, which according to the original outline should be "Develop Python Entrypoint Script". However, looking back at Step 4, I already created a comprehensive Python entrypoint script as part of the Docker image creation. 

Let me check the original outline:
1. Create and Configure GitHub App ✓
2. Setup AWS IAM Roles and Policies ✓ 
3. Store GitHub App Credentials in AWS Secrets Manager ✓
4. Create Docker Images ✓ (including Python entrypoint)
5. Develop Python Entrypoint Script
6. Configure ECS Task Definition
7. Deploy CloudFormation Stack
8. Setup Auto-scaling and Monitoring
9. Test and Validate the Setup
10. Maintenance and Troubleshooting

Since I already created the Python entrypoint script in Step 4, Step 5 should focus on enhancing and detailing the Python entrypoint script further, or perhaps I need to reframe this as Step 5 being more focused on advanced features, error handling, monitoring, and production-ready enhancements to the Python entrypoint script.

I think Step 5 should focus on:
1. Enhanced error handling and retry logic
2. Monitoring and observability features
3. Advanced configuration management
4. Workflow orchestration improvements
5. Security enhancements
6. Performance optimizations
7. Testing frameworks
8. Logging and debugging capabilities

This would make Step 5 a comprehensive enhancement of the basic entrypoint script created in Step 4.
</details>

# Step 5: Develop Enhanced Python Entrypoint Script

## Overview
While Step 4 provided a foundational Python entrypoint script, this step focuses on creating a production-ready, enterprise-grade Python application with advanced features including robust error handling, comprehensive monitoring, workflow orchestration, security enhancements, and observability. We'll enhance the basic script with monitoring capabilities, advanced retry logic, health checks, metrics collection, and sophisticated configuration management.

## Prerequisites
- Completed Steps 1-4 (GitHub App, IAM roles, secrets, and basic Docker images)
- Understanding of Python async programming, monitoring, and observability patterns
- Familiarity with Prometheus metrics and structured logging

## 5.1 Enhanced Project Structure

Let's expand our Python application structure for production readiness:

```bash
cd github-runner-fargate/runner

# Create enhanced directory structure
mkdir -p {monitoring,workflows,security,testing,configs}

tree .
# .
# ├── entrypoint.py                 # Main application entry point
# ├── requirements.txt              # Python dependencies
# ├── Dockerfile                    # Container definition
# ├── utils/                        # Core utilities
# │   ├── __init__.py
# │   ├── github_auth.py
# │   ├── runner_manager.py
# │   └── config_loader.py
# ├── monitoring/                   # Monitoring and observability
# │   ├── __init__.py
# │   ├── metrics.py               # Prometheus metrics
# │   ├── health_checker.py        # Health check logic
# │   ├── log_formatter.py         # Structured logging
# │   └── alerts.py                # Alert definitions
# ├── workflows/                    # Workflow orchestration
# │   ├── __init__.py
# │   ├── job_processor.py         # Job processing logic
# │   ├── queue_manager.py         # Queue management
# │   └── state_machine.py         # State management
# ├── security/                     # Security utilities
# │   ├── __init__.py
# │   ├── token_manager.py         # Secure token handling
# │   ├── secrets_rotation.py      # Credential rotation
# │   └── audit_logger.py          # Security audit logging
# ├── testing/                      # Testing framework
# │   ├── __init__.py
# │   ├── test_runner.py           # Test runner
# │   ├── mock_github.py           # GitHub API mocking
# │   └── integration_tests.py     # Integration tests
# └── configs/                      # Configuration templates
#     ├── logging.yaml             # Logging configuration
#     ├── metrics.yaml             # Metrics configuration
#     └── alerts.yaml              # Alert rules
```

## 5.2 Enhanced Requirements and Dependencies

Create an enhanced `requirements.txt`:

```txt
# Core dependencies
boto3>=1.34.0
requests>=2.31.0
PyJWT>=2.8.0
cryptography>=41.0.0

# GitHub API client
PyGithub>=1.59.0

# Async support
aiohttp>=3.9.0
asyncio>=3.4.3
aiofiles>=23.2.1

# Configuration management
click>=8.1.0
python-dotenv>=1.0.0
pyyaml>=6.0
pydantic>=2.5.0
pydantic-settings>=2.1.0

# Retry and resilience
tenacity>=8.2.0
backoff>=2.2.1
circuit-breaker>=1.3.2

# Monitoring and observability
structlog>=23.1.0
prometheus_client>=0.17.0
opentelemetry-api>=1.21.0
opentelemetry-sdk>=1.21.0
opentelemetry-exporter-prometheus>=1.12.0
datadog>=0.47.0

# Health checks and diagnostics
psutil>=5.9.6
py-healthcheck>=1.10.1

# AWS SDK extensions
boto3-stubs[secretsmanager,ecs,cloudwatch]>=1.34.0

# Date/time handling
python-dateutil>=2.8.2
pytz>=2023.3

# JSON Web Token handling
jwcrypto>=1.5.0

# Testing framework
pytest>=7.4.3
pytest-asyncio>=0.21.1
pytest-mock>=3.12.0
pytest-cov>=4.1.0
responses>=0.24.0

# Security
cryptography>=41.0.0
secrets>=1.0.0
hashlib-compat>=1.0.1

# Performance monitoring
memory-profiler>=0.61.0
line-profiler>=4.1.1

# Data validation
cerberus>=1.3.4
jsonschema>=4.20.0

# Utilities
rich>=13.7.0
tabulate>=0.9.0
humanize>=4.8.0
```

## 5.3 Enhanced Monitoring and Observability

### 5.3.1 Metrics Collection System

Create `monitoring/metrics.py`:

```python
"""
Comprehensive metrics collection for GitHub Runner
"""

import time
import threading
from typing import Dict, Any, Optional, List
from dataclasses import dataclass, field
from enum import Enum
import psutil
from prometheus_client import (
    Counter, Histogram, Gauge, Summary, 
    CollectorRegistry, generate_latest,
    start_http_server, CONTENT_TYPE_LATEST
)
import structlog


logger = structlog.get_logger(__name__)


class MetricType(Enum):
    """Metric type enumeration"""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    SUMMARY = "summary"


@dataclass
class MetricDefinition:
    """Metric definition with metadata"""
    name: str
    description: str
    metric_type: MetricType
    labels: List[str] = field(default_factory=list)
    buckets: Optional[List[float]] = None


class GitHubRunnerMetrics:
    """Comprehensive metrics collector for GitHub Runner"""
    
    def __init__(self, registry: Optional[CollectorRegistry] = None):
        """
        Initialize metrics collector
        
        Args:
            registry: Prometheus registry (uses default if None)
        """
        self.registry = registry or CollectorRegistry()
        self._metrics = {}
        self._system_info_gauge = None
        self._setup_metrics()
        
        # Start background system metrics collection
        self._metrics_thread = threading.Thread(target=self._collect_system_metrics, daemon=True)
        self._stop_event = threading.Event()
        self._metrics_thread.start()
        
        logger.info("Metrics collector initialized")
    
    def _setup_metrics(self) -> None:
        """Setup all metrics definitions"""
        
        # Define all metrics
        metrics_definitions = [
            # Runner lifecycle metrics
            MetricDefinition(
                "github_runner_starts_total",
                "Total number of runner starts",
                MetricType.COUNTER,
                ["runner_name", "repository", "status"]
            ),
            MetricDefinition(
                "github_runner_jobs_total", 
                "Total number of jobs processed",
                MetricType.COUNTER,
                ["runner_name", "repository", "job_status", "job_conclusion"]
            ),
            MetricDefinition(
                "github_runner_job_duration_seconds",
                "Duration of job execution in seconds",
                MetricType.HISTOGRAM,
                ["runner_name", "repository", "job_status"],
                buckets=[30, 60, 300, 600, 1800, 3600, 7200, float('inf')]
            ),
            MetricDefinition(
                "github_runner_registration_duration_seconds",
                "Time taken to register runner",
                MetricType.HISTOGRAM,
                ["runner_name", "repository"],
                buckets=[5, 10, 30, 60, 120, 300, float('inf')]
            ),
            
            # GitHub API metrics
            MetricDefinition(
                "github_api_requests_total",
                "Total GitHub API requests",
                MetricType.COUNTER,
                ["endpoint", "method", "status_code"]
            ),
            MetricDefinition(
                "github_api_request_duration_seconds",
                "GitHub API request duration",
                MetricType.HISTOGRAM,
                ["endpoint", "method"],
                buckets=[0.1, 0.5, 1.0, 2.0, 5.0, 10.0, float('inf')]
            ),
            MetricDefinition(
                "github_api_rate_limit_remaining",
                "GitHub API rate limit remaining",
                MetricType.GAUGE,
                ["endpoint"]
            ),
            
            # Authentication metrics
            MetricDefinition(
                "github_auth_token_renewals_total",
                "Total authentication token renewals",
                MetricType.COUNTER,
                ["token_type", "status"]
            ),
            MetricDefinition(
                "github_auth_errors_total",
                "Total authentication errors",
                MetricType.COUNTER,
                ["error_type", "endpoint"]
            ),
            
            # Docker metrics
            MetricDefinition(
                "docker_operations_total",
                "Total Docker operations",
                MetricType.COUNTER,
                ["operation", "status"]
            ),
            MetricDefinition(
                "docker_operation_duration_seconds", 
                "Docker operation duration",
                MetricType.HISTOGRAM,
                ["operation"],
                buckets=[1, 5, 10, 30, 60, 300, float('inf')]
            ),
            MetricDefinition(
                "docker_images_pulled_total",
                "Total Docker images pulled",
                MetricType.COUNTER,
                ["image", "status"]
            ),
            
            # System metrics
            MetricDefinition(
                "system_cpu_usage_percent",
                "System CPU usage percentage",
                MetricType.GAUGE,
                ["core"]
            ),
            MetricDefinition(
                "system_memory_usage_bytes",
                "System memory usage in bytes",
                MetricType.GAUGE,
                ["type"]  # used, available, total
            ),
            MetricDefinition(
                "system_disk_usage_bytes",
                "System disk usage in bytes", 
                MetricType.GAUGE,
                ["mountpoint", "type"]  # used, free, total
            ),
            MetricDefinition(
                "system_network_bytes_total",
                "Total network bytes",
                MetricType.COUNTER,
                ["interface", "direction"]  # sent, received
            ),
            
            # Error metrics
            MetricDefinition(
                "application_errors_total",
                "Total application errors",
                MetricType.COUNTER,
                ["component", "error_type", "severity"]
            ),
            MetricDefinition(
                "application_exceptions_total",
                "Total unhandled exceptions", 
                MetricType.COUNTER,
                ["component", "exception_type"]
            ),
            
            # Health metrics
            MetricDefinition(
                "health_check_status",
                "Health check status (1=healthy, 0=unhealthy)",
                MetricType.GAUGE,
                ["check_name"]
            ),
            MetricDefinition(
                "health_check_duration_seconds",
                "Health check execution duration",
                MetricType.HISTOGRAM,
                ["check_name"],
                buckets=[0.1, 0.5, 1.0, 2.0, 5.0, float('inf')]
            )
        ]
        
        # Create metric instances
        for metric_def in metrics_definitions:
            self._create_metric(metric_def)
    
    def _create_metric(self, metric_def: MetricDefinition) -> None:
        """Create a metric instance from definition"""
        
        kwargs = {
            'name': metric_def.name,
            'documentation': metric_def.description,
            'labelnames': metric_def.labels,
            'registry': self.registry
        }
        
        if metric_def.metric_type == MetricType.COUNTER:
            metric = Counter(**kwargs)
        elif metric_def.metric_type == MetricType.GAUGE:
            metric = Gauge(**kwargs)
        elif metric_def.metric_type == MetricType.HISTOGRAM:
            if metric_def.buckets:
                kwargs['buckets'] = metric_def.buckets
            metric = Histogram(**kwargs)
        elif metric_def.metric_type == MetricType.SUMMARY:
            metric = Summary(**kwargs)
        else:
            raise ValueError(f"Unknown metric type: {metric_def.metric_type}")
        
        self._metrics[metric_def.name] = metric
        logger.debug(f"Created metric: {metric_def.name}")
    
    def increment_counter(self, metric_name: str, labels: Optional[Dict[str, str]] = None, value: float = 1) -> None:
        """Increment a counter metric"""
        metric = self._metrics.get(metric_name)
        if metric and hasattr(metric, 'inc'):
            if labels:
                metric.labels(**labels).inc(value)
            else:
                metric.inc(value)
        else:
            logger.warning(f"Counter metric not found: {metric_name}")
    
    def set_gauge(self, metric_name: str, value: float, labels: Optional[Dict[str, str]] = None) -> None:
        """Set a gauge metric value"""
        metric = self._metrics.get(metric_name)
        if metric and hasattr(metric, 'set'):
            if labels:
                metric.labels(**labels).set(value)
            else:
                metric.set(value)
        else:
            logger.warning(f"Gauge metric not found: {metric_name}")
    
    def observe_histogram(self, metric_name: str, value: float, labels: Optional[Dict[str, str]] = None) -> None:
        """Observe a histogram metric"""
        metric = self._metrics.get(metric_name)
        if metric and hasattr(metric, 'observe'):
            if labels:
                metric.labels(**labels).observe(value)
            else:
                metric.observe(value)
        else:
            logger.warning(f"Histogram metric not found: {metric_name}")
    
    def time_histogram(self, metric_name: str, labels: Optional[Dict[str, str]] = None):
        """Context manager for timing histogram metrics"""
        return HistogramTimer(self, metric_name, labels)
    
    def record_runner_start(self, runner_name: str, repository: str, status: str) -> None:
        """Record runner start event"""
        self.increment_counter(
            "github_runner_starts_total",
            {"runner_name": runner_name, "repository": repository, "status": status}
        )
    
    def record_job_completion(self, runner_name: str, repository: str, 
                            job_status: str, job_conclusion: str, duration: float) -> None:
        """Record job completion"""
        labels = {
            "runner_name": runner_name,
            "repository": repository, 
            "job_status": job_status,
            "job_conclusion": job_conclusion
        }
        
        # Count the job
        self.increment_counter("github_runner_jobs_total", labels)
        
        # Record duration
        duration_labels = {k: v for k, v in labels.items() if k != "job_conclusion"}
        self.observe_histogram("github_runner_job_duration_seconds", duration, duration_labels)
    
    def record_api_request(self, endpoint: str, method: str, status_code: int, 
                          duration: float, rate_limit_remaining: Optional[int] = None) -> None:
        """Record GitHub API request metrics"""
        # Count request
        self.increment_counter(
            "github_api_requests_total",
            {"endpoint": endpoint, "method": method, "status_code": str(status_code)}
        )
        
        # Record duration  
        self.observe_histogram(
            "github_api_request_duration_seconds",
            duration,
            {"endpoint": endpoint, "method": method}
        )
        
        # Record rate limit
        if rate_limit_remaining is not None:
            self.set_gauge(
                "github_api_rate_limit_remaining",
                rate_limit_remaining,
                {"endpoint": endpoint}
            )
    
    def record_error(self, component: str, error_type: str, severity: str = "error") -> None:
        """Record application error"""
        self.increment_counter(
            "application_errors_total",
            {"component": component, "error_type": error_type, "severity": severity}
        )
    
    def record_exception(self, component: str, exception_type: str) -> None:
        """Record unhandled exception"""
        self.increment_counter(
            "application_exceptions_total", 
            {"component": component, "exception_type": exception_type}
        )
    
    def _collect_system_metrics(self) -> None:
        """Background thread for collecting system metrics"""
        while not self._stop_event.is_set():
            try:
                # CPU metrics
                cpu_percent = psutil.cpu_percent(interval=1, percpu=True)
                for i, percent in enumerate(cpu_percent):
                    self.set_gauge("system_cpu_usage_percent", percent, {"core": str(i)})
                
                # Memory metrics
                memory = psutil.virtual_memory()
                self.set_gauge("system_memory_usage_bytes", memory.used, {"type": "used"})
                self.set_gauge("system_memory_usage_bytes", memory.available, {"type": "available"})
                self.set_gauge("system_memory_usage_bytes", memory.total, {"type": "total"})
                
                # Disk metrics
                for partition in psutil.disk_partitions():
                    try:
                        usage = psutil.disk_usage(partition.mountpoint)
                        labels = {"mountpoint": partition.mountpoint}
                        self.set_gauge("system_disk_usage_bytes", usage.used, {**labels, "type": "used"})
                        self.set_gauge("system_disk_usage_bytes", usage.free, {**labels, "type": "free"})
                        self.set_gauge("system_disk_usage_bytes", usage.total, {**labels, "type": "total"})
                    except (OSError, PermissionError):
                        continue
                
                # Network metrics
                network = psutil.net_io_counters(pernic=True)
                for interface, stats in network.items():
                    labels_sent = {"interface": interface, "direction": "sent"}
                    labels_recv = {"interface": interface, "direction": "received"}
                    self.set_gauge("system_network_bytes_total", stats.bytes_sent, labels_sent)
                    self.set_gauge("system_network_bytes_total", stats.bytes_recv, labels_recv)
                
            except Exception as e:
                logger.warning(f"Error collecting system metrics: {e}")
            
            # Wait before next collection
            self._stop_event.wait(30)  # Collect every 30 seconds
    
    def get_metrics_text(self) -> str:
        """Get metrics in Prometheus text format"""
        return generate_latest(self.registry).decode('utf-8')
    
    def start_metrics_server(self, port: int = 8000) -> None:
        """Start HTTP server for metrics"""
        try:
            start_http_server(port, registry=self.registry)
            logger.info(f"Metrics server started on port {port}")
        except Exception as e:
            logger.error(f"Failed to start metrics server: {e}")
    
    def shutdown(self) -> None:
        """Shutdown metrics collection"""
        self._stop_event.set()
        if self._metrics_thread.is_alive():
            self._metrics_thread.join(timeout=5)
        logger.info("Metrics collector shutdown complete")


class HistogramTimer:
    """Context manager for timing histogram metrics"""
    
    def __init__(self, metrics: GitHubRunnerMetrics, metric_name: str, labels: Optional[Dict[str, str]] = None):
        self.metrics = metrics
        self.metric_name = metric_name
        self.labels = labels
        self.start_time = None
    
    def __enter__(self):
        self.start_time = time.time()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.start_time:
            duration = time.time() - self.start_time
            self.metrics.observe_histogram(self.metric_name, duration, self.labels)
```

### 5.3.2 Health Check System

Create `monitoring/health_checker.py`:

```python
"""
Comprehensive health check system for GitHub Runner
"""

import asyncio
import time
import socket
import subprocess
import requests
from typing import Dict, Any, List, Optional, Callable
from dataclasses import dataclass, field
from enum import Enum
import structlog
from abc import ABC, abstractmethod

from ..utils.github_auth import GitHubAppAuth


logger = structlog.get_logger(__name__)


class HealthStatus(Enum):
    """Health check status enumeration"""
    HEALTHY = "healthy"
    UNHEALTHY = "unhealthy"
    WARNING = "warning"
    UNKNOWN = "unknown"


@dataclass
class HealthCheckResult:
    """Health check result"""
    name: str
    status: HealthStatus
    message: str
    duration: float
    timestamp: float = field(default_factory=time.time)
    details: Optional[Dict[str, Any]] = None


class BaseHealthCheck(ABC):
    """Base class for health checks"""
    
    def __init__(self, name: str, timeout: float = 10.0):
        self.name = name
        self.timeout = timeout
    
    @abstractmethod
    async def check(self) -> HealthCheckResult:
        """Perform the health check"""
        pass
    
    def _create_result(self, status: HealthStatus, message: str, 
                      duration: float, details: Optional[Dict[str, Any]] = None) -> HealthCheckResult:
        """Create a health check result"""
        return HealthCheckResult(
            name=self.name,
            status=status,
            message=message,
            duration=duration,
            details=details
        )


class DockerHealthCheck(BaseHealthCheck):
    """Health check for Docker daemon connectivity"""
    
    def __init__(self, docker_host: str = "unix:///var/run/docker.sock"):
        super().__init__("docker", timeout=15.0)
        self.docker_host = docker_host
    
    async def check(self) -> HealthCheckResult:
        """Check Docker daemon health"""
        start_time = time.time()
        
        try:
            # Run docker version command
            process = await asyncio.create_subprocess_exec(
                "docker", "version",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            stdout, stderr = await asyncio.wait_for(
                process.communicate(),
                timeout=self.timeout
            )
            
            duration = time.time() - start_time
            
            if process.returncode == 0:
                # Parse Docker version info
                version_info = stdout.decode().strip()
                return self._create_result(
                    HealthStatus.HEALTHY,
                    "Docker daemon is accessible",
                    duration,
                    {"version_info": version_info}
                )
            else:
                error_msg = stderr.decode().strip()
                return self._create_result(
                    HealthStatus.UNHEALTHY,
                    f"Docker daemon error: {error_msg}",
                    duration
                )
                
        except asyncio.TimeoutError:
            duration = time.time() - start_time
            return self._create_result(
                HealthStatus.UNHEALTHY,
                f"Docker health check timed out after {self.timeout}s",
                duration
            )
        except Exception as e:
            duration = time.time() - start_time
            return self._create_result(
                HealthStatus.UNHEALTHY,
                f"Docker health check failed: {str(e)}",
                duration
            )


class GitHubAPIHealthCheck(BaseHealthCheck):
    """Health check for GitHub API connectivity"""
    
    def __init__(self, auth: GitHubAppAuth):
        super().__init__("github_api", timeout=30.0)
        self.auth = auth
    
    async def check(self) -> HealthCheckResult:
        """Check GitHub API health"""
        start_time = time.time()
        
        try:
            # Test GitHub API connectivity
            loop = asyncio.get_event_loop()
            response = await loop.run_in_executor(
                None,
                lambda: self.auth.make_request('GET', '/rate_limit')
            )
            
            duration = time.time() - start_time
            rate_limit_data = response.json()
            
            # Check rate limits
            core_remaining = rate_limit_data.get('resources', {}).get('core', {}).get('remaining', 0)
            
            if core_remaining > 100:
                status = HealthStatus.HEALTHY
                message = f"GitHub API healthy, {core_remaining} requests remaining"
            elif core_remaining > 10:
                status = HealthStatus.WARNING
                message = f"GitHub API rate limit low: {core_remaining} requests remaining"
            else:
                status = HealthStatus.UNHEALTHY
                message = f"GitHub API rate limit critical: {core_remaining} requests remaining"
            
            return self._create_result(
                status,
                message,
                duration,
                {"rate_limit": rate_limit_data}
            )
            
        except asyncio.TimeoutError:
            duration = time.time() - start_time
            return self._create_result(
                HealthStatus.UNHEALTHY,
                f"GitHub API health check timed out after {self.timeout}s",
                duration
            )
        except Exception as e:
            duration = time.time() - start_time
            return self._create_result(
                HealthStatus.UNHEALTHY,
                f"GitHub API health check failed: {str(e)}",
                duration
            )


class SystemResourcesHealthCheck(BaseHealthCheck):
    """Health check for system resources"""
    
    def __init__(self, memory_threshold: float = 90.0, disk_threshold: float = 90.0):
        super().__init__("system_resources", timeout=5.0)
        self.memory_threshold = memory_threshold
        self.disk_threshold = disk_threshold
    
    async def check(self) -> HealthCheckResult:
        """Check system resource health"""
        start_time = time.time()
        
        try:
            import psutil
            
            # Check memory usage
            memory = psutil.virtual_memory()
            memory_percent = memory.percent
            
            # Check disk usage
            disk = psutil.disk_usage('/')
            disk_percent = (disk.used / disk.total) * 100
            
            duration = time.time() - start_time
            
            details = {
                "memory_percent": memory_percent,
                "disk_percent": disk_percent,
                "memory_available_gb": memory.available / (1024**3),
                "disk_free_gb": disk.free / (1024**3)
            }
            
            # Determine health status
            if memory_percent > self.memory_threshold or disk_percent > self.disk_threshold:
                status = HealthStatus.UNHEALTHY
                message = f"Resource usage critical: Memory {memory_percent:.1f}%, Disk {disk_percent:.1f}%"
            elif memory_percent > (self.memory_threshold - 10) or disk_percent > (self.disk_threshold - 10):
                status = HealthStatus.WARNING
                message = f"Resource usage high: Memory {memory_percent:.1f}%, Disk {disk_percent:.1f}%"
            else:
                status = HealthStatus.HEALTHY
                message = f"Resources healthy: Memory {memory_percent:.1f}%, Disk {disk_percent:.1f}%"
            
            return self._create_result(status, message, duration, details)
            
        except Exception as e:
            duration = time.time() - start_time
            return self._create_result(
                HealthStatus.UNHEALTHY,
                f"System resources check failed: {str(e)}",
                duration
            )


class NetworkConnectivityHealthCheck(BaseHealthCheck):
    """Health check for network connectivity"""
    
    def __init__(self, endpoints: List[str] = None):
        super().__init__("network_connectivity", timeout=15.0)
        self.endpoints = endpoints or [
            "https://api.github.com",
            "https://github.com",
            "https://registry-1.docker.io"
        ]
    
    async def check(self) -> HealthCheckResult:
        """Check network connectivity"""
        start_time = time.time()
        
        try:
            results = {}
            
            async with asyncio.timeout(self.timeout):
                for endpoint in self.endpoints:
                    endpoint_start = time.time()
                    try:
                        # Simple HTTP check
                        response = requests.head(endpoint, timeout=5)
                        endpoint_duration = time.time() - endpoint_start
                        results[endpoint] = {
                            "status": "success",
                            "status_code": response.status_code,
                            "duration": endpoint_duration
                        }
                    except Exception as e:
                        endpoint_duration = time.time() - endpoint_start
                        results[endpoint] = {
                            "status": "failed",
                            "error": str(e),
                            "duration": endpoint_duration
                        }
            
            duration = time.time() - start_time
            
            # Analyze results
            successful = sum(1 for r in results.values() if r["status"] == "success")
            total = len(results)
            
            if successful == total:
                status = HealthStatus.HEALTHY
                message = f"All {total} endpoints reachable"
            elif successful > 0:
                status = HealthStatus.WARNING
                message = f"{successful}/{total} endpoints reachable"
            else:
                status = HealthStatus.UNHEALTHY
                message = "No endpoints reachable"
            
            return self._create_result(status, message, duration, {"endpoints": results})
            
        except Exception as e:
            duration = time.time() - start_time
            return self._create_result(
                HealthStatus.UNHEALTHY,
                f"Network connectivity check failed: {str(e)}",
                duration
            )


class HealthChecker:
    """Comprehensive health checker"""
    
    def __init__(self, checks: List[BaseHealthCheck] = None, metrics=None):
        """
        Initialize health checker
        
        Args:
            checks: List of health checks to perform
            metrics: Metrics collector instance
        """
        self.checks = checks or []
        self.metrics = metrics
        self.last_results: Dict[str, HealthCheckResult] = {}
        
        logger.info(f"Health checker initialized with {len(self.checks)} checks")
    
    def add_check(self, check: BaseHealthCheck) -> None:
        """Add a health check"""
        self.checks.append(check)
        logger.info(f"Added health check: {check.name}")
    
    async def run_check(self, check: BaseHealthCheck) -> HealthCheckResult:
        """Run a single health check"""
        logger.debug(f"Running health check: {check.name}")
        
        try:
            result = await check.check()
            self.last_results[check.name] = result
            
            # Record metrics if available
            if self.metrics:
                status_value = 1 if result.status == HealthStatus.HEALTHY else 0
                self.metrics.set_gauge(
                    "health_check_status",
                    status_value,
                    {"check_name": check.name}
                )
                self.metrics.observe_histogram(
                    "health_check_duration_seconds",
                    result.duration,
                    {"check_name": check.name}
                )
            
            logger.debug(f"Health check {check.name}: {result.status.value} - {result.message}")
            return result
            
        except Exception as e:
            logger.error(f"Health check {check.name} failed with exception: {e}")
            result = HealthCheckResult(
                name=check.name,
                status=HealthStatus.UNHEALTHY,
                message=f"Check failed with exception: {str(e)}",
                duration=0.0
            )
            self.last_results[check.name] = result
            return result
    
    async def run_all_checks(self) -> Dict[str, HealthCheckResult]:
        """Run all health checks"""
        logger.info("Running all health checks")
        
        if not self.checks:
            logger.warning("No health checks configured")
            return {}
        
        # Run all checks concurrently
        tasks = [self.run_check(check) for check in self.checks]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Process results
        check_results = {}
        for i, result in enumerate(results):
            check_name = self.checks[i].name
            if isinstance(result, Exception):
                logger.error(f"Health check {check_name} raised exception: {result}")
                check_results[check_name] = HealthCheckResult(
                    name=check_name,
                    status=HealthStatus.UNHEALTHY,
                    message=f"Exception: {str(result)}",
                    duration=0.0
                )
            else:
                check_results[check_name] = result
        
        return check_results
    
    def get_overall_status(self, results: Dict[str, HealthCheckResult] = None) -> HealthStatus:
        """Get overall health status"""
        if results is None:
            results = self.last_results
        
        if not results:
            return HealthStatus.UNKNOWN
        
        statuses = [result.status for result in results.values()]
        
        if any(status == HealthStatus.UNHEALTHY for status in statuses):
            return HealthStatus.UNHEALTHY
        elif any(status == HealthStatus.WARNING for status in statuses):
            return HealthStatus.WARNING
        elif all(status == HealthStatus.HEALTHY for status in statuses):
            return HealthStatus.HEALTHY
        else:
            return HealthStatus.UNKNOWN
    
    def get_health_report(self, results: Dict[str, HealthCheckResult] = None) -> Dict[str, Any]:
        """Get comprehensive health report"""
        if results is None:
            results = self.last_results
        
        overall_status = self.get_overall_status(results)
        
        return {
            "overall_status": overall_status.value,
            "timestamp": time.time(),
            "checks": {
                name: {
                    "status": result.status.value,
                    "message": result.message,
                    "duration": result.duration,
                    "timestamp": result.timestamp,
                    "details": result.details
                }
                for name, result in results.items()
            },
            "summary": {
                "total_checks": len(results),
                "healthy": sum(1 for r in results.values() if r.status == HealthStatus.HEALTHY),
                "warning": sum(1 for r in results.values() if r.status == HealthStatus.WARNING),
                "unhealthy": sum(1 for r in results.values() if r.status == HealthStatus.UNHEALTHY),
                "unknown": sum(1 for r in results.values() if r.status == HealthStatus.UNKNOWN)
            }
        }
```

### 5.3.3 Structured Logging System

Create `monitoring/log_formatter.py`:

```python
"""
Structured logging configuration for GitHub Runner
"""

import os
import sys
import json
import time
import logging
from typing import Dict, Any, Optional
from datetime import datetime
import structlog
from structlog.types import EventDict


class GitHubRunnerProcessor:
    """Custom processor for GitHub Runner specific fields"""
    
    def __init__(self, runner_name: str = None, repository: str = None):
        self.runner_name = runner_name
        self.repository = repository
    
    def __call__(self, logger: logging.Logger, method_name: str, event_dict: EventDict) -> EventDict:
        """Add runner-specific context to log events"""
        
        # Add runner context
        if self.runner_name:
            event_dict["runner_name"] = self.runner_name
        if self.repository:
            event_dict["repository"] = self.repository
        
        # Add timestamp
        event_dict["timestamp"] = datetime.utcnow().isoformat() + "Z"
        
        # Add log level
        event_dict["level"] = method_name.upper()
        
        # Add process information
        event_dict["pid"] = os.getpid()
        
        return event_dict


class AWSCloudWatchProcessor:
    """Processor for AWS CloudWatch compatibility"""
    
    def __call__(self, logger: logging.Logger, method_name: str, event_dict: EventDict) -> EventDict:
        """Format logs for CloudWatch"""
        
        # Add AWS specific fields
        event_dict["@timestamp"] = datetime.utcnow().isoformat() + "Z"
        event_dict["@version"] = "1"
        event_dict["logger_name"] = logger.name
        
        # Add ECS task metadata if available
        task_metadata_uri = os.environ.get('ECS_CONTAINER_METADATA_URI_V4')
        if task_metadata_uri:
            event_dict["ecs_task_metadata_uri"] = task_metadata_uri
        
        # Add container information
        if os.path.exists('/proc/1/cgroup'):
            try:
                with open('/proc/1/cgroup', 'r') as f:
                    cgroup_content = f.read()
                    # Extract container ID from cgroup
                    for line in cgroup_content.split('\n'):
                        if 'docker' in line or 'ecs' in line:
                            parts = line.split('/')
                            if parts:
                                container_id = parts[-1][:12]  # First 12 chars
                                event_dict["container_id"] = container_id
                                break
            except Exception:
                pass
        
        return event_dict


class SecurityAuditProcessor:
    """Processor for security audit logging"""
    
    SENSITIVE_FIELDS = {
        'token', 'password', 'secret', 'key', 'auth', 'credential',
        'private_key', 'jwt', 'bearer', 'authorization'
    }
    
    def __call__(self, logger: logging.Logger, method_name: str, event_dict: EventDict) -> EventDict:
        """Sanitize sensitive information in logs"""
        
        # Recursively sanitize the event dict
        event_dict = self._sanitize_dict(event_dict)
        
        return event_dict
    
    def _sanitize_dict(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Recursively sanitize sensitive information"""
        if not isinstance(data, dict):
            return data
        
        sanitized = {}
        for key, value in data.items():
            if any(sensitive in key.lower() for sensitive in self.SENSITIVE_FIELDS):
                # Replace sensitive data with masked value
                if isinstance(value, str) and len(value) > 4:
                    sanitized[key] = f"{value[:2]}***{value[-2:]}"
                else:
                    sanitized[key] = "***"
            elif isinstance(value, dict):
                sanitized[key] = self._sanitize_dict(value)
            elif isinstance(value, list):
                sanitized[key] = [
                    self._sanitize_dict(item) if isinstance(item, dict) else item
                    for item in value
                ]
            else:
                sanitized[key] = value
        
        return sanitized


def configure_logging(
    level: str = "INFO",
    format_type: str = "json",
    runner_name: str = None,
    repository: str = None,
    enable_cloudwatch: bool = True,
    enable_security_audit: bool = True
) -> None:
    """
    Configure structured logging for GitHub Runner
    
    Args:
        level: Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        format_type: Output format ('json' or 'console')
        runner_name: Runner name for context
        repository: Repository name for context
        enable_cloudwatch: Enable CloudWatch compatibility
        enable_security_audit: Enable security audit features
    """
    
    # Configure timestamper
    timestamper = structlog.processors.TimeStamper(fmt="ISO")
    
    # Build processor chain
    processors = [
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        timestamper,
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
    ]
    
    # Add custom processors
    if runner_name or repository:
        processors.append(GitHubRunnerProcessor(runner_name, repository))
    
    if enable_cloudwatch:
        processors.append(AWSCloudWatchProcessor())
    
    if enable_security_audit:
        processors.append(SecurityAuditProcessor())
    
    # Configure output format
    if format_type == "json":
        processors.append(structlog.processors.JSONRenderer())
    else:
        processors.append(structlog.dev.ConsoleRenderer())
    
    # Configure structlog
    structlog.configure(
        processors=processors,
        wrapper_class=structlog.stdlib.BoundLogger,
        logger_factory=structlog.stdlib.LoggerFactory(),
        context_class=dict,
        cache_logger_on_first_use=True,
    )
    
    # Configure standard logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=getattr(logging, level.upper())
    )
    
    # Set logging levels for noisy libraries
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("requests").setLevel(logging.WARNING)
    logging.getLogger("boto3").setLevel(logging.WARNING)
    logging.getLogger("botocore").setLevel(logging.WARNING)
    
    logger = structlog.get_logger(__name__)
    logger.info(
        "Logging configured",
        level=level,
        format_type=format_type,
        enable_cloudwatch=enable_cloudwatch,
        enable_security_audit=enable_security_audit
    )


# Logging utilities
def get_logger(name: str) -> structlog.BoundLogger:
    """Get a structured logger instance"""
    return structlog.get_logger(name)


def log_function_call(func):
    """Decorator to log function calls"""
    def wrapper(*args, **kwargs):
        logger = get_logger(func.__module__)
        logger.debug(
            "Function called",
            function=func.__name__,
            args_count=len(args),
            kwargs_keys=list(kwargs.keys())
        )
        
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            duration = time.time() - start_time
            logger.debug(
                "Function completed",
                function=func.__name__,
                duration=duration
            )
            return result
        except Exception as e:
            duration = time.time() - start_time
            logger.error(
                "Function failed",
                function=func.__name__,
                duration=duration,
                error=str(e),
                exception_type=type(e).__name__
            )
            raise
    
    return wrapper


def log_performance(operation_name: str):
    """Decorator to log performance metrics"""
    def decorator(func):
        def wrapper(*args, **kwargs):
            logger = get_logger(func.__module__)
            start_time = time.time()
            
            try:
                result = func(*args, **kwargs)
                duration = time.time() - start_time
                
                logger.info(
                    "Performance metric",
                    operation=operation_name,
                    function=func.__name__,
                    duration=duration,
                    status="success"
                )
                
                return result
            except Exception as e:
                duration = time.time() - start_time
                
                logger.error(
                    "Performance metric",
                    operation=operation_name,
                    function=func.__name__,
                    duration=duration,
                    status="error",
                    error=str(e)
                )
                raise
        
        return wrapper
    return decorator
```

## 5.4 Enhanced Error Handling and Resilience

### 5.4.1 Advanced Retry Logic

Create `utils/resilience.py`:

```python
"""
Enhanced resilience utilities for GitHub Runner
"""

import asyncio
import time
import random
from typing import Any, Callable, Optional, Type, Union, List
from dataclasses import dataclass
from enum import Enum
import structlog
from tenacity import (
    retry, stop_after_attempt, wait_exponential, 
    retry_if_exception_type, before_sleep_log
)
import requests


logger = structlog.get_logger(__name__)


class RetryStrategy(Enum):
    """Retry strategy enumeration"""
    EXPONENTIAL_BACKOFF = "exponential_backoff"
    FIXED_DELAY = "fixed_delay"
    LINEAR_BACKOFF = "linear_backoff"
    JITTERED_BACKOFF = "jittered_backoff"


@dataclass
class RetryConfig:
    """Configuration for retry behavior"""
    max_attempts: int = 3
    strategy: RetryStrategy = RetryStrategy.EXPONENTIAL_BACKOFF
    base_delay: float = 1.0
    max_delay: float = 60.0
    multiplier: float = 2.0
    jitter: bool = True
    retry_on_exceptions: List[Type[Exception]] = None
    
    def __post_init__(self):
        if self.retry_on_exceptions is None:
            self.retry_on_exceptions = [
                requests.exceptions.RequestException,
                ConnectionError,
                TimeoutError,
                OSError
            ]


class CircuitBreakerState(Enum):
    """Circuit breaker state enumeration"""
    CLOSED = "closed"
    OPEN = "open"  
    HALF_OPEN = "half_open"


class CircuitBreaker:
    """Circuit breaker implementation"""
    
    def __init__(self, failure_threshold: int = 5, recovery_timeout: float = 60.0,
                 expected_exception: Type[Exception] = Exception):
        """
        Initialize circuit breaker
        
        Args:
            failure_threshold: Number of failures before opening
            recovery_timeout: Time before attempting recovery
            expected_exception: Exception type to monitor
        """
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time: Optional[float] = None
        self.state = CircuitBreakerState.CLOSED
        
        logger.info(
            "Circuit breaker initialized",
            failure_threshold=failure_threshold,
            recovery_timeout=recovery_timeout
        )
    
    def __call__(self, func: Callable) -> Callable:
        """Decorator implementation"""
        
        def wrapper(*args, **kwargs):
            return self._call_with_circuit_breaker(func, *args, **kwargs)
        
        return wrapper
    
    def _call_with_circuit_breaker(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function with circuit breaker logic"""
        
        if self.state == CircuitBreakerState.OPEN:
            # Check if recovery timeout has passed
            if (time.time() - self.last_failure_time) < self.recovery_timeout:
                raise CircuitBreakerOpenError(
                    f"Circuit breaker is open. Last failure: {self.last_failure_time}"
                )
            else:
                # Move to half-open state
                self.state = CircuitBreakerState.HALF_OPEN
                logger.info("Circuit breaker moving to half-open state")
        
        try:
            result = func(*args, **kwargs)
            
            # Success - reset if we were in half-open state
            if self.state == CircuitBreakerState.HALF_OPEN:
                self._reset()
                logger.info("Circuit breaker reset after successful call")
            
            return result
            
        except self.expected_exception as e:
            self._record_failure()
            logger.warning(
                "Circuit breaker recorded failure",
                failure_count=self.failure_count,
                state=self.state.value,
                error=str(e)
            )
            raise
        except Exception as e:
            # Unexpected exception - don't affect circuit breaker
            logger.error(f"Unexpected exception in circuit breaker: {e}")
            raise
    
    def _record_failure(self) -> None:
        """Record a failure"""
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitBreakerState.OPEN
            logger.warning(
                "Circuit breaker opened",
                failure_count=self.failure_count,
                threshold=self.failure_threshold
            )
    
    def _reset(self) -> None:
        """Reset circuit breaker"""
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitBreakerState.CLOSED
    
    def get_state(self) -> CircuitBreakerState:
        """Get current circuit breaker state"""
        return self.state


class CircuitBreakerOpenError(Exception):
    """Exception raised when circuit breaker is open"""
    pass


class EnhancedRetry:
    """Enhanced retry decorator with multiple strategies"""
    
    def __init__(self, config: RetryConfig = None):
        """
        Initialize enhanced retry
        
        Args:
            config: Retry configuration
        """
        self.config = config or RetryConfig()
        
    def __call__(self, func: Callable) -> Callable:
        """Decorator implementation"""
        
        # Build tenacity retry decorator based on config
        retry_decorator = self._build_retry_decorator()
        
        return retry_decorator(func)
    
    def _build_retry_decorator(self):
        """Build tenacity retry decorator from config"""
        
        # Stop condition
        stop_condition = stop_after_attempt(self.config.max_attempts)
        
        # Wait strategy
        if self.config.strategy == RetryStrategy.EXPONENTIAL_BACKOFF:
            if self.config.jitter:
                wait_strategy = wait_exponential(
                    multiplier=self.config.multiplier,
                    min=self.config.base_delay,
                    max=self.config.max_delay
                )
            else:
                wait_strategy = wait_exponential(
                    multiplier=self.config.multiplier,
                    min=self.config.base_delay,
                    max=self.config.max_delay
                )
        elif self.config.strategy == RetryStrategy.FIXED_DELAY:
            wait_strategy = lambda retry_state: self.config.base_delay
        elif self.config.strategy == RetryStrategy.LINEAR_BACKOFF:
            wait_strategy = lambda retry_state: min(
                self.config.base_delay * retry_state.attempt_number,
                self.config.max_delay
            )
        elif self.config.strategy == RetryStrategy.JITTERED_BACKOFF:
            wait_strategy = lambda retry_state: min(
                self.config.base_delay * (2 ** retry_state.attempt_number) + random.uniform(0, 1),
                self.config.max_delay
            )
        else:
            wait_strategy = wait_exponential(multiplier=1, min=1, max=60)
        
        # Exception condition
        if self.config.retry_on_exceptions:
            retry_condition = retry_if_exception_type(tuple(self.config.retry_on_exceptions))
        else:
            retry_condition = retry_if_exception_type(Exception)
        
        # Build decorator
        return retry(
            stop=stop_condition,
            wait=wait_strategy,
            retry=retry_condition,
            before_sleep=before_sleep_log(logger, logging.WARNING)
        )


# Predefined retry configurations
GITHUB_API_RETRY = RetryConfig(
    max_attempts=5,
    strategy=RetryStrategy.EXPONENTIAL_BACKOFF,
    base_delay=2.0,
    max_delay=30.0,
    retry_on_exceptions=[
        requests.exceptions.RequestException,
        requests.exceptions.Timeout,
        requests.exceptions.ConnectionError
    ]
)

DOCKER_OPERATION_RETRY = RetryConfig(
    max_attempts=3,
    strategy=RetryStrategy.JITTERED_BACKOFF,
    base_delay=5.0,
    max_delay=60.0,
    retry_on_exceptions=[
        ConnectionError,
        TimeoutError,
        OSError
    ]
)

AWS_API_RETRY = RetryConfig(
    max_attempts=4,
    strategy=RetryStrategy.EXPONENTIAL_BACKOFF,
    base_delay=1.0,
    max_delay=16.0,
    retry_on_exceptions=[
        Exception  # AWS SDK handles specific retryable exceptions
    ]
)


# Convenience decorators
def github_api_retry(func: Callable) -> Callable:
    """Retry decorator for GitHub API operations"""
    return EnhancedRetry(GITHUB_API_RETRY)(func)


def docker_operation_retry(func: Callable) -> Callable:
    """Retry decorator for Docker operations"""
    return EnhancedRetry(DOCKER_OPERATION_RETRY)(func)


def aws_api_retry(func: Callable) -> Callable:
    """Retry decorator for AWS API operations"""
    return EnhancedRetry(AWS_API_RETRY)(func)


class RateLimiter:
    """Rate limiter for API calls"""
    
    def __init__(self, max_calls: int, time_window: float):
        """
        Initialize rate limiter
        
        Args:
            max_calls: Maximum calls per time window
            time_window: Time window in seconds
        """
        self.max_calls = max_calls
        self.time_window = time_window
        self.calls = []
        
        logger.info(
            "Rate limiter initialized",
            max_calls=max_calls,
            time_window=time_window
        )
    
    async def acquire(self) -> None:
        """Acquire permission to make a call"""
        now = time.time()
        
        # Remove old calls outside the time window
        self.calls = [call_time for call_time in self.calls if now - call_time < self.time_window]
        
        # Check if we can make another call
        if len(self.calls) >= self.max_calls:
            # Calculate wait time
            oldest_call = min(self.calls)
            wait_time = self.time_window - (now - oldest_call)
            
            logger.info(
                "Rate limit reached, waiting",
                wait_time=wait_time,
                current_calls=len(self.calls)
            )
            
            await asyncio.sleep(wait_time)
            return await self.acquire()  # Recursive call after waiting
        
        # Record this call
        self.calls.append(now)
    
    def __call__(self, func: Callable) -> Callable:
        """Decorator implementation"""
        
        async def async_wrapper(*args, **kwargs):
            await self.acquire()
            return await func(*args, **kwargs)
        
        def sync_wrapper(*args, **kwargs):
            # For sync functions, use asyncio.run
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                loop.run_until_complete(self.acquire())
                return func(*args, **kwargs)
            finally:
                loop.close()
        
        # Return appropriate wrapper based on function type
        if asyncio.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper
```

This enhanced Step 5 provides a robust foundation for production-ready GitHub runner deployment. Would you like me to continue with the remaining parts of the enhanced Python application, including workflow orchestration, security enhancements, and the comprehensive main entrypoint script?


---

### User

Let's move on to Step 6.


---

### Assistant (claude-4-sonnet-reasoning)




---
