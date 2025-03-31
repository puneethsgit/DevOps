# Kubernetes Deployment Strategies

When deploying applications in Kubernetes, different strategies can be used to update pods with new versions while minimizing downtime and ensuring application availability. This document explains the different deployment strategies available in Kubernetes.

## 1. Rolling Update (Default Strategy)

### Description
The **Rolling Update** strategy gradually replaces old pods with new ones. It ensures that the application remains available by controlling how many pods can be unavailable or created during the update process.

### Configuration
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: three-tier
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 25%
  selector:
    matchLabels:
      role: frontend
  template:
    metadata:
      labels:
        role: frontend
    spec:
      containers:
      - name: frontend
        image: my-app:v2
        ports:
        - containerPort: 3000
```

### Parameters
- **`maxSurge: 1`** → Allows one extra pod to be created during the update.
- **`maxUnavailable: 25%`** → Allows up to 25% of replicas to be unavailable during the update.

### Example Execution
1. A new pod is created with the updated version.
2. Once it becomes healthy, an old pod is terminated.
3. The process continues until all pods are updated.

### Pros
- Zero downtime.
- Gradual rollout allows detecting issues early.

### Cons
- If a bad version is deployed, rollback takes time.

---

## 2. Recreate Strategy

### Description
The **Recreate** strategy removes all existing pods before creating new ones. This results in downtime during the update process.

### Configuration
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: three-tier
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      role: frontend
  template:
    metadata:
      labels:
        role: frontend
    spec:
      containers:
      - name: frontend
        image: my-app:v2
        ports:
        - containerPort: 3000
```

### Execution Steps
1. All running pods are **terminated**.
2. New pods with the updated version are created.

### Pros
- Simple and straightforward.
- No need for extra resources (no overlapping pods).

### Cons
- Causes **downtime** while updating.

---

## 3. Blue-Green Deployment

### Description
**Blue-Green Deployment** runs two environments (Blue = Old, Green = New) and switches traffic to the new version once it's stable.

### Example Setup
1. **Blue Deployment**: Runs the stable version (`v1`).
2. **Green Deployment**: Deploys the new version (`v2`).
3. Once tested, traffic is switched to Green (new version).

### Configuration
```yaml
apiVersion: apps/v1
kind: Service
metadata:
  name: frontend-service
  namespace: three-tier
spec:
  selector:
    role: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
```
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-green
  namespace: three-tier
spec:
  replicas: 3
  selector:
    matchLabels:
      role: frontend-green
  template:
    metadata:
      labels:
        role: frontend-green
    spec:
      containers:
      - name: frontend
        image: my-app:v2
        ports:
        - containerPort: 3000
