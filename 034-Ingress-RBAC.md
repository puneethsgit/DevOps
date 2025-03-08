---

Kubernetes Ingress and Service Traffic Flow

This document explains how Kubernetes Ingress and Services work together to route external traffic to Pods, ensuring efficient traffic management and cost optimization.


---

1️⃣ What is Kubernetes Ingress?

Ingress is a Kubernetes resource that manages external access to services inside the cluster, typically via HTTP/HTTPS. It allows you to:

Expose multiple services through one external IP.

Use a single LoadBalancer instead of multiple, reducing cloud costs.

Enable path-based or host-based routing (e.g., puneeth.me/ → frontend, puneeth.me/api → backend).


How Ingress Helps Reduce Cloud Costs

Without Ingress: | Service  | LoadBalancer IP | Cost | |----------|----------------|------| | frontend | 35.123.45.67    | $$$  | | backend  | 52.234.56.78    | $$$  | | database | 13.98.76.54     | $$$  | | Total | 3 Load Balancers | High Cost |

With Ingress: | Service  | Ingress Controller (Single LoadBalancer) | |----------|----------------------------------| | frontend | puneeth.me/ | | backend  | puneeth.me/api | | database | Internal (No public exposure) | | Total | 1 Load Balancer (Low Cost) |


---

2️⃣ How Traffic Flows in Kubernetes

Let's understand the flow when a user visits puneeth.me.

Step-by-Step Traffic Flow


---

3️⃣ Kubernetes YAML Configuration

Ingress Configuration (ingress.yaml)

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

✔ Requests to puneeth.me/ go to frontend-service
✔ Requests to puneeth.me/api go to backend-service


---

Service Configuration (service.yaml)

apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  selector:
    app: frontend  # Selects pods with label app=frontend
  ports:
  - protocol: TCP
    port: 80        # Service listens on port 80
    targetPort: 3000  # Forwards traffic to pods running on port 3000
  type: ClusterIP

✔ Service listens on port: 80
✔ Traffic is forwarded to targetPort: 3000 (where the pod application runs)


---

Deployment Configuration (deployment.yaml)

apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: my-frontend-image
        ports:
        - containerPort: 3000  # The application runs inside the container on port 3000

✔ Each pod runs a container that serves the frontend app on port 3000
✔ Pods are dynamically assigned IPs, but the Service ensures stable access


---

4️⃣ How Service Discovery Works

How Does the Service Know the Pod’s IP?

1. Service uses labels & selectors to find matching Pods.


2. Kubernetes keeps an updated list of Pod IPs.


3. Requests coming to frontend-service:80 are forwarded to one of the matching Pod IPs on port 3000.



Behind-the-Scenes Example

📌 The Service ensures a stable entry point (frontend-service), even if Pod IPs change dynamically.


---

5️⃣ Why Use Port 80 Instead of 3000 in Service?

Yes, we could define the service directly with port 3000, but using port 80 has benefits:

🌍 Standard HTTP Port: Port 80 is universally recognized for HTTP traffic.

🔀 Ingress Compatibility: Many Ingress controllers expect backend services to use port 80 or 443.

🛠 Flexibility: If the container port changes (e.g., 4000 instead of 3000), we only update targetPort, not the Ingress rules.


💡 Best Practice: Use port: 80 in Service and targetPort: 3000 to forward traffic to the container.


---

6️⃣ Summary & Key Takeaways

✔ ClusterIP + Service Discovery = Internal communication between services using stable names.
✔ Ingress + DNS + Domain = Exposes the app to the internet using a single IP & domain.
✔ Cost Optimization = Instead of multiple Load Balancers, we use one Ingress to reduce cloud charges.
✔ No Direct Pod IP Usage = Services + Ingress handle all routing dynamically.


---

7️⃣ Final Traffic Flow Recap

1️⃣ User requests puneeth.me/ → DNS resolves it to Ingress IP
2️⃣ Ingress forwards request to frontend-service:80
3️⃣ Service discovers Pod IPs and routes traffic to targetPort: 3000
4️⃣ Container inside the Pod (port 3000) processes the request
5️⃣ Response flows back to the user ✅

By implementing Ingress + Service Discovery, we ensure efficient traffic management, domain-based routing, and cost savings. 🚀


---

📌 Next Steps

✅ Deploy these YAML files to your Kubernetes cluster.

✅ Check logs with kubectl logs -f <pod-name>

✅ Test routing with curl http://puneeth.me/

✅ Monitor with kubectl get ingress,svc,pods -o wide


🚀 Happy Kubernetes-ing! 🚀


---

This README.md file is structured for clarity, easy deployment, and learning. Let me know if you need any modifications!



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

