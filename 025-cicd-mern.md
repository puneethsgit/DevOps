
# 🚀 MERN Stack CI/CD Pipeline with Jenkins, Docker, Kubernetes & Argo CD  

This guide explains how to set up a **CI/CD pipeline** for a **MERN stack** project using **Jenkins, Docker, Kubernetes, and Argo CD**.  

---

## **📌 What is CI/CD?**  

CI/CD (**Continuous Integration and Continuous Deployment**) automates the process of:  
- **CI (Continuous Integration):** Automatically testing and building code when developers push changes.  
- **CD (Continuous Deployment):** Automatically deploying the application after a successful build.  

This ensures that our **MERN application** is deployed smoothly with minimal manual intervention.  

---

## **🛠 Tools Used in CI/CD Pipeline**  

| Tool | Purpose |
|------|---------|
| **GitHub/GitLab/Bitbucket** | Stores and tracks code changes |
| **Jenkins/GitHub Actions/GitLab CI/CD** | Automates build, test, and deployment processes |
| **Docker** | Packages the application into a container for consistency |
| **Kubernetes** | Manages and scales the application automatically |
| **Argo CD** | Automates Kubernetes deployments using GitOps |
| **PM2/NGINX** | Manages the Node.js backend and serves the React frontend |
| **MongoDB Atlas (or Self-hosted MongoDB)** | Stores the database |
| **AWS EC2/VPS/Render/Vercel** | Hosts the application |

---

## **🔗 CI/CD Pipeline Breakdown**  

### **1️⃣ Code Push (GitHub Repository)**  
- Developers push code changes to **GitHub/GitLab/Bitbucket**.  
- This triggers the **CI/CD pipeline**.  

---

### **2️⃣ Build & Test (Jenkins/GitHub Actions)**  
- The CI/CD tool:  
  1. Installs dependencies → `npm install`  
  2. Runs tests → `npm test`  
  3. Builds frontend → `npm run build` (for React)  

✔ **Why?**  
To ensure the code is error-free before deploying.  

---

### **3️⃣ Dockerize the Application (Docker)**  
- The app is packaged into a **Docker container**.  
- This container is stored in **Docker Hub** or AWS ECR
✔ **Why?**  
To ensure the app runs **consistently** across different environments.

#### **Example `Dockerfile` for MERN Stack**
```dockerfile
# Use Node.js official image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy all files
COPY . .

# Start the application
CMD ["npm", "start"]

# Expose port 3000
EXPOSE 3000
```

---

### **4️⃣ Deploy to Kubernetes (K8s)**
- The Docker image is pulled and deployed into a **Kubernetes cluster**.
- A **Deployment** and **Service** are created in Kubernetes.
- **Argo CD** ensures the deployment is in sync with the Git repository.

✔ **Why?**  
Kubernetes **orchestrates** the application, ensuring high availability and scalability.

#### **Example Kubernetes Deployment (`deployment.yaml`)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-app
  template:
    metadata:
      labels:
        app: mern-app
    spec:
      containers:
        - name: mern-app
          image: your-dockerhub-username/mern-app:latest
          ports:
            - containerPort: 3000
```

#### **Example Kubernetes Service (`service.yaml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mern-service
spec:
  selector:
    app: mern-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

---

### **5️⃣ Continuous Deployment with Argo CD**
- Argo CD watches the Git repository and automatically syncs changes to the **Kubernetes cluster**.
- Any change pushed to the repo is deployed automatically.

✔ **Why?**  
Argo CD follows **GitOps principles**, ensuring that deployments are always **declarative and version-controlled**.

#### **Example Argo CD Application (`argo-app.yaml`)**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mern-app
  namespace: argocd
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/your-repo/mern-app.git
    targetRevision: main
    path: k8s
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
```

---

## **📌 CI/CD Pipeline Workflow**
1️⃣ **Developer pushes code** → Triggers Jenkins/GitHub Actions  
2️⃣ **Jenkins builds & tests** → Ensures code is error-free  
3️⃣ **Docker image is built & pushed** → Image is stored in Docker Hub  
4️⃣ **Kubernetes deploys the image** → Using Argo CD for automation  
5️⃣ **Argo CD continuously monitors Git repo** → Ensures deployments match repo state  

---

## **🚀 Setting Up the CI/CD Pipeline**

### **1️⃣ Install Jenkins**
```sh
# Install Jenkins on Ubuntu
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install jenkins
```
- Start Jenkins: `sudo systemctl start jenkins`
- Access at: `http://your-server-ip:8080`

---

### **2️⃣ Configure Jenkins Pipeline**
- Install required plugins:  
  - **Pipeline**
  - **Docker Pipeline**
  - **Kubernetes CLI**
- Create a new **Pipeline job** and use the following `Jenkinsfile`:

