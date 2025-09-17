variable "region" {
  default = "ap-south-1"
}


variable "availability_zone" {
  default = "ap-south-1a"
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}



variable "instance_type" {
  default = "t3.micro"
}


variable "key_name" {
  default = "bastionkey"
}


variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

variable "nomad_client_count" {
  description = "Number of Nomad client instances to create"
  default     = 1
}
# s3 variables 

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  default     = "nomad-tfstate-mumbai" # must be globally unique
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  default     = "nomad-tf-lock"
}

# security group variable
variable "admin_cidr" {
  description = "Your IP range to allow SSH to bastion (format: x.x.x.x/32)"
  default     = "0.0.0.0/0" # replace with your real IP for security
}

variable "bastion_public_key" {}
