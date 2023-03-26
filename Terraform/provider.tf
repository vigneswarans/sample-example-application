terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "sample-application-terraform"
    key            = "sample/terraform.tfstate"
    region         = "ap-south-1"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "sample-application-terraform"
  }
}

provider "aws" {
  region  = "ap-south-1"
}