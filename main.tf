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

#resource "aws_subnet" "aap_subnet" {
#  cidr_block              = "10.1.0.0/24"
#  map_public_ip_on_launch = "true"
#  vpc_id                  = aws_vpc.aap_vpc.id
#
#  tags = {
#    Name      = "AAP-Subnet"
#    Terraform = "true"
#  }
#}

# Public Subnet in AZ1 (e.g., ap-southeast-2a)
resource "aws_subnet" "aap_public_subnet_az1" {
  vpc_id                  = aws_vpc.aap_vpc.id
  cidr_block              = "10.1.0.0/24"
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
  cidr_block              = "10.1.1.0/24"
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

#resource "aws_route_table_association" "aap_rt_subnet_public" {
#  subnet_id      = aws_subnet.aap_subnet.id
#  route_table_id = aws_route_table.aap_pub_igw.id
#}

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

# # Set ami for ec2 instance
# data "aws_ami" "rhel" {
#   most_recent = true
#   filter {
#     name   = "name"
#     values = ["RHEL-9.5.0_HVM*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   owners = ["309956199498"]
# }

resource "aws_instance" "aap_instance" {
  instance_type               = "m6a.xlarge"
  vpc_security_group_ids      = [aws_security_group.aap_security_group.id]
  associate_public_ip_address = true
  key_name                    = module.key_pair.key_pair_name
  #user_data                   = file("user_data.txt")
  ami = var.ami_id
  #subnet_id         = aws_subnet.aap_subnet.id
  subnet_id = aws_subnet.aap_public_subnet_az1.id

  # # Specify the root block device to adjust volume size
  # root_block_device {
  #   volume_size           = 150   # Set desired size in GB (e.g., 100 GB)
  #   volume_type           = "gp3" # Optional: Specify volume type (e.g., "gp3" for general purpose SSD)
  #   delete_on_termination = true  # Optional: Automatically delete volume on instance termination
  # }


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

resource "local_sensitive_file" "key_pair_pem" {
  filename        = "${path.root}/../${module.key_pair.key_pair_name}.pem"
  file_permission = "400"
  content         = module.key_pair.private_key_pem
}


# Create a Security Group for EFS
resource "aws_security_group" "efs_security_group" {
  name        = "efs-sg"
  description = "Allow EFS access"
  vpc_id      = aws_vpc.aap_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"] # Adjust CIDR block as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "EFS-Security-Group"
    Terraform = "true"
  }
}

# Create an EFS File System
resource "aws_efs_file_system" "efs" {
  creation_token   = "aap-efs"
  performance_mode = "generalPurpose" # or "maxIO" for high IOPS
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" # Optional: Move files to Infrequent Access after 30 days
  }

  tags = {
    Name      = "AAP-EFS"
    Terraform = "true"
  }
}

# Create Mount Targets for EFS
resource "aws_efs_mount_target" "efs_mount_target_az1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.aap_public_subnet_az1.id
  security_groups = [aws_security_group.efs_security_group.id]
}



resource "acme_registration" "reg" {
  email_address = var.acme_email
}

resource "acme_certificate" "cert" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names

  dns_challenge {
    provider = "route53"
  }
}

resource "aws_acm_certificate" "cert" {
  private_key       = acme_certificate.cert.private_key_pem
  certificate_body  = acme_certificate.cert.certificate_pem
  certificate_chain = acme_certificate.cert.issuer_pem
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow inbound HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.aap_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "ALB-SG"
    Terraform = "true"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "aap-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.aap_vpc.id

  health_check {
    path                = "/"
    port                = "443"
    protocol            = "HTTPS"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb" "aap_alb" {
  name               = "aap-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.aap_public_subnet_az1.id,
    aws_subnet.aap_public_subnet_az2.id
  ]
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
    prefix  = "alb-logs"
  }
  tags = {
    Name      = "AAP-ALB"
    Terraform = "true"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.aap_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.aap_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group_attachment" "attach_instance" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.aap_instance.id
  port             = 443
}

resource "aws_security_group_rule" "alb_to_instance" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.aap_security_group.id
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "aap-alb-access-s3-logging-bucket-${random_id.bucket_suffix.hex}"

  tags = {
    Name      = "ALB Access Logs"
    Terraform = "true"
  }
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite",
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

resource "aws_route53_record" "aap_alb_dns" {
  zone_id = data.aws_route53_zone.hashidemos_zone.id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.aap_alb.dns_name]
}

data "aws_route53_zone" "hashidemos_zone" {
  name         = var.route53_zone_name
  private_zone = false
}