#### **Example `Jenkinsfile`**
```groovy
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "your-dockerhub-username/mern-app:latest"
    }
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-repo/mern-app.git'
            }
        }
        stage('Build & Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
                sh 'npm run build'
            }
        }
        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
                sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                sh 'docker push $DOCKER_IMAGE'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}
```

---

## **🔧 Debugging Tips**
| Issue | Solution |
|-------|----------|
| Jenkins pipeline fails | Check console logs for errors |
| Docker image build fails | Ensure Dockerfile is correct |
| Kubernetes pod crash loop | Use `kubectl logs <pod-name>` to check errors |
| Argo CD not syncing | Ensure repo URL and paths are correct |

---

## **🎯 Final Thoughts**
With this setup:
✅ Code changes are **automatically built, tested, and deployed**  
✅ Docker ensures **consistency** across environments  
✅ Kubernetes ensures **scalability and availability**  
✅ Argo CD provides **automated deployment with GitOps**  

This **CI/CD pipeline** helps streamline the development & deployment process for your **MERN stack** application.

🚀 **Happy Coding!**
```

---

This README provides **step-by-step guidance** on setting up a **CI/CD pipeline** for a **MERN stack application**. Let me know if you want any modifications! 🚀```md
✔ **Why?**  
To ensure the app runs **consistently** across different environments.

#### **Example `Dockerfile` for MERN Stack**
```dockerfile
# Use Node.js official image
FROM node:18

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json .
RUN npm install

# Copy all files
COPY . .

# Start the application
CMD ["npm", "start"]

# Expose port 3000
EXPOSE 3000
```

---

### **4️⃣ Deploy to Kubernetes (K8s)**
- The Docker image is pulled and deployed into a **Kubernetes cluster**.
- A **Deployment** and **Service** are created in Kubernetes.
- **Argo CD** ensures the deployment is in sync with the Git repository.

✔ **Why?**  
Kubernetes **orchestrates** the application, ensuring high availability and scalability.

#### **Example Kubernetes Deployment (`deployment.yaml`)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mern-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mern-app
  template:
    metadata:
      labels:
        app: mern-app
    spec:
      containers:
        - name: mern-app
          image: your-dockerhub-username/mern-app:latest
          ports:
            - containerPort: 3000
```

#### **Example Kubernetes Service (`service.yaml`)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mern-service
spec:
  selector:
    app: mern-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

---

### **5️⃣ Continuous Deployment with Argo CD**
- Argo CD watches the Git repository and automatically syncs changes to the **Kubernetes cluster**.
- Any change pushed to the repo is deployed automatically.

✔ **Why?**  
Argo CD follows **GitOps principles**, ensuring that deployments are always **declarative and version-controlled**.

#### **Example Argo CD Application (`argo-app.yaml`)**
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mern-app
  namespace: argocd
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/your-repo/mern-app.git
    targetRevision: main
    path: k8s
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
```

---

## **📌 CI/CD Pipeline Workflow**
1️⃣ **Developer pushes code** → Triggers Jenkins/GitHub Actions  
2️⃣ **Jenkins builds & tests** → Ensures code is error-free  
3️⃣ **Docker image is built & pushed** → Image is stored in Docker Hub  
4️⃣ **Kubernetes deploys the image** → Using Argo CD for automation  
5️⃣ **Argo CD continuously monitors Git repo** → Ensures deployments match repo state  

---

## **🚀 Setting Up the CI/CD Pipeline**

### **1️⃣ Install Jenkins**
```sh
# Install Jenkins on Ubuntu
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install jenkins
```
- Start Jenkins: `sudo systemctl start jenkins`
- Access at: `http://your-server-ip:8080`

---

### **2️⃣ Configure Jenkins Pipeline**
- Install required plugins:  
  - **Pipeline**
  - **Docker Pipeline**
  - **Kubernetes CLI**
- Create a new **Pipeline job** and use the following `Jenkinsfile`:

#### **Example `Jenkinsfile`**
```groovy
pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "your-dockerhub-username/mern-app:latest"
    }
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-repo/mern-app.git'
            }
        }
        stage('Build & Test') {
            steps {
                sh 'npm install'
                sh 'npm test'
                sh 'npm run build'
            }
        }
        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
                sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
                sh 'docker push $DOCKER_IMAGE'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}
```

---

## **🔧 Debugging Tips**
| Issue | Solution |
|-------|----------|
| Jenkins pipeline fails | Check console logs for errors |
| Docker image build fails | Ensure Dockerfile is correct |
| Kubernetes pod crash loop | Use `kubectl logs <pod-name>` to check errors |
| Argo CD not syncing | Ensure repo URL and paths are correct |

---

## **🎯 Final Thoughts**
With this setup:
✅ Code changes are **automatically built, tested, and deployed**  
✅ Docker ensures **consistency** across environments  
✅ Kubernetes ensures **scalability and availability**  
✅ Argo CD provides **automated deployment with GitOps**  

This **CI/CD pipeline** helps streamline the development & deployment process for your **MERN stack** application.


