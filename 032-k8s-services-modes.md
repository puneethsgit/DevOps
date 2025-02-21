# Kubernetes Service Types

Kubernetes provides different types of services to expose applications running within a cluster. The main service types are:

## 1. ClusterIP (Default)
- Exposes the service on an internal IP within the cluster.
- Accessible only within the cluster (not externally).
- Used for internal communication between pods.
- Example use case: Microservices communicating with each other.

## 2. NodePort
- Exposes the service on a static port (30000-32767) on each node.
- Can be accessed externally using `NodeIP:NodePort`.
- Less flexible for production use but useful for development and debugging.
- Example use case: Quick access to a service without an external load balancer.

## 3. LoadBalancer
- Provisions an external load balancer (e.g., AWS ELB, Azure LB) to expose the service.
- Automatically assigns a public IP.
- Used for production workloads requiring external access.
- Example use case: Exposing a web application to the internet.

### Choosing the Right Service Type
| Service Type  | Internal Access | External Access | Use Case |
|--------------|----------------|----------------|----------|
| ClusterIP    | ✅ Yes          | ❌ No         | Internal microservices |
| NodePort     | ✅ Yes          | ✅ Yes (Node IP) | Development & debugging |
| LoadBalancer | ✅ Yes          | ✅ Yes (Public IP) | Production applications |

For advanced use cases, Kubernetes also provides `Ingress` for managing external access and `ExternalName` for mapping to external services.

---
**Note:** For cloud environments, LoadBalancer relies on cloud provider integrations, while NodePort works on any Kubernetes cluster but requires manual handling of external access.
