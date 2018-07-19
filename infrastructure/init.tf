terraform {
  backend "s3" {
    bucket = "playplace-terraform-state"
    key    = "infrastructure.tfstate"
    region = "us-east-1"
  }
}