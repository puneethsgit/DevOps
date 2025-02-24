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
