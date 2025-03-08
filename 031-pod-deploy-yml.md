# K8S

Kubernetes is an open-source platform that automates the deployment, management, and scaling of containerized applications. It's also known as "k8s". 

### **Difference Between `kubectl get pods` and `kubectl get nodes`**  

| Command                 | Purpose |
|------------------------|---------|
| `kubectl get pods`     | Lists all **pods** running in the cluster. |
| `kubectl get nodes`    | Lists all **nodes** (worker & master) in the cluster. |

---

### **1️⃣ `kubectl get pods` → Shows Running Pods**
```sh
kubectl get pods
```
🔹 **Lists all pods** in the **default namespace**.  
🔹 A **pod** is the smallest unit in Kubernetes that runs **one or more containers**.  

#### **Example Output:**
```
NAME         READY   STATUS    RESTARTS   AGE
nginx-abc    1/1     Running   0          5m
app-backend  2/2     Running   1          10m
db-mongo     1/1     Pending   0          3m
```
- **NAME** → Pod name  
- **READY** → Number of running containers in the pod  
- **STATUS** → Running, Pending, Completed, or Error  
- **RESTARTS** → Number of times the pod has restarted  
- **AGE** → Time since the pod was created  

✅ **Useful for** checking **which applications are running** in your cluster.

---

### **2️⃣ `kubectl get nodes` → Shows Cluster Nodes**
```sh
kubectl get nodes
```
🔹 **Lists all worker & master nodes** in the Kubernetes cluster.  
🔹 A **node** is a **physical/virtual machine** that runs **pods**.  

#### **Example Output:**
```
NAME          STATUS   ROLES    AGE     VERSION
minikube      Ready    master   10h     v1.28.0
worker-node1  Ready    <none>   5h      v1.28.0
worker-node2  Ready    <none>   3h      v1.28.0
```
- **NAME** → Node name  
- **STATUS** → `Ready` (accepting pods), `NotReady`, `SchedulingDisabled`, etc.  
- **ROLES** → `master` (control plane), `worker`, or `<none>` (default worker)  
- **AGE** → How long the node has been active  
- **VERSION** → Kubernetes version running on the node  

✅ **Useful for** checking **cluster health and node availability**.

---

### **3️⃣ Key Differences**
| Feature | `kubectl get pods` | `kubectl get nodes` |
|---------|-----------------|----------------|
| **Lists** | Pods (running applications) | Nodes (machines running the cluster) |
| **Scope** | Application-level | Infrastructure-level |
| **Used For** | Checking application health | Checking cluster health |
| **Shows** | Containers running in a pod | Machines running Kubernetes |
| **Status Types** | Running, Pending, CrashLoopBackOff, etc. | Ready, NotReady, SchedulingDisabled, etc. |

---

### **4️⃣ Bonus: Extra Commands**
✅ **Get pods in all namespaces**  
```sh
kubectl get pods --all-namespaces
```

✅ **Get more details about nodes**  
```sh
kubectl describe nodes
```

✅ **Get pods on a specific node**  
```sh
kubectl get pods --field-selector spec.nodeName=<NODE_NAME>
```

Let me know if you need more details! 🚀

### **Can You Use `kubectl` for EKS or Kops?**  
✅ **Yes!** You can use `kubectl` for both **EKS** (AWS-managed Kubernetes) and **Kops** (self-managed Kubernetes).  

---

### **1️⃣ Using `kubectl` with EKS**
EKS is a **managed Kubernetes service** by AWS, and `kubectl` is used to interact with it.

#### **🔹 Steps to Use `kubectl` with EKS:**
1️⃣ **Configure `kubectl` to connect to EKS**  
   ```sh
   aws eks update-kubeconfig --region <AWS_REGION> --name <EKS_CLUSTER_NAME>
   ```
   Example:
   ```sh
   aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
   ```

2️⃣ **Check if the connection is successful**  
   ```sh
   kubectl get nodes
   ```

