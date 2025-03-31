# Service Account in Kubernetes

## What is a Service Account?
A **Service Account** in Kubernetes provides an identity for **pods** to interact with the Kubernetes API or external services. It is mainly used for:
- Granting fine-grained access control to Kubernetes resources.
- Authenticating pods to access external cloud services securely (e.g., AWS, GCP).
- Replacing static credentials with dynamic authentication mechanisms.

## Use Case: Secure Access to AWS S3 from EKS Pods Using IRSA
### Scenario
We have an **EKS cluster** with pods running on **different EC2 instances (nodes)**. The pods need **secure access** to an **S3 bucket** without hardcoding AWS credentials. We achieve this using **Kubernetes ServiceAccount + IAM Role (IRSA)**.

### Step 1: Enable OIDC Provider for EKS
```sh
eksctl utils associate-iam-oidc-provider --region <AWS_REGION> --cluster <EKS_CLUSTER_NAME> --approve
```

### Step 2: Create an IAM Role for the Service Account
```sh
eksctl create iamserviceaccount \
  --name s3-access-sa \
  --namespace default \
  --cluster <EKS_CLUSTER_NAME> \
  --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve
```

### Step 3: Define a Kubernetes ServiceAccount
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-access-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/S3AccessRole
```

### Step 4: Deploy a Pod Using the Service Account
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: s3-access-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: s3-app
  template:
    metadata:
      labels:
        app: s3-app
    spec:
      serviceAccountName: s3-access-sa
      containers:
      - name: app
        image: amazonlinux
        command: [ "/bin/sh", "-c", "aws s3 ls s3://my-bucket" ]
```
✅ Now, the pod can securely access **S3** without AWS credentials.

## Service Account in Minikube vs. AWS EKS
| Feature | Minikube | AWS EKS |
|---------|---------|--------|
| **Authentication** | Uses Kubernetes API token | Uses IAM Role (IRSA) |
| **AWS Access** | No direct AWS access | Secure AWS service access |
| **OIDC Provider** | Not required | Required for IRSA |
| **Storage of Credentials** | ServiceAccount token in the pod | Temporary AWS credentials via STS |

## Conclusion
- A **ServiceAccount** provides identity to **pods** within a Kubernetes cluster.
- In **EKS**, ServiceAccounts can be mapped to **IAM Roles** for AWS service access.
- In **Minikube**, ServiceAccounts mainly control access to Kubernetes resources within the cluster.

This guide explains how to **securely use ServiceAccounts in EKS and Minikube** to authenticate pods efficiently.

