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

## Choosing the Right Strategy
| Strategy       | Zero Downtime | Rollback Speed | Resource Usage |
|---------------|--------------|---------------|---------------|
| Rolling Update | ✅ Yes        | ❌ Slow       | ✅ Efficient  |
| Recreate      | ❌ No         | ✅ Fast       | ✅ Efficient  |
| Blue-Green    | ✅ Yes        | ✅ Fast       | ❌ High      |

## Conclusion
- **Rolling Update**: Best for most applications, ensuring availability.
- **Recreate**: Simple but causes downtime, best for non-critical apps.
- **Blue-Green**: Ideal for quick rollbacks but requires extra resources.

Choose the best strategy based on your application's needs!

