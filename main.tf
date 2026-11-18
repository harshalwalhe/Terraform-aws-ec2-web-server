terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version ="6.4.0"
    }
  }
}

provider "aws"{
    region= "us-east-1"
  
}
data "aws_vpc" "default" {
    default=true
}

data "aws_subnets" "default" {
    filter{
        name="vpc-id"
        values =[data.aws_vpc.default.id]
    }
  
}
 resource "tls_private_key" "ec2_key" {
    algorithm = "RSA"
    rsa_bits = 4096
   
 }

resource "aws_key_pair" "generated_key" {
    key_name="mywebserver"
    public_key= tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
    content = tls_private_key.ec2_key.private_key_pem
    filename = "mywebserver.pem"
    file_permission = "0400"
    directory_permission = "0700"

  
}
resource "aws_security_group" "http_server_sg" {
    name ="http_server_sg"
    description= "allow HTTP and SSH"
    vpc_id = data.aws_vpc.default.id

    ingress{
        description="HTTP"
        from_port=80
        to_port=80
        protocol ="tcp"
        cidr_blocks=["0.0.0.0/0"]

    }    
    ingress{
        description ="HTTPS"
        from_port=443
        to_port=443
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    ingress{
        description="SSH"
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]


    }
    egress{
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }
    tags={
        name="https_server_sg"
    }
  
}
data "aws_ami" "mydata" {
    owners =["amazon"]
    most_recent =true
    filter{
        name="name"
        values=["al2023-ami-*x86_64"]
    }
}

resource "aws_instance" "HTTP_server" {
    ami =data.aws_ami.mydata.id
    instance_type="t3.micro"
    key_name=aws_key_pair.generated_key.key_name
    subnet_id=data.aws_subnets.default.ids[0]
    vpc_security_group_ids=[aws_security_group.http_server_sg.id]
    associate_public_ip_address=true

    user_data =<<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        yum install git -y
        systemctl start httpd
        systemctl enable httpd
        git clone https://github.com/harshalwalhe/ec2-website-1.git  /var/www/html/
        chmod 755 /var/www/html
        EOF
    
   tags = {
    Name = "Terraform-HTTP-Server"
  }

  depends_on = [local_file.private_key_pem]


  }

  output "instance_public_ip" {
  description = "Public IP of the deployed EC2 instance"
  value       = aws_instance.HTTP_server.public_ip
}

    