```

### Execution Steps
1. Deploy the **Green (new)** version alongside **Blue (current)** version.
2. Test the new version (`v2`).
3. Update the service to point to **Green**.
4. Remove **Blue** if successful.

### Pros
- No downtime.
- Quick rollback by switching back to Blue.

### Cons
- Requires **double** the resources during deployment.

---

## 4. Canary Deployment

### Description
Canary Deployment gradually introduces the new version to a small percentage of users before rolling it out completely.

### Execution Steps
1. Deploy a **small percentage** (e.g., 10%) of the new version.
2. Monitor logs and performance.
3. Gradually increase traffic to the new version.
4. Roll back if necessary.

### Pros
- Reduces risk by testing in production.
- Can detect issues early.

### Cons
- Requires monitoring and traffic control mechanisms.

---

## 5. A/B Testing Deployment

### Description
A/B Testing Deployment directs different segments of users to different versions for performance testing.

### Execution Steps
1. Deploy **two versions** (A and B) with different features.
2. Route traffic based on user segments.
3. Analyze which version performs better.

### Pros
- Data-driven decision-making.
- Controlled rollout.

### Cons
- Requires complex routing and analytics.

---

## 6. Shadow Deployment

### Description
Shadow Deployment mirrors production traffic to a new version **without affecting users**.

### Execution Steps
1. Users continue using **Version A** (stable).
2. Traffic is cloned and sent to **Version B** (new) silently.
3. Analyze performance before full rollout.

### Pros
- No impact on users.
- Real-time testing in production.

### Cons
- Requires additional resources for duplicated traffic.

---

## Choosing the Right Strategy
| Strategy         | Zero Downtime | Risk Level | Rollback Speed | Resource Usage |
|----------------|--------------|------------|---------------|---------------|
| Rolling Update | ✅ Yes       | Medium     | ❌ Slow       | ✅ Low        |
| Recreate       | ❌ No        | High       | ✅ Fast       | ✅ Low        |
| Blue-Green     | ✅ Yes       | Low        | ✅ Fast       | ❌ High      |
| Canary         | ✅ Yes       | Very Low   | ✅ Fast       | ✅ Medium    |
| A/B Testing    | ✅ Yes       | Medium     | ✅ Fast       | ❌ High      |
| Shadow         | ✅ Yes       | Low        | ❌ Slow       | ❌ High      |

## Conclusion
- **Rolling Update**: Best for most applications, ensuring availability.
- **Recreate**: Simple but causes downtime, best for non-critical apps.
- **Blue-Green**: Ideal for quick rollbacks but requires extra resources.
- **Canary**: Ideal for minimizing risk by gradual rollout.
- **A/B Testing**: Useful for feature testing based on user behavior.
- **Shadow**: Good for testing without affecting users.

Choose the best strategy based on your application's needs!


# **Full Kubernetes Hierarchy for a Deployed Application:**  
1️⃣ **Cluster** → 2️⃣ **Node** → 3️⃣ **Pod** → 4️⃣ **Container** → 5️⃣ **Process (Application Running Inside the Container)**  

---

### **Detailed Breakdown with Missing Components:**
| **Level** | **Description** |
|-----------|----------------|
| **1️⃣ Cluster** | The overall Kubernetes system that manages nodes, networking, and workloads. |
| **2️⃣ Node** | A single worker machine (virtual or physical) that runs applications. Each node has a `kubelet`, `kube-proxy`, and a container runtime (like Docker). |
| **3️⃣ Pod** | The smallest deployable unit in Kubernetes. It runs one or more containers and shares storage and networking. |
| **4️⃣ Container** | A lightweight, isolated runtime environment (Docker, containerd, CRI-O) that runs the actual application. Containers are created from **Docker images**. |
| **5️⃣ Process (Application)** | The actual program or application running inside the container. This is the final execution of your application source code. |

---

### **Additional Kubernetes Components (That Work Alongside This Hierarchy)**
- **Control Plane (API Server, Scheduler, Controller Manager, etc.)** – Manages the cluster.
- **Service** – Exposes the application (Pod) to the network.
- **Ingress** – Manages external access (like an API Gateway or Load Balancer).
- **ConfigMap & Secret** – Stores environment variables and sensitive data.
- **Persistent Volume (PV) & Persistent Volume Claim (PVC)** – Manages storage for stateful applications.

---

### **Final Visual Representation:**
```
Cluster
 ├── Node 1
 │    ├── Pod A
 │    │    ├── Container 1
 │    │    │    └── Process (Application Running)
 │    │    ├── Container 2
 │    │         └── Process (Application Running)
 │    ├── Pod B
 │         └── Container 3
 │              └── Process (Application Running)
 │
 ├── Node 2
 │    ├── Pod C
 │         └── Container 4
 │              └── Process (Application Running)
```

---


✅ The hierarchy you mentioned is **mostly correct**, but **the last level is the process running inside the container** (not just the application source code).  
✅ Kubernetes **Pods can have multiple containers**, which share storage and networking.  
✅ Additional components like **Services, Ingress, ConfigMaps, and Volumes** are important in real-world deployments.  

---

### **Final Corrected Hierarchy:**  
✅ **Cluster → Node → Pod → Container → Process (Application)**  



---

### ** Explanation:**  
1️⃣ **Node** = An **EC2 instance** (or any virtual/physical machine). It is a worker machine in a Kubernetes cluster.  
2️⃣ **Pods** = Kubernetes **runs Pods inside the Node**. A **Pod is NOT inside another Pod**—each Pod runs separately on the Node.  
3️⃣ **Containers** = **Each Pod contains one or more Containers**. The application runs inside these containers.  

---

### **Final Correct Hierarchy (EC2 Perspective in Kubernetes)**  
✅ **EC2 Instance (Node) → Kubernetes Pod → Container → Application Running**  

---

### **Example Explanation (Minikube or EKS on AWS):**  
If you have an EKS cluster running on AWS, you can think of it like this:  

- **Cluster** → The **whole EKS setup**  
- **Node** → An **EC2 instance** running Kubernetes  
- **Pod** → A **unit of deployment** inside the Node  
- **Container** → Runs inside the Pod (uses Docker, containerd, or CRI-O)  
- **Application** → The actual program running inside the container  

---

### **Visual Representation**
```
AWS EKS Cluster
 ├── EC2 Node 1
 │    ├── Pod A
 │    │    ├── Container 1 (App 1)
 │    │    └── Container 2 (App 2)
 │    ├── Pod B
 │         └── Container 3 (App 3)
 │
 ├── EC2 Node 2
 │    ├── Pod C
 │         └── Container 4 (App 4)
