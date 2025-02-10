# Terraform AWS EC2 Setup

## Overview
This project automates the creation of an **AWS EC2 Free-Tier Instance** using Terraform. The configuration is modular, utilizing `input.tf`, `main.tf`, and `output.tf` for better management.

---

## 📌 Prerequisites
Ensure the following are installed and configured:
- **AWS CLI** (Configured using `aws configure`)
- **Terraform** (Check installation using `terraform -version`)

Download Terraform from: [Terraform Official Download](https://developer.hashicorp.com/terraform/downloads)

---

## 📂 Project Structure
```
terraform-aws-ec2/
│── input.tf   # Defines input variables
│── main.tf    # Creates AWS EC2 instance
│── output.tf  # Displays EC2 instance details
│── README.md  # Project documentation
```

---

## 🛠 Setup Instructions

### **1️⃣ Create a Project Directory**
```sh
mkdir terraform-aws-ec2
cd terraform-aws-ec2
```

### **2️⃣ Create Terraform Files**

#### **input.tf** (Defines Variables)
```hcl
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "instance_ami" {
  description = "The AMI ID for the instance"
  type        = string
  default     = "ami-09a9858973b288bdd"  # Free-tier eligible AMI ID, Check once and update
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t3.micro"  # Free-tier eligible instance type, checl once and update
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
  default     = "Terraform_Demo"
}
```

#### **main.tf** (Creates EC2 Instance)
```hcl
terraform {
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

#### **output.tf** (Displays Instance Details)
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

---

## 🚀 Running Terraform Commands

### **Step 1: Initialize Terraform**
```sh
terraform init
```
**Purpose:**
- Downloads AWS provider plugin
- Initializes Terraform in the directory

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
- Displays Instance ID, Public IP, and Private IP

### **Step 6: Destroy Resources (Optional)**
```sh
terraform destroy
```
**Purpose:**
- Deletes the EC2 instance and removes all Terraform-managed resources
- Requires confirmation (**Type "yes" to proceed**)

---

## 📌 Terraform Command Summary
| Command               | Purpose |
|-----------------------|---------|
| `terraform init`     | Initializes Terraform and downloads providers |
| `terraform validate` | Checks for syntax errors |
| `terraform plan`     | Shows execution plan without applying changes |
| `terraform apply`    | Deploys the resources to AWS |
| `terraform output`   | Displays instance details |
| `terraform destroy`  | Deletes all created resources |

---

**Note:**
- aws_instance : This is a Terraform resource type that tells Terraform to create an EC2 instance in AWS. It comes from the AWS provider (hashicorp/aws).
- app_server : This is the logical name for the resource within Terraform. It helps you reference the resource elsewhere in your Terraform configuration.

## 🎯 End Goal: Free AWS EC2 Instance Created
After running these steps, you will have:
- **A free-tier eligible EC2 instance in AWS**
- **Automated deployment using Terraform**
- **Easy resource management with Terraform commands**

Happy Coding! 🚀

