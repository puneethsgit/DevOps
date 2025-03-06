# GitHub Actions is a CI/CD tool that automates workflows directly within GitHub. It provides cloud-hosted runners to build, test, and deploy applications.

### **How GitHub Actions Works**
1. **Workflow Execution:**  
   - Workflows are defined in `.github/workflows/*.yml` files.
   - Workflows run on GitHub-hosted or self-hosted runners.
   - They trigger on events like `push`, `pull_request`, or `schedule`.

2. **Runners:**  
   - **GitHub-Hosted Runners** (default):  
     - Runs on **Ubuntu, Windows, or macOS** VMs.
     - Comes pre-installed with tools like Java, Node.js, Docker, etc.
     - No need to manage infrastructure.
   - **Self-Hosted Runners**:  
     - You can use **EC2, on-prem servers, or even a Docker container**.
     - Gives more control but requires setup and maintenance.

3. **Docker Support:**  
   - GitHub Actions **can use Docker** to run jobs in isolated environments.
   - Jobs can run in a Docker container using:
     ```yaml
     jobs:
       build:
         runs-on: ubuntu-latest #runs-on: windows-latest  # Uses GitHub-hosted Windows runner
         container: node:18
         steps:
           - name: Checkout Code
             uses: actions/checkout@v3
           - name: Install Dependencies
             run: npm install
     ```
   - You can also build and push Docker images to DockerHub or AWS ECR.

4. **Where Does the Build Happen?**  
   - By default, builds run on **GitHub-hosted VMs** (like EC2 instances but fully managed).
   - If you use a **self-hosted runner**, your builds will happen on your specified infrastructure (EC2, on-prem, etc.).

### **Comparison with Jenkins & Docker**
| Feature         | GitHub Actions                          | Jenkins with Docker |
|---------------|-------------------------------------|--------------------|
| **Execution** | Runs on GitHub-hosted VMs or self-hosted runners | Runs on any server/container |
| **Docker Support** | Native support for Docker containers | Docker agents for execution |
| **Infrastructure** | Default: GitHub VMs; Custom: Self-hosted runners (EC2, etc.) | Requires manual server setup |
| **Ease of Use** | Simple YAML-based workflows | Requires Jenkinsfile & plugins |

**GitHub-hosted runners do not use Docker behind the scenes by default**. They run directly on virtual machines (VMs), but Docker **can be used explicitly** if needed.

### **How GitHub-Hosted Runners Work**
- GitHub provides pre-configured VMs (Ubuntu, Windows, macOS).
- These VMs run jobs directly on the OS (without Docker by default).
- Each job runs in a fresh VM instance (isolated environment).
- At the end of the job, the VM is destroyed.

### **Does GitHub Actions Use Docker Internally?**
❌ **No, not by default** – GitHub Actions runs jobs on raw VMs.  
✅ **Yes, if specified** – You can explicitly define Docker containers for jobs.

### **When Docker is Used in GitHub Actions**
1. **Running Jobs in a Docker Container**
   - You can run a job inside a Docker container:
   ```yaml
   jobs:
     build:
       runs-on: ubuntu-latest
       container: node:18
       steps:
         - name: Checkout Code
           uses: actions/checkout@v3
         - name: Install Dependencies
           run: npm install
   ```
   This isolates the job inside a Docker container.

2. **Building & Pushing Docker Images**
   - If you're working with Docker images, you can build and push them:
   ```yaml
   jobs:
     docker-build:
       runs-on: ubuntu-latest
       steps:
         - name: Checkout Code
           uses: actions/checkout@v3
         - name: Build Docker Image
           run: docker build -t my-app .
         - name: Push to Docker Hub
           run: docker push my-app
   ```

3. **Using Self-Hosted Runners with Docker**
   - If you set up a **self-hosted runner** (e.g., an EC2 instance with Docker installed), you can run workflows inside containers.

### **Key Differences from Jenkins with Docker**
| Feature              | GitHub Actions (Default)        | Jenkins with Docker Agents |
|----------------------|--------------------------------|----------------------------|
| **Default Execution** | Runs directly on VMs | Runs on Docker agents |
| **Docker Required?** | No, but can be used | Yes, if using Docker agents |
| **Isolation** | New VM per job | Containers per job |

#### **Final Answer:**
- **GitHub-hosted runners do not use Docker behind the scenes.**  
- **However, you can explicitly run jobs in Docker containers if needed.**  
- **If your workflow builds images, Docker will be used explicitly.**  

# GitHub Actions: CI/CD Guide

## Overview

GitHub Actions is a powerful automation tool that can be used for both **Continuous Integration (CI)** and **Continuous Deployment (CD)**. This guide explains how to set up multiple GitHub Actions workflows for CI/CD.

## 📌 CI (Continuous Integration)

GitHub Actions is commonly used for CI tasks such as:

- Running tests (unit, integration)
- Building applications
- Linting and code analysis
- Checking security vulnerabilities

### Example: CI Workflow (`ci.yml`)

This workflow runs on every push or pull request to validate the code before merging.

```yaml
name: CI Pipeline
on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      - name: Install Dependencies
        run: npm install
      - name: Run Tests
        run: npm test
```

#### Explanation:
1. **`on: [push, pull_request]`** - Triggers the workflow on code push or pull request events.
2. **`runs-on: ubuntu-latest`** - Runs the job on an Ubuntu machine.
3. **`actions/checkout@v3`** - Checks out the repository code.
4. **`npm install`** - Installs project dependencies.
5. **`npm test`** - Runs tests to verify the code.

## 🚀 CD (Continuous Deployment)

GitHub Actions can also handle CD tasks such as:

- Deploying applications to AWS, Kubernetes, DigitalOcean, etc.
- Managing infrastructure using Terraform or Ansible
- Triggering deployments via webhooks

