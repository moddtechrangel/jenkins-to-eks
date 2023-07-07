terraform {
  backend "s3" {
    bucket = "metex-poc"
    region = "us-east-2"
    key = "eks/terraform.tfstate"
  }
}
