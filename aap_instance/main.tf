#Generate SSH key pair 
resource "tls_private_key" "cloud_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate a random ID for the S3 bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Add key for ssh connection
resource "aws_key_pair" "cloud_key" {
  key_name   = "cloud_key"
  public_key = tls_private_key.cloud_key.public_key_openssh
}

resource "aws_vpc" "aap_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name      = "aap-VPC"
    Terraform = "true"
  }
}

resource "aws_internet_gateway" "aap_igw" {
  vpc_id = aws_vpc.aap_vpc.id

  tags = {
    Name      = "AAP_IGW"
    Terraform = "true"
  }
}

resource "aws_route_table" "aap_pub_igw" {
  vpc_id = aws_vpc.aap_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aap_igw.id
  }

  tags = {
    Name      = "AAP-RouteTable"
    Terraform = "true"
  }
}

# Public Subnet in AZ1 (e.g., ap-southeast-2a)
resource "aws_subnet" "aap_public_subnet_az1" {
  vpc_id                  = aws_vpc.aap_vpc.id
  cidr_block              = "10.1.3.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "AAP-Public-Subnet-AZ1"
    Terraform                = "true"
    "kubernetes.io/role/elb" = "1" # optional, helpful for EKS or ALB discovery
  }
}

# Public Subnet in AZ2 (e.g., ap-southeast-2b)
resource "aws_subnet" "aap_public_subnet_az2" {
  vpc_id                  = aws_vpc.aap_vpc.id
  cidr_block              = "10.1.4.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "AAP-Public-Subnet-AZ2"
    Terraform                = "true"
    "kubernetes.io/role/elb" = "1"
  }
}

# Associate AZ1 subnet with public route table
resource "aws_route_table_association" "aap_rt_public_az1" {
  subnet_id      = aws_subnet.aap_public_subnet_az1.id
  route_table_id = aws_route_table.aap_pub_igw.id
}

# Associate AZ2 subnet with public route table
resource "aws_route_table_association" "aap_rt_public_raz2" {
  subnet_id      = aws_subnet.aap_public_subnet_az2.id
  route_table_id = aws_route_table.aap_pub_igw.id
}

resource "aws_security_group" "aap_security_group" {
  name        = "aap-sg"
  description = "Security Group for AAP webserver"
  vpc_id      = aws_vpc.aap_vpc.id

  tags = {
    Name      = "AAP-Security-Group"
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "http_ingress_access" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "ssh_ingress_access" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "postgresql_ingress_access" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "redis_ingress_access" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "secure_ingress_access" {
  type              = "ingress"
  from_port         = 8433
  to_port           = 8433
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "https_ingress_access" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "grpc_ingress_access" {
  type              = "ingress"
  from_port         = 50051
  to_port           = 50051
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_security_group_rule" "egress_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aap_security_group.id
}

resource "aws_instance" "aap_instance" {
  instance_type               = "m6a.xlarge"
  vpc_security_group_ids      = [aws_security_group.aap_security_group.id]
  associate_public_ip_address = true
  key_name                    = module.key_pair.key_pair_name
  ami                         = var.ami_id
  subnet_id                   = aws_subnet.aap_public_subnet_az1.id

  tags = {
    Name      = "aap-controller-az1"
    Terraform = "true"
  }
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.2"

  key_name           = "aap-testing"
  create_private_key = true
} 