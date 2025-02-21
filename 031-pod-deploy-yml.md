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
```

