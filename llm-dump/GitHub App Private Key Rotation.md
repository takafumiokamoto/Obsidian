# GitHub App Private Key Rotation
Created: 6/17/2025, 4:44:49 PM
Last Updated: 6/17/2025, 4:44:49 PM
---

### User

is it able to rotate private key for GitHub App automatically?


---

### Assistant (gemini-2.5-pro)

<details>
<summary>Reasoning</summary>

**Clarifying the Query**

I'm now fully immersed in understanding the user's need. I'm focusing on the "GitHub" and "rotate private key" components. This deconstruction is helping me zero in on the exact problem and identify the relevant context for a comprehensive solution. My goal is to determine the optimal approach for key rotation within the GitHub ecosystem.


**Analyzing Automations**

I've explored the question further, focusing on automation. My research indicates GitHub itself doesn't offer built-in key rotation. Now, I'm examining scripting and third-party solutions that might provide an automated approach. I'm considering integrating these into a practical solution tailored to the user's need. The process is nearing an answer.


**Developing a Strategy**

I'm now crafting a structured response. I'll begin with a clear, direct answer to the user's question about automated key rotation. Then, I'll explain the security reasons behind rotation, enhancing the overall value. Lastly, I'll outline the high-level steps for automating this process, establishing a foundation for the automation script.


**Adjusting My Approach**

I've hit a significant roadblock. The GitHub API *lacks* a direct endpoint for uploading new private keys. This necessitates a revision of the automation strategy. Instead of a fully automated script, my response will focus on guiding the user through the manual steps, providing clear instructions for key generation, secure storage, and scheduled execution.


**Adjusting the Automation**

Now, I'm adapting my approach due to API limitations. My focus is on a *partially* automated solution. I'm building a plan to guide the user to generate a key pair and securely store it, triggering a notification for the manual upload step. I'm also considering supplemental processes, like checking for key ID updates, to enhance overall automation.


**Developing the Outline**

I'm now refining the automation strategy, recognizing the API limitations. My revised plan will offer a partially automated solution: a script generating the new key pair, storing it securely, and notifying the user. The user will then manually upload the key. I'm focusing on providing practical examples, like a GitHub Action, to make the solution more tangible.


**Finalizing the Response**

I'm now consolidating the response for clarity and impact. My focus is on the *partially automated* solution, emphasizing clear user guidance. I'll include a concrete GitHub Actions example, detailing both automated and manual steps. This will allow the user to immediately understand the practical implications, alongside clear notes.


**Developing a Solution**

I've carefully deconstructed the question, aiming to provide a practical solution. The GitHub API's limitations regarding private key management necessitate a partially automated approach. I plan to highlight both the automated components and the user-triggered actions. Providing clear instructions is now paramount, considering the complexities of key rotation.



</details>

Excellent question. This is a critical security practice for any application that relies on GitHub Apps.

The short answer is: **Yes, you can automate the rotation of GitHub App private keys, but GitHub does not provide a built-in, one-click service to do it for you.** You need to build the automation yourself using a combination of scripts and secure secret storage.

The most significant challenge is that **GitHub's API does not currently expose endpoints to programmatically add or delete private keys.** This means the final step of uploading the new key and deleting the old one must be done manually through the GitHub UI.

However, you can automate every other part of the process to make it a secure, repeatable, and auditable "human-in-the-loop" workflow.

### Why Rotate Keys?

Rotating keys is a security best practice that limits the "blast radius" if a key is ever compromised. If a key is stolen, it's only valid until the next rotation cycle, significantly reducing the window of opportunity for an attacker.

### The Automated Rotation Workflow

Here is a robust, semi-automated workflow you can implement. The goal is to automate key generation, secure storage, and notification, leaving only the final UI clicks for a human operator.

**The process looks like this:**

1.  **Schedule a Job:** A cron job, AWS Lambda function, or GitHub Actions workflow triggers on a schedule (e.g., every 90 days).
2.  **Generate New Key:** The job generates a new 2048-bit RSA private key.
3.  **Store New Key Securely:** The new private key is immediately stored in a secret manager like AWS Secrets Manager, Azure Key Vault, or HashiCorp Vault. **It should never be printed to logs or stored on disk.**
4.  **Notify an Administrator:** The job sends a notification (via Slack, email, etc.) to a designated administrator. This notification should include:
    *   The public key portion or a fingerprint of the new key.
    *   A direct link to the GitHub App's settings page.
    *   Clear instructions to upload the new key.