3️⃣ **Now you can use all `kubectl` commands**, such as:  
   ```sh
   kubectl get pods
   kubectl describe deployments
   kubectl logs <POD_NAME>
   ```

✅ **EKS supports `kubectl` by default** since it's a fully managed Kubernetes cluster.

---

### **2️⃣ Using `kubectl` with Kops**
Kops sets up a **self-managed Kubernetes cluster** in AWS (or another cloud). Since it's a standard Kubernetes cluster, `kubectl` works with it.

#### **🔹 Steps to Use `kubectl` with Kops:**
1️⃣ **Export the cluster configuration from Kops**
   ```sh
   export KUBECONFIG=~/.kube/config
   ```

2️⃣ **Verify cluster connection**
   ```sh
   kubectl cluster-info
   ```

3️⃣ **Use `kubectl` commands normally**
   ```sh
   kubectl get nodes
   kubectl get pods -A
   kubectl delete pod <POD_NAME>
   ```

✅ **Kops also supports `kubectl`** because it deploys a standard Kubernetes cluster.

---

### **3️⃣ Key Differences When Using `kubectl`**
| Feature | **EKS** (AWS Managed) | **Kops** (Self-Managed) |
|---------|-----------------|-----------------|
| **Cluster Creation** | AWS manages the control plane | You set up & manage everything |
| **kubectl Setup** | Uses `aws eks update-kubeconfig` | Uses `export KUBECONFIG` |
| **Management** | Easier (AWS handles upgrades & HA) | More control, but manual management |
| **kubectl Usage** | Fully supported | Fully supported |

---

### **4️⃣ Conclusion: Can You Use `kubectl` for EKS & Kops?**
✅ **YES!** `kubectl` works with both EKS and Kops, but the setup process is different.  
- **For EKS** → Use `aws eks update-kubeconfig`  
- **For Kops** → Use `export KUBECONFIG`  

Let me know if you need help setting it up! 🚀


What is a Namespace in Minikube? Does It Mean a Cluster?
No, a namespace is NOT a cluster. Instead, it is a logical partition inside a Kubernetes cluster that helps organize and isolate resources.

### **Can You Create Multiple Clusters in Minikube?**  
✅ **Yes!** You can create multiple clusters in Minikube by using **profiles**.

By default, Minikube runs a single cluster named `minikube`, but you can create and manage multiple clusters by specifying different profiles.

---

### **1️⃣ Create Multiple Clusters in Minikube**
To create a new cluster, use the `-p` (profile) flag:

```sh
minikube start -p cluster1
minikube start -p cluster2
```

🔹 This creates two separate Kubernetes clusters:  
   - One named **cluster1**  
   - Another named **cluster2**  

Each cluster runs **independently**, with its own nodes, configurations, and workloads.

---

### **2️⃣ List All Clusters**
To see all Minikube clusters:

```sh
minikube profile list
```

**Example Output:**
```
| Profile   | Status   | Nodes | CPU | Memory | Disk  |
|-----------|---------|-------|-----|--------|------ |
| cluster1  | Running | 1     | 2   | 4000MB | 20GB  |
| cluster2  | Stopped | 1     | 2   | 4000MB | 20GB  |
```

---

### **3️⃣ Switch Between Clusters**
To change the active cluster:

```sh
minikube profile cluster1
```

Now, all `kubectl` commands will be executed in `cluster1`.

To switch to another cluster:

```sh
minikube profile cluster2
```

---

### **4️⃣ Stop or Delete a Cluster**
To stop a specific cluster:

```sh
minikube stop -p cluster1
```

To delete a specific cluster:

```sh
minikube delete -p cluster1
```

To delete all Minikube clusters:

```sh
minikube delete --all
```

---

### **5️⃣ Key Points About Multiple Minikube Clusters**
✅ Each cluster runs independently.  
✅ You can start, stop, and delete clusters separately.  
✅ Use `minikube profile` to switch between clusters.  
✅ Useful for testing different environments (e.g., `dev-cluster`, `test-cluster`).  

Would you like help with any specific setup? 🚀

