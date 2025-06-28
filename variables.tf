variable "aws_region" {
  description = "AWS Region"
  default     = "ap-northeast-2"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  default     = "" # change this to your own access key
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  default     = "" # change this to your own secret key
}


# EC2
variable "ec2_key_name" {
  description = "EC2 Key Pair Name for SSH access"
  default     = "seoulclinic"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2"
  default     = "t2.large"
}

variable "ec2_ami" {
  description = "AMI for EC2"
  default     = "ami-0d5bb3742db8fc264" # Ubuntu 22.04 LTS in ap-northeast-2
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  default     = "seoulclinic"
}

variable "ec2_volume_size" {
  description = "Volume size for EC2"
  type        = number
  default     = 30
}

variable "ec2_volume_type" {
  description = "Volume type for EC2"
  type        = string
  default     = "gp2"
}

# RDS
variable "db_instance_name" {
  description = "Name of the RDS instance"
  default     = "seoulclinic-database-1"
}

variable "db_instance_type" {
  description = "Instance type for RDS"
  default     = "db.t3.micro" # Free tier
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS"
  default     = 20 # Free tier
}

variable "db_username" {
  description = "Username for RDS"
  default     = "postgres"
}

variable "db_password" {
  description = "Password for RDS"
  default     = "" # change this to your own password
}

# S3
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  default     = "bucket1" # change this to your own bucket name
}
