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

Yes, your hierarchy is mostly correct, but there are a few additional components in Kubernetes that play a crucial role. Here’s the **complete** hierarchy, including some missing pieces:  

---

### **Full Kubernetes Hierarchy for a Deployed Application:**  
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

### **Corrections & Key Additions:**
✅ The hierarchy you mentioned is **mostly correct**, but **the last level is the process running inside the container** (not just the application source code).  
✅ Kubernetes **Pods can have multiple containers**, which share storage and networking.  
✅ Additional components like **Services, Ingress, ConfigMaps, and Volumes** are important in real-world deployments.  

---

### **Final Corrected Hierarchy:**  
✅ **Cluster → Node → Pod → Container → Process (Application)**  

Let me know if you need more clarifications! 🚀
