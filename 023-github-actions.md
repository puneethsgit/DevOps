GitHub Actions is a CI/CD tool that automates workflows directly within GitHub. It provides cloud-hosted runners to build, test, and deploy applications.

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
         runs-on: ubuntu-latest
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