1️⃣ What is a Namespace in Minikube (or Kubernetes)?
🔹 A namespace is a virtual cluster inside a Kubernetes cluster.
🔹 It allows you to separate different environments, applications, or teams within the same cluster.
🔹 Useful for multi-tenant environments where multiple users or projects share a single Kubernetes cluster.

# **Difference Between Kops, EKS, and Minikube**  

| Feature         | **Kops** (Kubernetes Operations) | **EKS** (Elastic Kubernetes Service) | **Minikube** |
|---------------|--------------------------------|--------------------------------|----------------|
| **Type** | Kubernetes cluster installer | Managed Kubernetes service | Local Kubernetes environment |
| **Best For** | Self-managed Kubernetes on AWS | Fully managed Kubernetes on AWS | Local development/testing |
| **Infrastructure** | AWS, GCP, OpenStack, Bare Metal | AWS-only | Local machine (VM or Docker) |
| **Management** | You manage the cluster | AWS manages the cluster | You manage the cluster |
| **Scalability** | Manually scalable | Auto-scaling by AWS | Limited (local only) |
| **Cost** | You pay for cloud resources | Pay-as-you-go (AWS charges) | Free (uses local resources) |
| **Networking** | Full control over networking | AWS manages networking | Local network only |
| **Production-Ready?** | ✅ Yes | ✅ Yes | ❌ No (for development only) |

---

### **1️⃣ What is Kops?**  
🔹 **Kops (Kubernetes Operations)** is a tool to **install, upgrade, and manage** Kubernetes clusters **on AWS, GCP, OpenStack, and bare metal**.  
🔹 **You control everything**: networking, security, updates, etc.  
🔹 You are responsible for managing the cluster.  

✅ **Use Kops if:**  
- You need a **self-managed Kubernetes cluster** on AWS.  
- You want full control over **networking, updates, and security**.  
- You don’t want to depend on **EKS (AWS Managed Kubernetes)**.  

---

### **2️⃣ What is EKS?**  
🔹 **EKS (Elastic Kubernetes Service)** is **AWS’s fully managed Kubernetes service**.  
🔹 AWS **creates, manages, and updates** the Kubernetes control plane.  
🔹 You **only manage worker nodes** (or use AWS Fargate for serverless nodes).  

✅ **Use EKS if:**  
- You want **AWS to handle Kubernetes management**.  
- You need **auto-scaling, security, and HA**.  
- You don’t want to **manually install and manage Kubernetes** like in Kops.  

---

### **3️⃣ What is Minikube?**  
🔹 **Minikube is a tool for running Kubernetes locally on your laptop**.  
🔹 Creates a **single-node Kubernetes cluster** using Virtual Machines (VM) or Docker.  
🔹 **Not for production** → It’s for **testing, learning, and development**.  

✅ **Use Minikube if:**  
- You want to **test Kubernetes locally**.  
- You are **developing a Kubernetes-based application**.  
- You don’t need a **real cloud environment** (AWS, GCP, etc.).  

---

### **4️⃣ Final Comparison**  
- **Kops →** Self-managed Kubernetes in AWS.  
- **EKS →** Fully managed Kubernetes in AWS.  
- **Minikube →** Local Kubernetes for development.  

**Which one should you use?**  
- **For production on AWS:** Use **EKS** (if you want managed) or **Kops** (if you want full control).  
- **For local development:** Use **Minikube**.  

Let me know if you need more details! 😊
### **Cost Difference: Kops vs. EKS**  

Yes, you're right! **With Kops, you only pay for the resources**, but **with EKS, you pay for both the resources and the EKS control plane**.

---

### **1️⃣ Kops (Kubernetes Operations) - Cost**  
- **Kops is free** (open-source tool).  
- You **only pay for the AWS resources** used:  
  ✅ **EC2 instances** (for control plane & worker nodes)  
  ✅ **EBS volumes** (for storage)  
  ✅ **ELB (Load Balancer)**  
  ✅ **S3** (for storing cluster state)  
  ✅ **Networking costs** (VPC, NAT, etc.)  

