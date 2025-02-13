# Jenkins Setup on AWS EC2 and Docker Agent in Jenkins

## Table of Contents
- [Prerequisites](#prerequisites)
- [Step 1: Launch an EC2 Instance](#step-1-launch-an-ec2-instance)
- [Step 2: Install Java](#step-2-install-java)
- [Step 3: Install Jenkins](#step-3-install-jenkins)
- [Step 4: Start and Access Jenkins](#step-4-start-and-access-jenkins)
- [Jenkins Architecture vs Docker as Agent](#jenkins-architecture-vs-docker-as-agent)
- [Advantages and Disadvantages of Docker Agent](#advantages-and-disadvantages-of-docker-agent)

---

## Prerequisites
- AWS account
- EC2 instance (Ubuntu 20.04 recommended)
- Security Group with ports 22 (SSH) and 8080 (Jenkins UI) open

## Step 1: Launch an EC2 Instance
1. Log in to AWS Management Console.
2. Navigate to **EC2 Dashboard** and click **Launch Instance**.
3. Select an AMI (Ubuntu 20.04 LTS).
4. Choose instance type (e.g., `t2.medium` for better performance).
5. Configure instance settings and add a security group to allow SSH (22) and Jenkins UI (8080).
6. Launch the instance and connect using SSH:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-instance-ip
   ```

## Step 2: Install Java
Jenkins requires Java to run. Install OpenJDK:

For Ubuntu:
```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
```

Verify Java installation:
```bash
java -version
```

## Step 3: Install Jenkins

For Ubuntu:
```bash
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key
sudo echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
```

## Step 4: Start and Access Jenkins
Start and enable Jenkins service:
```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

Check status:
```bash
sudo systemctl status jenkins
```

Retrieve initial admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Access Jenkins in a browser: `http://your-ec2-public-ip:8080`

Follow the setup wizard and install suggested plugins.

---

### **Jenkins Architecture vs. Jenkins with Docker as an Agent Architecture**

Jenkins is a powerful automation server used for CI/CD. It can be set up in multiple ways depending on the infrastructure and requirements. Let’s compare the **standard Jenkins architecture** with **Jenkins using Docker as an agent**.

---

## **1. Standard Jenkins Architecture**
### **Components:**
1. **Jenkins Master (Controller)**
   - The main Jenkins instance that provides the web interface, manages job configurations, schedules builds, and handles plugins.
   - Assigns jobs to worker nodes (agents).

2. **Jenkins Agents (Workers)**
   - Execute build tasks and report results back to the master.
   - Can be on the same machine as the master or on different machines (physical or virtual).
   - Connected to the master using SSH, JNLP, or other methods.

### **How It Works:**
- The master schedules builds and assigns them to agents.
- Agents execute builds, run tests, and return results.
- This setup requires a dedicated agent machine with pre-installed dependencies.

### **Limitations:**
- Agents must have pre-installed dependencies (Java, Maven, Gradle, Node.js, etc.).
- Resource management can be inefficient; idle agents consume resources.
- Dependency conflicts may occur when multiple projects require different versions of tools.

---

## **2. Jenkins with Docker as an Agent**
Instead of using traditional static agents, Jenkins can use **Docker containers as ephemeral agents**.

### **Components:**
1. **Jenkins Master (Controller)**
   - Same as in standard architecture; schedules and manages builds.

2. **Docker Host**
   - Runs Docker to spawn agent containers dynamically.
   - Provides isolation for builds.

3. **Ephemeral Jenkins Agents (Docker Containers)**
   - Instead of dedicated agents, Jenkins launches a new container per build.
   - The container includes all dependencies required for the build.

### **How It Works:**
1. Jenkins Master triggers a build.
2. Instead of assigning the build to a traditional agent, it starts a new Docker container.
3. The container runs the build inside an isolated environment.
4. Once the build completes, the container is destroyed.

### **Advantages:**
✅ **Scalability:** Containers are created on demand, reducing idle resource usage.  
✅ **Isolation:** Each build runs in its own clean environment, avoiding dependency conflicts.  
✅ **Consistency:** Builds always use the exact same dependencies as defined in the container image.  
✅ **Simplicity:** No need to manage dedicated agent machines; just maintain Docker images.

### **Challenges:**
❌ **Startup Overhead:** Spinning up a new container for each build may introduce slight delays.  
❌ **Docker Requirement:** The Jenkins host must have Docker installed and properly configured.  
❌ **Networking & Volume Management:** Must handle data persistence and network configurations for effective builds.

---

## **Comparison Table**
| Feature                     | Standard Jenkins Architecture | Jenkins with Docker as Agent |
|-----------------------------|---------------------------------|-------------------------------|
| Agent Type                  | Dedicated VM or physical machine | Ephemeral Docker container |
| Dependency Management       | Pre-installed on agent machines | Included in container image |
| Resource Utilization        | Idle agents may consume resources | Containers exist only when needed |
| Build Isolation             | Low; shared environment | High; isolated per container |
| Maintenance Overhead        | High; requires updating dependencies manually | Low; managed through Docker images |
| Startup Time                | Fast (pre-existing agents) | Slightly slower (container creation overhead) |

---

## **When to Use Which?**
- **Use Standard Jenkins Architecture** if you have dedicated build machines and want persistent agents.
- **Use Jenkins with Docker as an Agent** if you want scalable, isolated, and easily maintainable CI/CD environments.


# How to Configure Docker as agent with Jenkins
To configure **Docker as an agent** with **Jenkins**, follow these steps:

---

### **Step 1: Install the Docker Plugin in Jenkins**
1. Go to **Jenkins Dashboard** → **Manage Jenkins** → **Manage Plugins**.
2. In the **Available** tab, search for **"Docker Plugin"**.
3. Check the box and click **Install without restart**.

---

### **Step 2: Install & Configure Docker on the Jenkins Server**
#### **Install Docker (if not installed)**
On **Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
```
On **CentOS/RHEL**:
```bash
sudo yum install -y docker
sudo systemctl enable --now docker
```
On **Windows/Mac**: Install Docker Desktop.

#### **Allow Jenkins to Use Docker Without sudo**
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```
**Log out and log back in** for changes to take effect.

---

### **Step 3: Configure Jenkins to Use Docker**
1. Go to **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**.
2. Click **Add a new cloud** → Select **Docker**.
3. Under **Docker Host URI**, enter:  
   ```
   unix:///var/run/docker.sock
   ```
   (For Windows, use `tcp://localhost:2375` if Docker is configured to expose the API.)

4. Click **Test Connection** to verify.

---

### **Step 4: Add a Docker Agent Template**
1. In the **Cloud Configuration** page, click **Add Docker Template**.
2. Configure:
   - **Labels**: `docker-agent` (or any label you want).
   - **Docker Image**: Use a pre-built agent image like  
     ```
     jenkins/inbound-agent
     ```
   - **Remote FS Root**: `/home/jenkins/agent`
   - **Connect Method**: **Attach Docker container**
   - **User**: `jenkins`
3. Click **Save**.

---

### **Step 5: Use Docker Agent in a Pipeline**
In your **Jenkins Pipeline (Jenkinsfile)**:
```groovy
pipeline {
    agent {
        docker { image 'maven:3.8.5-openjdk-11' }
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
```
Or for **Docker Cloud Agents**:
```groovy
pipeline {
    agent {
        label 'docker-agent'
    }
    stages {
        stage('Run') {
            steps {
                sh 'echo Running in Docker Agent!'
            }
        }
    }
}
```

---

### **Step 6: Verify**
- Run a **new pipeline job** and check if the agent spins up.
- If issues occur, check logs in **Manage Jenkins** → **System Log**.


## NOTE 
When you run a Jenkins job using Docker as an agent, you can observe the container lifecycle with:

```bash
docker ps -a
```

- While the job is running, you will see a container in the list.
- Once the job is completed, the container is **automatically destroyed** unless specified otherwise.

If you want to keep the container running after the job completes (for debugging), you can modify the **Docker Agent Template** in Jenkins and set **"Run Container in Detached Mode".
---



