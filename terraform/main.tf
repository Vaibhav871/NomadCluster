
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket       = "nomad-tfstate-us"
    key          = "terraform/state.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}