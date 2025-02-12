# Terraform Module README

## How to Create a Terraform Module

A Terraform module consists of multiple files inside a directory. The common structure looks like:

```
my-module/
├── main.tf        # Defines resources
├── variables.tf   # Defines input variables
├── outputs.tf     # Defines output values
├── README.md      # Documentation (optional)
```

### 1. Define Resources (main.tf)
Create a `main.tf` file inside the module directory to define infrastructure resources.

Example: A Simple AWS EC2 Module

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.instance_name
  }
}
```

### 2. Define Variables (variables.tf)
Modules allow users to pass custom values using variables.

```hcl
variable "region" {
  description = "AWS region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}
```

### 3. Define Outputs (outputs.tf)
Modules can return values using outputs.

```hcl
output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}
```

## How to Use the Module

Once the module is created, you can use it in your main Terraform configuration.

### 1. Create a New Terraform Project Directory

You should create a new folder to store the Terraform configuration that will call the module.

```bash
mkdir terraform-project
cd terraform-project
```

### 2. Create a main.tf File

Inside the terraform-project directory, create a `main.tf` file.

```bash
touch main.tf
```

Then, open `main.tf` and define the module usage:

```hcl
module "ec2_instance" {
  source         = "../my-module"  # Path to the module (go one level up)
  region         = "us-east-1"
  ami_id         = "ami-12345678"
  instance_type  = "t3.micro"
  instance_name  = "MyInstance"
}
```

### Explanation:
- `source = "../my-module"`: This tells Terraform where to find the module (it should be outside the `terraform-project` directory).
- The other variables (`region`, `ami_id`, etc.) are passed to the module.

### 3. Make Sure the Module Exists

Ensure your module (`my-module`) is available one directory level up (`../my-module`). The structure should look like this:

```
parent-folder/
├── my-module/           # This is the Terraform module you created
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── README.md
├── terraform-project/   # This is where you use the module
│   ├── main.tf
```

### 4. Initialize and Apply Terraform

Now, in your `terraform-project` folder, run:

```bash
terraform init     # Initialize Terraform and download the module
terraform apply    # Deploy the resources
```

Terraform will read `main.tf`, locate the module in `../my-module/`, and apply the configuration.

## Alternative: Use a Remote Module

Instead of referencing a local path, you can use a remote module (e.g., from GitHub or the Terraform Registry).

Example:

```hcl
module "ec2_instance" {
  source = "git::https://github.com/example-user/my-terraform-module.git"
  region = "us-east-1"
  ami_id = "ami-12345678"
}
```



