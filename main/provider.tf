provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

terraform {
  required_version = ">= 0.12.26"
  required_providers {
    aws = {
      "version" = ">= 2.46.0"
    }
  }
}