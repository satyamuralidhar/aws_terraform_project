terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region     = "${var.location}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}
