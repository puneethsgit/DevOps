# ConfigMap in Kubernetes

## Introduction

A **ConfigMap** in Kubernetes is an API object used to store non-confidential configuration data in key-value pairs. It allows you to decouple environment-specific configurations from your containerized applications, making them more portable and flexible.

## Creating a ConfigMap

A ConfigMap can be created in multiple ways:

### 1. Using a YAML file

The following example defines a ConfigMap named `test-cm`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-cm
data:
  db-port: "8888"
```

### 2. Using kubectl command

You can also create a ConfigMap from the command line:

```sh
kubectl create configmap test-cm --from-literal=db-port=8888
```

## Using ConfigMap in a Deployment

To use the ConfigMap inside a Pod, you reference it in the deployment YAML:

```yaml
        env:
         - name: DB-PORT
           valueFrom:
             configMapKeyRef:
               name: test-cm
               key: db-port
```

In this example, the `DB-PORT` environment variable inside the pod is set using the value from the `db-port` key in the `test-cm` ConfigMap.

## Verifying the Environment Variable in a Running Pod

Once the pod is running, you can verify whether the environment variable is set correctly by executing the following commands:

### 1. Get the pod name

```sh
kubectl get pods
```

### 2. Access the pod shell

```sh
kubectl exec -it <pod-name> -- /bin/sh
```

### 3. Check the environment variable

```sh
env | grep DB
```

Expected output:

```sh
DB-PORT=8888
```

## Volume Mounts in Kubernetes

### Problem with ConfigMap as Environment Variables

One limitation of using ConfigMaps as environment variables is that any changes to the ConfigMap do not reflect in running pods unless they are restarted. Kubernetes recommends using **volume mounts** for dynamic configuration updates without needing to restart the pods.

### Using ConfigMap as a Volume Mount

To overcome the above limitation, we mount the ConfigMap as a volume inside the container:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
  labels:
    app: python-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: python-app
        image: puneeth11/python-app:v1
        volumeMounts:
          - name: db-connection
            mountPath: /opt
        ports:
        - containerPort: 8000
      volumes:
        - name: db-connection
          configMap:
            name: test-cm
```

### Applying the Deployment

```sh
kubectl apply -f deployment.yaml
```

### Benefits of Volume Mounts

Now, any changes made to the ConfigMap will be automatically reflected inside the pod at the mount path (`/opt`) **without needing to restart the pod**.

This ensures that your application always has the latest configuration updates dynamically, improving flexibility and reducing downtime.

### Updating ConfigMap Without Restarting the Pod

Any changes you need to make should be updated in the `cm.yaml` file, and then you can apply the changes using:

```sh
kubectl apply -f cm.yaml
```

The changes will be reflected inside the pod immediately without requiring a restart.

## Kubernetes Secrets

### What are Secrets?

Secrets in Kubernetes are similar to ConfigMaps but are used to store **sensitive information** such as passwords, API keys, and tokens. Unlike ConfigMaps, Secrets are designed to keep data encrypted and secured.

### Types of Kubernetes Secrets

1. **Opaque** - The default type, used to store arbitrary key-value pairs.
2. **TLS** - Used to store TLS certificates and private keys.
3. **Docker-registry** - Stores credentials for Docker container registries.
4. **Basic-auth** - Stores credentials like username and password.
5. **SSH-auth** - Stores SSH keys.
6. **Service-account-token** - Holds tokens for service accounts.

### Creating a Secret

You can create a secret using a YAML file:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  username: dXNlcm5hbWU=
  password: cGFzc3dvcmQ=
```

The values in the secret must be **Base64 encoded**.

### Using a Secret in a Pod

You can mount a secret as an environment variable:

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: my-secret
        key: password
```

Alternatively, you can mount the secret as a volume:

```yaml
volumeMounts:
  - name: secret-volume
    mountPath: "/etc/secret"
volumes:
  - name: secret-volume
    secret:
      secretName: my-secret
```

### Viewing a Secret

To describe a secret:

```sh
kubectl describe secret my-secret
```

Unlike ConfigMaps, when you describe a Secret, the actual values are not shown for security reasons.

To decode the secret manually:

```sh
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode
```

### Are Secrets Changeable Without Pod Restart?

Secrets mounted as **environment variables** require a pod restart to reflect changes. However, if a Secret is **mounted as a volume**, changes in the Secret are dynamically reflected inside the pod without requiring a restart, similar to ConfigMaps.

## Conclusion

ConfigMaps and Secrets are essential for managing application configurations in Kubernetes. ConfigMaps store non-sensitive data, while Secrets are used for storing sensitive information securely. Using volume mounts with ConfigMaps ensures dynamic updates without requiring pod restarts, whereas Secrets keep sensitive information encrypted and secure. If Secrets are mounted as environment variables, a pod restart is required for changes to take effect, but if mounted as a volume, updates are reflected dynamically.


# EXAMPLE 

---

### **Kubernetes: Managing Environment Variables using ConfigMap and Secret**
Kubernetes uses:
- **ConfigMaps** to store **non-sensitive** environment variables.
- **Secrets** to store **sensitive** environment variables securely.
- The **Dockerfile does not contain environment variables**; instead, they are injected at runtime via Kubernetes.

---

## **1. Create a ConfigMap (For Non-Sensitive Variables)**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mern-config
data:
  NODE_ENV: "production"
  PORT: "5000"
