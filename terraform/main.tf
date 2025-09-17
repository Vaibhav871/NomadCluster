provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket         = "nomad-tfstate"
    key            = "terraform/state.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "nomad-tf-lock"
    encrypt        = true
  }
}


data "aws_s3_bucket" "terraform_state" {
  bucket = "nomad-tfstate"
}

data "aws_dynamodb_table" "tf_lock" {
  name = "nomad-tf-lock"
}
