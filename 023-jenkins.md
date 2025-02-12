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

## Jenkins Architecture vs Docker as Agent

### Traditional Jenkins Architecture
- Uses **static agents** (dedicated VMs or instances).
- Requires **manual configuration** and maintenance.
- **Slower scaling** due to fixed agent availability.

### Jenkins with Docker as an Agent
- Uses **dynamic agents** created on-demand.
- **Lightweight, disposable containers** instead of full VMs.
- Ensures **consistent build environments**.
- Easier **dependency management**.

---

## Advantages and Disadvantages of Docker Agent in Jenkins

### Advantages
1. **Scalability** - Containers are created dynamically per job, reducing idle resources.
2. **Isolation** - Each build runs in a separate container, avoiding conflicts.
3. **Portability** - Same container image runs across different environments.
4. **Faster Build Setup** - No need to install dependencies on Jenkins agents manually.
5. **Easy Cleanup** - Containers are ephemeral and removed after job completion.

### Disadvantages
1. **Extra Complexity** - Requires Docker setup and configuration.
2. **Security Concerns** - Running Jenkins jobs inside containers might pose security risks.
3. **Persistent Storage** - Containers are ephemeral, requiring volume mounts for data persistence.
4. **Overhead in Large Builds** - Spinning up a new container for each build may add slight overhead.

---

This guide provides a detailed step-by-step setup for Jenkins on EC2 and explains the use of Docker as an agent. 🚀