5.  **Manual Upload (The Human Step):**
    *   The administrator navigates to the GitHub App's settings.
    *   Under "Private keys," they click "Generate a new private key." Instead of letting GitHub generate it, they will upload the `.pem` file that was generated and stored in the secret manager in step 3.
    *   GitHub will now list two keys: the new one and the old one. **This is crucial for a zero-downtime rotation.** Your application can continue using the old key while you deploy the update.
6.  **Update Your Application:**
    *   Update your application's configuration to pull the *new* private key from your secret manager.
    *   Deploy the updated application. It will now start generating JWTs with the new key.
7.  **Manual Deletion (The Final Human Step):**
    *   Once you have confirmed the application is working correctly with the new key, the administrator returns to the GitHub App's settings and deletes the old key.

### Example: Automation with GitHub Actions

Here is a conceptual example of a GitHub Actions workflow that automates steps 1-4.

**Prerequisites:**

*   You have a secret manager (e.g., AWS Secrets Manager).
*   You have configured your GitHub repository with the necessary cloud credentials (e.g., using `aws-actions/configure-aws-credentials`).
*   You have a Slack Incoming Webhook URL stored as a repository secret (`SLACK_WEBHOOK_URL`).

**.github/workflows/rotate-key.yml**

```yaml
name: "GitHub App Key Rotation Reminder"

# Run this workflow every 90 days
on:
  schedule:
    - cron: "0 0 1 */3 *" # At 00:00 on day-of-month 1 in every 3rd month.
  workflow_dispatch: # Allows manual triggering

permissions:
  id-token: write # Required for OIDC with AWS
  contents: read

jobs:
  generate-and-notify:
    runs-on: ubuntu-latest
    steps:
      - name: "Generate new private key"
        id: generate_key
        run: |
          # Generate a new 2048-bit RSA private key
          openssl genpkey -algorithm RSA -out new-app-key.pem -pkeyopt rsa_keygen_bits:2048
          echo "New private key generated: new-app-key.pem"

          # Set the key content as an output for the next step
          # This is safe as outputs are not logged by default.
          # For extra security, use a file and pass the path.
          echo "key_content=$(cat new-app-key.pem)" >> $GITHUB_OUTPUT

      - name: "Configure AWS Credentials"
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GitHubActionKeyRotationRole # Replace with your IAM Role
          aws-region: us-east-1 # Replace with your region

      - name: "Store new key in AWS Secrets Manager"
        id: store_key
        run: |
          # The name of the secret where the key is stored
          SECRET_NAME="production/github-app/private-key"
          TIMESTAMP=$(date +%s)
          NEW_SECRET_NAME="${SECRET_NAME}-${TIMESTAMP}"

          echo "Storing new key in Secrets Manager: ${NEW_SECRET_NAME}"
          aws secretsmanager create-secret \
            --name "${NEW_SECRET_NAME}" \
            --description "GitHub App private key generated on $(date)" \
            --secret-string "${{ steps.generate_key.outputs.key_content }}"

          # Output the new secret name for the notification
          echo "new_secret_name=${NEW_SECRET_NAME}" >> $GITHUB_OUTPUT

      - name: "Send Slack Notification"
        uses: slackapi/slack-github-action@v1.26.0
        with:
          payload: |
            {
              "text": "GitHub App Key Rotation Required! :key:",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*A new GitHub App private key has been generated and requires manual upload.*"
                  }
                },
                {
                  "type": "section",
                  "fields": [
                    {
                      "type": "mrkdwn",
                      "text": "*App Name:*\nMy Awesome App"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*New AWS Secret Name:*\n`${{ steps.store_key.outputs.new_secret_name }}`"
                    }
                  ]
                },
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "Please download the key from AWS Secrets Manager and upload it to the GitHub App settings. *Do not delete the old key until the application is confirmed to be working with the new one.*"
                  }
                },
                {
                  "type": "actions",
                  "elements": [
                    {
                      "type": "button",
                      "text": {
                        "type": "plain_text",
                        "text": "Go to GitHub App Settings"
                      },
                      "url": "https://github.com/settings/apps/your-app-name"
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

This workflow automates the tedious and error-prone parts of the process, creating a reliable and secure system for ensuring your keys are regularly rotated.


---
