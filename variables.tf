variable "aws_region" {
  default = "ap-northeast-2"
}

# EC2
variable "ec2_key_name" {
  description = "EC2 Key Pair Name for SSH access"
  default     = "seoulclinic-2"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2"
  default     = "t2.micro" # Free tier
}

variable "ec2_ami" {
  description = "AMI for EC2"
  default     = "ami-0d5bb3742db8fc264" # Ubuntu 22.04 LTS in ap-northeast-2
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  default     = "seoulclinic-2"
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
}
