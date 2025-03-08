# Kubernetes Ingress: Understanding and Cost Optimization

## What is Ingress?
Ingress is a Kubernetes resource that manages external access to services within a cluster, typically using HTTP and HTTPS. It allows you to expose multiple services through a single external IP, reducing the need for multiple load balancers and saving cloud costs.

## Why Do We Need Ingress?
By default, Kubernetes services use **ClusterIP**, which is only accessible within the cluster. To expose services externally, we typically use **NodePort** or **LoadBalancer**, but these have downsides:
- **NodePort:** Exposes services on a random high port, making management difficult.
- **LoadBalancer:** Provisions a cloud provider load balancer per service, leading to extra costs.

Ingress provides a single entry point, efficiently routing traffic while reducing the number of external IPs needed, which helps cut down cloud expenses.

## How Ingress Solves Cloud Charges
Cloud providers like AWS charge for each **LoadBalancer Service**, as each provisioned LoadBalancer gets a unique external IP. Instead of creating a LoadBalancer for every service, we can use a **single** Ingress resource with one LoadBalancer, optimizing cost and simplifying management.

### Example: Without Ingress
| Service         | LoadBalancer IP | Cost |
|---------------|----------------|------|
| frontend      | 35.123.45.67    | $$$  |
| backend       | 52.234.56.78    | $$$  |
| database      | 13.98.76.54     | $$$  |
| **Total Cost** | **3 Load Balancers** | **High** |

### Example: With Ingress
| Service       | Ingress Controller (Single LoadBalancer) |
|--------------|---------------------------------|
| frontend     | puneeth.me/                    |
| backend      | puneeth.me/api                 |
| database     | Internal (No need for public)  |
| **Total Cost** | **1 Load Balancer** (Low Cost) |

## How Traffic Flows in Kubernetes with Ingress
Let's break down how a request flows through Ingress to reach the correct pod.

### Scenario: User Visits `puneeth.me`
1️⃣ **User opens `puneeth.me`** in the browser.
2️⃣ **DNS resolves `puneeth.me` to the Ingress Controller's IP.**
3️⃣ **Ingress receives the request and checks routing rules.**
4️⃣ **Ingress forwards traffic to the correct ClusterIP service.**
5️⃣ **ClusterIP service uses selector labels to find the right pods.**
6️⃣ **Traffic reaches the correct pod, and the application responds.**

### Step-by-Step Traffic Flow
| Step  | Action | Handled By |
|-------|--------|------------|
| 1 | User visits `puneeth.me` | DNS (resolves to Ingress Controller IP) |
| 2 | Request goes to Ingress | Ingress Controller (NGINX, Traefik, etc.) |
| 3 | Ingress forwards request to `frontend-service` | Kubernetes Ingress Rules |
| 4 | `frontend-service` forwards request to a frontend pod | Kubernetes Service (ClusterIP) |
| 5 | Frontend pod calls `backend-service` | Service Discovery (`http://backend-service`) |
| 6 | `backend-service` forwards request to a backend pod | Kubernetes Service (ClusterIP) |
| 7 | Backend pod calls `db-service` | Service Discovery (`http://db-service:3306`) |
| 8 | Database pod responds | Database Pod |
| 9 | Response flows back to user | ✅ Page Loads 🎉 |

## Ingress YAML Configuration
To configure Ingress for this setup, we define an Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - host: puneeth.me
    http:
      paths:
      - path: "/"
        pathType: Prefix
        backend:
          service:
            name: frontend-service  # 🎯 Routes "/" to frontend
            port:
              number: 80
      - path: "/api"
        pathType: Prefix
        backend:
          service:
            name: backend-service   # 🎯 Routes "/api" to backend
            port:
              number: 80
