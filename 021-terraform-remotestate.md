# Terraform EC2 Instance with Remote State in S3 and DynamoDB Locking

## Overview
This Terraform project provisions an AWS EC2 instance while storing the Terraform state in an S3 bucket with DynamoDB for state locking. This ensures that multiple users do not modify the state file simultaneously.

## Prerequisites
- AWS CLI installed and configured (`aws configure`)
- Terraform installed (>= 1.2.0)
- AWS S3 bucket and DynamoDB table created manually (or through Terraform after the first execution)

## Project Structure
```
remote/
│── main.tf          # Terraform configuration file
│── variables.tf     # Input variables
│── output.tf        # Output values
│── README.md        # Project documentation
```

## Steps to Set Up
### 1️⃣ Configure AWS Credentials
Run the following command to set up AWS credentials:
```sh
aws configure
```
Provide your AWS Access Key, Secret Access Key, Region, and output format.

### 2️⃣ Create S3 Bucket and DynamoDB Table (Manually)
#### 📌 Create an S3 Bucket:
1. Log in to the AWS Console.
2. Navigate to **S3**.
3. Click **Create bucket**.
4. Enter a unique bucket name (e.g., `your-terraform-state-bucket`).
5. Choose AWS Region (e.g., `eu-north-1`).
6. Enable **Bucket Versioning** (Recommended for state rollback).
7. Click **Create bucket**.

#### 📌 Create a DynamoDB Table:
1. Log in to the AWS Console.
2. Navigate to **DynamoDB**.
3. Click **Create table**.
4. Table Name: `terraform-lock`
5. Primary Key:
   - Partition Key (Hash Key) → `LockID` (Type: String)
6. Billing Mode: Choose **On-demand (PAY_PER_REQUEST)**
7. Click **Create table**.


#### ALTERNATIVE METHOD FOR S3 AND DyanmoDB Table Creation
#####  You can add this in main.tf but Make sure to remove or comment out after first run
```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "your-terraform-state-bucket"  # Replace with your actual S3 bucket name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### 3️⃣ Initialize Terraform Project
#### 📌 Clone or Create the `remote` Directory
```sh
mkdir remote && cd remote
```

#### main.tf
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-buckett"  # Replace with your actual S3 bucket name
    key            = "terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-lock" # Replace with your Dynamo table name
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}


resource "aws_instance" "app_server" {
  ami           = var.instance_ami
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

#### 📌 Initialize Terraform
```sh
terraform init
```
This will configure the S3 backend for storing Terraform state.

#### 📌 Review Execution Plan
```sh
terraform plan
```
This command checks what changes Terraform will make before applying them.

#### 📌 Apply the Configuration
```sh
terraform apply
```
Confirm with `yes` when prompted. Terraform will provision the EC2 instance.

### 4️⃣ Outputs
After execution, Terraform will output:
- **Instance ID**
- **Public IP**
- **Private IP**

### 5️⃣ Destroy Resources (If Needed)
To remove all resources created by Terraform, run:
```sh
terraform destroy
```

## Terraform Configuration Details
### 📌 `main.tf`
- Configures S3 backend for state storage
- Defines the AWS provider
- Provisions an EC2 instance

### 📌 `variables.tf`
Defines input variables for AWS region, AMI ID, instance type, and name.

### 📌 `output.tf`
Displays the EC2 instance details after deployment.

## Optional: Automate S3 & DynamoDB Creation
Instead of creating them manually, you can add these resources in `main.tf` but **comment them out** after the first execution:
```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "your-terraform-state-bucket"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

```


#### variable.tf
```hcl
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_ami" {
  description = "The AMI ID for the instance"
  type        = string
  default     = "ami-0xxxxxxxx"  # Free-tier eligible AMI ID, Check once and update
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t3.micro"  # Free-tier eligible instance type, checl once and update
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
  default     = "Terraform_Demo_remote"
}
```

#### output.tf
```hcl
output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.app_server.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

```

## 🚀 Running Terraform Commands

### **Step 1: Initialize Terraform**
```sh
terraform init
```

### **Step 2: Validate Configuration**
```sh
terraform validate
```
**Purpose:**
- Checks for syntax errors and misconfigurations

### **Step 3: Create Execution Plan**
```sh
terraform plan
```
**Purpose:**
- Shows the resources that will be created before execution

### **Step 4: Apply the Configuration**
```sh
terraform apply
```
**Purpose:**
- Deploys the EC2 instance in AWS
- Prompts for confirmation (**Type "yes" to proceed**)

### **Step 5: Retrieve EC2 Details**
```sh
terraform output
```
**Purpose:**
- Displays Instance ID, Public IP, and Private IP through s3 bucket - terraform.tfstate 

### **Step 6: Destroy Resources (Optional)**
```sh
terraform destroy
```
**Purpose:**
- Deletes the EC2 instance and removes all Terraform-managed resources
- Requires confirmation (**Type "yes" to proceed**) 


