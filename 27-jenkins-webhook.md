# Integrating Jenkins with GitHub Using Webhooks

This guide explains how to integrate Jenkins with GitHub using webhooks to trigger a CI/CD pipeline whenever there is a new commit or push to the repository.

## Prerequisites

- A running Jenkins instance
- GitHub repository with admin access
- Jenkins Git and GitHub plugins installed
- A publicly accessible Jenkins server or a tunnel (e.g., using `ngrok`)

## Step 1: Configure Jenkins Job

1. Open Jenkins and create a **New Item**.
2. Select **Freestyle project** or **Pipeline** (if using Jenkinsfile) and give it a name.
3. Under **Source Code Management**, select **Git** and enter your repository URL.
4. Provide GitHub credentials if required.
5. Under **Build Triggers**, check **GitHub hook trigger for GITScm polling**.
6. Configure your build steps as needed (e.g., shell script, Docker build, test commands).
7. Save the job.

## Step 2: Generate GitHub Webhook URL

If your Jenkins is publicly accessible, your URL will be:
```
http://your-jenkins-server/github-webhook/
```
If your Jenkins is running locally, use `ngrok` to expose it:
```
ngrok http 8080
```
Copy the `https://` forwarding URL from `ngrok` and append `/github-webhook/`, e.g.:
```
https://your-ngrok-url/github-webhook/
```

## Step 3: Configure GitHub Webhook

1. Go to your GitHub repository.
2. Navigate to **Settings** > **Webhooks**.
3. Click **Add webhook**.
4. In the **Payload URL**, enter your Jenkins webhook URL.
5. Set **Content type** to `application/json`.
6. Choose **Just the push event** or select additional triggers if needed.
7. Click **Add webhook**.

## Step 4: Test the Integration

1. Push a change to your GitHub repository.
2. Go to Jenkins and check if the build is triggered.
3. If not triggered, check **GitHub Webhook Deliveries** for errors.

## Troubleshooting

- Ensure Jenkins is reachable from GitHub.
- Check Jenkins logs for webhook trigger issues.
- Verify GitHub webhook settings and payload delivery.

## Conclusion

You have successfully set up Jenkins to monitor your GitHub repository using webhooks. Any new commit or push will now trigger your CI/CD pipeline automatically.
