
provider "aws" {
  region = "ap-south-1"
}

terraform {
  backend "s3" {
    bucket       = "nomad-tfstate"
    key          = "terraform/state.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}