# Setting Up and Running Python Web Application on Kubernetes

## Prerequisites

Ensure you have the following installed on your system:

- Kubernetes (Minikube or a running cluster)
- kubectl (Kubernetes CLI)
- Docker
- Git

---

## Step 1: Clone the Repository

Run the following command to clone the repository:

```sh
git clone https://github.com/puneethsgit/Docker-Zero-to-Hero.git
cd Docker-Zero-to-Hero/python-webapp
```

---

## Step 2: Deploy the Application in ClusterIP Mode

ClusterIP mode is the default service type in Kubernetes, allowing internal communication within the cluster.

### **Create the Deployment**

Create a `deployment.yaml` file:

```yaml
apiVersion: apps/v1  # Defines the API version used for deployments
kind: Deployment  # Specifies that this YAML file describes a Deployment resource
metadata:
  name: python-app  # Name of the deployment
  labels:
    app: python-app  # Label used for identifying the deployment
spec:
  replicas: 2  # Number of pod replicas to run
  selector:
    matchLabels:
      app: python-app  # Ensures that only pods with this label are managed by this deployment
  template:
    metadata:
      labels:
        app: python-app  # Label assigned to pods created by this deployment
    spec:
      containers:
      - name: python-app  # Name of the container
        image: puneeth11/python-app:v1  # Docker image to use for the container
        ports:
        - containerPort: 8000  # Port the container exposes inside the pod
```

Apply the deployment:

```sh
kubectl apply -f deployment.yaml
```

### **Create a Service for ClusterIP**

Create a `service-clusterip.yaml` file:

```yaml
apiVersion: v1  # API version for services
kind: Service  # Specifies that this YAML defines a Kubernetes Service
metadata:
  name: python-app-service  # Name of the service
spec:
  type: ClusterIP  # Exposes the service internally within the cluster
  selector:
    app: python-app  # Matches the pods labeled with app: python-app
  ports:
    - port: 80  # Port on which the service is exposed
      targetPort: 8000  # Port on which the container is listening inside the pod
```

Apply the service:

```sh
kubectl apply -f service-clusterip.yaml
```

### **Access the Application in ClusterIP Mode**

Since ClusterIP is only accessible within the cluster, use port forwarding:

```sh
kubectl port-forward service/python-app-service 8080:80
```

#### **Explanation of port-forward command:**

Port forwarding allows accessing an internal service from a local machine.

- `service/python-app-service`: Specifies the Kubernetes service to forward traffic to.
- `8080:80`: Maps port 80 of the service to port 8080 on the local machine, making the service accessible at `http://localhost:8080`.

Now, access the application at `http://localhost:8080`.

---

## Step 3: Deploy the Application in NodePort Mode

NodePort mode exposes the application externally on a specific port.

### **Create a Service for NodePort**

Modify the service YAML to use NodePort (`service-nodeport.yaml`):

```yaml
apiVersion: v1  # API version for services
kind: Service  # Defines this as a Kubernetes Service
metadata:
  name: python-app-service  # Name of the service
spec:
  type: NodePort  # Exposes the service externally through a port on each node
  selector:
    app: python-app  # Matches the pods labeled with app: python-app
  ports:
    - port: 80  # Service port
      targetPort: 8000  # Port where the container is listening
      nodePort: 30007  # NodePort to expose externally (must be in range 30000-32767)
```

Apply the NodePort service:

```sh
kubectl apply -f service-nodeport.yaml
```

### **Access the Application in NodePort Mode**

Find the Minikube IP:

```sh
minikube ip
```

Access the application using:

```sh
http://<minikube-ip>:30007
```

For a cloud-based Kubernetes cluster, use any node’s external IP:

```sh
kubectl get nodes -o wide
```

Then access: `http://<node-ip>:30007`

---

## Understanding YAML Syntax

YAML (Yet Another Markup Language) is used in Kubernetes to define configurations.

- **apiVersion**: Specifies the Kubernetes API version.
- **kind**: Defines the type of resource (Deployment, Service, etc.).
- **metadata**: Holds name and labels for identifying resources.
- **spec**: Contains the actual configuration (e.g., replicas, container details, ports).

---

## Kubernetes Auto-Healing & Auto-Scaling

### **Auto-Healing**

Kubernetes monitors and replaces failed pods automatically. If a pod crashes, Kubernetes restarts it to maintain the desired state.

### **Auto-Scaling**

Kubernetes supports horizontal and vertical scaling:

- **Horizontal Pod Autoscaler (HPA)**: Adjusts the number of pods based on CPU/memory usage.
- **Vertical Pod Autoscaler (VPA)**: Modifies pod resource limits dynamically and can also scale replicas if needed.

Example of setting up **HPA**:

```sh
kubectl autoscale deployment python-app --cpu-percent=50 --min=1 --max=5
```

Example of setting up **VPA**:

```sh
kubectl apply -f vpa.yaml
```

Example VPA YAML (`vpa.yaml`):

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: python-app-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: python-app
  updatePolicy:
    updateMode: Auto
```

To allow VPA to scale replicas along with resource limits, you can modify the deployment accordingly:

```sh
kubectl scale deployment python-app --replicas=5
```
While VPA modifies CPU/memory, you can still manually increase replicas for better availability.

---

## Kubernetes vs. Docker Single Host Issue

Docker runs containers on a single host, limiting scalability and fault tolerance. Kubernetes solves this by:

- **Distributing workloads across multiple nodes**
- **Ensuring high availability** with load balancing
- **Providing self-healing mechanisms** (auto-restart, rescheduling on failure)
- **Facilitating rolling updates and rollbacks**

---

Now, you have a fully deployed and scalable Python web application running on Kubernetes in both ClusterIP and NodePort modes!