### Example: CD Workflow (`deploy.yml`)

This workflow deploys the application to an EC2 instance after a successful CI pipeline run on the `main` branch.

```yaml
name: CD Pipeline
on:
  workflow_run:
    workflows: ["CI Pipeline"]
    types: [completed]
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      - name: Deploy to Server
        run: |
          echo "Deploying application..."
          # Add your deployment commands here
```

#### Explanation:
1. **`on: workflow_run`** - This workflow runs after the CI pipeline completes.
2. **`branches: [main]`** - Deployment happens only when changes are merged into `main`.
3. **`runs-on: ubuntu-latest`** - Uses an Ubuntu machine for deployment.
4. **`actions/checkout@v3`** - Checks out the latest code.
5. **Deployment Commands** - This section can include `scp`, `rsync`, or other deployment commands.

## 🔄 Execution Flow

1. The **CI workflow (`ci.yml`)** runs on every push or pull request.
2. Once CI completes successfully, the **CD workflow (`deploy.yml`)** starts automatically (triggered by `workflow_run`).
3. The application is deployed only when the CI process is successful on the `main` branch.

## ✅ CI vs. CD in GitHub Actions

| Feature                     | CI (Continuous Integration)                 | CD (Continuous Deployment)                    |
| --------------------------- | ------------------------------------------- | --------------------------------------------- |
| **Purpose**                 | Code validation, testing, and building      | Deploying code to production/staging          |
| **Common Steps**            | Linting, testing, security checks           | Deploying to cloud servers, Kubernetes, etc.  |
| **Example**                 | Running Jest tests, building a Docker image | Deploying to AWS EC2, Kubernetes, or Firebase |
| **GitHub Actions Support?** | ✅ Yes (default use case)                    | ✅ Yes (but requires extra setup)              |

## 🔹 Is GitHub Actions Best for CD?

While GitHub Actions is widely used for **CI**, it can also be used for **CD**. However, for complex deployments, tools like **ArgoCD, Jenkins, or Spinnaker** may be better suited.

## 🐳 Can I Use Docker Containers with GitHub Actions?

Yes! GitHub Actions supports Docker containers in several ways:

- You can run jobs inside Docker containers using `container` in your workflow.
- You can build, tag, and push Docker images as part of your workflow.
- You can use **self-hosted runners** inside Docker for custom execution environments.

### Example: Running a Job in a Docker Container

```yaml
jobs:
  docker-job:
    runs-on: ubuntu-latest
    container:
      image: node:16
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      - name: Install Dependencies
        run: npm install
      - name: Run Tests
        run: npm test
```

#### Explanation:
1. **`container: image: node:16`** - Runs the job inside a Node.js 16 Docker container.
2. **`actions/checkout@v3`** - Retrieves the code from the repository.
3. **`npm install`** - Installs necessary dependencies inside the container.
4. **`npm test`** - Runs the tests inside the container environment.

This setup ensures a **consistent runtime environment** by using a **Docker container** instead of the default GitHub runner environment.

## 🚀 Example: CI/CD Pipeline Using GitHub Actions, Docker, and Kubernetes

### Steps:

1. **CI Workflow (`ci.yml`)**
   - Runs tests and builds a Docker image.
   - Pushes the image to Docker Hub or AWS ECR.

2. **CD Workflow (`deploy.yml`)**
   - Deploys the Docker container to a Kubernetes cluster.
   
### CI Workflow (`ci.yml`):

```yaml
name: CI Pipeline
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3
      - name: Build Docker Image
        run: |
          docker build -t my-app:latest .
      - name: Push to Docker Hub
        run: |
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
          docker tag my-app:latest my-dockerhub-user/my-app:latest
          docker push my-dockerhub-user/my-app:latest
```

### CD Workflow (`deploy.yml`):

```yaml
name: Deploy to Kubernetes
on:
  workflow_run:
    workflows: ["CI Pipeline"]
    types: [completed]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Set Up Kubectl
        run: |
          echo "${{ secrets.KUBE_CONFIG }}" | base64 --decode > $HOME/.kube/config
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/my-app my-app=my-dockerhub-user/my-app:latest
```

### Explanation:
1. **CI Workflow**:
   - Builds the Docker image.
   - Pushes it to Docker Hub.
2. **CD Workflow**:
   - Uses `kubectl` to update the Kubernetes deployment with the new image.

This fully automates the **CI/CD pipeline using GitHub Actions, Docker, and Kubernetes**. 🚀


# NOTE
# Checking Changes in a GitHub Repository

## 1. Using Git in the Terminal

### Check What Has Changed in the Last 2 Days
```bash
git log --since="2 days ago" --oneline
```

### Fetch Latest Changes and Compare
```bash
git fetch origin
git diff origin/main
```

### Check Commit History with Details
```bash
git log --graph --oneline --decorate --all
```

## 2. Using GitHub Website
- Open the repository on GitHub.
- Click on the **"Commits"** section to see all recent commits.
- Click on **"Pull Requests"** to see any recent PRs merged or updated.
- Check the **"Insights" → "Code Frequency"** to see changes in lines of code over time.

## 3. Using GitHub CLI (if installed)
```bash
gh repo sync
gh browse
```
This will open the repo in the browser where you can check the latest commits.

## 4. Using `git blame` to Track Line Changes
```bash
git blame <filename>
```
Example:
```bash
git blame app.js
```
This will show each line of the file along with:
- The commit hash that last modified the line
- The author's name
- The timestamp of the change

### Using GitHub Web UI for Blame
1. Open the repository on GitHub.
2. Navigate to the file you want to inspect.
3. Click the **Blame** button (found at the top-right of the file view).
4. GitHub will display each line with the corresponding commit and author.

