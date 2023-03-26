terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      Version = "~>3.27"
    }
  }

  required_version = ">=0.14.9"
  
backend "s3" {
       bucket = "sample-application-terraform"
       key    = "sample/terraform.tfstate"
       region = "ap-south-1"
      dynamodb_table = "sample-application-terraform"
   }
}