🔹 **No extra charge for Kubernetes control plane** (you run & manage it yourself).  
🔹 **More effort** required to manage, update, and secure the cluster.  

---

### **2️⃣ EKS (Elastic Kubernetes Service) - Cost**  
- **EKS charges you for both**:  
  ✅ **EKS control plane** → **$0.10 per hour per cluster** (~$72/month).  
  ✅ **AWS resources** (same as Kops): EC2, EBS, ELB, S3, networking, etc.  
- If you use **Fargate (serverless nodes)** instead of EC2, you **only pay for running pods** (no need to manage worker nodes).  

🔹 **Easier to manage** (AWS handles control plane, HA, and security).  
🔹 **More expensive** than Kops because of the control plane fee.  

---

### **3️⃣ Cost Comparison Example**  
| Feature  | **Kops (Self-Managed)** | **EKS (AWS Managed)** |
|----------|----------------|----------------|
| **Control Plane Cost** | **$0** (you manage it) | **$0.10/hour** ($72/month) |
| **Worker Nodes (EC2, EBS, etc.)** | ✅ Yes (same as EKS) | ✅ Yes (same as Kops) |
| **Load Balancers** | ✅ Yes | ✅ Yes |
| **S3 for State Storage** | ✅ Yes | ❌ No (AWS manages control plane) |
| **Networking (VPC, NAT, etc.)** | ✅ Yes | ✅ Yes |
| **Overall Cost** | **Cheaper, but more effort** | **More expensive, but easier to manage** |

---

### **4️⃣ Which One Should You Choose?**
- **Choose Kops** → If you want **full control and lower costs**, and are okay with managing everything.  
- **Choose EKS** → If you want **AWS to handle the Kubernetes control plane**, and are okay with paying extra for **convenience & managed services**.  

Let me know if you need more details! 🚀

### **Can You Use Docker Compose with Kubernetes?**  
✅ **Yes!** But **Docker Compose** is designed for **single-host container orchestration**, while **Kubernetes** is meant for **multi-node, production-grade deployments**. However, you can convert Docker Compose files to Kubernetes YAML files.

---

## **1️⃣ Option 1: Use Kompose (Convert Docker Compose to Kubernetes)**
Kompose is a tool that automatically converts **docker-compose.yml** to Kubernetes manifests.

### **🔹 Install Kompose**
```sh
curl -L https://github.com/kubernetes/kompose/releases/download/v1.30.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv kompose /usr/local/bin/
```

### **🔹 Convert `docker-compose.yml` to Kubernetes YAML**
```sh
kompose convert
```
👉 This generates **Deployment, Service, and ConfigMap YAML files**.

### **🔹 Deploy to Kubernetes**
```sh
kubectl apply -f .
```
👉 Deploys the converted files to your Kubernetes cluster.

---

## **2️⃣ Option 2: Use Docker Compose with Kubernetes Directly**
Docker Desktop has a **built-in Kubernetes integration**, allowing you to run **docker-compose.yml** inside Kubernetes.

### **🔹 Enable Kubernetes in Docker Desktop**
1. Open **Docker Desktop**.
2. Go to **Settings > Kubernetes**.
3. Click **Enable Kubernetes**.

### **🔹 Deploy a Docker Compose File to Kubernetes**
```sh
docker stack deploy -c docker-compose.yml my-app
```
👉 This runs the Compose file as a **Kubernetes stack**.

---

## **🚀 Which Method Should You Use?**
| Approach | Best For | Pros | Cons |
|----------|---------|------|------|
| **Kompose** | Migrating apps from Docker Compose to Kubernetes | Automatic conversion | May require manual edits |
| **Docker Stack (Docker Desktop)** | Running Compose in Kubernetes locally | Simple, no conversion needed | Only works in Docker Desktop |

✅ **For real Kubernetes environments (Minikube, EKS, etc.), use Kompose.**  
✅ **For local development with Docker Desktop, use `docker stack deploy`.**

