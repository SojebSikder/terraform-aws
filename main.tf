# Generate a Key Pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = var.ec2_key_name
  public_key = tls_private_key.example.public_key_openssh
}

# Default VPC
resource "aws_default_vpc" "default" {
  # Use the default VPC
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh"
  description = "Allow SSH and all outbound"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "allow_postgres"
  description = "Allow PostgreSQL access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Public access to DB
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 Instance
resource "aws_instance" "ubuntu_server" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.generated.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = false

  root_block_device {
    volume_type           = var.ec2_volume_type # type: "gp2", "gp3", "io1", etc.
    volume_size           = var.ec2_volume_size # size in GB (example: 30)
    delete_on_termination = true                # optional: automatically delete the volume when instance is terminated
  }

  tags = {
    Name = var.ec2_instance_name
  }
}

# Create an Elastic IP (do NOT associate yet)
resource "aws_eip" "ec2_eip" {
  tags = {
    Name = var.ec2_instance_name
  }
}

# Associate Elastic IP with EC2
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ubuntu_server.id
  allocation_id = aws_eip.ec2_eip.id
}

# Data source to get all subnets in the VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "Default DB subnet group"
  }
}

# RDS Instance
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = var.db_instance_type
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Name = var.db_instance_name
  }
}

# S3 Bucket
resource "aws_s3_bucket" "public_bucket" {
  bucket = "${var.s3_bucket_name}-${random_id.suffix.hex}"

  tags = {
    Name = "${var.s3_bucket_name}"
  }
}

# Enable public access
resource "aws_s3_bucket_public_access_block" "public_bucket_block" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Set bucket policy to allow public read
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}
