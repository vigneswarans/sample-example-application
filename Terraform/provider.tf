terraform {
 required_providers {
   aws = {
     source = "hashicorp/aws"
   }
 }
 
 backend "s3" {
   bucket = "sample-application-terraform"
   region = "ap-south-1"
   key    = "sample/terraform.tfstate"
   dynamodb_table = "sample-application-terraform"
 }
}