```

---


✅ **Correct: A Pod runs inside a Node, and a Container runs inside a Pod.**  

Let me know if you need more clarifications! 🚀

## Source Code

The **source code of the application** is initially stored outside the Kubernetes cluster (e.g., in a GitHub repository) and then packaged into a **Docker image**. Let’s go step by step:  

---

### **Where is the Source Code in Kubernetes?**  

1️⃣ **Before Deployment:**  
- The application source code is typically **in a GitHub/GitLab repository** or **on your local machine**.  
- This source code is used to create a **Docker image**.  

2️⃣ **Containerization Process:**  
- The source code is **built into a Docker image** using a `Dockerfile`.  
- The Docker image is pushed to a container registry like **Docker Hub**, **Amazon ECR**, or **Google Container Registry**.  

3️⃣ **During Deployment in Kubernetes:**  
- The **Pod pulls the Docker image** from the container registry.  
- Inside the container, the **source code is extracted and executed** as part of the running application.  

---

### **Final Hierarchy (Including Source Code)**
✅ **Source Code → Docker Image → Container (Running in a Pod) → Application Execution**  

---

### **Where is the Source Code Stored Inside Kubernetes?**  
Once the Pod starts running, the source code **exists inside the container's filesystem** (inside the container's image). You can check it by accessing the running container:  

```sh
kubectl exec -it <pod-name> -- /bin/sh  # or bash if available
```
Then navigate inside the container:
```sh
cd /app  # Example path where source code might be stored
ls  # List files
```
  
**Note:** The exact path depends on how the Docker image was built.

---

### **Visual Representation**
```
Source Code (GitHub)
   ↓
Docker Image (Built using Dockerfile)
   ↓
Stored in Container Registry (Docker Hub, ECR, GCR, etc.)
   ↓
Pulled into Kubernetes Pod
   ↓
Pod runs a Container
   ↓
Container executes the application (Source Code is now inside the container)
```

---

### **Key Takeaways**  
✅ **Source code is NOT directly in a Pod or Node**—it is packaged into a container.  
✅ **The container pulls the source code from the Docker image and runs it inside the Pod.**  
✅ **Pods only store and run containers—they do not contain raw source code files like a GitHub repo.**  

Let me know if you need more details! 🚀

You're **very close**, but let’s clarify the **correct deployment flow** in Kubernetes.  

---

### **Correct Deployment Process (Step by Step)**  

✅ **Step 1: Source Code in GitHub**  
- Your application’s source code is stored in **GitHub (or another version control system like GitLab, Bitbucket, etc.).**  
- Example: A **MERN stack** application’s source code is in GitHub.  

✅ **Step 2: Build a Docker Image**  
- A **Dockerfile** is used to package the source code into a **Docker image**.  
- The Docker image contains everything needed:  
  - **Application source code**  
  - **Dependencies (e.g., Node.js, Python, Java, etc.)**  
  - **Runtime environment (e.g., Node.js, JDK, etc.)**  
- The built Docker image is pushed to **Docker Hub (or AWS ECR, GCR, etc.)**  

✅ **Step 3: Kubernetes Deployment (Pulling the Image from Docker Hub)**  
- When you deploy the application to Kubernetes, the **Pod pulls the Docker image from Docker Hub** (or another registry).  
- The Pod **DOES NOT pull code directly from GitHub**—it only pulls the **pre-built Docker image** from the registry.  
- Once pulled, the container inside the Pod **runs the application** from the image.  

---

### **Summary**
✅ **GitHub stores the source code.**  
✅ **Docker builds an image that contains the source code.**  
✅ **Docker Hub stores the built image.**  
✅ **Kubernetes pulls the Docker image from Docker Hub (NOT from GitHub).**  
✅ **The application runs inside the container in a Kubernetes Pod.**  

---

Let me know if you need further clarification! 🚀

## CICD

 During the **CI/CD process**, we define in the **Jenkinsfile** to **checkout** the source code from the GitHub repository. Then, we build a Docker image, push it to a container registry (e.g., **Docker Hub** or **AWS ECR**), and deploy it to Kubernetes.  

---

### **🔹 CI/CD Flow in Jenkins**
1️⃣ **Jenkins checks out the source code from GitHub.**  
2️⃣ **Jenkins builds the Docker image from the source code.**  
3️⃣ **Jenkins pushes the image to Docker Hub (or another registry).**  
4️⃣ **Jenkins updates Kubernetes to pull and deploy the new image.**  

---

### **🔹 Example `Jenkinsfile` for CI/CD Pipeline**
```groovy
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-username/app:v${BUILD_NUMBER}"  // Unique version for each build
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                    sh 'docker push $DOCKER_IMAGE'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/my-app my-app=$DOCKER_IMAGE --record
                kubectl rollout status deployment/my-app
                '''
            }
        }
    }
}
```

---

### **🔹 Explanation of Each Stage**
1️⃣ **Checkout Source Code** → Jenkins pulls the latest code from GitHub.  
2️⃣ **Build Docker Image** → Jenkins builds a Docker image with the application source code.  
3️⃣ **Push Image to Docker Hub** → Jenkins pushes the built image to Docker Hub.  
4️⃣ **Deploy to Kubernetes** → Jenkins updates the Kubernetes deployment to use the new image.  

---

### **🔹 Summary**
✅ **Jenkinsfile defines CI/CD pipeline.**  
✅ **GitHub contains source code; Jenkins pulls it.**  
✅ **Docker image is built and pushed to a registry.**  
✅ **Kubernetes pulls the image and deploys the app.**  

---

This setup automates the deployment process! 🚀 Let me know if you need more details! 😊
