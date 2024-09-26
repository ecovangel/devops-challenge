# Specify the provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAWOW4EQTEBXKKHGJ4"
  secret_key = "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"
}

# Fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

# VPC, Subnets, and NAT Gateway Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name               = "ecovangel-skyward-challenge-vpc"
  cidr               = var.vpc_cidr
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = var.public_subnet_cidrs
  private_subnets    = var.private_subnet_cidrs
  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "ecovangel-skyward-public-subnet"
  }

  private_subnet_tags = {
    Name = "ecovangel-skyward-private-subnet"
  }
}

# Security Groups Configuration
resource "aws_security_group" "alb_sg" {
  name        = "ecovangel-skyward-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "ecovangel-skyward-instance-sg"
  description = "Security group for EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "ecovangel-skyward-rds-sg"
  description = "Allow traffic for RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancer (ALB) Configuration
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.0.0"

  name               = "ecovangel-skyward-alb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  target_groups = [
    {
      name        = "ecovangel-skyward-tg"
      port        = 80  # Port specified here
      protocol    = "HTTP"
      target_type = "instance"
    }
  ]
}

# EC2 Launch Template with Base64-encoded user data
resource "aws_launch_template" "httpd" {
  name          = "ecovangel-skyward-httpd-launch-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  user_data = base64encode(file("${path.module}/user_data.sh"))

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group (ASG) Configuration
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.httpd.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "ecovangel-skyward-asg"
    propagate_at_launch = true
  }
}

# DB Subnet Group - Ensure a unique name to avoid errors
resource "aws_db_subnet_group" "ecovangel_skyward_subnet_group" {
  name       = "ecovangel-skyward-subnet-group-${random_string.suffix.result}"  # Ensure unique name
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "ecovangel-skyward-rds-subnet-group"
  }
}

# Random string generator to ensure unique DB subnet group name
resource "random_string" "suffix" {
  length  = 4
  special = false
}

# Aurora RDS Cluster
module "rds" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 6.0"

  engine                 = "aurora-mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.small"
  db_subnet_group_name   = aws_db_subnet_group.ecovangel_skyward_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  master_username        = "admin"
  master_password        = "your_password"  # Use a secure password

  database_name          = "ecovangel-skyward-db"

  apply_immediately      = true

  name                   = lower(var.name)  # Convert to lowercase for RDS compliance
}

# S3 Bucket Configuration
resource "aws_s3_bucket" "this" {
  bucket = "ecovangel-skyward-challenge-three"  # Ensure unique name
  acl    = "private"

  tags = {
    Name = "ecovangel-skyward-s3"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}



# S3 Bucket Policy to allow public read access
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}

# Disable BlockPublicAccess on S3 bucket (Optional)
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