```

### Explanation:
- Requests to `puneeth.me/` go to `frontend-service`.
- Requests to `puneeth.me/api` go to `backend-service`.
- Both services are exposed through a **single** Ingress resource, using **one** external IP, reducing cost.

## Key Takeaways
✔ **ClusterIP + Service Discovery** = Internal communication between services using stable names.
✔ **Ingress + DNS + Domain** = Exposes the app to the internet using a single IP & domain.
✔ **Cost Optimization** = Instead of multiple Load Balancers, we use one Ingress to reduce cloud charges.
✔ **No Direct Pod IP Usage** = Services + Ingress handle all routing.

---

By implementing Ingress in Kubernetes, we ensure efficient traffic management, simplify domain-based routing, and significantly reduce cloud costs. 🚀




# RBAC in Minikube

This guide walks through setting up **Role-Based Access Control (RBAC)** in **Minikube**, including user management, creating roles, service accounts, and testing access.

---

## 🚀 Step 1: Start Minikube
Ensure Minikube is running:
```bash
minikube start
```
Check if RBAC is enabled:
```bash
kubectl api-versions | grep rbac
```
If `rbac.authorization.k8s.io/v1` appears, RBAC is enabled.

---

## 👤 Step 2: User Management in Minikube
RBAC in Kubernetes is based on users and service accounts. While Minikube does not have real users (like a cloud-managed Kubernetes cluster), you can still create users and assign them roles. Cloud providers such as AWS EKS use IAM or other identity providers to manage authentication and authorization.

### 🔹 Create a Kubernetes User
In Minikube, users are managed through **certificates**.

#### ➤ Generate a Private Key for the User
```bash
openssl genrsa -out user-key.pem 2048
```

#### ➤ Create a Certificate Signing Request (CSR)
```bash
openssl req -new -key user-key.pem -out user.csr -subj "/CN=my-user"
```

#### ➤ Sign the Certificate with Kubernetes CA
First, get the Kubernetes CA certificate and key:
```bash
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > ca.crt
kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}' | base64 --decode > ca.key
```
Sign the CSR:
```bash
openssl x509 -req -in user.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out user.crt -days 365
```

### 🔹 Configure Kubectl for the New User
```bash
kubectl config set-credentials my-user --client-certificate=user.crt --client-key=user-key.pem
kubectl config set-context my-user-context --cluster=minikube --user=my-user
```
Now, you can switch to this user:
```bash
kubectl config use-context my-user-context
```

---

## 🛠 Step 3: Create a Service Account
Create a `service-account.yaml` file:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-sa
  namespace: default
```
Apply it:
```bash
kubectl apply -f service-account.yaml
```
Verify:
```bash
kubectl get serviceaccount my-sa -n default
```

---

## 🔹 Step 4: Create a Role with Limited Permissions
Create a `role.yaml` file:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
```
Apply it:
```bash
kubectl apply -f role.yaml
```
Verify:
```bash
kubectl get role pod-reader -n default
```

---

## 🔗 Step 5: Bind the Role to the Service Account
Create a `role-binding.yaml` file:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: my-sa
    namespace: default
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```
Apply it:
```bash
kubectl apply -f role-binding.yaml
```
Verify:
```bash
kubectl get rolebinding pod-reader-binding -n default
```

---

## 🏗 Step 6: Create a Pod with the Service Account
Create a `test-pod.yaml` file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: default
spec:
  serviceAccountName: my-sa
  containers:
    - name: test-container
      image: busybox
      command: ["sleep", "3600"]
```
Apply it:
```bash
kubectl apply -f test-pod.yaml
```
Verify:
```bash
kubectl get pods -n default
```

---

## ✅ Step 7: Test RBAC Permissions
### 🔹 Get Pod Name:
```bash
kubectl get pods -n default
```
### 🔹 Open a Shell in the Pod:
```bash
kubectl exec -it test-pod -- sh
```

### ✅ Allowed Actions:
```sh
kubectl get pods
kubectl get pods -o yaml
```

### ❌ Denied Actions:
```sh
kubectl create pod test-pod-2 --image=nginx
```
You should see a **"permission denied"** error since we only allowed `get`, `list`, and `watch`.

---

## 🎯 Summary
1. ✅ Created **User (`my-user`)** and configured authentication
2. ✅ Created **Service Account (`my-sa`)**
3. ✅ Defined **Role (`pod-reader`)** with **read-only access** to pods
4. ✅ Created **RoleBinding (`pod-reader-binding`)** to link them
5. ✅ Deployed a **test pod** using the ServiceAccount
6. ✅ Tested **RBAC restrictions** inside the pod

Your **RBAC setup is now working in Minikube!** 🎉

Would you like to extend this setup to allow access to other resources? 🚀

