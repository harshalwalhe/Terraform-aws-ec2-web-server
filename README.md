# Terraform AWS EC2 Web Server

Automated deployment of a static website on AWS using Terraform (Infrastructure as Code). With a single `terraform apply`, it creates an EC2 instance, installs the Apache web server and hosts a website cloned from GitHub.

## What this project creates

| Resource | Purpose |
|----------|---------|
| `tls_private_key` + `aws_key_pair` | Generates an RSA 4096 key pair for SSH access |
| `local_file` | Saves the private key locally as `mywebserver.pem` |
| `aws_security_group` | Allows inbound HTTP (80), HTTPS (443) and SSH (22) |
| `aws_instance` | EC2 instance (Amazon Linux 2023, t3.micro) in the default VPC |
| `user_data` script | Installs Apache (httpd) and Git, then clones the website into `/var/www/html` |

## Prerequisites

- An AWS account
- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured (`aws configure`)

## How to use

```bash
# 1. Clone this repository
git clone https://github.com/harshalwalhe/Terraform-aws-ec2-web-server.git
cd Terraform-aws-ec2-web-server

# 2. Initialize Terraform (downloads providers)
terraform init

# 3. Preview the changes
terraform plan

# 4. Create the infrastructure
terraform apply
```

After `apply` finishes, Terraform prints the output:

```
instance_public_ip = "x.x.x.x"
```

Open `http://x.x.x.x` in your browser to see the website. Wait 1 to 2 minutes after creation for the server setup to finish.

## Connect to the server (SSH)

```bash
ssh -i mywebserver.pem ec2-user@<instance_public_ip>
```

## Clean up

To avoid AWS charges, destroy everything when you are done:

```bash
terraform destroy
```

## Key concepts used

- Infrastructure as Code (IaC)
- Terraform providers, resources, data sources and outputs
- Dynamic AMI lookup using a data source
- EC2 user_data for automated server configuration
- Security groups (ingress and egress rules)
- Automatic SSH key pair generation

## Security notes

- SSH (port 22) is open to `0.0.0.0/0` for practice. For real use, restrict it to your own IP.
- `mywebserver.pem` and `terraform.tfstate` contain secrets. They are excluded using `.gitignore` and must never be committed.

## Author

**Harshal Walhe**
GitHub: [@harshalwalhe](https://github.com/harshalwalhe)
