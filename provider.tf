terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.45.0"
    }
    juju = {
      version = "~> 0.11"
      source  = "juju/juju"
    }
  }
  required_version = "~> 1.6"
}

provider "juju" {
  controller_addresses = join(",", var.controller_addresses)
}

provider "aws" {
  region = "ap-south-1"
}