Do you want help converting your **Docker Compose** file to **Kubernetes**? 🚀

# Understanding `pod.yml` and `deployment.yml`

## `pod.yml`

### Explanation
This YAML file defines a single Pod running an Nginx container.

```yaml
apiVersion: v1  # Specifies the API version used
kind: Pod  # Declares that this is a Pod configuration
metadata:
  name: nginx  # Names the Pod "nginx"
spec:
  containers:
  - name: nginx  # Defines the container's name
    image: nginx:1.14.2  # Uses the Nginx image with version 1.14.2
    ports:
    - containerPort: 80  # Exposes port 80 within the container
```

### Use Case
- Used when you want to run a single instance of a container.
- Useful for testing and debugging before creating a larger deployment.
- Not recommended for production since it does not provide self-healing or scalability.

---

## `deployment.yml`

### Explanation
This YAML file defines a Deployment, which manages multiple replicas of a Pod.

```yaml
apiVersion: apps/v1  # Specifies the API version for Deployments
kind: Deployment  # Declares that this is a Deployment resource
metadata:
  name: nginx-deployment  # Names the Deployment "nginx-deployment"
  labels:
    app: nginx  # Labels the Deployment
spec:
  replicas: 3  # Specifies 3 replicas of the Pod
  selector:
    matchLabels:
      app: nginx  # Ensures that the Deployment manages Pods with this label
  template:  # Describes the Pod template to be created
    metadata:
      labels:
        app: nginx  # Labels assigned to the Pod
    spec:
      containers:
      - name: nginx  # Defines the container's name
        image: nginx:1.14.2  # Uses the Nginx image with version 1.14.2
        ports:
        - containerPort: 80  # Exposes port 80 within the container
```

### Use Case
- Used for deploying scalable applications.
- Ensures high availability by running multiple instances of a Pod.
- Provides automatic self-healing and rolling updates.
- Essential for production workloads where uptime and redundancy are important.

---


# Kubernetes Pod and Deployment YAML Files

## Overview
This repository contains YAML configurations for deploying an Nginx container using both a Pod and a Deployment in Kubernetes.

## Files
- **pod.yml**: Defines a single Nginx Pod.
- **deployment.yml**: Defines a Deployment that manages multiple replicas of the Nginx Pod.

## Usage

### 1. Apply `pod.yml`
To create a single Nginx Pod, run:
```sh
kubectl apply -f pod.yml
```
Verify the Pod is running:
```sh
kubectl get pods
```

### 2. Apply `deployment.yml`
To create a Deployment with 3 replicas of the Nginx Pod, run:
```sh
kubectl apply -f deployment.yml
```
Check the Deployment and Pods:
```sh
kubectl get deployments
kubectl get pods
```

### 3. Scaling the Deployment
To scale the Deployment to 5 replicas, run:
```sh
kubectl scale deployment nginx-deployment --replicas=5
```
Verify the new replica count:
```sh
kubectl get deployments
```

No, running:  
```sh
kubectl scale deployment nginx-deployment --replicas=5
```
**will not update the `deployment.yaml` file.**  

It only updates the **live state** of the Deployment in the Kubernetes cluster but does not modify the **YAML manifest file** stored on your local system or Git repository.  

### If you apply the original `deployment.yaml` again:
```sh
kubectl apply -f deployment.yaml
```
Kubernetes will **reset the replicas to 3** because the YAML file still has `replicas: 3`.

### How to persist the change?
To make the change permanent, you need to **manually edit** the YAML file or use:
```sh
kubectl edit deployment nginx-deployment
```
This opens an editor where you can update the `replicas` count, and once you save, it persists in the cluster.

Let me know if you need more details! 🚀

### 4. Delete Resources
To delete the Pod:
```sh
kubectl delete -f pod.yml
```
To delete the Deployment:
```sh
kubectl delete -f deployment.yml
```

## Conclusion
- **Use `pod.yml`** for testing a single container.
- **Use `deployment.yml`** for scalable and resilient applications.

This setup helps manage applications efficiently within Kubernetes.

