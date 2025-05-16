provider "aws" {
  region = "us-east-2"
  profile = "DaMak0TwByWjAu7C/+J5EiABPDBGoUYos1dbLORU"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
