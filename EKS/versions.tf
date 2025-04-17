terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"  # Ensuring compatibility with the latest modules
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.14"  # Ensure Terraform version is 0.14 or later
}