```
**Apply ConfigMap:**
```sh
kubectl apply -f configmap.yaml
```

---

## **2. Create a Secret (For Sensitive Variables like Database Credentials)**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mern-secrets
type: Opaque
data:
  MONGO_URI: bW9uZ29kYjovL21vbmdvOjI3MDE3L215ZGF0YWJhc2U=  # Base64 encoded
```
**Apply Secret:**
```sh
kubectl apply -f secret.yaml
```
> Encode MongoDB URI before storing it in `secret.yaml`:
```sh
echo -n "mongodb://mongo:27017/mydatabase" | base64
```

---

## **3. Kubernetes Deployment YAML (Inject ConfigMap and Secret into Pod)**
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
          image: mymernapp:latest
          ports:
            - containerPort: 5000
          envFrom:
            - configMapRef:
                name: mern-config
          env:  #Can Use Volume mount also for better use case
            - name: MONGO_URI
              valueFrom:
                secretKeyRef:
                  name: mern-secrets
                  key: MONGO_URI
```
**Apply Deployment:**
```sh
kubectl apply -f deployment.yaml
```

---

## **4. Dockerfile (Minimal, No Environment Variables Defined)**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY . .

EXPOSE 5000

CMD ["npm", "start"]
```
- The **Dockerfile does not include `.env`**.
- Kubernetes injects environment variables at runtime.

---

## **5. Verify Environment Variables Inside the Running Pod**
```sh
kubectl get pods  # Get pod name
kubectl exec -it <pod-name> -- env | grep NODE_ENV
kubectl exec -it <pod-name> -- env | grep MONGO_URI
```

---

## **Summary**
✅ **ConfigMap** stores non-sensitive variables (`NODE_ENV`, `PORT`).  
✅ **Secret** stores sensitive variables (`MONGO_URI`) in **Base64 format**.  
✅ **Kubernetes Deployment** injects values into the container.  
✅ **Dockerfile does not store environment variables**; Kubernetes manages them.

---

### **Behind the Scenes: How Kubernetes Injects ConfigMap & Secret into the MERN App**  

When you define **ConfigMaps** and **Secrets** in Kubernetes and reference them in your **Deployment YAML**, Kubernetes automatically injects them as **environment variables** into the running container. Here's how it works step by step:

---

## **🔹 Step-by-Step Process**
### **1️⃣ When You Apply ConfigMap & Secret**
- **ConfigMap (`configmap.yaml`)** and **Secret (`secret.yaml`)** are created in Kubernetes.
- They are stored in the **Kubernetes key-value store (etcd)**.
- These resources are namespaced and can be accessed only within that namespace.

### **2️⃣ Deployment Uses Them**
- When you deploy your app (`deployment.yaml`), Kubernetes:
  - Pulls the Docker image (`mern-app:latest`) and creates a **Pod**.
  - Injects **ConfigMap** values (`NODE_ENV`, `PORT`) as environment variables.
  - Injects **Secret** values (`MONGO_URI`), decoding the Base64 format before setting them.

### **3️⃣ How the Container Accesses Them**
- Inside the running **Node.js app**, these values are accessible via:
  ```javascript
  process.env.NODE_ENV   // From ConfigMap
  process.env.PORT       // From ConfigMap
  process.env.MONGO_URI  // From Secret
  ```
- The **Dockerfile** doesn’t define `.env`, and **Kubernetes handles everything dynamically at runtime**.

---

## **Example: `server.js` or `app.js` (MERN Backend)**
Here’s how your **Node.js backend** reads environment variables injected by Kubernetes:

```javascript
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');

const app = express();

// Read environment variables from Kubernetes
const PORT = process.env.PORT || 5000;
const NODE_ENV = process.env.NODE_ENV || 'development';
const MONGO_URI = process.env.MONGO_URI;

if (!MONGO_URI) {
  console.error('❌ MongoDB URI is not set. Make sure Kubernetes Secret is configured correctly.');
  process.exit(1);
}

// Connect to MongoDB
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB Connection Error:', err));

// Basic route
app.get('/', (req, res) => {
  res.json({ message: 'MERN App Running...', environment: NODE_ENV });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT} in ${NODE_ENV} mode`);
});
```

---


## **🛠 Behind-the-Scenes Kubernetes Mechanism**
### **🔸 How Kubernetes Passes Environment Variables**
1. When a **Pod starts**, Kubernetes:
   - Reads the values from the **ConfigMap and Secret**.
   - Passes them into the container using `env` variables.
   - The container (running **Node.js**) gets access to them automatically.

2. When you run:
   ```sh
   kubectl describe pod <pod-name>
   ```
   You will see:
   ```
   Environment:
     NODE_ENV:        production
     PORT:            5000
     MONGO_URI:       <set from secret>
   ```

3. Inside the container, `process.env.NODE_ENV`, `process.env.PORT`, and `process.env.MONGO_URI` retrieve these values.

---

## **Summary**
✅ **ConfigMap and Secret are stored in Kubernetes and injected into Pods.**  
✅ **The Deployment YAML references them and sets them as environment variables.**  
✅ **The Node.js app accesses these values dynamically at runtime using `process.env`.**  
✅ **This ensures security, flexibility, and no hardcoded credentials in Docker or source code.**  

Would you like to set up **HTTPS (TLS) in Minikube using cert-manager and Let’s Encrypt** next? 🚀
